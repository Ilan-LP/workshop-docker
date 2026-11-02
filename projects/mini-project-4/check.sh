#!/usr/bin/env bash
# Mini-project 4 - checks the full stack. Usage: ./check.sh
cd "$(dirname "$0")" || exit 1

PROJECT=mp4check
COMPOSE="docker compose -p $PROJECT"
FAILED=0

ok() { echo "✅ $1"; }
ko() { echo "❌ $1"; FAILED=1; }
bonus_ok() { echo "⭐ $1"; }
bonus_ko() { echo "➖ $1 (bonus)"; }

[ -f .env ] || { cp .env.example .env; echo "ℹ️  .env created from .env.example"; }

cleanup() { $COMPOSE down -v >/dev/null 2>&1; }
trap cleanup EXIT
cleanup

echo "== Mini-project 4 =="

if $COMPOSE config -q 2>/tmp/mp4-config.log; then
  ok "compose.yml is valid"
else
  ko "compose.yml is invalid:"; cat /tmp/mp4-config.log; exit 1
fi

if $COMPOSE up -d --build >/tmp/mp4-up.log 2>&1; then
  ok "docker compose up --build works (3 services)"
else
  ko "docker compose up fails (see /tmp/mp4-up.log)"; tail -n 15 /tmp/mp4-up.log; exit 1
fi

echo "⏳ waiting for the stack..."
READY=0
for _ in $(seq 1 40); do
  if curl -sf http://localhost:8080/api/health >/dev/null 2>&1; then READY=1; break; fi
  sleep 2
done
if [ "$READY" -eq 1 ]; then ok "http://localhost:8080/api/health answers through nginx"; else
  ko "Stack not reachable. Check: docker compose -p $PROJECT logs"; exit 1; fi

if curl -sf http://localhost:8080/ | grep -q 'id="root"'; then
  ok "The React app is served on http://localhost:8080"
else
  ko "The front is not served on 8080"
fi

curl -sf -X POST http://localhost:8080/api/notes -H 'Content-Type: application/json' \
  -d '{"text":"fullstack-check"}' >/dev/null
if curl -sf http://localhost:8080/api/notes | grep -q "fullstack-check"; then
  ok "Front -> nginx -> api -> db works end to end"
else
  ko "Create/read a note through /api failed"
fi

if $COMPOSE port db 5432 >/dev/null 2>&1; then
  ko "Postgres is published on your machine: remove its ports, nobody outside needs it"
else
  ok "Postgres is not exposed to the host"
fi

if $COMPOSE port api 3000 >/dev/null 2>&1; then
  ko "The API is published on your machine: only web should have ports"
else
  ok "The API is not exposed to the host"
fi

STATUS=$($COMPOSE ps db --format '{{.Health}}' 2>/dev/null)
if [ "$STATUS" = "healthy" ]; then ok "db has a working healthcheck"; else ko "db healthcheck missing or failing (status: '$STATUS')"; fi

if $COMPOSE exec -T web sh -c 'nc -z -w 2 db 5432' >/dev/null 2>&1; then
  bonus_ko "web can reach the database: put db on the backend network only"
else
  bonus_ok "web cannot reach the database (network isolation)"
fi

echo
if [ "$FAILED" -eq 0 ]; then echo "🎉 Mini-project 4 done!"; else echo "Keep going, fix the ❌ and run ./check.sh again."; fi
exit "$FAILED"
