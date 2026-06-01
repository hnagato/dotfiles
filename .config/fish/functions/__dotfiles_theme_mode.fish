function __dotfiles_theme_mode --description 'Print the current dotfiles theme mode'
    if test (uname) = Darwin
        if defaults read -g AppleInterfaceStyle >/dev/null 2>/dev/null
            echo dark
        else
            echo light
        end
    else
        echo dark
    end
end
