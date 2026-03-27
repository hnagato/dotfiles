function fzf_tmux_files_popup
    set -l selected (
        fd --hidden --follow --exclude .git --strip-cwd-prefix |
        fzf --exit-0 --no-multi \
            --prompt="files> " \
            --preview '
                if [ -d {} ]
                    eza --all --icons --color=always --tree --level=2 --git-ignore {}
                else
                    bat --color=always --style=numbers --line-range :300 {}
                end
            ' \
            --preview-window=right:60%
    )

    if test -n "$selected"
        tmux send-keys -l -- "$selected"
    end
end
