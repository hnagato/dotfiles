# ssh先での文字化け対策
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# JAVA_OPTS / ANT_OPTS export JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"

# sbt
export SBT_OPTS="-XX:+CMSClassUnloadingEnabled -XX:MaxMetaspaceSize=256M"

# go
export GOPATH=$HOME/.gocode

# gist & gist-img
export GITHUB_URL=http://gist.github.team-lab.local/

# ruby
# export GEM_HOME=~/.gem
# eval "$(rbenv init -)"

# PATH
typeset -U path cdpath fpath manpath

path=($HOME/bin /usr/local/opt/coreutils/libexec/gnubin /usr/local/(bin|sbin) $GEM_HOME/bin $path)

#Java
# export JAVA_HOME=`/usr/libexec/java_home -v '1.8*'`
# path=($JAVA_HOME/bin $path)
# Scala
export SCALA_HOME=/usr/local/opt/scala/idea
path=($SCALA_HOME/bin $path)
# NodeJS
path=(/usr/local/opt/node@4/bin $path)
# bunlder
path=($HOME/.vendor/bin $path)
# pear
path=($HOME/pear/bin $path)
# composer
path=($HOME/.composer/vendor/bin $path)

path=($^path(N-/))

MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

# npm
[[ -d /usr/local/lib/node_modules ]] && export NODE_PATH=/usr/local/lib/node_modules

# autojump
[[ -f `brew --prefix`/etc/autojump.zsh ]] && source `brew --prefix`/etc/autojump.zsh

