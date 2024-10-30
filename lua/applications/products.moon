lapis = require "lapis"
import Products from require "models"
import respond_to from require "lapis.application"
import json_params from require "lapis.application"

class ProductsApplication extends lapis.Application
  [index: "/products"]: respond_to {
    GET: =>
      products = Products\select ""  -- Get all products
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

return ProductsApplication
