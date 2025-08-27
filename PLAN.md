# GNU Stow 移行計画

## 概要

現在の Ruby ベース dotfiles 管理システムを GNU Stow を使用したシンプルな管理システムに移行する計画書です。

### 特記事項
- **.editorconfig**: リポジトリ自体のエディタ設定のため、トップレベルに配置し stow 管理外とします
- **nvim**: git submodule として別途管理されるため、stow パッケージには含めません（現在のsetup.rbでも除外対象）
- **.config/fish**: functions/ ディレクトリの特殊処理が必要（個別ファイルリンク）
- **.config 配下の設定**: 各ツール別にパッケージ分割し、論理的な管理単位とします

## 現在の問題点

### setup.rb の課題
- **Ruby への依存**: 外部言語ランタイムが必要
- **複雑なカスタムロジック**: 200行を超えるスクリプトとカスタムメソッド
- **特殊ケース処理**: fish, nvim, .ssh の個別処理
- **メンテナンス負荷**: 独自実装によるバグリスクと保守コスト

### setup-tools.sh の課題
- **後処理の複雑さ**: fisher, tpm, nvim submodule の個別セットアップ
- **エラーハンドリング**: 各ツール固有のエラー処理

## GNU Stow の利点

### 標準的なツール
- **業界標準**: 多くの dotfiles 管理で使用される実績あるツール
- **シンプルな設計**: シンボリックリンク管理に特化
- **軽量**: 外部言語ランタイム不要（Perl製だが通常プリインストール）

### 基本的な使用方法
```bash
# パッケージをstow（シンボリックリンク作成）
stow package-name

# パッケージをunstow（シンボリックリンク削除）
stow -D package-name

# ターゲットディレクトリを指定
stow -t /path/to/target package-name

# dry-run モード
stow -n package-name
```

## 移行計画

### Phase 1: ディレクトリ構造の再編成

#### 現在の構造
```
dotfiles/
├── .config/           # 直接配置
├── .zshrc, .zshenv   # 直接配置
├── .ssh/             # 直接配置
└── bin/              # スクリプト群
```

#### 移行後の構造
```
dotfiles/
├── .editorconfig     # リポジトリのエディタ設定（stow管理外）
├── shell/
│   ├── .zshrc
│   ├── .zshenv
│   └── .inputrc
├── git/
│   └── .config/
│       └── git/
├── fish/
│   ├── .config/
│   │   └── fish/
│   │       ├── config.fish
│   │       ├── fish_plugins
│   │       └── functions/      # 特殊処理：個別ファイルリンク
│   │           ├── cm.fish
│   │           ├── fish_greeting.fish
│   │           ├── fish_title.fish
│   │           └── ... （個別.fishファイル）
├── tmux/
│   └── .config/
│       └── tmux/
├── karabiner/
│   └── .config/
│       └── karabiner/
├── ssh/
│   └── .ssh/
├── bat/
│   └── .config/
│       └── bat/
├── ghostty/
│   └── .config/
│       └── ghostty/
├── lazygit/
│   └── .config/
│       └── lazygit/
├── mise/
│   └── .config/
│       └── mise/
├── starship/
│   └── .config/
│       └── starship.toml
├── onepassword/
│   └── .config/
│       └── 1Password/
├── misc/
│   ├── .tigrc
│   └── .gnupg/
└── bin/              # 新しいスクリプト群
    ├── stow-setup.sh
    └── setup-tools.sh（改修版）
```

### Phase 2: パッケージ分割戦略

#### 論理的なパッケージ分割
1. **shell**: シェル関連設定（zsh, bash, 共通設定）
2. **git**: Git 関連設定とエイリアス
3. **fish**: Fish shell 専用設定（特殊構成）
4. **tmux**: Tmux 設定とプラグイン
5. **karabiner**: キーボード設定
6. **ssh**: SSH 設定（権限設定含む）
7. **bat**: bat（cat alternative）設定とテーマ
8. **ghostty**: Ghostty ターミナル設定
9. **lazygit**: Lazygit Git TUI 設定
10. **mise**: Mise ツールバージョン管理設定
11. **starship**: Starship プロンプト設定
12. **onepassword**: 1Password SSH agent 設定
13. **misc**: その他の設定ファイル群（.tigrc, .gnupg）

