#!/usr/bin/env bash
set -euo pipefail

dest="${1:-$HOME/.pi/agent/config-repo}"

if [[ ! -d "$dest/.git" ]]; then
  echo "Not a git checkout: $dest" >&2
  exit 1
fi

echo "Repository: $dest"
echo "Remote: $(git -C "$dest" remote get-url origin 2>/dev/null || true)"
echo "Branch: $(git -C "$dest" branch --show-current || true)"
echo "Commit: $(git -C "$dest" rev-parse --short HEAD)"
echo
git -C "$dest" status --short --branch
