set -gx LANG ja_JP.UTF-8
set -gx LC_ALL ja_JP.UTF-8

#set -gx EDITOR 'code --wait'
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx LESS "-RSM~gIsw"
set -gx GPG_TTY $(tty)

# homebrew
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx HOMEBREW_AUTO_UPDATE_SECS 86400

# fzf
set -gx fzf_fd_opts --hidden --exclude=.git
set -gx fzf_preview_dir_cmd eza -la --color=always --git --ignore-glob .git

# paths
if test -d $HOME/bin
  fish_add_path $HOME/bin
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

  if type -q mise
    mise activate fish | source
  end

  if type -q pyenv
    pyenv init - | source
  end
end

# aliases & abbrs
alias t='tmux attach-session -d || tmux new' 
alias tn='tmux new-session'
alias vi='nvim'

abbr -a ...   cd ../..
abbr -a ....  cd ../../../
abbr -a ll    ls -lhavGF
abbr -a e     cursor
abbr -a c     code
abbr -a i     idea
abbr -a cc    claude
abbr -a gs    git status -sb
abbr -a gco   git checkout
abbr -a gfa   git fetch --all
abbr -a gl    git l
abbr -a ga    git add
abbr -a gc    git czg ai emoji
abbr -a gb    git branch
abbr -a gd    git diff -ubw
abbr -a gp    git pull

if type -q eza
  abbr -a lf eza -la --icons --git --ignore-glob .git
  abbr -a lt eza -la --icons --git --git-ignore -T --ignore-glob .git --level=2
  abbr -a la eza -la --icons --color=never
  abbr -a ls eza --icons --git
end

function psg
  ps -ef | grep -i $argv
end

function push-line
  set -l cl (commandline)
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

# testcontainers
if type -q rdctl; and rdctl shell true &>/dev/null
  set -gx DOCKER_HOST "unix://$HOME/.rd/docker.sock"
  set -gx TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE "/var/run/docker.sock"
  set -gx TESTCONTAINERS_HOST_OVERRIDE (rdctl shell ip a show vznat | awk '/inet / {sub("/.*",""); print $2}')
end

if test -f "$HOME/.config/fish/fzf.fish"
  source "$HOME/.config/fish/fzf.fish"
end

if test -f "$HOME/.config/op/plugins.sh"
  source "$HOME/.config/op/plugins.sh"
end

