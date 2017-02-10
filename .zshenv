# ssh先での文字化け対策
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# JAVA_OPTS / ANT_OPTS export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"

# sbt
export SBT_OPTS="-XX:+CMSClassUnloadingEnabled -XX:MaxPermSize=256M"

# go
export GOPATH=$HOME/.gocode

# gist & gist-img
export GITHUB_URL=http://gist.github.team-lab.local/

# ruby
# export GEM_HOME=~/.gem
# eval "$(rbenv init -)"

# PATH
typeset -U path cdpath fpath manpath

path=($HOME/bin $JAVA_HOME $PLAY_HOME /usr/local/(bin|sbin) $GEM_HOME/bin $path)
# nodebrew
path=($HOME/.nodebrew/current/bin $path)
# bunlder
path=($HOME/.vendor/bin $path)
path=($^path(N-/))

# npm
[[ -d /usr/local/lib/node_modules ]] && export NODE_PATH=/usr/local/lib/node_modules

# autojump
[[ -f `brew --prefix`/etc/autojump.zsh ]] && source `brew --prefix`/etc/autojump.zsh

