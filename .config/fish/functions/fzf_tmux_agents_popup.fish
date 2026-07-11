function fzf_tmux_agents_popup
    command -sq tmux; or return 1
    command -sq fzf; or return 1
    command -sq fish; or return 1

    set -l client_name (tmux display-message -p '#{client_name}' 2>/dev/null)
    test -n "$client_name"; or return 1

    set -l list_script "$HOME/.config/tmux/scripts/coding-agent-list.fish"
    set -l reporter "$HOME/.config/tmux/scripts/coding-agent-state.sh"
    test -f "$list_script"; or return 1
    test -x "$reporter"; or return 1

    set -l reload_prefix (string join ' ' -- fish --no-config (string escape -- "$list_script"))
    set -l selected (
        fish --no-config "$list_script" all |
            fzf --ansi --no-multi --no-sort \
                --height=100% \
                --delimiter=\t \
                --with-nth=3,4,5,6 \
                --nth=3,4,5,6 \
                --track \
                --id-nth=10 \
                --prompt='agents/all> ' \
                --header='Alt-A all  Alt-B blocked  Alt-D done  Alt-W working  Alt-I idle' \
                --bind="alt-a:reload($reload_prefix all)+change-prompt(agents/all> )" \
                --bind="alt-b:reload($reload_prefix blocked)+change-prompt(agents/blocked> )" \
                --bind="alt-d:reload($reload_prefix done)+change-prompt(agents/done> )" \
                --bind="alt-w:reload($reload_prefix working)+change-prompt(agents/working> )" \
                --bind="alt-i:reload($reload_prefix idle)+change-prompt(agents/idle> )" \
                --preview='tmux capture-pane -p -t {7} -S -80 2>/dev/null' \
                --preview-window=right:60%:wrap \
                --border
    )

    test -n "$selected"; or return 0

    set -l fields (string split \t -- "$selected")
    test (count $fields) -eq 11; or return 1

    set -l pane_id "$fields[7]"
    set -l window_id "$fields[8]"
    set -l session_id "$fields[9]"
    set -l target "$session_id:$window_id.$pane_id"

    tmux switch-client -c "$client_name" -t "$target" >/dev/null; or return 1
    "$reporter" seen "$pane_id"
end
