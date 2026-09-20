#!/usr/bin/env bash
# Writes a gitignored bundle into dist/ and runs `turbo boundaries` with several versions.
set -uo pipefail
pnpm install --silent
mkdir -p apps/app/dist
cat > apps/app/dist/bundle.js <<'JS'
import leftPad from "undeclared-static-dep";
export const load = () => import("undeclared-dynamic-dep");
export { leftPad };
JS
git status --short --ignored apps/app/dist
for version in 2.8.11 2.8.12 2.11.2 2.11.3-canary.2; do
  echo "== turbo@$version boundaries"
  pnpm dlx "turbo@$version" --skip-infer boundaries 2>&1 | grep -oE "cannot import package \`[^\`]+\`|Checked .*"
done
