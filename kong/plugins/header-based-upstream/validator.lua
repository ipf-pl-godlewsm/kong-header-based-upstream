
local dump = require 'serial'
local utils = require "kong.plugins.header-based-upstream.utils"

local _M = {}

function _M.validateEntry(entry, plugin_config)

    -- Check whether header names are given
    if plugin_config.header_names == nil then
        return false, "Header names are not provided in plugin configuration"
    end

    if entry.headers == nil then
        return false, "Header names are not provided for entry"
    end

    ngx.log(ngx.DEBUG, "Pluging config header names: " .. dump.tostring(plugin_config.header_names) )
    ngx.log(ngx.DEBUG, "Entry headers names and values: " .. dump.tostring(entry.headers) )

    -- Retriev header names from entry
    local headerNamesFromEntry = {}
    for i, header in ipairs(entry.headers) do
        local ok = string.find(header, ":")
        if ok then
            local headerName, headerValue = header:match("^([^:]+):*(.-)$")

            ngx.log(ngx.DEBUG, "Header name: " .. headerName )
            ngx.log(ngx.DEBUG, "Header value: " .. headerValue )

            headerNamesFromEntry[i] = headerName
        else 
            return false, "Value not provided for header '" .. header .. "'"
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
        return false, msg
    end

    -- Validation successfull
    return true, nil
end

return _M