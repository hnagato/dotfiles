# JAVA_OPTS / ANT_OPTS
export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"

# Play!
export PLAY_PATH=$HOME/play-1.2.5
export PLAY_HOME=$PLAY_PATH

# ruby
export GEM_HOME=~/.gem

local RUBY_HOME=/usr/local/Cellar/ruby

# PATH
typeset -U path cdpath fpath manpath
path=($HOME/bin(N-/) $JAVA_HOME $PLAY_HOME /usr/local/(bin|sbin)(N-/) $RUBY_HOME/*/bin(N-/) $GEM_HOME/bin $path)

# npm
[[ -d /usr/local/lib/node_modules ]] && export NODE_PATH=/usr/local/lib/node_modules

# nodebrew
[[ -d $HOME/.nodebrew/current/bin ]] && path=($HOME/.nodebrew/current/bin(N-/) $path)

# autojump
[[ -f `brew --prefix`/etc/autojump.sh ]] && source `brew --prefix`/etc/autojump.sh

