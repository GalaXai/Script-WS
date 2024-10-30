local config
config = require("lapis.config").config
return config("development", function()
  server("nginx")
  code_cache("off")
  num_workers("1")
  sqlite(function()
    backend("sqlite")
    return database("lapis.db")
  end)
  return enable_migrations(true)
end)
