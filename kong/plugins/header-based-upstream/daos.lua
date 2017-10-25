local utils = require "kong.tools.utils"

local SCHEMA = {
  primary_key = {"id"},
  table = "header_based_upstream_urls",
  cache_key = { "api_id" },
  fields = {
    id = {type = "id", dao_insert_value = true},
    created_at = {type = "timestamp", immutable = true, dao_insert_value = true},
    api_id = {type = "id", required = true, foreign = "apis:id"},
    name = {type = "string", required = true },
    headers = {
      type = "array", 
      required = true, 
      default = {}
    },    
    upstream_url = {type = "string", required = true }
  },
}

return {header_based_upstream_urls = SCHEMA}