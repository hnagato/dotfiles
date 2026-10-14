# dotfiles

パッケージ、dotfiles、macOS defaults、hooks を `mise bootstrap` で宣言的に管理する

| ファイル | 内容 |
| --- | --- |
| `.config/mise/config.toml` | 共通の tools、dotfiles、macOS defaults、hooks と、それらが依存する packages |
| `.config/mise/config.personal.toml` | personal Mac だけに入れるもの |
| `.config/mise/config.work.toml` | work Mac だけに入れるもの |
| `.config/mise/config.private.toml` | dotfiles.private を clone し、その `bootstrap.toml` を `config.private.local.toml` として link する |
| `.config/mise/vscode-extensions.txt` | VS Code 拡張の一覧（`post-packages` hook で未導入分を入れる） |
| `~/.config/mise/miserc.local.toml` | マシンごとの env 選択。git 管理しない |

## 新規マシンのセットアップ

1. Homebrew を入れてから `brew install mise git`
2. GitHub に SSH 鍵を登録する（dotfiles.private は `git@github.com:` で clone する）
3. dotfiles を clone して `~/.config/mise` を link する

   ```shell
   git clone git@github.com:hnagato/dotfiles.git ~/projects/hnagato/dotfiles
   mkdir -p ~/.config
   ln -s ~/projects/hnagato/dotfiles/.config/mise ~/.config/mise
   ```

4. env を選ぶ（`personal` か `work` に、必要なら `private` を加える）

   ```shell
   echo 'env = ["personal", "private"]' > ~/.config/mise/miserc.local.toml
   ```

5. 内容を確認してから 2 回適用する。1 回目で dotfiles.private の clone と link を行い、2 回目でその設定が読み込まれる

   ```shell
   mise bootstrap --dry-run
   mise bootstrap
   mise bootstrap
   ```

## 日々の同期

```shell
git -C ~/projects/hnagato/dotfiles pull
mise bootstrap --skip-dirty
mise bootstrap status --missing
```

- repo に未コミットの変更（`mise.lock` など）があると repos ステップが止まるので、`--skip-dirty` を付ける
- hooks（fisher、TPM、bat cache、`killall Dock` など）は毎回実行される

## 管理対象外

| パス | 理由 |
| --- | --- |
| `~/.config/mise` | bootstrap の入口。config 自身の置き場なので手で link する |
| `~/.claude`、`~/.cache` | git で追跡していないデータ。既存の link はそのまま残す |
| `~/.claude.json` | Claude Code が書き換える実ファイル |
