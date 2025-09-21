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

# themes
set -gx NVIM_THEME kanagawa-dragon
set -gx BAT_THEME $NVIM_THEME
set -gx TMUX_THEME dark

# fzf
set -gx fzf_fd_opts --hidden --exclude=.git
set -gx fzf_preview_dir_cmd eza -la --color=always --git --ignore-glob .git
set -gx FZF_DEFAULT_OPTS --color=$TMUX_THEME --cycle --layout=reverse --height=90% --preview-window=wrap --marker="*"
set -gx FZF_TMUX_OPTS -p
set -gx fzf_history_time_format "%Y-%m-%d %H:%M:%S"
set -gx FZF_PROJECTS_ROOT ~/projects

# lazygit
set -gx LG_CONFIG_FILE $HOME/.config/lazygit/config.yml

# paths
fish_add_path -m $HOME/.local/bin
fish_add_path $HOME/.rd/bin

if status is-interactive
    set HOMEBREW_HOME /opt/homebrew
    if test -d $HOMEBREW_HOME/bin
        eval ($HOMEBREW_HOME/bin/brew shellenv)
        fish_add_path $HOMEBREW_HOME/bin $HOMEBREW_HOME/sbin
        if test -d $HOMEBREW_HOME/opt/mysql@8.0
            fish_add_path $HOMEBREW_HOME/opt/mysql@8.0/bin
        end
    end
    if type -q rdctl; and rdctl shell true &>/dev/null
        set -gx DOCKER_HOST "unix://$HOME/.rd/docker.sock"
        set -gx TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE "/var/run/docker.sock"
    end

    if type -q starship
        starship init fish | source
    end

    if type -q mise
        mise activate fish | source
    end

    if type -q pyenv
        pyenv init - | source
    end
end

if test -d $HOME/.cargo/bin
    fish_add_path $HOME/.cargo/bin
end

if test -d $HOME/.bun
    set -gx BUN_INSTALL "$HOME/.bun"
    fish_add_path $BUN_INSTALL/bin
end

abbr -a ... cd ../..
abbr -a .... cd ../../../
abbr -a ll ls -lhavGF
abbr -a e cursor
abbr -a c code
abbr -a i idea
abbr -a cc claude
abbr -a gs git status -sb
abbr -a gco git checkout
abbr -a gfa git fetch --all
abbr -a gl git l
abbr -a ga git add
abbr -a gc git czg ai
abbr -a gb git branch
abbr -a gd git diff -ubw
abbr -a gp git pull
abbr -a lg lazygit
abbr -a vi nvim

if type -q eza
    abbr -a lf eza -la --icons --git --ignore-glob .git
    abbr -a lt eza -la --icons --git --git-ignore -T --ignore-glob .git --level=2
    abbr -a la eza -la --icons --color=never
    abbr -a ls eza --icons --git
end

function psg
    ps -ef | grep -i $argv
end

if test -f "$HOME/.config/op/plugins.sh"
    source "$HOME/.config/op/plugins.sh"
end

function t
    tmux attach-session -d || tmux new
end

function tn
    tmux new-session
end
