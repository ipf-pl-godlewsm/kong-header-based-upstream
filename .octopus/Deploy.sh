echo "Building plugin on server"
sudo luarocks make kong-plugin-header-based-upstream-0.1.0-1.rockspec
echo "Performing migrations and restarting kong..."
sudo kong stop
sudo kong start
echo "Restarting kong...done"