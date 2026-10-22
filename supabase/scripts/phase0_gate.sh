#!/usr/bin/env bash
# Phase 0 gate (CLAUDE.md): against local Supabase,
#   1. a known Indian 890… EAN-13 in Open Food Facts → registry identity
#   2. the same barcode again → identical score/summary from cache, credit still consumed
#   3. an invalid check digit → rejected, no credit consumed
#
# Prereqs: `supabase start`, `supabase functions serve --env-file supabase/.env.local`
# with GEMINI_API_KEY in that env file. Requires curl + python3.
set -euo pipefail

eval "$(supabase status -o env 2>/dev/null | grep -E '^(API_URL|ANON_KEY)=')"
FN="$API_URL/functions/v1/analyze-scan"
EMAIL="gate+$(date +%s)@example.com"
PASS="gate-pass-123"
KNOWN_EAN="8901058851298"   # Maggi Masala noodles (Open Food Facts)
BAD_EAN="8901058851299"     # same code, wrong check digit

json() { python3 -c "import sys,json; d=json.load(sys.stdin); print($1)"; }

TOKEN=$(curl -s "$API_URL/auth/v1/signup" -H "apikey: $ANON_KEY" -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASS\"}" | json "d['access_token']")

quota() {
  curl -s "$API_URL/rest/v1/rpc/get_my_quota" -H "apikey: $ANON_KEY" -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" -d '{}' | json "d['remaining']"
}
scan() {
  curl -s "$FN" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -d "{\"scanType\":\"barcode\",\"barcode\":\"$1\"}"
}

echo "Signed up $EMAIL — remaining: $(quota)"

echo "--- 1. Known EAN $KNOWN_EAN"
FIRST=$(scan "$KNOWN_EAN")
echo "$FIRST" | json "{k: d['result'].get(k) for k in ('productName','brand','parentCompany','category','healthScore','rating')} | {'cached': d.get('cached'), 'remaining': d.get('remaining')}"

echo "--- 2. Same EAN again (cache)"
SECOND=$(scan "$KNOWN_EAN")
echo "$SECOND" | json "{'cached': d.get('cached'), 'remaining': d.get('remaining')}"
python3 - "$FIRST" "$SECOND" <<'PY'
import json, sys
a, b = (json.loads(x)["result"] for x in sys.argv[1:3])
same = a["healthScore"] == b["healthScore"] and a["summary"] == b["summary"]
print("identical score/summary:", same)
sys.exit(0 if same else 1)
PY

BEFORE=$(quota)
echo "--- 3. Bad check digit $BAD_EAN"
scan "$BAD_EAN" | json "d"
AFTER=$(quota)
echo "remaining before: $BEFORE, after: $AFTER"
[ "$BEFORE" = "$AFTER" ] && echo "PASS: no credit consumed" || { echo "FAIL: credit consumed"; exit 1; }
