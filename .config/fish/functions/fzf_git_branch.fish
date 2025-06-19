function fzf_git_branch
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
