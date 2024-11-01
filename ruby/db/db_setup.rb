require 'sequel'

DB = Sequel.connect('sqlite://db/amazon_products.db')

unless DB.table_exists?(:products)
  DB.create_table :products do
    String :asin, primary_key: true
    String :title, null: false
    Float :price
    Float :rating
    Integer :reviews_count
    String :url, null: false
    String :image_url
    DateTime :created_at
    DateTime :updated_at
  end
end
