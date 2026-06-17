#!/usr/bin/env bash
# Ensure Flutter dev web server is running on :8080.
# Usage:
#   ./scripts/ensure-dev-web.sh          # start only if down
#   ./scripts/ensure-dev-web.sh --reload # kill + restart (after code changes)
set -euo pipefail

cd "$(dirname "$0")/.."
PORT="${PORT:-8080}"
RELOAD=false

if [[ "${1:-}" == "--reload" ]]; then
  RELOAD=true
fi

if "$RELOAD"; then
  lsof -ti ":${PORT}" | xargs kill -9 2>/dev/null || true
  sleep 1
elif ./scripts/check-dev-web.sh >/dev/null 2>&1; then
  echo "Dev server already running at http://localhost:${PORT}"
  exit 0
fi

echo "Starting dev server at http://localhost:${PORT} ..."
nohup flutter run -d web-server --web-hostname=localhost --web-port="${PORT}" \
  > /tmp/acrosstool-flutter-web.log 2>&1 &

for _ in $(seq 1 90); do
  if ./scripts/check-dev-web.sh >/dev/null 2>&1; then
    echo "Ready: http://localhost:${PORT} (log: /tmp/acrosstool-flutter-web.log)"
    exit 0
  fi
  sleep 1
done

echo "Timed out waiting for dev server. See /tmp/acrosstool-flutter-web.log" >&2
exit 1
