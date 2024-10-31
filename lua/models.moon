import Model from require "lapis.db.model"
import autoload from require "lapis.util"

-- Define the Product model
class Products extends Model
  @primary_key: "id"
  @timestamp: true  -- Adds created_at and updated_at columns

  @create_table: =>
    db = require "lapis.db"
    create_table "products", {
      {"id", serial: true, primary_key: true}
      {"name", varchar: true}
      {"description", text: true}
      {"price", numeric: true}
      {"stock", integer: true}

      {"created_at", timestamp: true}
      {"updated_at", timestamp: true}

      "PRIMARY KEY (id)"
    }

  @serialize: =>
    {
        id: @id
        name: @name
        description: @description
        price: @price
        stock: @stock
        created_at: @created_at
        updated_at: @updated_at
    }

autoload "models"

return {
    Products: Products
}
