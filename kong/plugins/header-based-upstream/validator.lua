
local dump = require 'serial'
local utils = require "kong.plugins.header-based-upstream.utils"

local _M = {}


-- Validates entry against configuration - are all headers given in configuration given in entry
-- @return True if success, nil+error ( as { tbl = { error_key = "error_value" } }  ) otherwise
function _M.validate_against_conf(entry, plugin_config)

    -- Check whether header names are given
    if plugin_config.header_names == nil then
        local msg = "Header names are not provided in plugin configuration"
        local err = { tbl = { validation_error = msg }}
        return false, err
    end

    if entry.headers == nil then
        local msg = "Header names are not provided for entry"
        local err = { tbl = { validation_error = msg }}
        return false, err
        
    end

    ngx.log(ngx.DEBUG, "Plugin config header names: " .. dump.tostring(plugin_config.header_names) )
    ngx.log(ngx.DEBUG, "Entry headers names and values: " .. dump.tostring(entry.headers) )

    -- Extract header names provided in request ( entry ) for validation against plugin configuration
    local headerNamesFromEntry = {}
    for i, header in ipairs(entry.headers) do
        local ok = string.find(header, ":")
        if ok then
            local headerName, headerValue = header:match("^([^:]+):*(.-)$")
            headerNamesFromEntry[i] = headerName
        else
            local msg =  "Value not provided for header '" .. header .. "'"
            local err = { tbl = { validation_error = msg }}
            return false, err
        end
    end

    -- Check whether header names given in plugin configuration and ones used for new entry match
    local headerNamesDiff1 = utils.difference(plugin_config.header_names, headerNamesFromEntry)
    local headerNamesDiff2 = utils.difference(headerNamesFromEntry,plugin_config.header_names)

    ngx.log(ngx.DEBUG, "Diff ( pluging config vs entry ): " .. dump.tostring(plugin_config.header_names) )
    ngx.log(ngx.DEBUG, "Diff ( entry vs pluging config ) " .. dump.tostring(entry.headers) )

    if utils.table_length(headerNamesDiff1) > 0 or utils.table_length(headerNamesDiff2) > 0 then

        local msg = string.format(
            "Header names given in plugin configuration and for entry differ: \n %s %s", 
            dump.tostring(plugin_config.header_names),
            dump.tostring(entry.headers))
        local err = { tbl = { validation_error = msg }}
        return false, err
    end

    -- Validation successfull
    return true, nil
end

-- Validates entry against configuration - are all headers given in configuration given in entry
-- @return List of matcghing entries if success, nil+error ( as { tbl = { error_key = "error_value" } }  ) otherwise
function _M.validate_against_other_entries(entry, current_entries)
    
    local matching_existing_entries = {}

    -- Check whether header names are given
    if entry.headers == nil then
        local msg = "Header names are not provided for entry"
        local err = { tbl = { validation_error = msg }}
        return false, err
        
    end

    ngx.log(ngx.DEBUG, "Entry headers names and values: " .. dump.tostring(entry.headers) )
    ngx.log(ngx.DEBUG, "Other entries ( from DB ): " .. dump.tostring(current_entries) )

    local i = 1;
    local is_duplicate = false
    for i, current_entry in ipairs(current_entries) do
        
        local all_match = true
        for i, current_entry_header in ipairs(current_entry.headers) do
            
            local match = utils.table_contains( entry.headers, current_entry_header )
            if not match then
                all_match = false
                break
            end
        end

        if all_match then
            matching_existing_entries[0] = current_entry
            i = i + 1
        end
    end        

    return matching_existing_entries
end

return _M