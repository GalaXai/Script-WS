local lapis = require("lapis")
local Products
Products = require("models").Products
local respond_to, json_params
do
  local _obj_0 = require("lapis.application")
  respond_to, json_params = _obj_0.respond_to, _obj_0.json_params
end
local Application
do
  local _class_0
  local _parent_0 = lapis.Application
  local _base_0 = {
    ["/"] = function(self)
      print("hello-app-index")
      return "Welcome to Lapis " .. tostring(require("lapis.version")) .. "!"
    end,
    [{
      index = "/products"
    }] = respond_to({
      GET = function(self)
        print("hello-app-products")
        print("Products:")
        local products = Products:select()
        print("HERE ARE YOUR SERIALIZED PRODUCTS")
        return {
          json = {
            success = true,
            products = (function()
              local _accum_0 = { }
              local _len_0 = 1
              for _index_0 = 1, #products do
                local product = products[_index_0]
                _accum_0[_len_0] = product:serialize()
                _len_0 = _len_0 + 1
              end
              return _accum_0
            end)()
          }
        }
      end,
      POST = json_params(function(self)
        print("hello-app-products-post")
        Products:create({
          name = self.params.name,
          description = self.params.description,
          price = self.params.price,
          stock = self.params.stock
        })
        print("Created product")
        return {
          json = {
            success = true,
            message = "Product created successfully"
          }
        }
      end)
    }),
    [{
      show = "/products/:id"
    }] = respond_to({
      GET = function(self)
        local product = Products:find(self.params.id)
        if not (product) then
          return {
            json = {
              success = false,
              error = "Product not found"
            }
          }
        end
        return {
          json = {
            success = true,
            product = product
          }
        }
      end,
      PUT = json_params(function(self)
        local product = Products:find(self.params.id)
        if not (product) then
          return {
            json = {
              success = false,
              error = "Product not found"
            }
          }
        end
        product:update({
          name = self.params.name,
          description = self.params.description,
          price = self.params.price,
          stock = self.params.stock
        })
        return {
          json = {
            success = true,
            product = product
          }
        }
      end),
      DELETE = function(self)
        local product = Products:find(self.params.id)
        if not (product) then
          return {
            json = {
              success = false,
              error = "Product not found"
            }
          }
        end
        product:delete()
        return {
          json = {
            success = true,
            message = "Product deleted"
          }
        }
      end
    })
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "Application",
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
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  Application = _class_0
end
return Application
