#!/usr/bin/env bash
# Prunes the same commit six times; the pruned turbo.json differs every time.
set -euo pipefail
pnpm install --silent
for run in 1 2 3 4 5 6; do
  rm -rf out
  pnpm exec turbo prune app --docker --out-dir out >/dev/null 2>&1
  echo "run $run: $(jq -r '.boundaries.tags | keys_unsorted | join(",")' out/full/turbo.json)  sha=$(shasum out/full/turbo.json | cut -c1-10)"
done
rm -rf out
