function __dotfiles_start_update_in_herdr
    command -sq herdr; or return 1
    command -sq jq; or return 1
    test -n "$HERDR_WORKSPACE_ID"; or return 1

    set -l create_result (command herdr tab create \
        --workspace "$HERDR_WORKSPACE_ID" \
        --cwd "$PWD" \
        --label update \
        --no-focus 2>/dev/null)
    or return 1

    set -l tab_id (printf '%s\n' $create_result | jq -r '.result.tab.tab_id // empty' 2>/dev/null)
    set -l pane_id (printf '%s\n' $create_result | jq -r '.result.root_pane.pane_id // empty' 2>/dev/null)

    if test -z "$tab_id"; or test -z "$pane_id"
        test -n "$tab_id"; and command herdr tab close "$tab_id" >/dev/null 2>&1
        return 1
    end

    set -l update_command "command herdr tab rename \$HERDR_TAB_ID update >/dev/null 2>&1; __dotfiles_update_tools; set -l exit_code \$status; if test \$exit_code -eq 0; echo 'Update completed successfully'; else; echo 'Update failed (exit code: '\$exit_code')'; end"

    if command herdr pane run "$pane_id" "$update_command" >/dev/null 2>&1
        return 0
    end

    command herdr tab close "$tab_id" >/dev/null 2>&1
    return 1
end

function update_tools --on-event fish_prompt
    set -l current_date (date '+%Y-%m-%d')
    set -l current_hour (date '+%H')
    set -l last_run $__fish_update_tools_timestamp
    set -l last_run_date

    if string match -qr '^\d{4}-\d{2}-\d{2}$' -- "$last_run"
        set last_run_date $last_run
    else if string match -qr '^\d+$' -- "$last_run"
        set last_run_date (date -r $last_run '+%Y-%m-%d' 2>/dev/null)
    end

    if test $current_hour -ge 9; and test "$last_run_date" != "$current_date"
        set -l lock_file /tmp/fish_update_tools_(id -u)

        if test -f $lock_file
            set -l lock_pid (cat $lock_file 2>/dev/null)

            if not string match -qr '^\d+$' -- $lock_pid
                echo "Removing lock file with invalid PID: $lock_file" >&2
                rm -f $lock_file
            else if not kill -0 $lock_pid 2>/dev/null
                echo "Removing lock file of terminated process ($lock_pid): $lock_file" >&2
                rm -f $lock_file
            end
        end

        find /tmp -name "fish_update_tools_*" -mmin +480 -delete 2>/dev/null

        if not test -f $lock_file
            echo $fish_pid >$lock_file

            if __dotfiles_start_update_in_herdr
                set -U __fish_update_tools_timestamp $current_date
            else
                __dotfiles_update_tools
                set -l exit_code $status
                set -U __fish_update_tools_timestamp $current_date
                if test $exit_code -eq 0
                    echo "Update completed successfully" >&2
                else
                    echo "Update failed (exit code: $exit_code)" >&2
                end
            end

            rm -f $lock_file
        end
    end
end
