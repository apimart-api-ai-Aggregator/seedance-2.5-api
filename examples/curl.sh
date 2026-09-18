#!/usr/bin/env bash
# Seedance 2.5 (seedance-2.5) video generation: submit, poll, print cost. Set APIMART_API_KEY first.
set -euo pipefail
: "${APIMART_API_KEY:?export APIMART_API_KEY first}"
BASE="${APIMART_BASE_URL:-https://api.apimart.ai/v1}"
PROMPT="${1:-A kitten yawning at the camera}"
SIZE="${2:-16:9}"
RESOLUTION="${3:-720p}"
DURATION="${4:-5}"

read -r -d '' BODY <<JSON || true
{"model":"seedance-2.5","prompt":"$PROMPT","size":"$SIZE","resolution":"$RESOLUTION","duration":$DURATION,"generate_audio":false}
JSON

TASK=$(curl -sS "$BASE/videos/generations" \
  -H "Authorization: Bearer $APIMART_API_KEY" -H 'Content-Type: application/json' \
  -H "Idempotency-Key: $(uuidgen)" -d "$BODY" \
  | python3 -c 'import json,sys; d=json.load(sys.stdin)["data"]; print(d["id"] if isinstance(d,dict) else d[0]["task_id"])')
echo "task: $TASK"

for _ in $(seq 1 60); do
  RESPONSE=$(curl -sS "$BASE/tasks/$TASK" -H "Authorization: Bearer $APIMART_API_KEY")
  STATUS=$(printf '%s' "$RESPONSE" | python3 -c 'import json,sys; print(json.load(sys.stdin)["data"]["status"])')
  echo "status: $STATUS"
  [ "$STATUS" = "completed" ] && break
  [ "$STATUS" = "failed" ] && { printf '%s\n' "$RESPONSE"; exit 1; }
  sleep 10
done
printf '%s' "$RESPONSE" | python3 -c 'import json,sys; d=json.load(sys.stdin)["data"]; print("cost:", d.get("cost"), "videos:", d.get("result",{}).get("videos",[{}])[0].get("url"))'
