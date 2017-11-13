local dump = require 'serial'

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function validation_header_names(given_value, given_config)
  
  ngx.log(ngx.ERR, dump.tostring(given_value))

  if ( given_value == nil or tablelength(given_value) == 0 ) then
    return false, "Incorrect configuration - At least one header name must be provided in 'header_names' configuration array"
  end
  
  return true
end

return {
  no_consumer = true,
  fields = {
    header_names = { type = "array", required = false, default = {}, immutable = true, func = validation_header_names }
  },
  self_check = function(schema, plugin_t, dao, is_updating)
    return true
  end
}