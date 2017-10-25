echo "---------------------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------"
echo -n > /usr/local/Cellar/kong/0.11.0/logs/error.log
luarocks make kong-plugin-header-based-upstream-0.1.0-1.rockspec
kong restart

curl -i -X GET http://kong:8000/valuesApi/values \
	-H "X-Market-ID:POL1" \
	-H "X-ApiVersion:v1"

# curl -i -X POST http://kong:8001/apis/valuesApi/header-based-upstream \
#     --data "name=PL-v1" \
# 	--data "headers[1]=X-Market-ID:POL1" \
# 	--data "headers[2]=X-ApiVersion:v1" \
#     --data "upstream_url=http://127.0.0.1:5001/valuesApi/pl/api/"

# curl -i -X PUT http://kong:8001/apis/valuesApi/header-based-upstream \
#     --data "name=CZ" \
# 	--data "headers[1]=X-Market-ID:POL1" \
# 	--data "headers[2]=X-ApiVersion:v1" \
#     --data "upstream_url=http://127.0.0.1:5001/valuesApi/cz/api/"

#curl -i -X GET http://kong:8001/apis/valuesApi/header-based-upstream

# curl -X POST http://kong:8001/apis/valuesApi/plugins \
#     -d "name=header-based-upstream" \
#     -d "config.header_names[1]=X-Market-ID" \
#     -d "config.header_names[2]=X-ApiVersion"



# curl -i -X POST http://kong:8001/apis/valuesApi/header-based-upstream \
#     --data "name=CZ" \
#     --data "upstream_url=http://127.0.0.1:5001/valuesApi/cz/api/"



#cat /usr/local/Cellar/kong/0.11.0/logs/error.log
#    --data "headers[1].name=X-Market-ID:PL" \
#
#   --data "headers[2].name=X-Version:V1" \



#cat /usr/local/Cellar/kong/0.11.0/logs/error.log