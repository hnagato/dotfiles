function fzf_z_search
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
