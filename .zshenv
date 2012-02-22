
# JAVA_OPTS / ANT_OPTS
export JAVA_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"
export ANT_OPTS="-Dfile.encoding=UTF-8 -Duser.country=JP -Duser.language=ja"

# MySQL prompt
# via. http://subtech.g.hatena.ne.jp/secondlife/20100427/1272350109
export MYSQL_PS1='([32m\u[00m@[33m\h[00m) [34m[\d][00m > '

# PATH
# export JAVA_HOME=$(/usr/libexec/java_home)
# export JRE_HOME=$JAVA_HOME
# export PATH=$JAVA_HOME/bin:$PATH

# MySQL
[[ -d /usr/local/mysql/bin ]] && PATH=/usr/local/mysql/bin:$PATH

# npm
[[ -d /usr/local/lib/node_modules ]] && export NODE_PATH=/usr/local/lib/node_modules

# nvm
[[ -s $HOME/.nvm/nvm.sh ]] && source $HOME/.nvm/nvm.sh

# rvm
[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm
export CFLAGS="-O2 -arch x86_64"
#export LDFLAGS="-L/opt/local/lib"
#export CPPFLAGS="-I/opt/local/include"

# Github / gisty(gem)
# refs. https://github.com/swdyh/gisty
export GISTY_DIR=$HOME/git/gists
# ruby -ropenssl -e 'p OpenSSL::X509::DEFAULT_CERT_FILE'
#export GISTY_SSL_CA="/opt/local/etc/openssl/cert.pem"

export PATH=$HOME/bin:$PATH


PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
