function update_tools --on-event fish_prompt
  set -l today (date '+%Y%m%d')

  if test "$__fish_update_tools_date" != "$today"
    set -l lock_file /tmp/fish_update_tools_(id -u)

    if not test -f $lock_file
      touch $lock_file
      set -U __fish_update_tools_date $today

      brew upgrade --greedy
      mas upgrade
      gh extension upgrade --all
      ~/.local/share/tmux/plugins/tpm/bin/update_plugins all
      cargo install-update -a
      npm update -g
      fisher update
      fish_update_completions
      rm -f '$lock_file'
    end
  end
end

