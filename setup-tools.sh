#!/bin/bash

set -e

error() {
  echo "ERROR: $1" >&2
  exit 1
}

show_help() {
  cat << EOF
Usage: $0 [options]
Options:
  -t, --test      Setup in /tmp instead of \$HOME
  -h, --help      Show this help
EOF
}

# Parse command line options
TEST_MODE=false
while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--test)
    TEST_MODE=true
    shift
    ;;
    -h|--help)
    show_help
    exit 0
    ;;
    *)
    echo "Unknown option: $1" >&2
    show_help
    exit 1
    ;;
  esac
done

# Set target directory
if [ "$TEST_MODE" = true ]; then
  TARGET="/tmp/$USER"
else
  TARGET="$HOME"
fi

# Get dotfiles directory
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Target directory: $TARGET"
echo "Dotfiles directory: $DOTFILES"

# Install fisher plugins
echo "Installing fisher plugins..."
command -v fish >/dev/null 2>&1 || error "fish not installed"

fisher_cmd='curl -sL git.io/fisher | source && fisher update'
if [ "$TEST_MODE" = true ]; then
  HOME="$TARGET" fish -c "$fisher_cmd" || error "fisher failed"
else
  fish -c "$fisher_cmd" || error "fisher failed"
fi

# nvim is now managed via stow as a regular package
echo "nvim configuration is managed via stow - use ./setup.sh nvim"

# Setup tpm
echo "Setting up tpm..."
mkdir -p "$TARGET/.local/share/tmux/plugins" || error "Failed to create tmux plugins directory"
cd "$TARGET/.local/share/tmux/plugins"
if [ ! -d "$TARGET/.local/share/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TARGET/.local/share/tmux/plugins/tpm" || error "Failed to clone tpm"
else
  echo "tpm is already installed"
fi
$TARGET/.local/share/tmux/plugins/tpm/bin/install_plugins

# SSH permissions setup
[ -d "$TARGET/.ssh" ] && chmod 700 "$TARGET/.ssh" && find "$TARGET/.ssh" -type f -exec chmod 600 {} \;

echo "Setup tools completed successfully!"
