function herdr_shell_popup
    __herdr_cd_active_pane_cwd

    set -l target_pane (__herdr_target_pane_id)
    if test -z "$target_pane"
        return 1
    end

    set -lx HERDR_POPUP_TARGET_PANE_ID "$target_pane"
    command fish --interactive --init-command 'bind alt-enter __herdr_send_popup_commandline'
end
