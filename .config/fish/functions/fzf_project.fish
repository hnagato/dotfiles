function fzf_project
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
