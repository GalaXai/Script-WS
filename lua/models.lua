local Model
Model = require("lapis.db.model").Model
local autoload
autoload = require("lapis.util").autoload
local Products
do
  local _class_0
  local _parent_0 = Model
  local _base_0 = { }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Products",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  local self = _class_0
  self.primary_key = "id"
  self.timestamp = true
  self.create_table = function(self)
    local db = require("lapis.db")
    return create_table("products", {
      {
        "id",
        serial = true,
        primary_key = true
      },
      {
        "name",
        varchar = true
      },
      {
        "description",
        text = true
      },
      {
        "price",
        numeric = true
      },
      {
        "stock",
        integer = true
      },
      {
        "created_at",
        timestamp = true
      },
      {
        "updated_at",
        timestamp = true
      },
      "PRIMARY KEY (id)"
    })
  end
  self.serialize = function(self)
    return {
      id = self.id,
      name = self.name,
      description = self.description,
      price = self.price,
      stock = self.stock,
      created_at = self.created_at,
      updated_at = self.updated_at
    }
  end
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Products = _class_0
end
autoload("models")
return {
  Products = Products
}
