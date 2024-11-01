require 'sequel'
require 'logger'

DB = Sequel.connect('sqlite://db/products.db')
DB.loggers << Logger.new($stdout)

DB.create_table? :products do
  primary_key :id
  String :title
  Float :price
  String :url
  String :details, text: true
  DateTime :created_at
  DateTime :updated_at
end
