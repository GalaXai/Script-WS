import config from require "lapis.config"

config "development", ->
  server "nginx"
  code_cache "off"
  num_workers "1"

  sqlite ->
    backend "sqlite"
    database "lapis.db"

  enable_migrations true  -- Add this line
