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

# Get dotfiles directory (script location)
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Setup nvim submodule
echo "Setting up nvim submodule..."
cd "$DOTFILES"

nvim_git="$DOTFILES/.config/nvim/.git"
if [ ! -e "$nvim_git" ]; then
    git submodule init .config/nvim || error "submodule init failed"
    git submodule update .config/nvim || error "submodule update failed"
fi

cd "$DOTFILES/.config/nvim"
if ! git pull origin main 2>/dev/null; then
    git pull origin master || error "nvim pull failed"
fi

# Create nvim symlink
nvim_link="$TARGET/.config/nvim"
nvim_source="$DOTFILES/.config/nvim"

if [ -L "$nvim_link" ] && [ "$(readlink "$nvim_link")" = "$nvim_source" ]; then
    echo "nvim link already exists and is correct"
else
    echo "Creating nvim symlink..."
    if [ -e "$nvim_link" ]; then
        rm -rf "$nvim_link"
    fi
    ln -s "$nvim_source" "$nvim_link"
fi

echo "Setup tools completed successfully!"
