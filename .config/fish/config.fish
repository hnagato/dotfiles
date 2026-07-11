set -gx LANG ja_JP.UTF-8
set -gx LC_ALL ja_JP.UTF-8

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less
set -gx DELTA_PAGER 'less -FRX'
set -gx LESS "-RSM~gIsw"

# themes
__dotfiles_apply_theme_mode (__dotfiles_theme_mode) --universal

# fzf
set -gx fzf_fd_opts --hidden --exclude=.git
set -gx fzf_preview_dir_cmd eza -la --color=always --git --ignore-glob .git
set -gx FZF_TMUX_OPTS -p
set -gx fzf_history_time_format "%Y-%m-%d %H:%M:%S"
set -gx FZF_PROJECTS_ROOT ~/projects

# fish greeting
set -gx fish_greeting

# pure prompt
set -g pure_show_numbered_git_indicator true
set -g pure_show_jobs true
set -g pure_separate_prompt_on_error true
set -g pure_show_subsecond_command_duration true
set -g pure_threshold_command_duration 2
set -g pure_color_success green
set -g fish_transient_prompt 1
set -g async_prompt_functions _pure_prompt_git

# paths
fish_add_path -m $HOME/.local/bin

set HOMEBREW_HOME /opt/homebrew
if test -d $HOMEBREW_HOME/bin
    eval ($HOMEBREW_HOME/bin/brew shellenv)
    fish_add_path $HOMEBREW_HOME/bin $HOMEBREW_HOME/sbin
    set -x HOMEBREW_FORBIDDEN_FORMULAE "node python python3 pip npm pnpm yarn openjdk"
    function python3 --description "Run the Python interpreter selected by uv"
        set -l interpreter (uv python find)
        or return $status

        command $interpreter $argv
    end
    alias python python3
    if test -d $HOMEBREW_HOME/opt/mysql@8.0
        fish_add_path $HOMEBREW_HOME/opt/mysql@8.0/bin
    end
end

if type -q git-wt
    git-wt --init fish | source
end

if type -q mise
    mise activate fish | source
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
abbr -a e zed
abbr -a i idea
abbr -a c claude
abbr -a cc claude --continue
abbr -a cr claude --resume
abbr -a cx codex
abbr -a cxr codex --resume
abbr -a gs git status -sb
abbr -a gco git checkout
abbr -a gfa git fetch --all
abbr -a gl git l
abbr -a ga git add
abbr -a gc git czg ai
abbr -a gb git branch
abbr -a gd git diff -ubw
abbr -a gp git pull
abbr -a gr git graph -l
abbr -a lg lazygit

if type -q eza
    abbr -a lf eza -la --icons --git --ignore-glob .git
    abbr -a lt eza -la --icons --git --git-ignore -T --ignore-glob .git --level=2
    abbr -a la eza -la --icons --color=never
    abbr -a ls eza --icons --git
end

function psg
    ps -ef | grep -i $argv
end

function t
    tmux new-session -A -s main
end

function tn
    tmux new-session
end

function vi
    nvim $argv
end

if status is-interactive
    and set -q HERDR_PANE_ID
    and command -sq herdr
    and command -sq jq
    __herdr_sync_tab_name
end
