curl -i -X POST http://kong:8001/apis/valuesApi/header-based-upstream \
	--data "headers[1]=X-Market-ID:POL1" \
	--data "headers[2]=X-ApiVersion:v10" \
    --data "name=PL-v1" \
    --data "upstream_url=http://127.0.0.1:5001/valuesApi/pl/api/"