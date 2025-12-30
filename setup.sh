#!/bin/bash
set -e

find "$(cd "$(dirname "$0")" && pwd)" -name '.DS_Store' -type f -delete

if [[ " $* " == *" -t "* ]]; then
  TARGET="/tmp/$USER"
else
  TARGET="$HOME"
fi
export TARGET
mkdir -p "$TARGET"

if command -v mise >/dev/null 2>&1; then
  mise trust "$TARGET/.config/mise/config.toml" || true
fi

./setup.rb "$@"

command -v fish >/dev/null 2>&1 && fish -c 'curl -sL git.io/fisher | source && fisher update'

mkdir -p "$TARGET/.local/share/tmux/plugins"
if [ ! -d "$TARGET/.local/share/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TARGET/.local/share/tmux/plugins/tpm"
fi
"$TARGET/.local/share/tmux/plugins/tpm/bin/install_plugins"

if [ -d "$TARGET/.ssh" ]; then
  chmod 700 "$TARGET/.ssh"
  find "$TARGET/.ssh/" -type f -exec chmod 600 {} \;
fi

if [ -d "$TARGET/.gnupg" ]; then
  chmod 700 "$TARGET/.gnupg"
  find "$TARGET/.gnupg/" -type d -exec chmod 700 {} \;
  find "$TARGET/.gnupg/" -type f -exec chmod 600 {} \;
fi
