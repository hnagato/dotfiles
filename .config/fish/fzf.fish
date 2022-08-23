function fzf-git-co-branch
  set -l query (commandline)
  git --no-pager branch -a | grep -v HEAD |
      fzf --exit-0 --info=hidden --no-multi --prompt="branch> " --query="$query" \
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
  z -l |
      cut -c 12- |
      fzf --exit-0 --print0 --no-multi --query="$query" --prompt="z> " \
          --preview-window="right,50%" --preview="echo -n {} | xargs -0 exa -la" |
      read -lz recent
  if [ $recent ]
    cd $recent
    commandline -r ''
    commandline -f repaint
  end
end

bind \co    fzf-z-search
bind \cx\cb fzf-git-co-branch

# patrickf1/fzf.fish
fzf_configure_bindings --directory=\cx\cf
