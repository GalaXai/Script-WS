import clear_db, create_test_app from require "spec.helper"
import Products from require "models"
import request, load_test_server from require "lapis.spec.server"
import mock_request from require "lapis.spec.request"
import from_json from require "lapis.util"

describe "Products API", ->
  local app

  setup ->
    app = create_test_app!
    load_test_server!

  before_each ->
    clear_db!

  describe "GET /products", ->
    it "should return empty list when no products exist", ->
      status, body = request "/products"
      res = from_json body
      assert.same 200, status
      assert.truthy res.success
      assert.same {}, res.products

    it "should return list of products", ->
      -- Create test product directly in database
      product = Products\create {
        name: "Test Product"
        description: "Test Description"
        price: 100
        stock: 10
      }

      -- Get the product list
      status, body = request "/products"
      res = from_json body

      assert.same 200, status
      assert.truthy res.success
      assert.same 1, #res.products

      -- Verify product data
      product_response = res.products[1]
      assert.same product.id, product_response.id
      assert.same product.name, product_response.name
      assert.same product.description, product_response.description
      assert.same product.price, product_response.price
      assert.same product.stock, product_response.stock
