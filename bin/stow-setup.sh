#!/bin/bash

# GNU Stow ベースの dotfiles セットアップスクリプト
# 使用法: ./stow-setup.sh [options] [packages...]

set -e

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# デフォルトパッケージリスト
DEFAULT_PACKAGES=(shell git fish tmux karabiner ssh bat ghostty lazygit mise starship onepassword misc)

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

パッケージ:
    shell       シェル関連設定 (.zshrc, .zshenv, .inputrc)
    git         Git 関連設定
    fish        Fish shell 専用設定
    tmux        Tmux 設定とプラグイン
    karabiner   キーボード設定 (Karabiner)
    ssh         SSH 設定 (権限設定含む)
    bat         bat 設定とテーマ
    ghostty     Ghostty ターミナル設定
    lazygit     Lazygit Git TUI 設定
    mise        Mise ツールバージョン管理設定
    starship    Starship プロンプト設定
    onepassword 1Password SSH agent 設定
    misc        その他の設定ファイル (.tigrc, .gnupg)

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
    for package in "${DEFAULT_PACKAGES[@]}"; do
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
    for package in "$@"; do
        if [ ! -d "$package" ]; then
            invalid_packages+=("$package")
        fi
    done
    
    if [ ${#invalid_packages[@]} -gt 0 ]; then
        log_error "以下のパッケージが見つかりません:"
        printf '  - %s\n' "${invalid_packages[@]}"
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

# パッケージリスト（引数で指定されていれば使用）
PACKAGES=("$@")
if [ ${#PACKAGES[@]} -eq 0 ]; then
    PACKAGES=("${DEFAULT_PACKAGES[@]}")
fi

# dotfiles ディレクトリに移動
cd "$(dirname "$0")/.."

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

# 特殊な後処理
if [[ " ${PACKAGES[*]} " =~ " ssh " ]]; then
    if [ "$DRY_RUN" = true ]; then
        echo "Would set SSH permissions: chmod 700 $TARGET/.ssh && chmod 600 $TARGET/.ssh/*"
    else
        log "Setting SSH permissions..."
        chmod 700 "$TARGET/.ssh" 2>/dev/null || true
        chmod 600 "$TARGET/.ssh"/* 2>/dev/null || true
    fi
fi

# fish の特殊処理：functions/ ディレクトリの個別ファイルリンクを保証
if [[ " ${PACKAGES[*]} " =~ " fish " ]]; then
    if [ "$DRY_RUN" = true ]; then
        echo "Would ensure fish functions directory structure"
    else
        log "Ensuring fish functions directory structure..."
        # functions/ ディレクトリが存在しない場合作成
        mkdir -p "$TARGET/.config/fish/functions"
        # stow の tree folding を防止するための制御ファイル
        if [ ! -f "$TARGET/.config/fish/functions/.stow-local" ]; then
            touch "$TARGET/.config/fish/functions/.stow-local"
        fi
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

# nvim は git submodule として別途管理される
# setup-tools.sh で処理される予定
if [ "$DRY_RUN" = false ] && [ "$TEST_MODE" = false ]; then
    if [ -f "bin/legacy/setup-tools.sh" ]; then
        log "外部ツールのセットアップは bin/legacy/setup-tools.sh を実行してください"
    fi
fi
