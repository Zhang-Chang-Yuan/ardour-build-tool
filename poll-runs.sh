#!/bin/bash
# 轮询远端 main 最新 2 个 workflow runs，直到全部完成（最长 ~2.5h）
get() {
  TOKEN=$(printf "protocol=https\nhost=github.com\n\n" | git credential fill | grep '^password=' | cut -d= -f2-)
  curl -sS -H "Authorization: Bearer $TOKEN" \
    "https://api.github.com/repos/Zhang-Chang-Yuan/ardour-build-tool/actions/runs?per_page=2"
}
seen_any=0
TARGET_SHA=$(curl -sS -H "Authorization: Bearer $(printf "protocol=https\nhost=github.com\n\n" | git credential fill | grep '^password=' | cut -d= -f2-)" \
  "https://api.github.com/repos/Zhang-Chang-Yuan/ardour-build-tool/commits/main" | uv run python -c "import json,sys; print(json.load(sys.stdin)['sha'][:7])")
echo "target: $TARGET_SHA"
for i in $(seq 1 60); do
  sleep 150
  summary=$(get | uv run python -c "
import json, sys
d = json.load(sys.stdin)
rows = [(r['id'], r['head_sha'][:7], r['status'], r['conclusion']) for r in d.get('workflow_runs', [])]
for r in rows: print(r)
active = [r for r in rows if r[2] not in ('completed',)]
print('ROWS=' + str(len(rows)) + ' ACTIVE=' + str(len(active)))
")
  echo "=== poll $i $(date +%H:%M) ==="
  echo "$summary"
  if [ "$seen_any" = "0" ]; then
    if [ "$(echo "$summary" | grep -c "$TARGET_SHA")" -ge 2 ]; then seen_any=1; fi
    continue
  fi
  if echo "$summary" | grep -q "ACTIVE=0"; then echo "ALL_COMPLETED"; break; fi
done
