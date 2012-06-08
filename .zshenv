# PATH
typeset -U path cdpath fpath manpath
path=($HOME/bin(N-/) $HOME/play-1.2.4 /usr/local/(bin|sbin)(N-/) $path)

# JAVA_OPTS / ANT_OPTS
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export JAVA_HOME=$(/usr/libexec/java_home)
# export JRE_HOME=$JAVA_HOME
# export PATH=$JAVA_HOME/bin:$PATH

# rbenv
if which rbenv >/dev/null 2>&1; then
  eval "$(rbenv init -)"
  [[ -s $HOME/.rbenv/completions/rbenv.zsh ]] && source $HOME/.rbenv/completions/rbenv.zsh
fi

# npm
[[ -d /usr/local/lib/node_modules ]] && export NODE_PATH=/usr/local/lib/node_modules

# nodebrew
[[ -d $HOME/.nodebrew/current/bin ]] && path=($HOME/.nodebrew/current/bin(N-/) $path)

# autojump : https://github.com/joelthelion/autojump
if which brew >/dev/null 2>&1 ; then
  local BREW_PREFIX=`brew --prefix`
  fpath=($BREW_PREFIX/share/zsh/(site-|)functions(N) $fpath)
  [[ -f $BREW_PREFIX/etc/autojump ]] && source $BREW_PREFIX/etc/autojump
  unset BREW_PREFIX
fi

