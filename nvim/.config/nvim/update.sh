#!/usr/bin/env bash
# Usage: update.sh [--dry-run] [--force]

set -euo pipefail

# === CONSTANTS ===
readonly SCRIPT_REAL_PATH="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_REAL_PATH")" && pwd)"
readonly NVIM_DIR="$SCRIPT_DIR"
readonly UPSTREAM_REPO="https://github.com/nvim-lua/kickstart.nvim.git"
readonly TEMP_DIR="/tmp/nvim-upstream-sync-$$"
readonly SYNC_METADATA_DIR="$NVIM_DIR/.nvim-upstream-sync"

# File paths
readonly KICKSTART_INIT="$NVIM_DIR/lua/kickstart/init.lua"
readonly UPSTREAM_INIT="$TEMP_DIR/init.lua"
readonly UPSTREAM_PLUGINS="$TEMP_DIR/lua/kickstart/plugins"
readonly UPSTREAM_HEALTH="$TEMP_DIR/lua/kickstart/health.lua"
readonly LOCAL_PLUGINS="$NVIM_DIR/lua/kickstart/plugins"
readonly LOCAL_HEALTH="$NVIM_DIR/lua/kickstart/health.lua"
readonly LAST_COMMIT_FILE="$SYNC_METADATA_DIR/last-commit"
readonly LAST_SYNC_FILE="$SYNC_METADATA_DIR/last-sync"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Options
DRY_RUN=false
FORCE=false

# === UTILITY FUNCTIONS ===
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

execute_with_dry_run() {
  local description="$1"
  local command="$2"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN] Would $description"
    return 0
  fi

  eval "$command"
}

ensure_file_exists() {
  local file_path="$1"
  local description="$2"

  if [[ ! -f "$file_path" ]]; then
    log_error "$description not found: $file_path"
    return 1
  fi
  return 0
}

sync_file() {
  local src="$1"
  local dest="$2"
  local description="$3"

  ensure_file_exists "$src" "Source file" || return 1

  execute_with_dry_run "$description" "cp '$src' '$dest'"
  [[ "$DRY_RUN" == false ]] && log_success "Updated $dest"
}

sync_directory() {
  local src="$1"
  local dest="$2"
  local description="$3"

  if [[ ! -d "$src" ]]; then
    log_warn "Source directory not found: $src"
    return 0
  fi

  execute_with_dry_run "$description" "rm -rf '$dest' && cp -r '$src' '$(dirname "$dest")'"
  [[ "$DRY_RUN" == false ]] && log_success "Updated $dest"
}

# === ARGUMENT PARSING ===
show_help() {
  cat <<EOF
update.sh: Sync nvim config with upstream kickstart.nvim

Usage: update.sh [--dry-run] [--force] [-h|--help]

Options:
    --dry-run     Show what would be done without making changes
    --force       Force sync even if no upstream changes detected
    -h, --help    Show this help message

Description:
    Synchronizes the kickstart/ directory with upstream kickstart.nvim while
    preserving custom/ directory and local modifications.

    The sync process:
    1. Fetches latest upstream kickstart.nvim
    2. Compares current state with upstream
    3. Updates lua/kickstart/init.lua and lua/kickstart/plugins/
    4. Preserves lua/custom/ directory completely
    5. Automatically restores custom plugin imports
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    -h | --help)
      show_help
      exit 0
      ;;
    *)
      log_error "Unknown option: $1"
      show_help
      exit 1
      ;;
    esac
  done
}

# === SYNC LOGIC ===
get_upstream_commit() {
  git ls-remote "$UPSTREAM_REPO" HEAD | cut -f1
}

get_last_synced_commit() {
  [[ -f "$LAST_COMMIT_FILE" ]] && cat "$LAST_COMMIT_FILE" || echo ""
}

check_sync_needed() {
  if [[ "$FORCE" == true ]]; then
    return 0
  fi

  local upstream_commit=$(get_upstream_commit)
  local last_commit=$(get_last_synced_commit)

  if [[ "$upstream_commit" == "$last_commit" ]]; then
    log_info "Already up to date with upstream (commit: ${upstream_commit:0:8})"
    return 1
  fi

  log_info "Upstream changes detected:"
  log_info "  Last synced: ${last_commit:0:8}"
  log_info "  Upstream:    ${upstream_commit:0:8}"
  return 0
}

