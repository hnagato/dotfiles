# env
set fish_cursor_unknown block
set fish_greeting

set -gx EDITOR code
set -gx PAGER less
set -gx JAVA_HOME ~/.sdkman/candidates/java/current
set -gx NODE_PATH /usr/local/lib/node_modules
set -gx GOPATH ~/.local/lib/go

# aliases & abbrs
alias t='tmux attach-session -d || tmux new' 
abbr -a lf ls -lhavGF
abbr -a h history

abbr -a gst git status
abbr -a gco git checkout
abbr -a gsb git stash -b
abbr -a gfa git fetch --all
abbr -a gl  git l
abbr -a ga  git add
abbr -a gc  git commit -v
abbr -a gb  git branch
abbr -a gd  git diff -ubw
abbr -a gt  git stash

# paths
set fish_user_paths $JAVA_HOME/bin ~/.nodebrew/current/bin ~/bin

# sdk command
function sdk
    bash -c "source $HOME/.sdkman/bin/sdkman-init.sh && sdk $argv"
end

# vim
function vi
    bash -c "/Applications/MacVim.app/Contents/MacOS/Vim $argv"
end

