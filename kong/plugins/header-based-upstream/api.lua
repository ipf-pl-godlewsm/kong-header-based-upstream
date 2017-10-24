local crud = require "kong.api.crud_helpers"
local dump = require 'serial'

local validator = require "kong.plugins.header-based-upstream.validator"
local utils = require "kong.plugins.header-based-upstream.utils"

local function retrieve_plugin_config()
  
end

return {
  ["/apis/:api_name_or_id/header-based-upstream/"] = {
    before = function(self, dao_factory, helpers)
      crud.find_api_by_name_or_id (self, dao_factory, helpers)

      -- Assign API ID
      self.params.api_id = self.api.id    

      

      
    end,

    GET = function(self, dao_factory, helpers)
      crud.paginated_set(self, dao_factory.header_based_upstream_urls)
    end,

    PUT = function(self, dao_factory, helpers)


      crud.put(self.params, dao_factory.header_based_upstream_urls)
    end,

    POST = function(self, dao_factory, helpers)

      -- Retrieve plugin configuration
      filter = { 
        api_id = self.params.api_id,
        name = "header-based-upstream"
      }
      local plugins, err = dao_factory.plugins:find_all(filter);
      
      if err then
        return helpers.yield_error(err)
      end

      if utils.table_length(plugins) ~= 1 then
        return helpers.responses.send_HTTP_BAD_REQUEST("Plugin not configured for api")        
      end

      local plugin_config = plugins[1].config
  
      --Validate parameters against plugin configuration
      local res, err = validator.validateEntry(self.params, plugin_config)

      if err then
        return helpers.responses.send_HTTP_BAD_REQUEST(err)        
      end

      crud.post(self.params, dao_factory.header_based_upstream_urls)

      ngx.log(ngx.DEBUG, "Post")

      
    end
  }
--   ,
--   ["/consumers/:username_or_id/key-auth/:credential_key_or_id"] = {
--     before = function(self, dao_factory, helpers)
--       crud.find_consumer_by_username_or_id(self, dao_factory, helpers)
--       self.params.consumer_id = self.consumer.id

--       local credentials, err = crud.find_by_id_or_field(
--         dao_factory.header_based_upstream_urlss,
--         { consumer_id = self.params.consumer_id },
--         self.params.credential_key_or_id,
--         "key"
--       )

--       if err then
--         return helpers.yield_error(err)
--       elseif next(credentials) == nil then
--         return helpers.responses.send_HTTP_NOT_FOUND()
--       end
--       self.params.credential_key_or_id = nil

--       self.header_based_upstream_urls = credentials[1]
--     end,

--     GET = function(self, dao_factory, helpers)
--       return helpers.responses.send_HTTP_OK(self.header_based_upstream_urls)
--     end,

--     PATCH = function(self, dao_factory)
--       crud.patch(self.params, dao_factory.header_based_upstream_urlss, self.header_based_upstream_urls)
--     end,

--     DELETE = function(self, dao_factory)
--       crud.delete(self.header_based_upstream_urls, dao_factory.header_based_upstream_urlss)
--     end
--   }
}