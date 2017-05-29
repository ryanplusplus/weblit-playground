  return {
    name = "ryanplusplus/weblit-playground",
    version = "0.0.1",
    description = "Playing around with Luvit+Weblit",
    tags = { "lua", "lit", "luvit" },
    license = "MIT",
    author = { name = "Ryan Hartlage", email = "ryanplusplus@gmail.com" },
    homepage = "https://github.com/ryanplusplus/weblit-playground",
    dependencies = {
      'creationix/weblit@3.0.1',
      'luvit/luvit@2.14.1'
    },
    files = {
      "**.lua",
      "!spec*"
    }
  }
