#!/usr/bin/env bash
# Usage: update.sh [--dry-run] [--force]

set -euo pipefail

# Resolve symlink to get actual script location
SCRIPT_REAL_PATH="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_REAL_PATH")" && pwd)"
NVIM_DIR="$SCRIPT_DIR"
UPSTREAM_REPO="https://github.com/nvim-lua/kickstart.nvim.git"
TEMP_DIR="/tmp/nvim-upstream-sync-$$"
SYNC_METADATA_DIR="$NVIM_DIR/.nvim-upstream-sync"

# Options
DRY_RUN=false
FORCE=false
VERBOSE=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

show_help() {
  cat <<EOF
update.sh: Sync nvim config with upstream kickstart.nvim

Usage:
    update.sh [OPTIONS]

Options:
    --dry-run     Show what would be done without making changes
    --force       Force sync even if no upstream changes detected
    --verbose     Show detailed output
    -h, --help    Show this help message

Description:
    Synchronizes the kickstart/ directory with upstream kickstart.nvim while
    preserving custom/ directory and local modifications.

    The sync process:
    1. Fetches latest upstream kickstart.nvim
    2. Compares current state with upstream
    3. Updates lua/kickstart/init.lua and lua/kickstart/plugins/
    4. Preserves lua/custom/ directory completely
    5. Updates sync metadata with commit info

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
    --verbose)
      VERBOSE=true
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

# Check if sync is needed by comparing commit hashes
check_sync_needed() {
  if [[ "$FORCE" == true ]]; then
    return 0 # Force sync
  fi

  # Get current upstream commit
  local upstream_commit
  upstream_commit=$(git ls-remote "$UPSTREAM_REPO" HEAD | cut -f1)

  # Get last synced commit
  local last_commit=""
  if [[ -f "$SYNC_METADATA_DIR/last-commit" ]]; then
    last_commit=$(cat "$SYNC_METADATA_DIR/last-commit")
  fi

  if [[ "$upstream_commit" == "$last_commit" ]]; then
    log_info "Already up to date with upstream (commit: ${upstream_commit:0:8})"
    return 1 # No sync needed
  else
    log_info "Upstream changes detected:"
    log_info "  Last synced: ${last_commit:0:8}"
    log_info "  Upstream:    ${upstream_commit:0:8}"
    return 0 # Sync needed
  fi
}

# Clone upstream repository
fetch_upstream() {
  log_info "Fetching upstream kickstart.nvim..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN] Would clone $UPSTREAM_REPO to $TEMP_DIR"
    return 0
  fi

  git clone --depth 1 "$UPSTREAM_REPO" "$TEMP_DIR"
  log_success "Upstream repository fetched"
}

# Sync kickstart content while preserving custom
sync_kickstart_content() {
  log_info "Syncing kickstart content..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN] Would sync upstream init.lua to lua/kickstart/init.lua"
    log_info "[DRY RUN] Would sync upstream lua/kickstart/plugins/ to lua/kickstart/plugins/"
    log_info "[DRY RUN] Would sync upstream lua/kickstart/health.lua to lua/kickstart/health.lua"
    return 0
  fi

  # Sync main init.lua to lua/kickstart/init.lua
  if [[ -f "$TEMP_DIR/init.lua" ]]; then
    cp "$TEMP_DIR/init.lua" "$NVIM_DIR/lua/kickstart/init.lua"
    log_success "Updated lua/kickstart/init.lua"
  fi

  # Sync kickstart plugins directory
  if [[ -d "$TEMP_DIR/lua/kickstart/plugins" ]]; then
    rm -rf "$NVIM_DIR/lua/kickstart/plugins"
    cp -r "$TEMP_DIR/lua/kickstart/plugins" "$NVIM_DIR/lua/kickstart/"
    log_success "Updated lua/kickstart/plugins/"
  fi

  # Sync health.lua if it exists
  if [[ -f "$TEMP_DIR/lua/kickstart/health.lua" ]]; then
    cp "$TEMP_DIR/lua/kickstart/health.lua" "$NVIM_DIR/lua/kickstart/"
    log_success "Updated lua/kickstart/health.lua"
  fi
}

# Update metadata with sync information
update_metadata() {
  log_info "Updating sync metadata..."

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN] Would update sync metadata"
    return 0
  fi

  mkdir -p "$SYNC_METADATA_DIR"

  # Get upstream commit hash
  local upstream_commit
  upstream_commit=$(cd "$TEMP_DIR" && git rev-parse HEAD)

  # Save metadata
  echo "$upstream_commit" >"$SYNC_METADATA_DIR/last-commit"
  date -Iseconds >"$SYNC_METADATA_DIR/last-sync"

  # Save upstream version info
  if [[ -f "$TEMP_DIR/README.md" ]]; then
    head -5 "$TEMP_DIR/README.md" >"$SYNC_METADATA_DIR/upstream-info.txt"
  fi

  log_success "Metadata updated (commit: ${upstream_commit:0:8})"
}

# Cleanup temporary directory
cleanup() {
  if [[ -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
    [[ "$VERBOSE" == true ]] && log_info "Cleaned up temporary directory"
  fi
}

# Restore custom plugin import after upstream sync
restore_custom_plugins() {
  log_info "Restoring custom plugin imports..."

  local kickstart_init="$NVIM_DIR/lua/kickstart/init.lua"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[DRY RUN] Would uncomment { import = 'custom.plugins' } in $kickstart_init"
    return 0
  fi

  if [[ -f "$kickstart_init" ]]; then
    # Use sed to uncomment the custom.plugins import line
    if grep -q "-- { import = 'custom.plugins' }" "$kickstart_init"; then
      sed -i.bak "s/^[[:space:]]*-- { import = 'custom\.plugins' },/  { import = 'custom.plugins' },/" "$kickstart_init"
      rm -f "$kickstart_init.bak" # Clean up backup file
      log_success "Custom plugin import restored"
    else
      log_warn "Custom plugin import line not found or already active"
    fi
  else
    log_error "kickstart init.lua not found: $kickstart_init"
  fi
}

# Show sync summary
show_summary() {
  log_success "Nvim upstream sync completed successfully!"
  echo
  log_info "Summary:"
  echo "  ✅ Kickstart content updated from upstream"
  echo "  ✅ Custom configuration preserved"
  echo "  ✅ Sync metadata updated"
  echo
  log_info "File structure:"
  echo "  📁 lua/kickstart/     ← Upstream content"
  echo "  📁 lua/custom/        ← Your customizations"
  echo "  📄 init.lua          ← Integration layer"
  echo "  🔧 update.sh         ← This sync script"
  echo
  if [[ -f "$SYNC_METADATA_DIR/last-commit" ]]; then
    local last_commit
    last_commit=$(cat "$SYNC_METADATA_DIR/last-commit")
    echo "  🔗 Synced to: ${last_commit:0:8}"
  fi
}

# Main execution
main() {
  parse_args "$@"

  log_info "Starting nvim upstream sync"
  log_info "Target directory: $NVIM_DIR"

  if [[ "$DRY_RUN" == true ]]; then
    log_warn "DRY RUN MODE - no changes will be made"
  fi

  # Set up cleanup trap
  trap cleanup EXIT

  # Check if sync is needed
  if ! check_sync_needed; then
    log_info "No sync required"
    return 0
  fi

  # Perform sync
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

# Execute main function
main "$@"
