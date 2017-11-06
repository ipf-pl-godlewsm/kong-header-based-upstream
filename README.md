# kong-header-based-upstream

Plugin for kong for routing requests based on values passed in headers

Usage

curl -i -X POST http://kong:8001/apis/valuesApi/header-based-upstream \
	--data "headers[1]=X-Market-ID:POL1" \
	--data "headers[2]=X-ApiVersion:v1" \
    --data "name=PL-v1" \
    --data "upstream_url=http://127.0.0.1:5001/apivaluesApi/pl/api/"

curl -i -X POST http://kong:8001/apis/valuesApi/header-based-upstream \
	--data "headers[1]=X-Market-ID:CZR1" \
	--data "headers[2]=X-ApiVersion:v1" \
    --data "name=CZ-v1" \
    --data "upstream_url=http://127.0.0.1:5001/apivaluesApi/cz/api/"