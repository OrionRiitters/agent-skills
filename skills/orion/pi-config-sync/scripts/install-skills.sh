#!/usr/bin/env bash
set -euo pipefail

repo_dir="${1:-$HOME/.pi/agent/config-repo}"
target_arg="${2:-project}"
if [[ "$#" -gt 0 ]]; then shift; fi
if [[ "$#" -gt 0 ]]; then shift; fi

case "$target_arg" in
  project)
    target_root=".pi/skills"
    ;;
  global|user)
    target_root="$HOME/.pi/agent/skills"
    ;;
  *)
    target_root="$target_arg"
    ;;
esac

source_root="$repo_dir/skills"

if [[ ! -d "$source_root" ]]; then
  echo "Skills directory not found: $source_root" >&2
  exit 1
fi

mkdir -p "$target_root"

remove_flattened_duplicate() {
  local rel="$1"
  local dest="$target_root/$rel"
  local skill_name
  skill_name="$(basename "$rel")"
  local flat_dest="$target_root/$skill_name"

  if [[ "$flat_dest" != "$dest" && -e "$flat_dest" ]]; then
    echo "Removing flattened duplicate: $flat_dest"
    rm -rf "$flat_dest"
  fi
}

copy_skill() {
  local rel="$1"
  rel="${rel#skills/}"
  rel="${rel#/}"

  if [[ -z "$rel" || "$rel" == *".."* ]]; then
    echo "Invalid skill path: $1" >&2
    exit 1
  fi

  local src="$source_root/$rel"
  local dest="$target_root/$rel"

  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "Not a skill directory with SKILL.md: $src" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -R "$src" "$dest"
  remove_flattened_duplicate "$rel"
  echo "Installed: $dest"
}

if [[ "$#" -eq 0 ]]; then
  # Copy all namespace directories while preserving the tree under target_root.
  for namespace in "$source_root"/*; do
    [[ -d "$namespace" ]] || continue
    name="$(basename "$namespace")"
    dest="$target_root/$name"
    rm -rf "$dest"
    mkdir -p "$(dirname "$dest")"
    cp -R "$namespace" "$dest"
    while IFS= read -r skill_file; do
      rel="${skill_file#"$source_root/"}"
      rel="${rel%/SKILL.md}"
      remove_flattened_duplicate "$rel"
    done < <(find "$namespace" -name SKILL.md -type f)
    echo "Installed namespace: $dest"
  done
else
  for rel in "$@"; do
    copy_skill "$rel"
  done
fi

echo "Done. Run /reload in pi to discover updated skills."
