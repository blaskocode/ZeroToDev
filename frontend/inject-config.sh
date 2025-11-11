#!/bin/sh
# Script to inject runtime configuration into index.html
# This allows the API URL to be set at container startup time

API_URL="${VITE_API_URL:-}"

# Inject config script before closing </head> tag if API_URL is provided
if [ -n "$API_URL" ] && [ -f "/usr/share/nginx/html/index.html" ]; then
  CONFIG_SCRIPT="<script>window.__API_URL__='${API_URL}';</script>"
  sed -i "s|</head>|${CONFIG_SCRIPT}</head>|" /usr/share/nginx/html/index.html
  echo "✓ Injected API URL: ${API_URL}"
else
  echo "ℹ Using relative URL (API_URL not set or index.html not found)"
fi

# Start nginx
exec nginx -g "daemon off;"

