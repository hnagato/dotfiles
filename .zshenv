# PATH
typeset -U path cdpath fpath manpath
path=($HOME/bin(N-/) /usr/*/(bin|sbin)(N-/) $path)

# JAVA_OPTS / ANT_OPTS
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
# export JAVA_HOME=$(/usr/libexec/java_home)
# export JRE_HOME=$JAVA_HOME
# export PATH=$JAVA_HOME/bin:$PATH

# MySQL prompt.
# via. http://subtech.g.hatena.ne.jp/secondlife/20100427/1272350109
export MYSQL_PS1='([32m\u[00m@[33m\h[00m) [34m[\d][00m > '

# npm
[[ -d /usr/local/lib/node_modules ]] && export NODE_PATH=/usr/local/lib/node_modules

# nvm
[[ -s $HOME/.nvm/nvm.sh ]] && source $HOME/.nvm/nvm.sh

# rbenv
if which rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
  [[ -s $HOME/.rbenv/completions/rbenv.zsh ]] && source $HOME/.rbenv/completions/rbenv.zsh
fi

# autojump : https://github.com/joelthelion/autojump
if which brew >/dev/null 2>&1 ; then
  local BREW_PREFIX=`brew --prefix`
  fpath=($BREW_PREFIX/share/zsh/(site-|)functions(N) $fpath)
  test -f $BREW_PREFIX/etc/autojump && source $BREW_PREFIX/etc/autojump
fi


# gisty
# via. https://github.com/swdyh/gisty
export GISTY_DIR=$HOME/git/gists
