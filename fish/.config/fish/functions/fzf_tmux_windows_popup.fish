function fzf_tmux_windows_popup
    tmux list-windows -F '#{window_index}: #{window_name} #{window_flags} (#{pane_current_path})' |
        sed "s|$HOME|~|g" |
        fzf --exit-0 --no-multi --prompt="tmux> " --height=~50% --border |
        cut -d':' -f1 | read -l win
    if [ $win ]
        tmux select-window -t $win
    end
end