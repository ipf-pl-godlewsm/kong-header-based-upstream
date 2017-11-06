local crud = require "kong.api.crud_helpers"
local dump = require 'serial'

local validator = require "kong.plugins.header-based-upstream.validator"
local utils = require "kong.plugins.header-based-upstream.utils"

-- Retrieves plugin configuration for given api
-- @return Plugin configuration entity on success, nil+error ( as { tbl = { error_key = "error_value" } }  ) otherwise
local function retrieve_plugin_configuration( dao_factory, api_id)
  
  local plugin_name = "header-based-upstream"
  local filter = { 
    api_id = api_id,
    name = plugin_name
  }
  local plugins, err = dao_factory.plugins:find_all(filter)

  if err then
    return nil,err
  end

  if utils.table_length(plugins) == 1 then
    return plugins[1].config
  else
    err = { tbl = { not_configured = "Plugin '"..plugin_name.."' not configured for api" }}
    return nil,err
  end
end

-- Retrieves existing entries for given api
-- @return Array of existing entries on success, nil+error ( as { tbl = { error_key = "error_value" } }  ) otherwise
local function retrieve_current_entries( dao_factory, api_id)
  
  local filter = { 
    api_id = api_id
  }
  local mappings, err = dao_factory.header_based_upstream_urls:find_all(filter)
  if not mappings then
    return nil, err
  end

  return mappings
end

-- TODO: Add doc
local function find_matchging_entries(entry, current_entries)
  
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
      
      -- Check whether headers are the same
      local all_headers_match = true
      for i, current_entry_header in ipairs(current_entry.headers) do
          
          local match = utils.table_contains( entry.headers, current_entry_header )
          if not match then
            all_headers_match = false
              break
          end
      end

      -- Check whether name is not the same
      local name_match = false
      if entry.name == current_entry.name then
        name_match = true
      end

      if all_headers_match or name_match then
          matching_existing_entries[i] = current_entry
          i = i + 1
      end
  end        

  return matching_existing_entries
end

return {
  ["/apis/:api_name_or_id/header-based-upstream/"] = {
    before = function(self, dao_factory, helpers)
      crud.find_api_by_name_or_id (self, dao_factory, helpers)

      self.params.api_id = self.api.id    
    end,

    GET = function(self, dao_factory, helpers)
      crud.paginated_set(self, dao_factory.header_based_upstream_urls)
    end,

    POST = function(self, dao_factory, helpers)

      -- Retrieve plugin configuration
      local plugin_config, err = retrieve_plugin_configuration( dao_factory, self.params.api_id )
      if err then
        return helpers.yield_error(err)
      end

      --Validate parameters against plugin configuration and against other entries ( duplicate check )
      local res, err = validator.validate_against_conf(self.params, plugin_config)
      if err then
        return helpers.yield_error(err)
      end
      
      -- Retrieve existing entries for API
      local current_entries, err = retrieve_current_entries( dao_factory, self.params.api_id )
      if err then
        return helpers.yield_error(err)
      end

      -- Validate whether other entries does not have the same header configuration
      local matching_entries, err = find_matchging_entries(self.params, current_entries)
      if err then
        return helpers.yield_error(err)
      end

      if matching_entries ~= nil and utils.table_length(matching_entries) > 0 then

        local msg = "Already exists configuration with same values of headers or name - id '" .. matching_entries[1].id .. "'"
        local err = { tbl = { validation_error = msg }}
        return helpers.yield_error(err)
      end
      
      crud.post(self.params, dao_factory.header_based_upstream_urls)      
    end
  },
  ["/apis/:api_name_or_id/header-based-upstream/:entry_name_or_id"] = {
    before = function(self, dao_factory, helpers)

      crud.find_api_by_name_or_id (self, dao_factory, helpers)

      -- Find entry by ID
      local entries, err = crud.find_by_id_or_field(
        dao_factory.header_based_upstream_urls,
        { api_id = self.api.id },
        self.params.entry_name_or_id,
        "name"
      )
      if err then
        return helpers.yield_error(err)
      elseif next(entries) == nil then
        return helpers.responses.send_HTTP_NOT_FOUND()
      end

      -- Assign locally
      self.header_based_upstream_url = entries[1]
    end,

    GET = function(self, dao_factory, helpers)
      return helpers.responses.send_HTTP_OK(self.header_based_upstream_url)
    end,

    PATCH = function(self, dao_factory, helpers)

      ngx.log( ngx.DEBUG, "self.params")
      ngx.log( ngx.DEBUG, dump.tostring(self.params))

      local valuesForUpdate = {}

      if self.params.upstream_url ~= nil then

        valuesForUpdate["upstream_url"] = self.params.upstream_url
      else
        local msg = "Upstream URL not given"
        local err = { tbl = { validation_error = msg }}
        return helpers.yield_error(err)
      end

      crud.patch(valuesForUpdate, dao_factory.header_based_upstream_urls, self.header_based_upstream_url)      
    end,

    DELETE = function(self, dao_factory, helpers)
      crud.delete(self.header_based_upstream_url, dao_factory.header_based_upstream_urls)
    end
  }
}