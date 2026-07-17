function herdr_tabs_picker
    command -sq jq; or return 1

    set -l data_dir (command mktemp -d /tmp/herdr-tabs-picker.XXXXXX)
    or return 1

    command herdr tab list >"$data_dir/tabs.json"
    or begin
        command rm -rf "$data_dir"
        return 1
    end

    command herdr workspace list >"$data_dir/workspaces.json"
    or begin
        command rm -rf "$data_dir"
        return 1
    end

    command herdr pane list >"$data_dir/panes.json"
    or begin
        command rm -rf "$data_dir"
        return 1
    end

    set -l pane_filter '
        [
            .result.panes[]?
            | select(.tab_id == $tab_id)
        ] as $panes
        | (([$panes[] | select(.focused)] | first) // $panes[0])
        | .pane_id // empty
    '
    set -l preview_command "pane_id=\$(jq -r --arg tab_id {1} '$pane_filter' $data_dir/panes.json); test -n \"\$pane_id\" && command herdr pane read \"\$pane_id\" --source visible --lines \"\${FZF_PREVIEW_LINES:-20}\" --format ansi"

    set -l selected (
        command jq -r --slurpfile workspaces "$data_dir/workspaces.json" '
            .result.tabs[]
            | . as $tab
            | ([$workspaces[0].result.workspaces[] | select(.workspace_id == $tab.workspace_id)] | first) as $workspace
            | [
                .tab_id,
                ($workspace.label // .workspace_id),
                ((.number | tostring) + ": " + (.label // "")),
                ((.pane_count | tostring) + " panes"),
                (.agent_status // "unknown"),
                (if .focused then "*" else "" end)
            ]
            | @tsv
        ' "$data_dir/tabs.json" |
            command fzf --exit-0 --no-multi --prompt="herdr tabs> " --height=100% --margin=0 --padding=0 --border \
                --delimiter '\t' --with-nth=2.. \
                --preview="$preview_command" --preview-window=down:85%:nowrap \
                --preview-label="pane output" --with-shell='sh -c'
    )
    set -l picker_status $status
    command rm -rf "$data_dir"

    if test $picker_status -ne 0
        return $picker_status
    end

    if test -z "$selected"
        return 0
    end

    set -l fields (string split \t -- "$selected")
    if test -z "$fields[1]"
        return 1
    end

    herdr tab focus "$fields[1]" >/dev/null
end
