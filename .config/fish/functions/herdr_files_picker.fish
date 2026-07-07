function herdr_files_picker
    __herdr_cd_active_pane_cwd

    set -l target_pane (__herdr_target_pane_id)
    if test -z "$target_pane"
        return 1
    end

    set -l selected (
        fd --hidden --follow --type f --type d --exclude .git --exclude .DS_Store --strip-cwd-prefix |
            fzf --exit-0 --multi \
                --height=100% \
                --prompt="Files> " \
                --preview '
                    if [ -d {} ]
                        eza --all --icons --color=always --tree --level=2 --git-ignore {}
                    else
                        bat --color=always --style=numbers --line-range :300 {}
                    end
                ' \
                --preview-window=down:60%:wrap
    )

    if not set -q selected[1]
        return 0
    end

    __herdr_send_paths_to_pane "$target_pane" $selected
end
