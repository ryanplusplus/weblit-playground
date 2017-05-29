local fs = require 'fs'
local path = require 'path'
local timer = require 'timer'
local spawn = require 'coro-spawn'

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
      local name = part:match('name="([^";]*)";')
      local filename = part:match('filename="([^\r\n]*)"')
      local contents = part:match('Content%-Type[^\r\n]*\r\n\r\n' .. '(.*)' .. '\r\n%-%-$')
      if name and filename and contents then
        req.multipart[name] = req.multipart[name] or {}
        table.insert(req.multipart[name], { filename = filename, contents = contents })
      end
    end
  end

  return go()
end

local function write_to_file(filename, contents)
  fs.mkdirpSync(path.dirname(filename))
  local f = io.open(filename, 'w')
  assert(f, 'Cannot open ' .. filename .. ' for writing')
  f:write(contents)
  f:close()
end

return function(args)
  local weblit = require 'weblit'

  local app = weblit.app

  app.bind({ host = '127.0.0.1', port = 1337 })

  app.use(weblit.logger)
  app.use(weblit.autoHeaders)
  app.use(weblit.static('static'))
  app.use(weblit.static('tmp'))
  app.use(multipart)

  app.route({ method = 'POST', path = '/upload' }, function(req, res)
    p(req.multipart)

    local rand = math.random(1234567890)
    local dir = path.resolve('tmp/' .. rand)
    local data

    for _, o in pairs(req.multipart.project) do
      if o.filename:match(req.multipart.data[1].filename) then
        data = o.filename
      end
      write_to_file(dir .. '/' .. o.filename, o.contents)
    end

    coroutine.wrap(function()
      timer.sleep(10000)
      spawn('rm', { args = { '-rf', dir } })
    end)()

    res.code = 301
    res.headers.Location = rand .. '/' .. data
  end)

  app.route({ path = '/:name' }, function(req, res)
    res.body = req.method .. ' - ' .. req.params.name .. '\n'
    res.code = 200
    res.headers['Content-Type'] = 'text/plain'
  end)

  app.start()
end
