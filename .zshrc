# env {{{
umask 002
bindkey -e
limit coredumpsize 0

## Editor & Pager
if [[ -x /Applications/MacVim.app/Contents/MacOS/Vim ]]; then
  export EDITOR=/Applications/MacVim.app/Contents/MacOS/Vim
else
  export EDITOR=vim
fi
export PAGER=lv

## いろいろ
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

export LESSCHARSET=utf-8
export CLICOLOR=1
export LSCOLORS=cxFxCxDxBxegedabagacad
export LV="-z -Ia -c -Ou8"
#export TERM=xterm-color
#export DISPLAY=:0.0
export GREP_OPTIONS="--color=auto --mmap"

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
# }}}

# history {{{
HISTFILE=$HOME/.zsh_history  # 履歴保存ファイル
HISTSIZE=10000               # メモリ内の履歴の数
SAVEHIST=500000              # 保存される履歴の数
LISTMAX=10000                # 補完リストを尋ねる数 (1=黙って表示, 0=ウィンドウから溢れるときは尋ねる)
if [ $UID = 0 ]; then        # root のコマンドは履歴に追加しない
  unset HISTFILE
  SAVEHIST=0
fi

zshaddhistory() {
  local line=${1%%$'\n'}
  local cmd=${line%% *}
  # 以下の条件をすべて満たすものだけをヒストリに追加する
  [[ ${#line} -ge 5
    && ${cmd} != (c|cd)
    && ${cmd} != (m|man)
    #&& ${cmd} != (l|l[safl])
  ]]
}
#}}}

# prompt {{{
setopt prompt_subst

## vsc info on right prompt. {{{2
## refs. http://d.hatena.ne.jp/mollifier/20100906/p1
autoload -Uz add-zsh-hook
autoload -Uz colors; colors
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn #hg bzr
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true

autoload -Uz is-at-least
if is-at-least 4.3.10; then
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "+"    # 適当な文字列に変更する
  zstyle ':vcs_info:git:*' unstagedstr "-"  # 適当の文字列に変更する
  zstyle ':vcs_info:git:*' formats '(%s)-[%b] %c%u'
  zstyle ':vcs_info:git:*' actionformats '(%s)-[%b|%a] %c%u'
fi

function _update_vcs_info_msg() {
  psvar=()
  LANG=en_US.UTF-8 vcs_info
  [[ -n "$vcs_info_msg_0_" ]] && psvar[1]="$vcs_info_msg_0_"
}
add-zsh-hook precmd _update_vcs_info_msg
# }}}

## growl-notify after lazy command {{{2
## orig. http://d.hatena.ne.jp/umezo/20100508/1273332857
local COMMAND=""
local COMMAND_TIME=""
function _growl_lazy_precmd() {
  if [ "$COMMAND_TIME" -ne "0" ] ; then
    local d=`date +%s`
    d=`expr $d - $COMMAND_TIME`
    if [ "$d" -ge "5" ] ; then
      COMMAND="$COMMAND "
      growlnotify -t "${${(s: :)COMMAND}[1]}" -m "$COMMAND" -a iTerm > /dev/null 2>&1
    fi
  fi
  COMMAND="0"
  COMMAND_TIME="0"
}
function _growl_lazy_preexec() {
  COMMAND="${1}"
  if [[ ! $COMMAND =~ "^(ssh|vi|man|lv|tail)" ]]; then
    COMMAND_TIME=`date +%s`
  fi
}
add-zsh-hook precmd _growl_lazy_precmd
add-zsh-hook preexec _growl_lazy_preexec
# }}}

## update shell title & screen's window name {{{2
function _update_title() {
  local CURCMD="$1"
  if [[ $TERM =~ 'screen' ]]; then
    case $1 in
      ssh)
        CURCMD="$2"
        ;;
      *)
        CURCMD="$1"
        ;;
    esac
    # screen window name
    echo -ne "\ek${CURCMD}\e\\"
  fi
  # term title
  echo -ne "\033]0;${USER}@${HOST%%.*}:${PWD} [${CURCMD}]\007"
}
function _revert_title() {
  if [[ $TERM =~ 'screen' ]]; then
    #echo -ne "\ek$(basename $SHELL)\e\\"
  # window title
    echo -ne "\ek$(pwd)\e\\"
  fi
}
add-zsh-hook precmd  _revert_title
add-zsh-hook preexec _update_title
# }}}

RPROMPT="%{${fg[cyan]}%}%n@%m%{${reset_color}%}%1(v|%F{green}%1v%f|)"
PROMPT="%{${fg[blue]}%}[%~]
%(?.%{${fg[yellow]}%}».%{${fg[red]}%}») %{${reset_color}%}"

# }}}

# aliases && functions {{{
if [[ $TERM =~ '256color' ]]; then
  alias ssh='TERM=xterm ssh'
