echo "Building and deploying plugin"
luarocks make kong-plugin-header-based-upstream-0.1.0-1.rockspec
echo "Clearing kong logs"
echo -n > /usr/local/Cellar/kong/0.11.0/logs/error.log
echo "Restarting kong"
kong restart

# Query end-service

# No token
# curl -i -X GET http://kong:8000/valuesApi/values \
# 	-H "X-Market-ID:POL1" \
# 	-H "X-ApiVersion:v1"
# 	
# Token - not signed with accepted ISS
# curl -i -X GET http://kong:8000/valuesApi/values \
# 	-H "X-Market-ID:POL1" \
# 	-H "X-ApiVersion:v1" \
# 	-H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJvdWF0aC5wcm92aWRlbnQucGwiLCJpYXQiOjE1MDk2MjQ0NjcsImV4cCI6MTU0MTE2MDQ3NSwiYXVkIjoiYXBpMSIsInN1YiI6Impyb2NrZXRAZXhhbXBsZS5jb20iLCJHaXZlbk5hbWUiOiJKb2hubnkiLCJTdXJuYW1lIjoiUm9ja2V0IiwiRW1haWwiOiJqcm9ja2V0QGV4YW1wbGUuY29tIiwiUm9sZSI6WyJNYW5hZ2VyIiwiUHJvamVjdCBBZG1pbmlzdHJhdG9yIl19.W9c_UNOxrTKzYSh1mBfOAD-yI3JR2Er2hw8io95oGjo"
# 
# Token - correct #1
# curl -i -X GET http://kong:8000/valuesApi/values \
# 	-H "X-Market-ID:POL1" \
# 	-H "X-ApiVersion:v1" \
# 	-H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2p3dC1pZHAuZXhhbXBsZS5jb20iLCJzdWIiOiJtYWlsdG86bWlrZUBleGFtcGxlLmNvbSIsIm5iZiI6MTUwOTYyNzg4MywiZXhwIjoxNTA5NjMxNDgzLCJpYXQiOjE1MDk2Mjc4ODMsImp0aSI6ImlkMTIzNDU2IiwidHlwIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9yZWdpc3RlciIsImF1ZCI6WyJodHRwOi8vZm9vMS5jb20iLCJodHRwOi8vZm9vMi5jb20iXX0.fHqE5KSrpEOt6EJL7MRWzhta25P8rEBc7OvNqqONEXBEifS6hT3ACCn7bhGyA_ZhGChLP2hCE-CGfrCJTHuggLWOoAeIvoiBhZZ9WkO9gz4VixIwmk0ABlI7ALjoOM2ki02na9zLLtXA5dfTl-ZfrlTLER-H0wPU-zYMlm-ZebWxGxeG9T4hqmvPqKmMwdZT9TElEYTouvXkE2rXPkga3B6c1ffbY0PoiOCBjh6vsjwMTpndcTtYc0JVjdKpwF8WAefAIkXYLzqWazWF7yhSo6l-b30X9n8pvgvdwmBiBB3I5GDPXhQqAsUVuIUZlq5xf2LWh8JgW56Tz-f0s2yYyQ"
# 	
# Token - correct #2
# curl -i -X GET http://kong:8000/valuesApi/values \
# 	-H "X-Market-ID:POL1" \
# 	-H "X-ApiVersion:v1" \
# 	-H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2p3dC1pZHAuZXhhbXBsZS5jb20iLCJzdWIiOiJtYWlsdG86bWlrZUBleGFtcGxlLmNvbSIsIm5iZiI6MTUwOTYyNzg4MywiZXhwIjoxNTA5NjMxNDgzLCJpYXQiOjE1MDk2Mjc4ODMsImp0aSI6ImlkMTIzNDU2IiwidHlwIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9yZWdpc3RlciIsImF1ZCI6WyJodHRwOi8vZm9vMS5jb20iLCJodHRwOi8vZm9vMi5jb20iXX0.fHqE5KSrpEOt6EJL7MRWzhta25P8rEBc7OvNqqONEXBEifS6hT3ACCn7bhGyA_ZhGChLP2hCE-CGfrCJTHuggLWOoAeIvoiBhZZ9WkO9gz4VixIwmk0ABlI7ALjoOM2ki02na9zLLtXA5dfTl-ZfrlTLER-H0wPU-zYMlm-ZebWxGxeG9T4hqmvPqKmMwdZT9TElEYTouvXkE2rXPkga3B6c1ffbY0PoiOCBjh6vsjwMTpndcTtYc0JVjdKpwF8WAefAIkXYLzqWazWF7yhSo6l-b30X9n8pvgvdwmBiBB3I5GDPXhQqAsUVuIUZlq5xf2LWh8JgW56Tz-f0s2yYyQ"
	
# Signed with RS256
# 	-H "Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2p3dC1pZHAuZXhhbXBsZS5jb20iLCJzdWIiOiJtYWlsdG86bWlrZUBleGFtcGxlLmNvbSIsIm5iZiI6MTUwOTYyNzg4MywiZXhwIjoxNTA5NjMxNDgzLCJpYXQiOjE1MDk2Mjc4ODMsImp0aSI6ImlkMTIzNDU2IiwidHlwIjoiaHR0cHM6Ly9leGFtcGxlLmNvbS9yZWdpc3RlciIsImF1ZCI6WyJodHRwOi8vZm9vMS5jb20iLCJodHRwOi8vZm9vMi5jb20iXX0.fHqE5KSrpEOt6EJL7MRWzhta25P8rEBc7OvNqqONEXBEifS6hT3ACCn7bhGyA_ZhGChLP2hCE-CGfrCJTHuggLWOoAeIvoiBhZZ9WkO9gz4VixIwmk0ABlI7ALjoOM2ki02na9zLLtXA5dfTl-ZfrlTLER-H0wPU-zYMlm-ZebWxGxeG9T4hqmvPqKmMwdZT9TElEYTouvXkE2rXPkga3B6c1ffbY0PoiOCBjh6vsjwMTpndcTtYc0JVjdKpwF8WAefAIkXYLzqWazWF7yhSo6l-b30X9n8pvgvdwmBiBB3I5GDPXhQqAsUVuIUZlq5xf2LWh8JgW56Tz-f0s2yYyQ"

curl -i -X POST http://kong:8001/apis/valuesApi/header-based-upstream \
    --data "name=PL-v1" \
	--data "headers[1]=X-Market-ID:POL1" \
	--data "headers[2]=X-ApiVersion:v1" \
    --data "upstream_url=http://127.0.0.1:5001/valuesApi/pl/api/"

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