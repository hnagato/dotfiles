function __herdr_target_pane_id
    if set -q HERDR_ACTIVE_PANE_ID; and test -n "$HERDR_ACTIVE_PANE_ID"
        echo "$HERDR_ACTIVE_PANE_ID"
        return 0
    end

    command -sq jq; or return 1

    herdr pane current --current 2>/dev/null | jq -r '.result.pane.pane_id // empty'
end
