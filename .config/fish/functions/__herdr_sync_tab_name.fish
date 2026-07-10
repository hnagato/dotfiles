function __herdr_sync_tab_name --on-variable PWD
    set -l tab_id (command herdr pane current --current 2>/dev/null | command jq -r '.result.pane.tab_id // empty' 2>/dev/null)
    test -n "$tab_id"
    or return

    set -l tab_name (path basename "$PWD")
    if test -z "$tab_name"
        set tab_name /
    end

    command herdr tab rename "$tab_id" "$tab_name" >/dev/null 2>&1
end
