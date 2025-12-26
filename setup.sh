#!/bin/bash
set -e

test_mode=0
for arg in "$@"; do
  if [ "$arg" = "-t" ]; then
    test_mode=1
  fi
done

./link-dotfiles.sh "$@"

if [ "$test_mode" -eq 0 ]; then
  command -v fish >/dev/null 2>&1 && fish -c 'curl -sL git.io/fisher | source && fisher update'

  mkdir -p "$HOME/.local/share/tmux/plugins"
  if [ ! -d "$HOME/.local/share/tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.local/share/tmux/plugins/tpm"
  fi
  "$HOME/.local/share/tmux/plugins/tpm/bin/install_plugins"
fi

target_root="$HOME"
[ "$test_mode" -eq 1 ] && target_root="/tmp/$USER"

if [ -d "$target_root/.ssh" ]; then
  chmod 700 "$target_root/.ssh"
  find "$target_root/.ssh/" -type f -exec chmod 600 {} \;
fi

if [ -d "$target_root/.gnupg" ]; then
  chmod 700 "$target_root/.gnupg"
  find "$target_root/.gnupg/" -type d -exec chmod 700 {} \;
  find "$target_root/.gnupg/" -type f -exec chmod 600 {} \;
fi
