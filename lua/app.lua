local lapis = require("lapis")
local Products
Products = require("models").Products
local respond_to, json_params
do
  local _obj_0 = require("lapis.application")
  respond_to, json_params = _obj_0.respond_to, _obj_0.json_params
end
local google = require("cloud_storage.google")
local Application
do
  local _class_0
  local _parent_0 = lapis.Application
  local _base_0 = {
    [{
      test_storage = "/test-storage"
    }] = function(self)
      print("Testing Google Cloud Storage connection")
      self.storage = google.CloudStorage:from_json_key_file("gcp_key.json")
      self.bucket_name = "scipt-ws"
      local success, result = pcall(function()
        local files = self.storage:get_bucket(self.bucket_name)
        if files then
          return {
            success = true,
            files = files
          }
        else
          return {
            success = false,
            error = "Could not fetch bucket contents"
          }
        end
      end)
      if success then
        return {
          json = result
        }
      else
        return {
          json = {
            success = false,
            error = "Storage error: " .. tostring(result)
          }
        }
      end
    end,
    [{
      upload_image = "/products/:id/image"
    }] = respond_to({
      PUT = json_params(function(self)
        print("Processing image upload for product " .. tostring(self.params.id))
        self.storage = google.CloudStorage:from_json_key_file("gcp_key.json")
        self.bucket_name = "scipt-ws"
        local product = Products:find(self.params.id)
        if not (product) then
          return {
            json = {
              success = false,
              error = "Product not found"
            }
          }
        end
        local image_data = self.params.image
        if not (image_data) then
          return {
            json = {
              success = false,
              error = "No image data provided"
            }
          }
        end
        image_data = image_data:gsub("^data:image/[^;]+;base64,", "")
        image_data = image_data:gsub("%s+", "")
        local success, binary_data = pcall(function()
          return require("mime").unb64(image_data)
        end)
        if not (success and binary_data) then
          return {
            json = {
              success = false,
              error = "Invalid base64 image data"
            }
          }
        end
        local timestamp = os.time()
        local filename = "product_" .. tostring(product.id) .. "_" .. tostring(timestamp) .. ".jpg"
        print("Uploading file: " .. tostring(filename))
        local err
        success, err = self.storage:put_file_string(self.bucket_name, filename, binary_data, {
          mimetype = "image/jpeg",
          cache_control = "public, max-age=31536000"
        })
        if success then
          local image_url = self.storage:file_url(self.bucket_name, filename)
          print("Upload successful. URL: " .. tostring(image_url))
          return {
            json = {
              success = true,
              image_url = image_url
            }
          }
        else
          print("Upload failed: " .. tostring(err))
          return {
            json = {
              success = false,
              error = "Failed to upload image: " .. tostring(err)
            }
          }
        end
      end)
    }),
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
        print("hello-app-product-get")
        local product = Products:find(self.params.id)
        if not (product) then
          return {
            json = {
              success = false,
              error = "Product not found"
            }
          }
        end
        print("Found product:")
        return {
          json = {
            success = true,
            product = product:serialize()
          }
        }
      end,
      PUT = json_params(function(self)
        print("hello-app-product-put")
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
        print("Updated product")
        return {
          json = {
            success = true,
            product = product:serialize()
          }
        }
      end),
      DELETE = function(self)
        print("hello-app-product-delete")
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
        print("Deleted product")
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
