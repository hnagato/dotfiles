#!/bin/bash
set -e

for dir in */; do
  stow -t "$HOME" "$(basename "$dir")"
done

command -v fish >/dev/null 2>&1 && fish -c 'curl -sL git.io/fisher | source && fisher update'

mkdir -p "$HOME/.local/share/tmux/plugins"
if [ ! -d "$HOME/.local/share/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$HOME/.local/share/tmux/plugins/tpm"
fi
"$HOME/.local/share/tmux/plugins/tpm/bin/install_plugins"

[ -d "$HOME/.ssh" ] && chmod 700 "$HOME/.ssh" && find "$HOME/.ssh" -type f -exec chmod 600 {} \;
