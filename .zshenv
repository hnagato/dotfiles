# JAVA_OPTS / ANT_OPTS
export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"

# Play!
export PLAY_PATH=$HOME/play-1.2.5
export PLAY_HOME=$PLAY_PATH

local RUBY_HOME=/usr/local/Cellar/ruby

# PATH
typeset -U path cdpath fpath manpath
path=($HOME/bin(N-/) $JAVA_HOME $PLAY_HOME /usr/local/(bin|sbin)(N-/) $RUBY_HOME/*/bin(N-/) $path)

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

