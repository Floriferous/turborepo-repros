#!/usr/bin/env bash
# globalDependencies is ["ci/**", "!ci/test/**"]. The global hash honors the
# negation, but --affected treats the negated file as a global change.
set -euo pipefail
pnpm install --silent
git checkout -q -- ci docs
report() {
  local hash affected
  hash=$(pnpm exec turbo run build --dry=json 2>/dev/null | jq -r '.tasks[] | select(.taskId == "a#build") | .hash')
  affected=$(TURBO_SCM_BASE=HEAD pnpm exec turbo run build --affected --dry=json 2>/dev/null | jq -r '[.tasks[].taskId] | join(",")')
  printf '%-44s hash=%s  affected=[%s]\n' "$1" "$hash" "$affected"
}
report "clean tree"
echo 2 >> docs/notes.md;          report "edit docs/notes.md (not a global dep)";      git checkout -q -- docs
echo 2 >> ci/test/plan.test.ts;   report "edit ci/test/plan.test.ts (negated)";        git checkout -q -- ci
echo 2 >> ci/plan.ts;             report "edit ci/plan.ts (global dep)";               git checkout -q -- ci
