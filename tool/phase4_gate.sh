#!/usr/bin/env bash
# Phase 4 gate driver: runs integration_test/phase4_gate_test.dart and, on each
# STEP marker it prints, changes that account's plan directly in the local
# database (the app itself can never write plan columns).
set -euo pipefail
DEVICE="${1:?usage: tool/phase4_gate.sh <simulator-id>}"
LOG="$(mktemp -t phase4gate)"
sql() { docker exec supabase_db_rapscanz psql -U postgres -tAc "$1" >/dev/null; }

flutter test integration_test/phase4_gate_test.dart --dart-define-from-file=config/local.json -d "$DEVICE" >"$LOG" 2>&1 &
TEST=$!
handled=""
while kill -0 "$TEST" 2>/dev/null; do
  EMAIL=$(grep -o 'GATE_EMAIL=[^ ]*' "$LOG" | head -1 | cut -d= -f2 || true)
  for step in PRO_MAX EXPIRED FOUNDER; do
    if grep -q "STEP:$step" "$LOG" && [[ "$handled" != *"$step"* ]]; then
      where="(select id from public.profiles where email = '$EMAIL')"
      case $step in
        PRO_MAX) sql "update public.profiles set plan='pro_max', plan_expires_at=now()+interval '30 days' where id=$where" ;;
        EXPIRED) sql "update public.profiles set plan_expires_at=now()-interval '1 day' where id=$where" ;;
        FOUNDER) sql "update public.profiles set plan='free', plan_expires_at=null where id=$where;
                      insert into public.user_roles(user_id, role) select $where, 'founder'" ;;
      esac
      echo "applied $step for $EMAIL"
      handled="$handled $step"
    fi
  done
  sleep 1
done
wait "$TEST" && status=0 || status=$?
grep -E "All tests passed|Some tests failed|Timed out|On screen|Expected|Actual|Which|Plan did not" "$LOG" | head -12
exit $status
