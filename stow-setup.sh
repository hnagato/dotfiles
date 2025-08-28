#!/bin/bash

# GNU Stow ベースの dotfiles セットアップスクリプト
# 使用法: ./stow-setup.sh [options] [packages...]

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# パッケージ自動発見
discover_packages() {
  find . -maxdepth 1 -type d -name '[^.]*' \
    -exec sh -c 'test -n "$(find "$1" -name ".*" -o -name ".config" 2>/dev/null | head -1)"' _ {} \; \
    -print | sed 's|^\./||' | sort
}

# 全利用可能パッケージを取得
get_all_packages() {
  discover_packages
}

# ヘルプ表示
show_help() {
  cat << EOF
GNU Stow ベースの dotfiles セットアップスクリプト

使用法: $0 [options] [packages...]

オプション:
  -t, --test      テスト環境 (/tmp/\$USER) にセットアップ
  -d, --dry-run   実際の処理は行わず、実行内容のみ表示
  -l, --list      利用可能なパッケージを表示
  -h, --help      このヘルプを表示

例:
  $0                      # 全パッケージをインストール
  $0 shell git fish       # 指定したパッケージのみインストール
  $0 -t shell git         # テスト環境で shell と git をインストール
  $0 -d                   # dry-run モードで全パッケージの処理内容を確認
EOF
}

# パッケージリスト表示
show_packages() {
  echo "利用可能なパッケージ:"
  get_all_packages | while read -r package; do
    echo "  - $package"
  done
}

# ログ出力
log() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

# stow コマンドの存在確認
check_stow() {
  if ! command -v stow &> /dev/null; then
    log_error "GNU Stow が見つかりません。先にインストールしてください:"
    echo "  macOS: brew install stow"
    echo "  Ubuntu/Debian: sudo apt install stow"
    echo "  CentOS/RHEL: sudo yum install stow"
    exit 1
  fi
}

# パッケージの存在確認
validate_packages() {
  local invalid_packages=()
  local all_packages=""

  while IFS= read -r package; do
    all_packages="$all_packages $package "
  done < <(get_all_packages)

  for package in "$@"; do
    if [[ ! "$all_packages" =~ " $package " ]]; then
    invalid_packages+=("$package")
    fi
  done

  if [ ${#invalid_packages[@]} -gt 0 ]; then
    log_error "以下のパッケージが見つかりません:"
    printf '  - %s\n' "${invalid_packages[@]}"
    echo
    show_packages
    exit 1
  fi
}

# オプション解析
TEST_MODE=false
DRY_RUN=false
TARGET="$HOME"

while [[ $# -gt 0 ]]; do
  case $1 in
    -t|--test)
    TEST_MODE=true
    TARGET="/tmp/$USER"
    shift
    ;;
    -d|--dry-run)
    DRY_RUN=true
    shift
    ;;
    -l|--list)
    show_packages
    exit 0
    ;;
    -h|--help)
    show_help
    exit 0
    ;;
    --)
    shift
    break
    ;;
    -*)
    log_error "Unknown option: $1"
    show_help
    exit 1
    ;;
    *)
    break
    ;;
  esac
done

# パッケージリスト決定
if [ $# -eq 0 ]; then
  PACKAGES=()
  while IFS= read -r package; do
    PACKAGES+=("$package")
  done < <(get_all_packages)
else
  PACKAGES=("$@")
fi

# 前処理
log "GNU Stow dotfiles セットアップを開始します"

if [ "$TEST_MODE" = true ]; then
  log_warn "テストモード: $TARGET にセットアップします"
  mkdir -p "$TARGET"
fi

if [ "$DRY_RUN" = true ]; then
  log_warn "Dry-run モード: 実際の処理は実行されません"
fi

# 必須コマンドの確認
check_stow

# パッケージの存在確認
validate_packages "${PACKAGES[@]}"

log "対象パッケージ: ${PACKAGES[*]}"

# Stow の実行
for package in "${PACKAGES[@]}"; do
  if [ "$DRY_RUN" = true ]; then
    echo "Would execute: stow -t \"$TARGET\" -v \"$package\""
  else
    log "Stowing $package..."
    if [ "$TEST_MODE" = true ]; then
    stow -t "$TARGET" -v "$package"
    else
    stow -v "$package"
    fi
  fi
done

# 特殊な後処理（最小限）
if [[ " ${PACKAGES[*]} " =~ " ssh " ]]; then
  if [ "$DRY_RUN" = true ]; then
    echo "Would set SSH permissions: chmod 700 $TARGET/.ssh && chmod 600 $TARGET/.ssh/*"
  else
    log "Setting SSH permissions..."
    chmod 700 "$TARGET/.ssh" 2>/dev/null || true
    chmod 600 "$TARGET/.ssh"/* 2>/dev/null || true
  fi
fi

# 完了メッセージ
if [ "$DRY_RUN" = true ]; then
  log "Dry-run 完了。上記のコマンドが実行される予定です。"
else
  log "dotfiles セットアップが完了しました!"

  if [ "$TEST_MODE" = true ]; then
    log "テスト環境での結果を確認してください: $TARGET"
    log "問題がなければ、テストモードなしで実行してください"
  else
    log "新しいシェルセッションを開始するか、設定を再読み込みしてください"
  fi
fi

# 外部ツールのセットアップ案内
if [ "$DRY_RUN" = false ] && [ "$TEST_MODE" = false ]; then
  if [ -f "setup-tools.sh" ]; then
    log "外部ツールのセットアップは ./setup-tools.sh を実行してください"
  fi
fi
