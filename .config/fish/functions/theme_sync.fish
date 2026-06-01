function theme_sync --description 'Sync dotfiles theme with the current macOS appearance'
    set -l mode

    for arg in $argv
        switch $arg
            case -h --help
                echo 'usage: theme_sync [light|dark]'
                return 0
            case light dark
                set mode $arg
            case '*'
                echo "theme_sync: unknown argument: $arg" >&2
                return 2
        end
    end

    if test -z "$mode"
        set mode (__dotfiles_theme_mode)
    end

    __dotfiles_apply_theme_mode $mode --universal
    or return $status

    if not type -q tmux
        return 0
    end

    set -l has_tmux_server false
    if test -n "$TMUX"
        set has_tmux_server true
    else if tmux has-session >/dev/null 2>/dev/null
        set has_tmux_server true
    end

    if test "$has_tmux_server" != true
        return 0
    end

    set -l theme_vars DOTFILES_THEME_MODE BAT_THEME BAT_THEME_LIGHT BAT_THEME_DARK NVIM_THEME TMUX_THEME DELTA_FEATURES HUNK_THEME LG_CONFIG_FILE GIT_PAGER FZF_DEFAULT_OPTS
    for name in $theme_vars
        if set -q $name
            set -l value (string join -- ' ' $$name)
            tmux set-environment -g $name "$value"
            or return $status
        end
    end

    set -l theme_file "$HOME/.config/tmux/themes/$mode.conf"
    if not test -f "$theme_file"
        echo "theme_sync: tmux theme file not found: $theme_file" >&2
        return 1
    end

    tmux source-file "$theme_file"
    or return $status

    set -l tmux_dotbar_script "$HOME/.local/share/tmux/plugins/tmux-dotbar/dotbar.tmux"
    if test -f "$tmux_dotbar_script"
        command bash "$tmux_dotbar_script"
        or return $status
    end

    tmux refresh-client -S 2>/dev/null
end
