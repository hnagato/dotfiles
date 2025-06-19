function fzf_ssh
  set -l query (commandline)
  cat ~/.ssh/**/config | grep 'Host ' | grep -v '*' | cut -d ' ' -f2 |
    _fzf_wrapper --exit-0 --no-multi --query="$query" --prompt="ssh> " |
    read -l host
  if [ $host ]
    commandline "ssh $host"
  end
  commandline -f repaint
end