fi
# vim
if [[ -x /Applications/MacVim.app/Contents/MacOS/Vim ]]; then
  alias vi='/Applications/MacVim.app/Contents/MacOS/Vim "$@"'
  alias mvim='open -a /Applications/MacVim.app "$@"'
  ## sudo vi を unite.vim が許してくれないので仕方なく function 定義してる
  function suvi() {
    /Applications/MacVim.app/Contents/MacOS/Vim $(echo $@ | perl -pe 's/(\S+)/sudo:\1/g')
  }
fi

alias ls='ls -v'
alias ll='ls -lhtrvGF'
alias la='ls -lhavG'
alias lf='ls -lhavGF'
alias cp='cp -p'
alias scp='scp -p'
alias du='du -h'
alias df='df -h'
alias h='history'
alias j='jobs -l'
alias rmdir='rm -rf'
alias ntop='nice -10 top -s 2'
alias sr="screen -R -U -O"
alias sls="screen -ls"
alias jdate='date +"%Y/%m/%d (%a) %H:%M:%S"'
alias tcp='sudo lsof -nPiTCP'
alias udp='sudo lsof -nPiUDP'

# ネットワークにアクセスしているプロセスの一覧
alias nwps='lsof -Pni | cut -f1 -d" " | sort -u'
# IO待ちのプロセス一覧
alias iops='ps auxwwww|awk "\$8 ~ /(D|STAT)/{print}"'
# メモリ使用量の多い順
alias memps='ps -ecmo "command %cpu %mem pid rss" | head -11'
# CPU使用率の高い順
alias cpups='ps -ecro "command %cpu %mem pid rss" | head -11'

alias -g H="|& head"
alias -g L="|& lv -z -Ia -c -Ou8"
alias -g N="|& nkf -w"
alias -g G="| grep"
alias -g V="| vim -R -"

if which pbcopy >/dev/null 2>&1 ; then
  # 文字化けさせない pbcopy
  # refs http://d.hatena.ne.jp/edvakf/20080929/1222657230
  alias pbcopy="nkf -w | __CF_USER_TEXT_ENCODING=0x$(printf %x $(id -u)):0x08000100:14 pbcopy"

  # Copy to clipboard: Mac
  alias -g C='| pbcopy'

elif which xsel >/dev/null 2>&1 ; then
  # Copy to clipboard: Linux
  alias -g C='| xsel --input --clipboard'
fi

# Hibernate
if which osascript >/dev/null 2>&1 ; then
  alias hibernate="osascript -e 'tell app \"Finder\" to sleep'"
fi

# extract で圧縮ファイルを解凍
# via. http://d.hatena.ne.jp/se-kichi/20101017/1287341473
function extract() {
  case $1 in
    *.tar.gz|*.tgz) tar xzvf $1 ;;
    *.tar.xz) tar Jxvf $1 ;;
    *.zip) unzip $1 ;;
    *.lzh) lha e $1 ;;
    *.tar.bz2|*.tbz) tar xjvf $1 ;;
    *.tar.Z) tar zxvf $1 ;;
    *.gz) gzip -dc $1 ;;
    *.bz2) bzip2 -dc $1 ;;
    *.Z) uncompress $1 ;;
    *.tar) tar xvf $1 ;;
    *.arj) unarj $1 ;;
  esac
}
alias -s {gz,tgz,zip,lzh,bz2,tbz,Z,tar,arj,xz}=extract

# tmux
alias tm="tmux attach-session || tmux new"
#}}}

# predict {{{
autoload predict-on
zle -N predict-on
zle -N predict-off
#bindkey '^T' predict-on
#bindkey '^Y' predict-off
zstyle ':predict' verbose true
#}}}

# completion {{{
fpath=($HOME/.zsh/completion $fpath)

autoload -U compinit; compinit -u
### pid 補完
zstyle ':completion:*:processes' command 'ps x -o pid,args'
# sudo でも補完まくる
zstyle ':completion:*:sudo:*' command-path /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin /opt/local/bin /opt/local/sbin ~/bin
# 補完の時に大文字小文字を区別しない (但し、大文字を打った場合は小文字に変換しない)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補を ←↓↑→ で選択 (補完候補が色分け表示される)
zstyle ':completion:*:default' menu select=1
### ファイルリスト補完でも ls と同様に色をつける｡
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# /Applications/* を補完候補に追加
if [ "`uname`" = "Darwin" ]; then
   compctl -f -x 'p[2]' -s "`/bin/ls -d1 /Applications/*/*.app /Applications/*.app | sed 's|^.*/\([^/]*\)\.app.*|\\1|;s/ /\\\\ /g'`" -- open
   alias run='open -a'
fi

