return function(args)
  local weblit = require 'weblit'

  local app = weblit.app

  app.bind({ host = '127.0.0.1', port = 1337 })

  app.use(weblit.logger)
  app.use(weblit.autoHeaders)
  app.use(weblit.static('static'))

  app.route({ method = 'POST', path = '/upload' }, function(req, res)
    p(#req.body)
    res.code = 200
  end)

  app.route({ path = '/:name' }, function(req, res)
    res.body = req.method .. ' - ' .. req.params.name .. '\n'
    res.code = 200
    res.headers['Content-Type'] = 'text/plain'
  end)

  app.start()
end
