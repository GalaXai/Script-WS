local config
config = require("lapis.config").config
return config("development", function()
  server("nginx")
  code_cache("off")
  return num_workers("1")
end)