#### 各パッケージの特徴
- **独立性**: 各パッケージは他への依存を最小化
- **選択的インストール**: 必要なパッケージのみ選択可能
- **クリーンなアンインストール**: `stow -D` で完全削除可能

#### fish パッケージの特殊構成

**現在のsetup.rbによる特殊処理**:
```ruby
# .config/fish 内のファイル（ディレクトリ除く）を個別にリンク
(dotfiles/'.config/fish').glob('*').select(&:file?).each do |file|
  link = fish_dir/file
  link.safe_symlink(file)
end

# functions/*.fish ファイルを個別にリンク
(dotfiles/'.config/fish/functions').glob('*.fish').each do |file|
  link = functions_dir/file
  link.safe_symlink(file)
end
```

この処理により、`functions/` ディレクトリ自体はシンボリックリンクされず、個別の `.fish` ファイルのみがリンクされます。

**stow での実現方法**:

**方法1: stow の自然な動作を活用**
```bash
# ターゲットディレクトリに既存の functions/ ディレクトリまたはファイルが
# 存在する場合、stow は自動的に「tree unfolding」を行い、
# 個別のファイルレベルでシンボリックリンクを作成する
```

**方法2: 事前セットアップによる制御**
```bash
# ~/.config/fish/functions/ に dummy ファイルを作成し、
# stow の folding を防止する
mkdir -p ~/.config/fish/functions
touch ~/.config/fish/functions/.stow-no-folding
```

**方法3: 後処理スクリプトでの個別処理**
```bash
# stow 実行後に functions/ ディレクトリを調整
if [[ " ${PACKAGES[*]} " =~ " fish " ]]; then
    echo "Adjusting fish functions directory structure..."
    # 必要に応じて個別調整を実行
fi
```

**推奨アプローチ**: **方法1（stow の自然な動作）**を基本とし、必要に応じて**方法2**で制御する。これにより最小限の特殊処理で現在の動作を再現できます。

### Phase 3: 新しいセットアップスクリプト

#### bin/stow-setup.sh
```bash
#!/bin/bash

# GNU Stow ベースの dotfiles セットアップスクリプト
# 使用法: ./stow-setup.sh [options] [packages...]

set -e

# デフォルトパッケージリスト
DEFAULT_PACKAGES=(shell git fish tmux karabiner ssh bat ghostty lazygit mise starship onepassword misc)

# オプション解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--test)
            TEST_MODE=true
            TARGET="/tmp/$USER"
            shift
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
            echo "Unknown option: $1"
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

# Stow の実行
for package in "${PACKAGES[@]}"; do
    echo "Stowing $package..."
    if [ "$TEST_MODE" = true ]; then
        stow -t "$TARGET" -v "$package"
    else
        stow -v "$package"
    fi
done

# 特殊な後処理
if [[ " ${PACKAGES[*]} " =~ " ssh " ]]; then
    echo "Setting SSH permissions..."
    chmod 600 ~/.ssh/*
    chmod 700 ~/.ssh
fi

# fish の特殊処理：functions/ ディレクトリの個別ファイルリンクを保証
if [[ " ${PACKAGES[*]} " =~ " fish " ]]; then
    echo "Ensuring fish functions directory structure..."
    # functions/ ディレクトリが存在しない場合作成
    mkdir -p ~/.config/fish/functions
    # stow の tree folding を防止するための制御ファイル
    if [ ! -f ~/.config/fish/functions/.stow-local ]; then
        touch ~/.config/fish/functions/.stow-local
    fi
fi

# nvim は git submodule として別途管理される
# setup-tools.sh で処理される予定
```

### Phase 4: 移行手順

