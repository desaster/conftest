#!/usr/bin/env sh

echo "Generating static config"

# whichever you prefer to use in your app:
echo "api_url = \"${API_URL}\";" > /usr/share/nginx/html/static_conf.js
echo "{ \"api_url\": \"${API_URL}\" }" > /usr/share/nginx/html/static_conf.json

echo "Starting nginx"

nginx -g "daemon off;"
