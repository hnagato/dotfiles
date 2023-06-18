# env
set fish_cursor_unknown block
set fish_greeting

# fzf
set -gx fzf_fd_opts --hidden --exclude=.git
set -gx fzf_preview_dir_cmd exa -la --git --ignore-glob .git

# paths
fish_add_path $JAVA_HOME/bin
fish_add_path $HOME/bin
fish_add_path $HOME/bin/onelogin
fish_add_path $HOME/.rd/bin

if status is-interactive
  # homebrew
  if test -d /home/linuxbrew/.linuxbrew
    set HOMEBREW_HOME /home/linuxbrew/.linuxbrew
  else if test -d /opt/homebrew
    set HOMEBREW_HOME /opt/homebrew
  else
    set HOMEBREW_HOME /usr/local
  end
  eval ($HOMEBREW_HOME/bin/brew shellenv)

  # prompt
  starship init fish | source
end

set -gx EDITOR code
set -gx PAGER less
set -gx LESS "-RSM~gIsw"
set -gx JAVA_HOME ~/.sdkman/candidates/java/current
set -gx GPG_TTY $(tty)

# aliases & abbrs
alias t='tmux attach-session -d || tmux new' 
alias tn='tmux new-session'
abbr -a ... cd ../..
abbr -a .... cd ../../../
abbr -a ll ls -lhavGF
abbr -a e code
abbr -a i idea

abbr -a gs  git status -sb
abbr -a gco git checkout
abbr -a gfa git fetch --all
abbr -a gl  git l
abbr -a ga  git add
abbr -a gc  git commit -vS -m
abbr -a gb  git branch
abbr -a gd  git diff -ubw
abbr -a gp  git pull
abbr -a gg  git clone

if type -q exa
  abbr -a lf exa -la --icons --git --ignore-glob .git
  abbr -a lt exa -la --icons --git --git-ignore -T --ignore-glob .git --level=2
  abbr -a la exa -la --icons --color=never
  abbr -a ls exa --icons --git
  set -gx EXA_COLORS "uu=38;5;249:un=38;5;241:gu=38;5;245:gn=38;5;241:da=38;5;245:sn=38;5;7:sb=38;5;7:ur=38;5;3;1:uw=38;5;5;1:ux=38;5;1;1:ue=38;5;1;1:gr=38;5;249:gw=38;5;249:gx=38;5;249:tr=38;5;249:tw=38;5;249:tx=38;5;249:fi=38;5;248:di=38;5;253:ex=38;5;1:xa=38;5;12:*.png=38;5;4:*.jpg=38;5;4:*.gif=38;5;4"
end

function psg
  ps -ef | grep -i $argv
end

source "$HOME/.config/fish/peco.fish"
source "$HOME/.config/fish/fzf.fish"
