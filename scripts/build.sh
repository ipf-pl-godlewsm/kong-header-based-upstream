echo "Building and deploying plugin"
luarocks make kong-plugin-header-based-upstream-0.1.0-1.rockspec
echo "Clearing kong logs"
echo -n > /usr/local/Cellar/kong/0.11.0/logs/error.log
echo "Restarting kong"
kong restart
