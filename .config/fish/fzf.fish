function fzf-git-branch
  if not test -d .git
    return
  end
  set -l current_line (commandline)
  set -l trimmed_line (string trim "$current_line")
  set -l branch (git --no-pager branch -a | grep -v HEAD |
      _fzf_wrapper --exit-0 --info=hidden --no-multi --prompt="branch> " \
          --preview-window="right,65%" \
          --preview "echo {} | sed -e 's/^.* //g' | xargs git lgn --color=always" |
      head -n1 |
      sed -e "s/^.* //g" -e "s#remotes/[^/]*/##")
  if test -n "$branch"
    if test -z "$trimmed_line"
      git switch "$branch"
    else
      commandline -i "$branch"
    end
  end
  commandline -f repaint
end

function fzf-z-search
  set -l query (commandline)
  z -lr |
      _fzf_wrapper --exit-0 --print0 --no-multi --query="$query" --prompt="z> " \
          --preview-window="right,50%" \
          --preview="_fzf_preview_file (echo -n {} | cut -c 12- | tr -d '\n')" |
      cut -c 12- |
      read -l recent
  if [ $recent ]
    cd $recent
    commandline -r ''
  end
  commandline -f repaint
end

function fzf-ssh
  set -l query (commandline)
  cat ~/.ssh/**/config | grep 'Host ' | grep -v '*' | cut -d ' ' -f2 |
    _fzf_wrapper --exit-0 --no-multi --query="$query" --prompt="ssh> " |
    read -l host
  if [ $host ]
    commandline "ssh $host"
  end
  commandline -f repaint
end

function fzf-docker
  set -l query (commandline)
  docker ps --format "{{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Command}}\t{{.RunningFor}}" |
    _fzf_wrapper --exit-0 --no-multi --query="$query" --prompt="docker> " |
    cut -f 1 |
    read -l container
  if [ $container ]
    commandline -r "docker exec -it $container sh"
  end
  commandline -f repaint
end

function fzf-tmux-windows
  set -l query (commandline)
  tmux list-windows -F '#{window_index}: #{window_name} #{window_flags} (#{pane_current_path})' |
    _fzf_wrapper --exit-0 --no-multi --query="$query" --prompt="tmux> " |
    cut -d':' -f1 | read -l win
  if [ $win ]
    tmux select-window -t $win
  end
  commandline -f repaint
end

function fzf-project
  set -f dir (eval echo -- $FZF_PROJECTS_ROOT)
  set -f current_line (commandline)
  set -f query ""
  if not string match -q "* " "$current_line"
    set -f words (string split " " "$current_line")
    if test (count $words) -gt 0
      set query $words[-1]
    end
  end  
  fd -d2 -td --base-directory $dir |
      _fzf_wrapper --exit-0 --print0 --no-multi --query="$query" --prompt="project> " \
          --preview-window="right,50%" \
          --preview="_fzf_preview_file $dir/{}" |
      read -l project_dir
  if [ $project_dir ]
    if test -n "$query"
      set -f new_line (string replace -r "$query\$" "$dir/$project_dir" "$current_line")
      commandline -r "$new_line"
    else
      commandline -i "$dir/$project_dir"
    end
  end
  commandline -f repaint
end

bind \co    fzf-z-search
bind \cx\cb fzf-git-branch
bind \cx\cs fzf-ssh
bind \cx\cd fzf-docker
bind \cx\cw fzf-tmux-windows
bind \cx\ce fzf-project

set -x FZF_DEFAULT_OPTS '--cycle --layout=reverse --height=90% --preview-window=wrap --marker="*"'
set -x FZF_TMUX_OPTS '-p'
set -x fzf_history_time_format "%Y-%m-%d %H:%M:%S"
