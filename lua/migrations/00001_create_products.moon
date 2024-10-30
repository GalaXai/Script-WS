import create_table, types from require "lapis.db.schema"

{
  :integer
  :text
  :varchar
} = types

{
  [1]: =>
    create_table "products", {
      {"id", integer primary_key: true}
      {"name", varchar}
      {"description", text}
      {"price", text}
      {"stock", integer}
      {"created_at", integer}
      {"updated_at", integer}
    }
}
