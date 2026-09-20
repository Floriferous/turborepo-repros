#!/usr/bin/env bash
# Every task below declares the changed file as an input and hashes it,
# but --affected drops the ones whose glob starts with "./".
set -euo pipefail
pnpm install --silent
git checkout -q -- infra packages
echo "== resolved inputs, and whether the hasher includes the file"
pnpm exec turbo run plain prefixed dotslash build test lint --dry=json 2>/dev/null |
  jq -r '.tasks[] | "\(.taskId)\t\(.resolvedTaskDefinition.inputs | join(","))\thashed=\(.inputs | keys | map(select(test("config.txt|x.txt"))) | length > 0)"'
echo two >> infra/config.txt
echo two >> packages/a/src/x.txt
echo "== turbo run --affected (expected: all six tasks)"
TURBO_SCM_BASE=HEAD pnpm exec turbo run plain prefixed dotslash build test lint --affected --dry=json 2>/dev/null | jq -r '.tasks[].taskId'
echo "== turbo query affected (expected: all six tasks)"
pnpm exec turbo query affected --tasks plain prefixed dotslash build test lint --base HEAD 2>/dev/null | jq -r '.data.affectedTasks.items[].fullName'
git checkout -q -- infra packages
