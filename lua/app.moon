lapis = require "lapis"
import Products from require "models"
import respond_to, json_params from require "lapis.application"
google = require "cloud_storage.google"

class Application extends lapis.Application
  -- Test Google Cloud Storage connectivity
  [test_storage: "/test-storage"]: =>
    print "Testing Google Cloud Storage connection"
    @storage = google.CloudStorage\from_json_key_file "gcp_key.json"
    @bucket_name = "scipt-ws"

    success, result = pcall ->
      -- If bucket exists, try to list files
      files = @storage\get_bucket @bucket_name
      if files
        { success: true, files: files }
      else
        { success: false, error: "Could not fetch bucket contents" }

    if success
      return json: result
    else
      return json: { success: false, error: "Storage error: #{result}" }


  [upload_image: "/products/:id/image"]: respond_to {
    PUT: json_params =>
      print "Processing image upload for product #{@params.id}"
      @storage = google.CloudStorage\from_json_key_file "gcp_key.json"
      @bucket_name = "scipt-ws"
      -- Find the product
      product = Products\find @params.id
      return json: { success: false, error: "Product not found" } unless product

      -- Get the base64 image data from request
      image_data = @params.image
      return json: { success: false, error: "No image data provided" } unless image_data

      -- Remove potential data URL prefix
      image_data = image_data\gsub "^data:image/[^;]+;base64,", ""
      -- Remove any whitespace
      image_data = image_data\gsub("%s+", "")

      -- Decode base64 to binary
      success, binary_data = pcall -> require("mime").unb64(image_data)
      return json: { success: false, error: "Invalid base64 image data" } unless success and binary_data

      -- Generate unique filename with timestamp
      timestamp = os.time!
      filename = "product_#{product.id}_#{timestamp}.jpg"

      print "Uploading file: #{filename}"

      -- Upload to Google Cloud Storage with explicit content type
      success, err = @storage\put_file_string @bucket_name, filename, binary_data, {
        mimetype: "image/jpeg"
        cache_control: "public, max-age=31536000"  -- Cache for 1 year
      }

      if success
        -- Get the public URL (assuming the bucket is publicly accessible)
        image_url = @storage\file_url @bucket_name, filename
        print "Upload successful. URL: #{image_url}"

        -- This might be implemented later.
        -- product\update {
        --   image_url: image_url
        -- }

        json: { success: true, image_url: image_url }
      else
        print "Upload failed: #{err}"
        json: { success: false, error: "Failed to upload image: #{err}" }
    }
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
      print "hello-app-product-get"
      product = Products\find @params.id
      return json: { success: false, error: "Product not found" } unless product
      print "Found product:"
      json: { success: true, product: product\serialize! }

    PUT: json_params =>
      print "hello-app-product-put"
      product = Products\find @params.id
      return json: { success: false, error: "Product not found" } unless product

      product\update {
        name: @params.name
        description: @params.description
        price: @params.price
        stock: @params.stock
      }
      print "Updated product"
      json: { success: true, product: product\serialize! }

    DELETE: =>
      print "hello-app-product-delete"
      product = Products\find @params.id
      return json: { success: false, error: "Product not found" } unless product

      product\delete!
      print "Deleted product"
      json: { success: true, message: "Product deleted" }
  }

return Application
