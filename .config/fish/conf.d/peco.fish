function peco
    command peco --layout=bottom-up $argv
end


function peco-git-checkout
    git branch -a |
        grep -v -e '->' -e '*' |
        perl -pe 's/^\h+//g' |
        perl -pe 's#^remotes/origin/##' |
        perl -nle 'print if !$c{$_}++' |
        peco |
        xargs git checkout
    commandline -f repaint
end


function peco-delete-branch
    git branch | peco | read line
    set -l branch_name (echo $line | awk '{print $1}')
    if test "$branch_name" != "*"
        git branch -d $branch_name
        commandline -f repaint
    else
        commandline -f repaint
        echo "Can't delete current branch."
    end
end

function peco-z
    set -l query (commandline)
  
    if test -n $query
        set peco_flags --query "$query"
    end
  
    z -l | peco $peco_flags | awk '{ print $2 }' | read recent
    if [ $recent ]
        cd $recent
        commandline -r ''
        commandline -f repaint
    end
end

set -l srcdir ~/projects/tle

function peco-idea
    set repo (ls $srcdir | peco)
    if test -n "$repo"
        idea $srcdir/(echo $repo)
    end
end

function peco-code
    set repo (ls $srcdir | peco)
    if test -n "$repo"
        code $srcdir/(echo $repo)
    end
end


function fish_user_key_bindings
    bind \cr peco_select_history
    bind \cx\cc peco-code
    bind \cx\ci peco-idea
    bind \cx\cb peco-git-checkout
    bind \cx\cd peco-delete-branch
    bind \cx\co peco-z
end

