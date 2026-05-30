#!/usr/bin/env bash
set -euo pipefail

repo="${1:-https://github.com/OrionRiitters/agent-skills.git}"
dest="${2:-$HOME/.pi/agent/config-repo}"

if [[ -d "$dest/.git" ]]; then
  echo "Updating existing checkout: $dest"
  git -C "$dest" fetch --prune
  current_branch="$(git -C "$dest" branch --show-current)"
  if [[ -z "$current_branch" ]]; then
    echo "Checkout is detached; fetched remote refs but did not merge."
  else
    git -C "$dest" pull --ff-only
  fi
else
  if [[ -e "$dest" ]]; then
    echo "Destination exists but is not a git checkout: $dest" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dest")"
  git clone "$repo" "$dest"
fi

echo "Config repo ready: $dest"
git -C "$dest" rev-parse --short HEAD
