function fzf_tmux_windows
  set -l query (commandline)
  tmux list-windows -F '#{window_index}: #{window_name} #{window_flags} (#{pane_current_path})' |
    _fzf_wrapper --exit-0 --no-multi --query="$query" --prompt="tmux> " |
    cut -d':' -f1 | read -l win
  if [ $win ]
    tmux select-window -t $win
  end
  commandline -f repaint
end
