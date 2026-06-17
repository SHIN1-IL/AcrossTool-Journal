#!/usr/bin/env bash
# Dev web server health check. Exit 0 if http://localhost:8080 responds.
set -euo pipefail

PORT="${PORT:-8080}"
URL="http://localhost:${PORT}/"

if curl -sf --max-time 3 "$URL" >/dev/null 2>&1; then
  echo "OK ${URL}"
  exit 0
fi

echo "DOWN ${URL}"
exit 1