fetch_upstream() {
  log_info "Fetching upstream kickstart.nvim..."
  execute_with_dry_run "clone $UPSTREAM_REPO to $TEMP_DIR" \
    "git clone --depth 1 '$UPSTREAM_REPO' '$TEMP_DIR'"
  [[ "$DRY_RUN" == false ]] && log_success "Upstream repository fetched"
}

sync_init_file() {
  sync_file "$UPSTREAM_INIT" "$KICKSTART_INIT" "sync upstream init.lua to lua/kickstart/init.lua"
}

sync_plugins_dir() {
  sync_directory "$UPSTREAM_PLUGINS" "$LOCAL_PLUGINS" "sync upstream plugins directory"
}

sync_health_file() {
  [[ -f "$UPSTREAM_HEALTH" ]] && sync_file "$UPSTREAM_HEALTH" "$LOCAL_HEALTH" "sync upstream health.lua"
}

sync_kickstart_content() {
  log_info "Syncing kickstart content..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN] Would sync all kickstart files"
    return 0
  fi

  sync_init_file
  sync_plugins_dir
  sync_health_file
}

save_commit_hash() {
  local commit_hash=$(cd "$TEMP_DIR" && git rev-parse HEAD)
  echo "$commit_hash" >"$LAST_COMMIT_FILE"
  echo "$commit_hash"
}

update_metadata() {
  log_info "Updating sync metadata..."

  execute_with_dry_run "update sync metadata" "
        mkdir -p '$SYNC_METADATA_DIR' &&
        date -Iseconds > '$LAST_SYNC_FILE'
    "

  if [[ "$DRY_RUN" == false ]]; then
    local commit_hash=$(save_commit_hash)
    log_success "Metadata updated (commit: ${commit_hash:0:8})"
  fi
}

restore_custom_plugins() {
  log_info "Restoring custom plugin imports..."

  ensure_file_exists "$KICKSTART_INIT" "kickstart init.lua" || return 1

  if ! grep -qF -- "-- { import = 'custom.plugins' }" "$KICKSTART_INIT"; then
    log_warn "Custom plugin import line not found or already active"
    return 0
  fi

  execute_with_dry_run "uncomment { import = 'custom.plugins' } in $KICKSTART_INIT" "
        sed -i.bak 's/^[[:space:]]*--[[:space:]]*{[[:space:]]*import[[:space:]]*=[[:space:]]*'\''custom\.plugins'\''[[:space:]]*},/  { import = '\''custom.plugins'\'' },/' '$KICKSTART_INIT' &&
        rm -f '$KICKSTART_INIT.bak'
    "

  [[ "$DRY_RUN" == false ]] && log_success "Custom plugin import restored"
}

show_summary() {
  log_success "Nvim upstream sync completed successfully!"
  echo
  echo "  ✅ Kickstart content updated from upstream"
  echo "  ✅ Custom configuration preserved"
  echo "  ✅ Custom plugins automatically restored"
  echo
  log_info "File structure:"
  echo "  📁 lua/kickstart/     ← Upstream content"
  echo "  📁 lua/custom/        ← Your customizations"
  echo "  📄 init.lua          ← Integration layer"
  echo "  🔧 update.sh         ← This sync script"

  if [[ -f "$LAST_COMMIT_FILE" ]]; then
    local last_commit=$(cat "$LAST_COMMIT_FILE")
    echo "  🔗 Synced to: ${last_commit:0:8}"
  fi
}

cleanup() {
  [[ -d "$TEMP_DIR" ]] && rm -rf "$TEMP_DIR"
}

# === MAIN EXECUTION ===
main() {
  parse_args "$@"

  log_info "Starting nvim upstream sync"
  log_info "Target directory: $NVIM_DIR"

  [[ "$DRY_RUN" == true ]] && log_warn "DRY RUN MODE - no changes will be made"

  trap cleanup EXIT

  if ! check_sync_needed; then
    log_info "No sync required"
    return 0
  fi

  fetch_upstream
  sync_kickstart_content
  update_metadata
  restore_custom_plugins

  if [[ "$DRY_RUN" == false ]]; then
    show_summary
  else
    log_info "[DRY RUN] Sync simulation completed"
  fi
}

main "$@"
