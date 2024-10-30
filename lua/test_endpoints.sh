# Create a product with all fields
curl -X POST http://localhost:8080/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Product",
    "description": "A detailed description of the test product",
    "price": 99.99,
    "stock": 100
  }'

# Get all products
curl http://localhost:8080/products

# Get specific product (replace 1 with actual ID)
curl http://localhost:8080/products/1

# Update product with all possible fields
curl -X PUT http://localhost:8080/products/1 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Product",
    "description": "Updated description of the test product",
    "price": 199.99,
    "stock": 50
  }'

# Delete product
curl -X DELETE http://localhost:8080/products/1
