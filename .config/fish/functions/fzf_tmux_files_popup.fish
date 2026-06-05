function fzf_tmux_files_popup
    # parent pane ID stored in tmux buffer by the key binding before popup opens
    set -l parent_pane (tmux show-buffer -b _fzf_parent_pane 2>/dev/null | string trim)

    # Detect if parent pane is running an AI coding tool → prefix paths with '@'
    set -l at_prefix_mode false
    if test -n "$parent_pane"
        set -l pane_cmd (tmux display-message -t "$parent_pane" -p '#{pane_current_command}' 2>/dev/null)
        if string match -qr 'claude|gemini|codex|copilot' -- "$pane_cmd"
            set at_prefix_mode true
        end
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

    set -l output ""
    if test "$at_prefix_mode" = true
        for path in $selected
            set output "$output@$path "
        end
    else
        for path in $selected
            set output "$output"(string escape -- $path)" "
        end
    end

    tmux send-keys -l -- "$output"
end
