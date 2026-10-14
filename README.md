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

Run `bootstrap.sh`; it performs the steps below and skips the ones already done, so re-run it after any interruption.

```shell
bash <(curl -fsSL https://raw.githubusercontent.com/hnagato/dotfiles/master/bootstrap.sh) personal   # or work
```

The manual steps follow. SSH keys live in 1Password, but 1Password, `~/.ssh/config`, and the agent config are all installed by this setup. Break the cycle by installing 1Password by hand and pointing SSH straight at its agent for the first session.

1. Install the Xcode Command Line Tools and Homebrew.

   ```shell
   xcode-select --install
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```

2. Install 1Password and mise, sign in to 1Password, and turn on Settings → Developer → Use the SSH agent.

   ```shell
   brew install --cask 1password
   brew install mise
   ```

3. In the same shell, use the 1Password agent without `~/.ssh/config`. Do not create `~/.ssh` yourself; bootstrap links it from this repository. `UserKnownHostsFile=/dev/null` keeps ssh from creating it.

   ```shell
   export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
   export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null"
   ssh -T git@github.com
   ```

4. Clone this repository and link `~/.config/mise`.

   ```shell
   git clone git@github.com:hnagato/dotfiles.git ~/projects/hnagato/dotfiles
   mkdir -p ~/.config
   ln -s ~/projects/hnagato/dotfiles/.config/mise ~/.config/mise
   ```

5. Choose the envs: `personal` or `work`, plus `private` when needed.

   ```shell
   echo 'env = ["personal", "private"]' > ~/.config/mise/miserc.local.toml
   ```

6. Apply twice in the same shell, from `$HOME`. Skip `--dry-run` here: on a new Mac it stops at the link to dotfiles.private, which only the real run clones. The first run clones dotfiles.private with the exported agent and links `~/.ssh` and its `bootstrap.toml`; the second run loads the private config. After that, `~/.ssh/config` selects the agent, so new shells need no exports.

   ```shell
   cd ~
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
