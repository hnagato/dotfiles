#!/bin/bash
# migrate.sh - stow migration tool with backup
# Usage: ./migrate.sh [-t target] [packages...]

set -e
TARGET="$HOME"

while [[ $# -gt 0 ]]; do
  case $1 in
    -t)
      if [ -z "$2" ]; then
        TARGET="/tmp/$USER"
      else
        TARGET="$2"
        shift
      fi
      mkdir -p "$TARGET"
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      echo "Usage: $0 [-t target] [packages...]"
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

backup_conflicts() {
  local backup_dir="$TARGET/.backup/$(date +%Y%m%d_%H%M%S)"
  local packages=("$@")

  if [ ${#packages[@]} -eq 0 ]; then
    packages=()
    while IFS= read -r package; do
      packages+=("$package")
    done < <(find . -maxdepth 1 -type d -name '[^.]*' -exec basename {} \;)
  fi

  echo "Migration mode: backing up conflicting files to $backup_dir"

  for package in "${packages[@]}"; do
    echo "Processing package: $package"

    # Handle both stow conflict patterns: file conflicts and directory conflicts
    local conflicts
    local file_conflicts dir_conflicts
    file_conflicts=$(stow -n -t "$TARGET" "$package" 2>&1 | grep "cannot stow .* over existing target" | sed 's/.*over existing target \(.*\) since.*/\1/' || true)
    dir_conflicts=$(stow -n -t "$TARGET" "$package" 2>&1 | grep "existing target is not owned by stow:" | sed 's/.*existing target is not owned by stow: *\(.*\)/\1/' || true)
    conflicts=$(printf '%s\n%s' "$file_conflicts" "$dir_conflicts" | grep -v '^$' || true)

    if [ -n "$conflicts" ]; then
      mkdir -p "$backup_dir"
      echo "  Found conflicts, backing up..."

      while IFS= read -r conflict; do
        if [ -n "$conflict" ]; then
          local source_file="$TARGET/$conflict"
          local backup_file="$backup_dir/$conflict"

          if [ -e "$source_file" ]; then
            echo "    Backing up: $conflict"
            mkdir -p "$(dirname "$backup_file")"
            mv "$source_file" "$backup_file"
          fi
        fi
      done <<< "$conflicts"
    fi
  done

  if [ -d "$backup_dir" ]; then
    echo "Backup completed. Files backed up to: $backup_dir"
  else
    echo "No conflicts found, no backup needed."
  fi
}

run_stow() {
  if [ "$TARGET" != "$HOME" ]; then
    ./setup.sh -t "$TARGET" "$@"
  else
    ./setup.sh "$@"
  fi
}

echo "Starting dotfiles migration with backup..."

backup_conflicts "$@"

echo "Running stow via setup.sh..."
run_stow "$@"

echo "Migration completed successfully!"
