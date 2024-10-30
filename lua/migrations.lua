return {
    [1] = function(self)
        local create_table, types = require("lapis.db.schema").create_table, require("lapis.db.schema").types
        local integer, text, varchar = types.integer, types.text, types.varchar

        return create_table("products", {
            {"id", integer{primary_key = true}},
            {"name", varchar},
            {"description", text},
            {"price", text},
            {"stock", integer},
            {"created_at", integer},
            {"updated_at", integer}
        })
    end
}
