# ssh先での文字化け対策
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# JAVA_OPTS / ANT_OPTS export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"

# Play!
export PLAY_PATH=$HOME/play1.x
export PLAY_HOME=$PLAY_PATH

# ruby
export GEM_HOME=~/.gem

# go
export GOPATH=$HOME/.gocode

local RUBY_HOME=/usr/local/opt/ruby

# PATH
typeset -U path cdpath fpath manpath

path=($HOME/bin $JAVA_HOME $PLAY_HOME /usr/local/(bin|sbin) $RUBY_HOME/bin $GEM_HOME/bin $path)
# nodebrew
path=($HOME/.nodebrew/current/bin $path)
# bunlder
path=($HOME/.vendor/bin $path)
path=($^path(N-/))

# npm
[[ -d /usr/local/lib/node_modules ]] && export NODE_PATH=/usr/local/lib/node_modules

# autojump
[[ -f `brew --prefix`/etc/autojump.zsh ]] && source `brew --prefix`/etc/autojump.zsh
