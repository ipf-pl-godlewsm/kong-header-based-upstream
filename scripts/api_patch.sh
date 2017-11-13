curl -i -X PATCH http://kong:8001/apis/valuesApi/header-based-upstream/PL-v1 \
	--data "upstream_url=https://127.0.0.1:5001/api"