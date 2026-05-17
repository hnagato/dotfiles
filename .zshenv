# ssh先での文字化け対策
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export PAGER=less
export DELTA_PAGER='less -FRX'

if (( $+commands[brew] )); then
  eval "$($(brew --prefix)/bin/brew shellenv zsh)"
  [[ -f `brew --prefix`/etc/autojump.zsh ]] && source `brew --prefix`/etc/autojump.zsh
fi

# mise
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# PATH
typeset -U path cdpath fpath manpath

path=($HOME/bin $HOME/.rd/bin $path)
path=($^path(N-/))
