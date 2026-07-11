function __herdr_send_popup_commandline
    set -l popup_input (commandline | string collect)
    if test -z "$popup_input"
        return 0
    end

    if not set -q HERDR_POPUP_TARGET_PANE_ID; or test -z "$HERDR_POPUP_TARGET_PANE_ID"
        return 1
    end

    command herdr pane send-text "$HERDR_POPUP_TARGET_PANE_ID" "$popup_input" >/dev/null
    or return 1

    commandline --replace ''
    exit
end
