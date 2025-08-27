function fzf_docker
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
