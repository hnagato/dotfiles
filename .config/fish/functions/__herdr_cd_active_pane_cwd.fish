function __herdr_cd_active_pane_cwd
    if set -q HERDR_ACTIVE_PANE_CWD; and test -d "$HERDR_ACTIVE_PANE_CWD"
        cd "$HERDR_ACTIVE_PANE_CWD"
    end
end
