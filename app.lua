local function escape(s)
  local needs_escape = {
    ['-'] = true
  }

  return (s:gsub('.', function(c)
    if needs_escape[c] then
      return '%' .. c
    end
  end))
end

local function multipart(req, res, go)
  if (req.headers['Content-Type'] or ''):match('^' .. escape('multipart/form-data')) then
    req.multipart ={}

    local boundary = req.headers['Content-Type']:match('boundary=(.*)$')
    boundary = escape(boundary)

    local body = req.body:match(boundary .. '(.*)')

    for part in body:gmatch('(..-)' .. boundary) do
      local filename = part:match('filename=([^\r\n]*)')
      local contents = part:match('Content%-Type[^\r\n]*\r\n\r\n' .. '(.*)' .. '\r\n%-%-$')
      if filename and contents then
        req.multipart[filename] = contents
      end
    end
  end

  return go()
end

return function(args)
  local weblit = require 'weblit'

  local app = weblit.app

  app.bind({ host = '127.0.0.1', port = 1337 })

  app.use(weblit.logger)
  app.use(weblit.autoHeaders)
  app.use(weblit.static('static'))
  app.use(multipart)

  app.route({ method = 'POST', path = '/upload' }, function(req, res)
    p('uploading file')
    p(req.multipart)
    res.code = 200
  end)

  app.route({ method = 'POST', path = '/upload-dir' }, function(req, res)
    p('uploading directory')
    p(req.multipart)
    res.code = 200
  end)

  app.route({ path = '/:name' }, function(req, res)
    res.body = req.method .. ' - ' .. req.params.name .. '\n'
    res.code = 200
    res.headers['Content-Type'] = 'text/plain'
  end)

  app.start()
end
