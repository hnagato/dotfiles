function update_tools --on-event fish_prompt
  set -l current_timestamp (date '+%s')
  set -l last_run_timestamp $__fish_update_tools_timestamp
  set -l min_interval_seconds (math "8 * 60 * 60")

  # Execute only on first run or when 8+ hours have passed
  if test -z "$last_run_timestamp"; or test (math "$current_timestamp - $last_run_timestamp") -ge $min_interval_seconds
    set -l lock_file /tmp/fish_update_tools_(id -u)

    # PID-based validation of existing lock file
    if test -f $lock_file
      set -l lock_pid (cat $lock_file 2>/dev/null)
      
      # Remove old lock file if PID is not numeric
      if not string match -qr '^\d+$' -- $lock_pid
        echo "Removing lock file with invalid PID: $lock_file" >&2
        rm -f $lock_file
      # Remove old lock file if process no longer exists
      else if not kill -0 $lock_pid 2>/dev/null
        echo "Removing lock file of terminated process ($lock_pid): $lock_file" >&2
        rm -f $lock_file
      end
    end

    # Remove lock files older than 8 hours
    find /tmp -name "fish_update_tools_*" -mmin +480 -delete 2>/dev/null

    # Execute only if lock file doesn't exist
    if not test -f $lock_file
      # Record current process ID in lock file
      echo $fish_pid > $lock_file
      
      ~/.local/bin/update
      if test $status -eq 0
        set -U __fish_update_tools_timestamp $current_timestamp
      else
        echo "Failed to update (exit code: $status)" >&2
      end
      
      rm -f $lock_file
    end
  end
end

