lapis = require "lapis"
db = require "lapis.db"

-- Reset database before each test
clear_db = ->
  db.truncate "products"

-- Helper to create a test application
create_test_app = ->
  import Application from require "lapis"

  class TestApp extends Application
    @before_filter =>
      -- Mock response writing
      @write = ->
      -- Initialize empty request headers
      @req or= {}
      @req.headers or= {}
      -- Set default request method
      @req.method = "GET"
      -- Add any custom response methods needed for testing
      @json = (data) =>
        @res.status = 200
        @res.json = data
      -- Initialize response object
      @res or= {
        status: 200
        headers: {}
      }

{ :clear_db, :create_test_app }
