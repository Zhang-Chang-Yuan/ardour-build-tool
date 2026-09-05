#!/bin/bash
# 轮询仓库最近的 workflow runs，直到没有进行中的运行（最长 ~2.5h）
get() {
  TOKEN=$(printf "protocol=https\nhost=github.com\n\n" | git credential fill | grep '^password=' | cut -d= -f2-)
  curl -sS -H "Authorization: Bearer $TOKEN" \
    "https://api.github.com/repos/Zhang-Chang-Yuan/ardour-build-tool/actions/runs?per_page=4"
}
for i in $(seq 1 70); do
  sleep 150
  summary=$(get | uv run python -c "
import json, sys
d = json.load(sys.stdin)
rows = [(r['id'], r['head_sha'][:7], r['status'], r['conclusion']) for r in d.get('workflow_runs', [])]
for r in rows: print(r)
active = [r for r in rows if r[2] not in ('completed',)]
print('ACTIVE=' + str(len(active)))
")
  echo "=== poll $i $(date +%H:%M) ==="
  echo "$summary"
  if echo "$summary" | grep -q "ACTIVE=0"; then echo "ALL_COMPLETED"; break; fi
done