#### 1. バックアップ作成
```bash
# 現在の設定のバックアップ
tar czf ~/dotfiles-backup-$(date +%Y%m%d).tar.gz ~/.config ~/.zshrc ~/.ssh
```

#### 2. ディレクトリ構造変更
```bash
# 新しい構造でファイルを再配置
mkdir -p shell
mkdir -p git/.config
mkdir -p fish/.config
mkdir -p tmux/.config
mkdir -p karabiner/.config
mkdir -p ssh
mkdir -p bat/.config
mkdir -p ghostty/.config
mkdir -p lazygit/.config
mkdir -p mise/.config
mkdir -p starship/.config
mkdir -p onepassword/.config
mkdir -p misc
mkdir -p bin

# ファイルの移動
mv .zshrc .zshenv .inputrc shell/
mv .config/git git/.config/
mv .config/fish fish/.config/
mv .config/tmux tmux/.config/
mv .config/karabiner karabiner/.config/
mv .ssh ssh/
mv .config/bat bat/.config/
mv .config/ghostty ghostty/.config/
mv .config/lazygit lazygit/.config/
mv .config/mise mise/.config/
mv .config/starship.toml starship/.config/
mv .config/1Password onepassword/.config/
mv .tigrc .gnupg misc/
```

#### 3. 段階的移行
1. **テスト環境での検証**
   ```bash
   ./bin/stow-setup.sh -t shell git
   ```

2. **本環境での適用**
   ```bash
   # 既存のシンボリックリンクを削除
   # 新しいシステムで再作成
   ./bin/stow-setup.sh
   ```

### Phase 5: 追加機能

#### 便利スクリプトの追加
```bash
# bin/stow-list.sh - インストール済みパッケージの確認
# bin/stow-clean.sh - 孤立したシンボリックリンクのクリーンアップ
# bin/stow-sync.sh - Git pull後の自動再stow
```

## 検証計画

### テスト項目
1. **基本機能テスト**
   - 各パッケージの正常なstow/unstow
   - シンボリックリンクの正確性
   - 権限設定（SSH）
   - fish functions の個別ファイルリンク確認

2. **エッジケーステスト**
   - 既存ファイルとの競合
   - 部分的なインストール・アンインストール
   - 異なる環境での動作確認

3. **パフォーマンステスト**
   - セットアップ時間の比較
   - ディスク使用量の確認

## 利点と期待効果

### 開発効率の向上
- **保守性**: 標準ツールによる簡潔な管理
- **可読性**: 明確なパッケージ分割
- **拡張性**: 新しい設定の追加が容易

### 運用の簡素化
- **デバッグ**: 問題の切り分けが容易
- **バックアップ**: パッケージ単位での管理
- **移植性**: 他環境への展開が簡単

## リスク・課題

### 潜在的なリスク
1. **学習コスト**: GNU Stow の概念習得
2. **移行時のダウンタイム**: 一時的な設定不能状態
3. **特殊な要件**: 現在の複雑な処理の代替実装
4. **fish 設定の複雑性**: functions/ ディレクトリの個別ファイルリンクの確実な実現

### 対策
- 段階的移行による影響最小化
- 詳細なテスト計画による事前検証（特にfish設定の動作確認）
- バックアップ作成による緊急時対応
- fish 設定の特殊処理についての十分なテスト実施

## スケジュール

1. **Week 1**: ディレクトリ構造設計・再編成
2. **Week 2**: 新しいセットアップスクリプト開発
3. **Week 3**: テスト環境での検証・調整
4. **Week 4**: 本環境への移行・最終確認

## まとめ

GNU Stow への移行により、dotfiles 管理システムは以下のように改善されます：

- **Simple**: 複雑なRubyスクリプトから標準ツールへ
- **Modular**: パッケージベースの柔軟な管理
- **Maintainable**: 標準的で理解しやすい構造
- **Portable**: 他環境への簡単な移植

この移行により、長期的なメンテナンス負荷の削減と、より柔軟で管理しやすい dotfiles システムの実現を目指します。
