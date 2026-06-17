#!/usr/bin/env bash
# Kill port 8080 and start Flutter web-server (foreground).
set -euo pipefail

cd "$(dirname "$0")/.."
PORT="${PORT:-8080}"

lsof -ti ":${PORT}" | xargs kill -9 2>/dev/null || true
sleep 1

flutter pub get
exec flutter run -d web-server --web-hostname=localhost --web-port="${PORT}"
