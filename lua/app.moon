lapis = require "lapis"
import Products from require "models"
import respond_to, json_params from require "lapis.application"

class Application extends lapis.Application
  -- Root route
  -- Struggle to get import working with endpoints.
  "/": =>
    print "hello-app-index"
    "Welcome to Lapis #{require "lapis.version"}!"

  -- Product Routes
  -- GET /products - List all products
  -- POST /products - Create new product
  [index: "/products"]: respond_to {
    GET: =>
      print "hello-app-products"
      print "Products:"  -- Add this debug line
      products = Products\select!
      print "HERE ARE YOUR SERIALIZED PRODUCTS"
      -- print serialized products
      json: { success: true, products: [product\serialize! for product in *products] }

    POST: json_params =>
      print "hello-app-products-post"

      Products\create {
        name: @params.name
        description: @params.description
        price: @params.price
        stock: @params.stock
      }

      print "Created product"
      json: {
        success: true,
        message: "Product created successfully"
      }
  }

  -- Single Product Routes
  -- GET /products/:id - Get single product
  -- PUT /products/:id - Update product
  -- DELETE /products/:id - Delete product
  [show: "/products/:id"]: respond_to {
    GET: =>
      product = Products\find @params.id
      return json: { success: false, error: "Product not found" } unless product
      json: { success: true, product: product }

    PUT: json_params =>
      product = Products\find @params.id
      return json: { success: false, error: "Product not found" } unless product

      product\update {
        name: @params.name
        description: @params.description
        price: @params.price
        stock: @params.stock
      }
      json: { success: true, product: product }

    DELETE: =>
      product = Products\find @params.id
      return json: { success: false, error: "Product not found" } unless product

      product\delete!
      json: { success: true, message: "Product deleted" }
  }

return Application
