#!/bin/bash
# First-time setup for a new Mac. Safe to re-run; finished steps are skipped.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/hnagato/dotfiles/master/bootstrap.sh) personal
#
# Usage: bootstrap.sh <personal|work> [--no-private] [--dry-run]
set -euo pipefail

REPO_URL="git@github.com:hnagato/dotfiles.git"
REPO_DIR="$HOME/projects/hnagato/dotfiles"
AGENT_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

usage() {
  echo "Usage: $0 <personal|work> [--no-private] [--dry-run]" >&2
  exit 1
}

log() { printf '\n==> %s\n' "$*"; }

wait_until() {
  local message="$1"
  shift
  until "$@" >/dev/null 2>&1; do
    echo "$message"
    sleep 5
  done
}

machine_env=""
private=true
dry_run=false
for arg in "$@"; do
  case "$arg" in
    personal | work) machine_env="$arg" ;;
    --no-private) private=false ;;
    --dry-run) dry_run=true ;;
    *) usage ;;
  esac
done
[ -n "$machine_env" ] || usage

envs="\"$machine_env\""
mise_env="$machine_env"
if $private; then
  envs="$envs, \"private\""
  mise_env="$mise_env,private"
fi

log "Xcode Command Line Tools"
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install || true
  wait_until "Waiting for the Command Line Tools installer to finish..." xcode-select -p
fi

log "Homebrew"
if [ ! -x /opt/homebrew/bin/brew ]; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

log "1Password and mise"
brew list --cask 1password >/dev/null 2>&1 || brew install --cask 1password
brew list mise >/dev/null 2>&1 || brew install mise

log "1Password SSH agent"
# ssh-add exits 0 when the agent lists keys, 1 when it has none, and 2 when it is unreachable.
if ! SSH_AUTH_SOCK="$AGENT_SOCK" ssh-add -l >/dev/null 2>&1; then
  open -a 1Password
  echo "Sign in to 1Password and turn on Settings > Developer > Use the SSH agent."
  wait_until "Waiting for the 1Password SSH agent to offer keys..." env SSH_AUTH_SOCK="$AGENT_SOCK" ssh-add -l
fi
# Until bootstrap links ~/.ssh/config, point ssh at the agent directly.
# UserKnownHostsFile=/dev/null keeps ssh from creating ~/.ssh, which bootstrap links from the repository.
export SSH_AUTH_SOCK="$AGENT_SOCK"
export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null"
# ssh -T exits 1 even on success because GitHub offers no shell, so check the greeting instead.
github_greeting="$(ssh -T git@github.com 2>&1 || true)"
if [[ "$github_greeting" != *"successfully authenticated"* ]]; then
  echo "GitHub rejected the SSH key. Check that 1Password offers the key registered with GitHub." >&2
  exit 1
fi

log "dotfiles repository"
if [ ! -d "$REPO_DIR/.git" ]; then
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone "$REPO_URL" "$REPO_DIR"
fi

log "$HOME/.config/mise"
if [ -L "$HOME/.config/mise" ]; then
  if [ "$(readlink "$HOME/.config/mise")" != "$REPO_DIR/.config/mise" ]; then
    echo "$HOME/.config/mise links to $(readlink "$HOME/.config/mise"), not $REPO_DIR/.config/mise." >&2
    exit 1
  fi
elif [ -e "$HOME/.config/mise" ]; then
  echo "$HOME/.config/mise exists and is not a link. Move it away and re-run." >&2
  exit 1
else
  mkdir -p "$HOME/.config"
  ln -s "$REPO_DIR/.config/mise" "$HOME/.config/mise"
fi

# Run from $HOME so that no project config is picked up from the current directory.
cd "$HOME"

if $dry_run; then
  # On a new Mac this stops at the link to dotfiles.private/bootstrap.toml, which only the real run clones.
  log "mise bootstrap --dry-run (env: $mise_env)"
  MISE_ENV="$mise_env" mise bootstrap --dry-run --skip-dirty
  exit 0
fi

log "env: $envs"
miserc="$HOME/.config/mise/miserc.local.toml"
[ -e "$miserc" ] || echo "env = [$envs]" >"$miserc"

# The first run clones dotfiles.private and links its bootstrap.toml; the second run loads it.
log "mise bootstrap (1/2)"
mise bootstrap --skip-dirty
log "mise bootstrap (2/2)"
mise bootstrap --skip-dirty

log "Done. New shells pick up the 1Password agent from ~/.ssh/config."
