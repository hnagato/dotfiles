# JAVA_OPTS / ANT_OPTS
export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"

# Play!
export PLAY_PATH=$HOME/play1.x
export PLAY_HOME=$PLAY_PATH

# ruby
export GEM_HOME=~/.gem

local RUBY_HOME=/usr/local/opt/ruby

# PATH
typeset -U path cdpath fpath manpath

path=($HOME/bin(N-/) $JAVA_HOME $PLAY_HOME /usr/local/(bin|sbin)(N-/) $RUBY_HOME/*/bin(N-/) $RUBY_HOME/bin $GEM_HOME/bin $path)

# npm
[[ -d /usr/local/lib/node_modules ]] && export NODE_PATH=/usr/local/lib/node_modules

# nodebrew
[[ -d $HOME/.nodebrew/current/bin ]] && path=($HOME/.nodebrew/current/bin(N-/) $path)

# autojump
[[ -f `brew --prefix`/etc/autojump.zsh ]] && source `brew --prefix`/etc/autojump.zsh

# bunlder
[[ -d $HOME/.vendor/bin ]] && path=($HOME/.vendor/bin(N-/) $path)

