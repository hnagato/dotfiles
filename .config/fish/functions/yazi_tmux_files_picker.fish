function yazi_tmux_files_picker
    # parent pane ID stored in tmux buffer by the key binding before this window opens
    set -l parent_pane (tmux show-buffer -b _yazi_parent_pane 2>/dev/null | string trim)

    # Detect if parent pane is running an AI coding tool → prefix paths with '@'
    set -l at_prefix_mode false
    if test -n "$parent_pane"
        set -l pane_cmd (tmux display-message -t "$parent_pane" -p '#{pane_current_command}' 2>/dev/null)
        if string match -qr 'claude|gemini|codex|copilot' -- "$pane_cmd"
            set at_prefix_mode true
        end
    end

    # Use a /tmp template (not `mktemp -t`) so a stale $TMPDIR inherited by a
    # long-lived tmux server cannot break chooser mode and fall back to nvim.
    set -l chooser_file (mktemp /tmp/yazi-chooser.XXXXXX)
    if test -z "$chooser_file"
        return 1
    end

    command yazi --chooser-file="$chooser_file"

    set -l selected (string split -- \n (string trim (cat "$chooser_file")) | string match -vr '^$')
    rm -f "$chooser_file"

    if not set -q selected[1]
        # nothing chosen → just restore focus to the original window/pane
        if test -n "$parent_pane"
            tmux select-window -t "$parent_pane" 2>/dev/null
            tmux select-pane -t "$parent_pane" 2>/dev/null
        end
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

    if test -n "$parent_pane"
        tmux send-keys -t "$parent_pane" -l -- "$output"
        tmux select-window -t "$parent_pane" 2>/dev/null
        tmux select-pane -t "$parent_pane" 2>/dev/null
    else
        tmux send-keys -l -- "$output"
    end
end
