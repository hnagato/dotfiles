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
    # 引数なし：全パッケージ処理
    find . -maxdepth 1 -type d -name '[^.]*' -exec basename {} \; | xargs stow -t "$TARGET"
else
    # 引数あり：指定パッケージのみ処理
    stow -t "$TARGET" "$@"
fi