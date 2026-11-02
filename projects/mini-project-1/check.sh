#!/usr/bin/env bash
# Mini-project 1 - checks your Dockerfile. Usage: ./check.sh
cd "$(dirname "$0")/api" || exit 1

IMAGE=mp1-check-image
CONTAINER=mp1-check-container
PORT=3101
FAILED=0

ok()   { echo "✅ $1"; }
ko()   { echo "❌ $1"; FAILED=1; }
bonus_ok() { echo "⭐ $1"; }
bonus_ko() { echo "➖ $1 (bonus)"; }

cleanup() { docker rm -f "$CONTAINER" >/dev/null 2>&1; }
trap cleanup EXIT
cleanup

echo "== Mini-project 1 =="

if docker build -t "$IMAGE" . >/tmp/mp1-build.log 2>&1; then
  ok "The image builds"
else
  ko "docker build fails (see /tmp/mp1-build.log)"
  tail -n 15 /tmp/mp1-build.log
  exit 1
fi

if grep -qx "node_modules" .dockerignore 2>/dev/null; then
  ok ".dockerignore excludes node_modules"
else
  ko ".dockerignore must contain node_modules"
fi

SIZE=$(docker image inspect "$IMAGE" --format '{{.Size}}')
SIZE_MB=$((SIZE / 1000000))
if [ "$SIZE_MB" -lt 300 ]; then
  ok "Image size is reasonable (${SIZE_MB} MB)"
else
  ko "Image is ${SIZE_MB} MB, expected < 300 MB (did you pick an alpine variant?)"
fi

docker run -d --name "$CONTAINER" -p "$PORT:3000" "$IMAGE" >/dev/null 2>&1
sleep 2

if curl -sf "http://localhost:$PORT/" | grep -q "Hello from the container"; then
  ok "The API answers on http://localhost:$PORT"
else
  ko "The API does not answer. Check: docker logs $CONTAINER"
fi

if curl -sf "http://localhost:$PORT/" | grep -q '"env":"production"'; then
  ok "NODE_ENV=production is set"
else
  ko "NODE_ENV should be production inside the container"
fi

if docker image inspect "$IMAGE" --format '{{json .Config.ExposedPorts}}' | grep -q "3000/tcp"; then
  ok "Port 3000 is documented with EXPOSE"
else
  ko "Missing EXPOSE 3000"
fi

USER_NAME=$(docker exec "$CONTAINER" whoami 2>/dev/null)
if [ -n "$USER_NAME" ] && [ "$USER_NAME" != "root" ]; then
  bonus_ok "Running as non-root user ($USER_NAME)"
else
  bonus_ko "Container runs as root"
fi

echo
if [ "$FAILED" -eq 0 ]; then echo "🎉 Mini-project 1 done!"; else echo "Keep going, fix the ❌ and run ./check.sh again."; fi
exit "$FAILED"
