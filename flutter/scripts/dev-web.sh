#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

lsof -ti :8080 | xargs kill -9 2>/dev/null || true
sleep 1

flutter pub get
exec flutter run -d web-server --web-hostname=localhost --web-port=8080
