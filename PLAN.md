# GNU Stow 統合移行プロジェクト計画

## 全体計画 (Comprehensive Migration Strategy)

### 目標
- 現在の2つのリポジトリ（public dotfiles + private dotfiles.private）を統合
- GNU Stow による標準的な管理への移行
- 機密情報の適切な分離とセキュリティ強化
- 現代的な secrets management ツールの導入

### 戦略的アプローチ（3-Phase Evolution）
1. **Phase 1**: Public dotfiles の Stow 移行（リスク最小化）
2. **Phase 2**: Private dotfiles 機密度評価・分類・ツール統合
3. **Phase 3**: 統合最適化・自動化強化

## 基本設計 (Hybrid Architecture + Modern Tools)

### 推奨構造：ハイブリッド＋現代ツール統合
```
~/dotfiles/ (public repo, Stow managed)
├── shell/           # .zshrc, .zshenv, .tigrc, .inputrc, .editorconfig
├── editors/         # .config/nvim (submodule handling)
├── terminal/        # .config/ghostty, .config/tmux, starship.toml
├── dev-tools/       # .config/git, .config/lazygit, .config/bat
├── security/        # .ssh/config (non-sensitive parts)
├── system/          # .config/karabiner, .config/mise
├── secrets/         # SOPS encrypted files (*.sops.yaml)
├── bin/             # setup scripts, utilities
└── .stow-local-ignore  # Stow ignore patterns

~/dotfiles.private/ (private repo, Stow managed with SOPS/SecretSpec)
├── credentials/     # .aws, .kube, .gnupg, .netrc (SOPS encrypted)
├── work/            # work-specific configs (SOPS encrypted)
├── containers/      # .docker configs
├── terraform/       # .terraform.d
├── claude-artifacts/  # .claude/ directories (local-only)
├── scripts/         # automation scripts (scheduler, etc)
└── .secretspec.toml   # SecretSpec configuration
```

## Secrets Management Tool 比較分析

### 🥇 推奨：SOPS + age (Phase 2)
**なぜ最適か：**
- **実績**: CNCF sandbox project、広範囲での採用
- **技術優位性**: 値のみ暗号化、meaningful diffs
- **エコシステム**: Stow, Git, CI/CD との優れた統合
- **学習コスト**: moderate、豊富なドキュメント

### 🥈 次点：SecretSpec (Phase 3 検討)
**将来性を評価：**
- **革新性**: 2025年7月リリース、declarative approach
- **柔軟性**: 複数プロバイダー、プロファイル対応
- **懸念**: 新しすぎ、エコシステム未成熟
- **採用判断**: Phase 3 での評価・段階導入

## 機密情報分類マトリクス

### 🔴 **High Sensitivity** → SOPS encryption + private repo
- SSH private keys (.ssh/id_*)
- AWS credentials (.aws/credentials)
- API tokens, service keys
- Work-specific configurations

### 🟡 **Medium Sensitivity** → SecretSpec候補（Phase 3）
- Development API endpoints
- Non-production credentials
- Local development configs

### 🟢 **Low/No Sensitivity** → Public repo, plain Stow
- Shell configurations
- Editor settings
- Public dotfiles

### 🔵 **Special Handling** → Local-only, .stow-local-ignore
- Claude Code artifacts (.claude/)
- Log files, cache
- Machine-specific temporary files

## リスク評価

### 🚨 **Critical Risks**
1. **機密情報露出**: 分類ミスによる public repo への流出
2. **既存 symlink 破綻**: 移行中の設定システム停止
3. **権限管理失敗**: SSH, GPG 等の不適切な権限設定
4. **Submodule 競合**: nvim submodule の Stow 管理競合

### ⚠️ **Medium Risks**
1. **SOPS 学習コスト**: 新ツール習得時間
2. **2-repo 同期複雑性**: 統合後の運用ワークフロー
3. **Claude Code 統合**: .claude/ の適切な処理方法
4. **スケジューラー移行**: daily scheduler の Stow 対応

## 段階的実装ロードマップ

### **Phase 1: Public dotfiles Stow 移行**（2週間）
- GNU Stow インストール・セットアップ
- 現在の構造をStowパッケージ構造に再編成
- 既存 setup.rb からの段階的移行
- テスト・検証・バックアップ体制確立

### **Phase 2: SOPS 統合 + 機密情報移行**（3週間）  
- SOPS + age セットアップ
- Private dotfiles の機密度分類・移行
- 2-repo 統合ワークフロー確立
- セキュリティ検証・権限管理

### **Phase 3: 運用最適化 + SecretSpec 評価**（2週間）
- パフォーマンス最適化
- 自動化強化
- SecretSpec 評価・段階導入検討
- ドキュメント整備・運用手順確立