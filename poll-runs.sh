#!/bin/bash
# 轮询最新 workflow runs，直到全部完成（最长 ~2.5h）
get() {
  TOKEN=$(printf "protocol=https\nhost=github.com\n\n" | git credential fill | grep '^password=' | cut -d= -f2-)
  curl -sS -H "Authorization: Bearer $TOKEN" \
    "https://api.github.com/repos/Zhang-Chang-Yuan/ardour-build-tool/actions/runs?per_page=3&head_sha=$(git rev-parse HEAD)"
}
for i in $(seq 1 60); do
  sleep 150
  resp=$(get)
  summary=$(echo "$resp" | uv run python -c "
import json, sys
d = json.load(sys.stdin)
rows = [(r['id'], r['name'][:40], r['status'], r['conclusion']) for r in d.get('workflow_runs', [])]
for r in rows: print(r)
active = [r for r in rows if r[2] not in ('completed',)]
print('ACTIVE_COUNT=' + str(len(active)))
")
  echo "=== poll $i $(date +%H:%M) ==="
  echo "$summary"
  if ! echo "$summary" | grep -q "ACTIVE_COUNT=0" ; then :; else
    echo "ALL_COMPLETED"
    break
  fi
done
