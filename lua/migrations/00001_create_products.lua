local create_table, types
do
  local _obj_0 = require("lapis.db.schema")
  create_table, types = _obj_0.create_table, _obj_0.types
end
local integer, text, varchar
integer, text, varchar = types.integer, types.text, types.varchar
return {
  [1] = function(self)
    return create_table("products", {
      {
        "id",
        integer({
          primary_key = true
        })
      },
      {
        "name",
        varchar
      },
      {
        "description",
        text
      },
      {
        "price",
        text
      },
      {
        "stock",
        integer
      },
      {
        "created_at",
        integer
      },
      {
        "updated_at",
        integer
      }
    })
  end
}
