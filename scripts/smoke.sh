#!/usr/bin/env sh
set -eu

API_PORT="${API_PORT:-8080}"
WEB_PORT="${WEB_PORT:-5173}"

curl -fsS "http://localhost:${API_PORT}/api/swagger-ui/index.html" >/dev/null
curl -fsS "http://localhost:${API_PORT}/api/docs" >/dev/null
curl -fsS "http://localhost:${WEB_PORT}" >/dev/null
curl -fsS "http://localhost:${WEB_PORT}/api/docs" >/dev/null

echo "ok: web, backend, OpenAPI and nginx API proxy are reachable"
