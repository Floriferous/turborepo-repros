#!/usr/bin/env bash
# The root package.json depends on workspace package "a"; package "b" is unrelated.
# Editing a file in "a" changes the hash of every task (hashOfInternalDependencies).
# turbo.json has futureFlags.affectedUsingTaskInputs on; turbo.flag-off.json is the
# same config without the flag.
set -euo pipefail
pnpm install --silent
git checkout -q -- packages
hashes() { pnpm exec turbo run build --dry=json 2>/dev/null | jq -r '[.tasks[] | "\(.taskId)=\(.hash[:8])"] | join("  ")'; }
echo "== task hashes"
echo "clean:                $(hashes)"
echo 2 >> packages/a/src/x.txt
echo "edit packages/a/src:  $(hashes)"
echo "== turbo run build --affected"
echo "flag off: $(TURBO_SCM_BASE=HEAD pnpm exec turbo run build --affected --dry=json --root-turbo-json turbo.flag-off.json 2>/dev/null | jq -r '[.tasks[].taskId] | join(", ")')"
echo "flag on:  $(TURBO_SCM_BASE=HEAD pnpm exec turbo run build --affected --dry=json 2>/dev/null | jq -r '[.tasks[].taskId] | join(", ")')"
echo "== turbo query affected (flag on)"
echo "--tasks build: $(pnpm exec turbo query affected --tasks build --base HEAD 2>/dev/null | jq -r '[.data.affectedTasks.items[] | "\(.fullName) (\(.reason.__typename))"] | join(", ")')"
echo "--packages:    $(pnpm exec turbo query affected --packages --base HEAD 2>/dev/null | jq -r '[.data.affectedPackages.items[] | "\(.name) (\(.reason.__typename))"] | join(", ")')"
git checkout -q -- packages
