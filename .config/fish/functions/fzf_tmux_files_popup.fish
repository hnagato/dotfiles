function fzf_tmux_files_popup
    # PARENT_PANE / PARENT_PID are injected by the tmux.conf popup command
    set -l parent_pane "$PARENT_PANE"
    set -l parent_pid "$PARENT_PID"
    if test -z "$parent_pane"
        set parent_pane (tmux display-message -p '#{pane_id}')
    end
    if test -z "$parent_pid"
        set parent_pid (tmux display-message -p '#{pane_pid}')
    end

    # Detect if parent pane is running an AI coding tool → prefix paths with '@'
    set -l at_prefix_mode false
    if pgrep -P "$parent_pid" -f 'claude|gemini|codex|copilot' > /dev/null 2>&1
        set at_prefix_mode true
    end

    set -l selected (
        fd --hidden --follow --type f --type d --exclude .git --exclude .DS_Store --strip-cwd-prefix |
        fzf --exit-0 --multi \
            --height=100% \
            --prompt="Files> " \
            --preview '
                if [ -d {} ]; then
                    eza --all --icons --color=always --tree --level=2 --git-ignore {}
                else
                    bat --color=always --style=numbers --line-range :300 {}
                fi
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

    tmux send-keys -t "$parent_pane" -l -- "$output"
end
