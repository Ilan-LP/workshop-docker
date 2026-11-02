#!/usr/bin/env bash
# Mini-project 2 - checks your multi-stage Dockerfile. Usage: ./check.sh
cd "$(dirname "$0")/web" || exit 1

IMAGE=mp2-check-image
CONTAINER=mp2-check-container
PORT=3102
FAILED=0

ok() { echo "✅ $1"; }
ko() { echo "❌ $1"; FAILED=1; }

cleanup() { docker rm -f "$CONTAINER" >/dev/null 2>&1; }
trap cleanup EXIT
cleanup

echo "== Mini-project 2 =="

if docker build -t "$IMAGE" --build-arg VITE_APP_NAME=check-ok . >/tmp/mp2-build.log 2>&1; then
  ok "The image builds (with --build-arg VITE_APP_NAME=check-ok)"
else
  ko "docker build fails (see /tmp/mp2-build.log)"
  tail -n 15 /tmp/mp2-build.log
  exit 1
fi

STAGES=$(grep -ciE '^FROM ' Dockerfile)
if [ "$STAGES" -ge 2 ]; then ok "Dockerfile has $STAGES stages"; else ko "Expected at least 2 FROM (multi-stage)"; fi

SIZE_MB=$(( $(docker image inspect "$IMAGE" --format '{{.Size}}') / 1000000 ))
if [ "$SIZE_MB" -lt 120 ]; then
  ok "Final image is small (${SIZE_MB} MB)"
else
  ko "Final image is ${SIZE_MB} MB, expected < 120 MB. Is Node still in the last stage?"
fi

if docker run --rm --entrypoint sh "$IMAGE" -c 'command -v node' >/dev/null 2>&1; then
  ko "Node is present in the final image: it should only contain nginx + static files"
else
  ok "No Node in the final image"
fi

docker run -d --name "$CONTAINER" -p "$PORT:80" "$IMAGE" >/dev/null 2>&1
sleep 2

HTML=$(curl -sf "http://localhost:$PORT/")
if echo "$HTML" | grep -q 'id="root"'; then
  ok "nginx serves the React app on http://localhost:$PORT"
else
  ko "Nothing served on port $PORT. Check: docker logs $CONTAINER"
fi

JS_PATH=$(echo "$HTML" | grep -o '/assets/[^"]*\.js' | head -n 1)
if [ -n "$JS_PATH" ] && curl -sf "http://localhost:$PORT$JS_PATH" | grep -q "check-ok"; then
  ok "The build argument reached the bundle (VITE_APP_NAME=check-ok)"
else
  ko "VITE_APP_NAME was not injected. Do you have ARG + ENV before npm run build?"
fi

echo
if [ "$FAILED" -eq 0 ]; then echo "🎉 Mini-project 2 done!"; else echo "Keep going, fix the ❌ and run ./check.sh again."; fi
exit "$FAILED"
