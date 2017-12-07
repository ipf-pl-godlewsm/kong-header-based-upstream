local dump = require 'serial'
local validator = require "kong.plugins.header-based-upstream.validator"

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function validate_mappings(given_value, given_config)
  
  return validator.validate_mappings(given_value, given_config)
end

return {
  no_consumer = true,
  fields = {
    mappings = { type = "array", required = true, func = validate_mappings }
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    return true
  end
}