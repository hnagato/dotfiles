function herdr_tabs_picker
    command -sq jq; or return 1

    set -l workspace_arg
    if set -q HERDR_ACTIVE_WORKSPACE_ID; and test -n "$HERDR_ACTIVE_WORKSPACE_ID"
        set workspace_arg --workspace "$HERDR_ACTIVE_WORKSPACE_ID"
    end

    set -l selected (
        herdr tab list $workspace_arg |
            jq -r '.result.tabs[] | [.tab_id, ((.number | tostring) + ": " + (.label // "")), ((.pane_count | tostring) + " panes"), (.agent_status // "unknown"), (if .focused then "*" else "" end)] | @tsv' |
            fzf --exit-0 --no-multi --prompt="herdr tabs> " --height=~50% --border
    )

    if test -z "$selected"
        return 0
    end

    set -l fields (string split \t -- "$selected")
    if test -z "$fields[1]"
        return 1
    end

    herdr tab focus "$fields[1]" >/dev/null
end
