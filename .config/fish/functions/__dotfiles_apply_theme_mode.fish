function __dotfiles_set_theme_var --argument-names scope name
    set -l values $argv[3..-1]

    switch $scope
        case universal
            set -e -g $name 2>/dev/null
            set -l current_value (string join -- \n $$name)
            set -l next_value (string join -- \n $values)
            if test "$current_value" = "$next_value"
                return 0
            end
            set -Ux $name $values
        case global
            set -gx $name $values
        case '*'
            echo "__dotfiles_set_theme_var: unknown scope: $scope" >&2
            return 2
    end
end

function __dotfiles_apply_theme_mode --description 'Apply dotfiles theme variables'
    set -l mode
    set -l scope global

    for arg in $argv
        switch $arg
            case light dark
                set mode $arg
            case --universal
                set scope universal
            case '*'
                echo "__dotfiles_apply_theme_mode: unknown argument: $arg" >&2
                return 2
        end
    end

    if test -z "$mode"
        set mode (__dotfiles_theme_mode)
    end

    set -l nvim_theme
    set -l tmux_theme
    set -l delta_features
    set -l lazygit_config
    set -l leaf_theme

    switch $mode
        case light
            set nvim_theme flexoki-light
            set tmux_theme light
            set delta_features flexoki-light
            set lazygit_config "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme-light.yml"
            set leaf_theme "$HOME/.config/leaf/flexoki-light.toml"
        case dark
            set nvim_theme kanagawa-dragon
            set tmux_theme dark
            set delta_features kanagawa-dragon
            set lazygit_config "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme-dark.yml"
            set leaf_theme "$HOME/.config/leaf/kanagawa-dragon.toml"
        case '*'
            echo "__dotfiles_apply_theme_mode: unsupported theme mode: $mode" >&2
            return 2
    end

    __dotfiles_set_theme_var $scope DOTFILES_THEME_MODE $mode
    __dotfiles_set_theme_var $scope BAT_THEME auto:system
    __dotfiles_set_theme_var $scope BAT_THEME_LIGHT flexoki-light
    __dotfiles_set_theme_var $scope BAT_THEME_DARK kanagawa-dragon
    __dotfiles_set_theme_var $scope NVIM_THEME $nvim_theme
    __dotfiles_set_theme_var $scope TMUX_THEME $tmux_theme
    __dotfiles_set_theme_var $scope DELTA_FEATURES $delta_features
    __dotfiles_set_theme_var $scope LG_CONFIG_FILE $lazygit_config
    __dotfiles_set_theme_var $scope LEAF_THEME $leaf_theme
    __dotfiles_set_theme_var $scope FZF_DEFAULT_OPTS "--color=$mode" --cycle --layout=reverse --height=90% --preview-window=wrap '--marker=*'
end
