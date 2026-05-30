#!/usr/bin/env bash
set -euo pipefail

dest="${1:-$HOME/.pi/agent/config-repo}"
message="${2:-Update pi config}"

if [[ ! -d "$dest/.git" ]]; then
  echo "Not a git checkout: $dest" >&2
  exit 1
fi

if [[ -z "$(git -C "$dest" status --porcelain)" ]]; then
  echo "No changes to commit."
  exit 0
fi

git -C "$dest" add -A
git -C "$dest" commit -m "$message"
git -C "$dest" push

echo "Pushed commit: $(git -C "$dest" rev-parse --short HEAD)"
