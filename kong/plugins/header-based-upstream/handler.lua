local url = require "socket.url"
local dump = require 'serial'

local responses = require "kong.tools.responses"
local singletons = require "kong.singletons"

local utils = require "kong.plugins.header-based-upstream.utils"

local plugin = require("kong.plugins.base_plugin"):extend()

-- Aliases
local ngx_get_headers = ngx.req.get_headers

-- Function verifies all mappings ( headers to URL ) against header values provided in request
--  - All headers from configuration ( mapping ) must match headers in request
--  - Header values comparison is case-insensitive
local function find_matching_mappings(mappings, requestHeaders)

  local matching = {}
  local i = 0;

  -- Iterate over all mappings
  for j,mapping in pairs(mappings) do

    ngx.log(ngx.DEBUG, "Veryfing mapping '" .. mapping.name .. "'...")

    local isMatch = true

    -- Iterate over all header predicates defined for mapping against header values provided in requuest
    for k,header in pairs(mapping.headers) do

      -- Extract header name and value
      local epxectedHeaderName, expectedHeaderValue = header:match("^([^:]+):*(.-)$")

      ngx.log(ngx.DEBUG, "  Expected header name: " .. epxectedHeaderName)
      ngx.log(ngx.DEBUG, "    Expected header value: " .. expectedHeaderValue)

      if requestHeaders[epxectedHeaderName] ~= nil then

        ngx.log(ngx.DEBUG, "    Actual header value: " .. requestHeaders[epxectedHeaderName] )

        if requestHeaders[epxectedHeaderName]:upper() ~= expectedHeaderValue:upper() then
          isMatch = false
          break
        end
      else
        isMatch = false
        break
      end
    end

    ngx.log(ngx.DEBUG, "Veryfing mapping '" .. mapping.name .. "'. Is matched: " .. tostring(isMatch))

    -- In match add to return set
    if isMatch then
      i = i+1
      matching[i] = mapping
    end
  end

  return matching
end

-- constructor
function plugin:new()
  plugin.super.new(self, "header-based-upstream")
end

function plugin:access(plugin_conf)
  plugin.super.access(self)

  -- Match mapping by sent headers
  local matching_mappings = find_matching_mappings( plugin_conf.mappings, ngx.req.get_headers() )
  local matching_mappings_count = utils.table_length( matching_mappings )

  ngx.log( ngx.DEBUG, "Number of matching mappings found:" .. matching_mappings_count)
  if matching_mappings_count == 1 then

    local parsed = url.parse(matching_mappings[1].upstream_url)

    if parsed.port == nil then
      parsed.port = 80
    end

    ngx.log(ngx.DEBUG, "Before:" )
    ngx.log(ngx.DEBUG, "ngx.var.scheme: " .. dump.tostring(ngx.var.scheme) )
    ngx.log(ngx.DEBUG, "ngx.var.request_uri: " .. dump.tostring(ngx.var.request_uri) )
    ngx.log(ngx.DEBUG, "ngx.ctx: " .. dump.tostring(ngx.ctx) )
    ngx.log(ngx.DEBUG, "ngx.var.uri: " .. dump.tostring(ngx.var.uri) )
    ngx.log(ngx.DEBUG, "Parsed url: " .. dump.tostring(parsed) )

    -- Update upstream
    ngx.ctx.api.upstream_url = matching_mappings[1].upstream_url
    ngx.ctx.balancer_address.host = parsed.host
    ngx.ctx.balancer_address.port = parsed.port
    ngx.var.upstream_scheme = parsed.scheme
    ngx.var.upstream_uri = string.gsub( ngx.var.uri, ngx.ctx.router_matches.uri, parsed.path )
    ngx.var.upstream_host = parsed.host

    ngx.log(ngx.DEBUG, "After:" )
    ngx.log(ngx.DEBUG, dump.tostring(ngx.var.scheme) )
    ngx.log(ngx.DEBUG, dump.tostring(ngx.ctx) )

  elseif matching_mappings_count == 0 then

    -- No matching entry found
    local msg = "No matching entry found"
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(err)
  else

    -- Multiple matchching mapping found
    local msg = "Multiple matching entries found"
    return responses.send_HTTP_INTERNAL_SERVER_ERROR(msg)
  end
end

-- set the plugin priority, which determines plugin execution order
plugin.PRIORITY = 10

-- return our plugin object
return plugin