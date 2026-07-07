function __dotfiles_has_broken_nested_git_checkout --argument-names plugin
    for nested_git in (find "$plugin" -mindepth 2 -name .git -type f 2>/dev/null)
        set -l nested_dir (dirname "$nested_git")

        if not git -C "$nested_dir" status --short --ignore-submodules=dirty >/dev/null 2>&1
            return 0
        end
    end

    return 1
end

function __dotfiles_repair_nvim_lazy_checkouts
    set -l lazy_dir "$HOME/.local/share/nvim/lazy"

    if not test -d "$lazy_dir"
        return 0
    end

    for plugin in "$lazy_dir"/*
        if not test -e "$plugin/.git"
            continue
        end

        set -l plugin_name (basename "$plugin")

        if string match -q '*.broken-*' -- "$plugin_name"
            continue
        end

        set -l tracked_status (git -C "$plugin" status --short --untracked-files=no --ignore-submodules=dirty 2>/dev/null)
        set -l git_status $status

        if test $git_status -ne 0
            echo "Removing broken Neovim Lazy checkout: $plugin_name" >&2
            command rm -rf -- "$plugin"; or return $status
            continue
        end

        if test (count $tracked_status) -gt 0
            echo "Removing Neovim Lazy checkout with dirty tracked files: $plugin_name" >&2
            command rm -rf -- "$plugin"; or return $status
            continue
        end

        if __dotfiles_has_broken_nested_git_checkout "$plugin"
            echo "Removing Neovim Lazy checkout with broken nested git metadata: $plugin_name" >&2
            command rm -rf -- "$plugin"; or return $status
        end
    end
end
