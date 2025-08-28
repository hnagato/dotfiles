#!/bin/bash
set -e
TARGET="$HOME"
if [ "$1" = "-t" ]; then
  if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
    TARGET="$2"
    shift 2
  else
    TARGET="/tmp/$USER"
    shift
  fi
  mkdir -p "$TARGET"
fi

if [ $# -eq 0 ]; then
  find . -print0 -maxdepth 1 -type d -name '[^.]*' -exec basename {} \; | xargs -0 stow -t "$TARGET"
else
  stow -t "$TARGET" "$@"
fi
