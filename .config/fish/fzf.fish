function fzf-git-co-branch
  if not test -d .git
    return
  end
  set -l query (commandline)
  git --no-pager branch -a | grep -v HEAD |
      _fzf_wrapper --exit-0 --info=hidden --no-multi --prompt="branch> " --query="$query" \
          --preview-window="right,65%" \
          --preview "echo {} | sed -e 's/^.* //g' | xargs git lgn --color=always" |
      head -n1 |
      read -l branch
  if test -n $branch
    git checkout (echo "$branch" | sed -e "s/^.* //g" -e "s#remotes/[^/]*/##")
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

function _fzf_open_in_dir
  set -f app $argv[1]
  set -f dir (eval echo -- $argv[2])
  set -f query (commandline)
  fd -d2 -td --base-directory $dir |
      _fzf_wrapper --exit-0 --print0 --no-multi --query="$query" --prompt="$app> " \
          --preview-window="right,50%" \
          --preview="_fzf_preview_file $dir/{}" |
      read -l project_dir
  if [ $project_dir ]
    commandline "$app $dir/$project_dir"
  end
  commandline -f repaint
end

function fzf-idea
  _fzf_open_in_dir idea $FZF_PROJECTS_ROOT
end

function fzf-code
  _fzf_open_in_dir code $FZF_PROJECTS_ROOT
end

bind \co    fzf-z-search
bind \cx\cb fzf-git-co-branch
bind \cx\cs fzf-ssh
bind \cx\cd fzf-docker
bind \cx\cw fzf-tmux-windows
bind \cx\ci fzf-idea
bind \cx\ce fzf-code
# fzf_configure_bindings では複合キーを指定できない
bind \cx\cf _fzf_search_directory

# patrickf1/fzf.fish
fzf_configure_bindings --history=\cr

set -x FZF_DEFAULT_OPTS '--cycle --layout=reverse --height=90% --preview-window=wrap --marker="*"'
set -x FZF_TMUX_OPTS '-p'
set -x fzf_history_time_format "%Y-%m-%d %H:%M:%S"

