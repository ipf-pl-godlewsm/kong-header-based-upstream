package = "kong-plugin-header-based-upstream"
version = "0.1.0-1"               

-- TODO: renumber, must match the info in the filename of this rockspec!
-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.

supported_platforms = {"linux", "macosx"}
source = {
  -- these are initially not required to make it work
  url = "git://github.com/Mashape/kong_plugin",
  tag = "0.1.0"
}

description = {
  summary = "Kong is a scalable and customizable API Management Layer built on top of Nginx.",
  homepage = "http://getkong.org",
  license = "MIT"
}

dependencies = {
}

local pluginName = "header-based-upstream"
build = {
  type = "builtin",
  modules = {
    ["kong.plugins."..pluginName..".migrations.cassandra"] = "kong/plugins/"..pluginName.."/migrations/cassandra.lua",
    ["kong.plugins."..pluginName..".migrations.postgres"] = "kong/plugins/"..pluginName.."/migrations/postgres.lua",
    ["kong.plugins."..pluginName..".handler"] = "kong/plugins/"..pluginName.."/handler.lua",
    ["kong.plugins."..pluginName..".daos"] = "kong/plugins/"..pluginName.."/daos.lua",
    ["kong.plugins."..pluginName..".schema"] = "kong/plugins/"..pluginName.."/schema.lua",
    ["kong.plugins."..pluginName..".api"] = "kong/plugins/"..pluginName.."/api.lua",
    ["kong.plugins."..pluginName..".validator"] = "kong/plugins/"..pluginName.."/validator.lua",
    ["kong.plugins."..pluginName..".utils"] = "kong/plugins/"..pluginName.."/utils.lua"
  }
}