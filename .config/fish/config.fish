# env
set fish_cursor_unknown block

set -gx EDITOR 'code --wait'
set -gx PAGER less
set -gx LESS "-RSM~gIsw"
set -gx JAVA_HOME ~/.sdkman/candidates/java/current
set -gx GPG_TTY $(tty)

# homebrew
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx HOMEBREW_AUTO_UPDATE_SECS 86400

# fzf
set -gx fzf_fd_opts --hidden --exclude=.git
set -gx fzf_preview_dir_cmd eza -la --color=always --git --ignore-glob .git

# paths
if test -d $HOME/bin
  fish_add_path 
end
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.rd/bin
fish_add_path $JAVA_HOME/bin

if status is-interactive
  if test -d /opt/homebrew
    set HOMEBREW_HOME /opt/homebrew
  else
    set HOMEBREW_HOME /usr/local
  end
  if test -d $HOMEBREW_HOME/bin
    eval ($HOMEBREW_HOME/bin/brew shellenv)
    fish_add_path $HOMEBREW_HOME/bin $HOMEBREW_HOME/sbin
    if test -d $HOMEBREW_HOME/opt/mysql@8.0
      fish_add_path $HOMEBREW_HOME/opt/mysql@8.0/bin
    end
  end

  if type -q starship
    starship init fish | source
  end

  if type -q fnm
    fnm env --use-on-cd | source
  end
end

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

abbr -a vi  code

if type -q eza
  abbr -a lf eza -la --icons --git --ignore-glob .git
  abbr -a lt eza -la --icons --git --git-ignore -T --ignore-glob .git --level=2
  abbr -a la eza -la --icons --color=never
  abbr -a ls eza --icons --git
  set -gx EZA_COLORS "uu=38;5;249:un=38;5;241:gu=38;5;245:gn=38;5;241:da=38;5;245:sn=38;5;7:sb=38;5;7:ur=38;5;3;1:uw=38;5;5;1:ux=38;5;1;1:ue=38;5;1;1:gr=38;5;249:gw=38;5;249:gx=38;5;249:tr=38;5;249:tw=38;5;249:tx=38;5;249:fi=38;5;248:di=38;5;253:ex=38;5;1:xa=38;5;12:*.png=38;5;4:*.jpg=38;5;4:*.gif=38;5;4"
end

function psg
  ps -ef | grep -i $argv
end

function push-line
  set cl (commandline)
  commandline -f repaint
  if test -n (string join $cl)
    set -g fish_buffer_stack $cl
    commandline ''
    commandline -f repaint

    function restore_line -e fish_postexec
      commandline $fish_buffer_stack
      functions -e restore_line
      set -e fish_buffer_stack
    end
  end
end

function fish_user_key_bindings
  bind \cs push-line
end

source "$HOME/.config/fish/fzf.fish"

