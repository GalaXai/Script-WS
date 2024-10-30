lapis = require "lapis"
import ProductsApplication from require "applications.products"
import Products from require "models"
import respond_to, json_params from require "lapis.application"

class Application extends lapis.Application
  -- Root route
  "/": =>
    "Welcome to Lapis #{require "lapis.version"}!"

  -- Product Routes
  -- GET /products - List all products
  -- POST /products - Create new product
  [index: "/products"]: respond_to {
    GET: =>
      products = Products\select ""
      json: { success: true, products: products }

    POST: json_params =>
      product = Products\create {
        name: @params.name
        description: @params.description
        price: @params.price
        stock: @params.stock
      }
      json: { success: true, product: product }
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