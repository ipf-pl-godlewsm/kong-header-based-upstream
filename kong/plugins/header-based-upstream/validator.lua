
local dump = require 'serial'
local utils = require "kong.plugins.header-based-upstream.utils"

local _M = {}

function _M.validate_mappings(mappings, config)

  ngx.log(ngx.DEBUG, "Mappings: ".. dump.tostring(mappings))
  ngx.log(ngx.DEBUG, "Config: "..dump.tostring(config))

  if ( mappings == nil or utils.table_length(mappings) == 0 ) then
    return false, "Incorrect configuration - At least one mapping must be provided"
  end

  -- Check whether each entry contains required attributes - name, headers and upstream url
  -- Check whether header list is not empty
  for _, mapping in ipairs(mappings) do

    if not mapping.name or not mapping.headers or not mapping.upstream_url then
      return false, "Each mapping must have defined 'name', 'headers' and 'upstream_url'"
    end

    if utils.table_length(mapping.headers) == 0 then
      return false, "Header list for mapping with name '"..mapping.name.."' is empty"
    end
  end

  -- Check whether names are unique
  local names = {}
  for i, mapping in ipairs(mappings) do

    if utils.table_contains(names, mapping.name) then
      return false, "Multiple entries with name '"..mapping.name.."'"
    else
      names[i] = mapping.name
    end

  end

  -- Determine list of header names used for all mappings
  local header_names = {}
  for i, mapping in ipairs(mappings) do
    for j, header_with_value in ipairs(mapping.headers) do
      local ok, err, header_name, header_value = _M.extract_header_name_value(header_with_value)

      if ok then
        if ( utils.table_contains(header_names,header_name) == false ) then
          table.insert(header_names,header_name)
        end
      else
        return false, err
      end
    end
  end

  ngx.log(ngx.DEBUG, "List of all header names within mappings: " .. dump.tostring(header_names) )

  -- Determine whether the same header names are used for all mappings
  for i, mapping in ipairs(mappings) do

    local headers_names_from_mapping = {}
    for i, header_with_value in ipairs(mapping.headers) do

      local ok, err, header_name, header_value = _M.extract_header_name_value(header_with_value)
      table.insert(headers_names_from_mapping, header_name)
    end

    local header_names_diff1 = utils.difference(header_names, headers_names_from_mapping)
    local header_names_diff2 = utils.difference(headers_names_from_mapping, header_names)

    ngx.log(ngx.DEBUG, "Diff ( all header names vs mapping header names ): " .. dump.tostring(header_names_diff1) )
    ngx.log(ngx.DEBUG, "Diff ( mapping header names vs all header names ) " .. dump.tostring(header_names_diff2) )

    if utils.table_length(header_names_diff1) > 0 or utils.table_length(header_names_diff2) > 0 then

      local msg = string.format(
        "Error found mapping with name '"..mapping.name.."'. Same header names should be used for all mappings: \n %s %s",
        dump.tostring(header_names_diff1),
        dump.tostring(header_names_diff2)
      )
      return false, msg
    end
  end

  -- Determine whether there are mapping with same header values
  local c = 1
  local err
  for i, mapping in ipairs(mappings) do

    for j, otherMapping in ipairs(mappings) do
      -- Ignore mapping with same name
      if not ( mapping.name == otherMapping.name ) then

        local all_match = true
        -- Itarate over all headers
        for k, header_with_value in ipairs(mapping.headers) do
          local match = utils.table_contains( otherMapping.headers, header_with_value )
          if not match then
            all_match = false
            break
          end
        end

        if all_match then
          local err = "Mappings '"..mapping.name.."' and '"..otherMapping.name.."' uses the same header name/value combination"
          return false, err
        end

      end
      
    end
    
  end
  
  return true
end

function _M.extract_header_name_value(header_with_value)

  local ok = string.find(header_with_value, ":")
  if ok then
    local header_name, header_value = header_with_value:match("^([^:]+):*(.-)$")
    return true, nil, header_name, header_value
  else
    local err =  "Values for header incorrect ( '" .. header_with_value .. "' ). Expected format 'header_name:header_value'"
    return false, err, nil, nil
  end
end

return _M