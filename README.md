# dotfiles

Packages, dotfiles, macOS defaults, and setup hooks are declared for `mise bootstrap`.

| File | Contents |
| --- | --- |
| `.config/mise/config.toml` | Shared tools, packages, dotfiles, macOS defaults, and hooks |
| `.config/mise/config.personal.toml` | Packages for the personal Mac only |
| `.config/mise/config.work.toml` | Packages for the work Mac only |
| `.config/mise/config.private.toml` | Clones dotfiles.private and links its `bootstrap.toml` as `config.private.local.toml` |
| `.config/mise/vscode-extensions.txt` | VS Code extensions; the `post-packages` hook installs missing ones |
| `~/.config/mise/miserc.local.toml` | Per-machine env selection, not tracked |

## Set up a new Mac

1. Install Homebrew, then run `brew install mise git`.
2. Register an SSH key with GitHub. dotfiles.private is cloned over `git@github.com:`.
3. Clone this repository and link `~/.config/mise`.

   ```shell
   git clone git@github.com:hnagato/dotfiles.git ~/projects/hnagato/dotfiles
   mkdir -p ~/.config
   ln -s ~/projects/hnagato/dotfiles/.config/mise ~/.config/mise
   ```

4. Choose the envs: `personal` or `work`, plus `private` when needed.

   ```shell
   echo 'env = ["personal", "private"]' > ~/.config/mise/miserc.local.toml
   ```

5. Preview, then apply twice. The first run clones and links dotfiles.private; the second run loads its config.

   ```shell
   mise bootstrap --dry-run
   mise bootstrap
   mise bootstrap
   ```

## Sync

```shell
git -C ~/projects/hnagato/dotfiles pull
mise bootstrap --skip-dirty
mise bootstrap status --missing
```

- Pass `--skip-dirty`; otherwise uncommitted changes in a declared repository (such as `mise.lock`) stop the repos step.
- Hooks (fisher, TPM, bat cache, `killall Dock`, and so on) run on every invocation.

## Not managed

| Path | Reason |
| --- | --- |
| `~/.config/mise` | Entry point that holds the config itself; link it by hand |
| `~/.claude`, `~/.cache` | Untracked data; existing links are left as they are |
| `~/.claude.json` | A real file that Claude Code rewrites |