# ~/.ssh/config に入ってるホストを補完候補に追加
hosts=( ${(@)${${(M)${(s:# :)${(zj:# :)${(Lf)"$([[ -f ~/.ssh/config ]] && < ~/.ssh/config)"}%%\#*}}##host(|name) *}#host(|name) }/\*} )
zstyle ':completion:*:hosts' hosts $hosts

# 今入力している内容から始まるヒストリを探す
#autoload history-search-end
#zle -N history-beginning-search-backward-end history-search-end
#zle -N history-beginning-search-forward-end history-search-end
#bindkey "^P" history-beginning-search-backward-end
#bindkey "^N" history-beginning-search-forward-end

bindkey '^R' history-incremental-pattern-search-backward
bindkey '^S' history-incremental-pattern-search-forward

# rake
function _rake () {
  if [ -f Rakefile ]; then
    compadd `rake -T | awk "{print \\$2}" | xargs`
  fi
}
compdef _rake rake

# cdgem: refs. http://subtech.g.hatena.ne.jp/secondlife/20101224/1293179431
function cdgem() { 
  cd `echo $GEM_HOME/**/gems/$1*|awk -F' ' '{print $1}'`
}
compctl -K _cdgem cdgem
function _cdgem() {
  reply=(`find $GEM_HOME -type d|grep -e '/gems/[^/]\+$'|xargs basename|sort -nr`)
}

# C-w で､直前の/までを削除する｡
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# URLコピペしたときに勝手にエスケープさせる（wgetとか用）
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# ファイル名の一括変更とか
## zmv -W *.htm *.html
autoload zmv
alias zmv='noglob zmv -W'

#}}}

# dabbrev {{{
# ref. http://d.hatena.ne.jp/secondlife/20060108/1136650653
HARDCOPYFILE=$HOME/tmp/screen-hardcopy
touch $HARDCOPYFILE

dabbrev-complete () {
  local reply lines=80 # 80行分
  screen -X eval "hardcopy -h $HARDCOPYFILE"
  reply=($(sed '/^$/d' $HARDCOPYFILE | sed '$ d' | tail -$lines))
  compadd - "${reply[@]%[*/=@|]}"
}

zle -C dabbrev-complete menu-complete dabbrev-complete
bindkey '^o' dabbrev-complete
bindkey '^o^_' reverse-menu-complete
#}}}

# setopt {{{
#-------------------------------------------------------
# based by http://devel.aquahill.net/zsh/zshoptions

# 複数の zsh を同時に使う時など history ファイルに上書きせず追加する
setopt append_history

# 指定したコマンド名がなく、ディレクトリ名と一致した場合 cd する
setopt auto_cd

# 補完候補が複数ある時に、一覧表示する
setopt auto_list

# 補完キー（Tab, Ctrl+I) を連打するだけで順に補完候補を自動で補完する
setopt auto_menu

# カッコの対応などを自動的に補完する
setopt auto_param_keys

# ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt auto_param_slash

# 最後がディレクトリ名で終わっている場合末尾の / を自動的に取り除く
#setopt auto_remove_slash

# サスペンド中のプロセスと同じコマンド名を実行した場合はリジュームする
setopt auto_resume

# ビープ音を鳴らさないようにする
setopt no_beep

# {a-c} を a b c に展開する機能を使えるようにする
setopt brace_ccl

# 内部コマンドの echo を BSD 互換にする
#setopt bsd_echo

# シンボリックリンクは実体を追うようになる
#setopt chase_links

# 既存のファイルを上書きしないようにする
#setopt clobber

# コマンドのスペルチェックをする
setopt correct

# コマンドライン全てのスペルチェックをする
#setopt correct_all

# =command を command のパス名に展開する
setopt equals

# ファイル名で #, ~, ^ の 3 文字を正規表現として扱う
setopt extended_glob

# zsh の開始・終了時刻をヒストリファイルに書き込む
setopt extended_history

# Ctrl+S/Ctrl+Q によるフロー制御を使わないようにする
setopt no_flow_control

# 各コマンドが実行されるときにパスをハッシュに入れる
#setopt hash_cmds

# 直前と同じコマンドラインはヒストリに追加しない
setopt hist_ignore_dups

# コマンドラインの先頭がスペースで始まる場合ヒストリに追加しない
setopt hist_ignore_space

# ヒストリを呼び出してから実行する間に一旦編集できる状態になる
setopt hist_verify

# シェルが終了しても裏ジョブに HUP シグナルを送らないようにする
setopt no_hup

# Ctrl+D では終了しないようになる（exit, logout などを使う）
#setopt ignore_eof

# コマンドラインでも # 以降をコメントと見なす
setopt interactive_comments

# auto_list の補完候補一覧で、ls -F のようにファイルの種別をマーク表示
setopt list_types

# 内部コマンド jobs の出力をデフォルトで jobs -l にする
setopt long_list_jobs

# コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt magic_equal_subst

# メールスプール $MAIL が読まれていたらワーニングを表示する
#setopt mail_warning

# ファイル名の展開でディレクトリにマッチした場合末尾に / を付加する
setopt mark_dirs

# 補完候補が複数ある時、一覧表示 (auto_list) せず、すぐに最初の候補を補完する
#setopt menu_complete

# 複数のリダイレクトやパイプなど、必要に応じて tee や cat の機能が使われる
setopt multios

# ファイル名の展開で、辞書順ではなく数値的にソートされるようになる
setopt numeric_glob_sort

# コマンド名に / が含まれているとき PATH 中のサブディレクトリを探す
#setopt path_dirs

# 8 ビット目を通すようになり、日本語のファイル名などを見れるようになる
setopt print_eight_bit

# 戻り値が 0 以外の場合終了コードを表示する
#setopt print_exit_value

# ディレクトリスタックに同じディレクトリを追加しないようになる
setopt pushd_ignore_dups

# pushd を引数なしで実行した場合 pushd $HOME と見なされる
#setopt pushd_to_home

# rm * などの際、本当に全てのファイルを消して良いかの確認しないようになる
#setopt rm_star_silent

# rm_star_silent の逆で、10 秒間反応しなくなり、頭を冷ます時間が与えられる
#setopt rm_star_wait

# for, repeat, select, if, function などで簡略文法が使えるようになる
setopt short_loops

# デフォルトの複数行コマンドライン編集ではなく、１行編集モードになる
#setopt single_line_zle

# コマンドラインがどのように展開され実行されたかを表示するようになる
#setopt xtrace

# シェルのプロセスごとに履歴を共有
setopt share_history

# history (fc -l) コマンドをヒストリリストから取り除く。
setopt hist_no_store

# 文字列末尾に改行コードが無い場合でも表示する
unsetopt promptcr

#コピペの時rpromptを非表示する
setopt transient_rprompt

# cd -[tab] でpushd
setopt autopushd

# 端末殺しても子プロセスにSIGHUP送らせない
setopt nocheckjobs
#}}}

# utilities {{{
## cd on screen
source ~/.zsh/cdd
function chpwd() {
  _reg_pwd_screennum
  ls -lhavF
}

# Private IP 表示＆コピー
function getip() {
  ifconfig | ruby -ane 'puts $F[1] if $_ =~ /inet /' |
    tee /dev/stderr | pbcopy
}
# Global IP 表示＆コピー
function getexip() {
  curl -L -s --max-time 10 http://checkip.dyndns.org | egrep -o -m 1 '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}' |
    tee /dev/stderr | pbcopy
}

## CPU 使用率の高い方から8つ
function pst() {
  #ps aux | head -n 1
  #ps aux | sort -r -n +1 | grep -v "ps aux" | grep -v grep | head -n 8
  ps aux -r | head -8
}
## メモリ占有率の高い方から8つ
function psm() {
  #ps aux | head -n 1
  #ps aux | sort -r -n +3 | grep -v "ps aux" | grep -v grep | head -n 8
  ps -eo rss,vsz,args -m | head -8
}
## 全プロセスから引数の文字列を含むものを grep
function psg() {
  ps aux | head -n 1                                 # ラベルを表示
  ps aux | grep $* | grep -v "ps aux" | grep -v grep # grep プロセスを除外
}

## 引数のファイルを euc-LF や sjis-CR+LF に変換
function euc() {
  for i in $@; do;
    nkf -e -Lu $i >! /tmp/euc.$$ # -Lu :改行を LF にする
    mv -f /tmp/euc.$$ $i
  done;
}
function sjis() {
  for i in $@; do;
    nkf -s -Lw $i >! /tmp/euc.$$ # -Lu :改行を CR+LF にする
    mv -f /tmp/euc.$$ $i
  done;
}
# }}}

# obsolete {{{
# 指定されたディレクトリ以下をgrep
#function search() { 
#  dir=.
#  file=*
#  case $# in
#    0)
#    echo "usage: search STRING [DIR [FILE]]"
# exit 1
#    ;;
#    1) 
#    string=$1
#    ;;
#    2)
#    string=$1
#    dir=$2
#    ;;
#    3)
#    string=$1
#    dir=$2
#    file=$3
#    ;;
#  esac  
#  find $dir -name "$file" -exec grep -IHn $string {} \; ;
#}

#
# JDK の version 変更というか切り替え
# 引数は 1.5 とか 1.6 とか
#
#function jdk() {
#  cd /System/Library/Frameworks/JavaVM.framework/Versions
#  sudo rm CurrentJDK && sudo ln -s $1 CurrentJDK
#  cd -
#  java -version
#}# }}}

