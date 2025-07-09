function git --wraps=git --description 'Wrap git to run confirm-pam on --no-verify option'
    set -l no_verify 0
    set -l target_cmd 0
    
    for arg in $argv
        switch $arg
            case commit push
                set target_cmd 1
            case --no-verify -n
                set no_verify 1
        end
    end
    
    if test $no_verify -eq 1 -a $target_cmd -eq 1
        if not confirm-pam "Dangerous --no-verify option. Continue?"
            echo "❌ Authentication failed."
            return 1
        end
    end
    
    command git $argv
end
