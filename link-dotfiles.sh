#!/usr/bin/env bash

set -u

repo_root="$(cd "$(dirname "$0")" && pwd)"
target_root="$HOME"

while getopts "t" opt; do
  [ "$opt" = "t" ] && target_root="/tmp/$USER"
done
shift $((OPTIND - 1))

backup_root="$target_root/.bak/$(date +%Y%m%d-%H%M%S)"
backup_ready=0
moved_items=()

ensure_backup_root() {
  if [ "$backup_ready" -eq 0 ]; then
    mkdir -p "$backup_root"
    backup_ready=1
  fi
}

backup_move() {
  local dest="$1"
  local rel="${dest#"$target_root"/}"
  local target="$backup_root/$rel"
  ensure_backup_root
  mkdir -p "$(dirname "$target")"
  mv "$dest" "$target"
  moved_items+=("$dest -> $target")
}

link_path() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
      return 0
    fi
    backup_move "$dest"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest" || printf 'WARN: failed to link %s\n' "$dest"
}

if [ -d "$repo_root/.config" ]; then
  if [ -e "$target_root/.config" ] && [ ! -d "$target_root/.config" ]; then
    backup_move "$target_root/.config"
  fi
  mkdir -p "$target_root/.config"
  for entry in "$repo_root/.config/"*; do
    [ -e "$entry" ] || continue
    link_path "$entry" "$target_root/.config/$(basename "$entry")"
  done
fi

for entry in "$repo_root"/.*; do
  base="$(basename "$entry")"
  case "$base" in
    .|..|.config|.git|.gitignore|.DS_Store|.claude) continue ;;
  esac
  link_path "$entry" "$target_root/$base"
done

if [ "${#moved_items[@]}" -gt 0 ]; then
  printf 'Moved existing items to: %s\n' "$backup_root"
  printf '%s\n' "${moved_items[@]}"
else
  printf 'No existing items moved.\n'
fi
