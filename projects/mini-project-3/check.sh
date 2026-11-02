#!/usr/bin/env bash
# Mini-project 3 - checks your compose.yml (API + Postgres). Usage: ./check.sh
cd "$(dirname "$0")" || exit 1

PROJECT=mp3check
COMPOSE="docker compose -p $PROJECT"
FAILED=0

ok() { echo "✅ $1"; }
ko() { echo "❌ $1"; FAILED=1; }

[ -f .env ] || { cp .env.example .env; echo "ℹ️  .env created from .env.example"; }

cleanup() { $COMPOSE down -v >/dev/null 2>&1; }
trap cleanup EXIT
cleanup

echo "== Mini-project 3 =="

if $COMPOSE config -q 2>/tmp/mp3-config.log; then
  ok "compose.yml is valid"
else
  ko "compose.yml is invalid:"; cat /tmp/mp3-config.log; exit 1
fi

if $COMPOSE up -d --build >/tmp/mp3-up.log 2>&1; then
  ok "docker compose up --build works"
else
  ko "docker compose up fails (see /tmp/mp3-up.log)"; tail -n 15 /tmp/mp3-up.log; exit 1
fi

echo "⏳ waiting for the API (the database needs a few seconds)..."
READY=0
for _ in $(seq 1 30); do
  if curl -sf http://localhost:3000/health >/dev/null 2>&1; then READY=1; break; fi
  sleep 2
done
if [ "$READY" -eq 1 ]; then ok "API is up and connected to the database"; else
  ko "API never became healthy. Check: docker compose -p $PROJECT logs api"; exit 1; fi

if curl -sf http://localhost:3000/notes | grep -q "Hello from init.sql"; then
  ok "init.sql was executed (seed note found)"
else
  ko "Seed note missing: is init.sql mounted in /docker-entrypoint-initdb.d ?"
fi

curl -sf -X POST http://localhost:3000/notes -H 'Content-Type: application/json' \
  -d '{"text":"persistence-check"}' >/dev/null
if curl -sf http://localhost:3000/notes | grep -q "persistence-check"; then
  ok "POST /notes writes in Postgres"
else
  ko "Could not create a note"
fi

$COMPOSE down >/dev/null 2>&1       # NO -v: the volume must survive
$COMPOSE up -d >/dev/null 2>&1
READY=0
for _ in $(seq 1 30); do
  if curl -sf http://localhost:3000/health >/dev/null 2>&1; then READY=1; break; fi
  sleep 2
done
if [ "$READY" -eq 1 ] && curl -sf http://localhost:3000/notes | grep -q "persistence-check"; then
  ok "Data survives down/up: the named volume works"
else
  ko "Data lost after down/up: is the data directory on a named volume?"
fi

echo
if [ "$FAILED" -eq 0 ]; then echo "🎉 Mini-project 3 done!"; else echo "Keep going, fix the ❌ and run ./check.sh again."; fi
exit "$FAILED"
