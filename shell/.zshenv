# ssh先での文字化け対策
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

if (( $+commands[brew] )); then
  eval "$($(brew --prefix)/bin/brew shellenv)"
  [[ -f `brew --prefix`/etc/autojump.zsh ]] && source `brew --prefix`/etc/autojump.zsh
fi

if (( $+commands[fnm] )); then
  eval "$(fnm env --use-on-cd)"
fi

# PATH
typeset -U path cdpath fpath manpath

path=($HOME/bin $HOME/.rd/bin $path)
path=($^path(N-/))
