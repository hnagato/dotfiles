function herdr_yazi_files_picker
    __herdr_cd_active_pane_cwd

    set -l target_pane (__herdr_target_pane_id)
    if test -z "$target_pane"
        return 1
    end

    set -l chooser_file (mktemp /tmp/yazi-herdr-chooser.XXXXXX)
    if test -z "$chooser_file"
        return 1
    end

    command yazi --chooser-file="$chooser_file"

    set -l selected (string split -- \n (string trim (cat "$chooser_file")) | string match -vr '^$')
    rm -f "$chooser_file"

    if not set -q selected[1]
        return 0
    end

    __herdr_send_paths_to_pane "$target_pane" $selected
end
