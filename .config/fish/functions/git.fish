function git --wraps=git --description "Wrap git to run confirm-pam on --no-verify option"
  set -l has_no_verify 0
  set -l is_commit_or_push 0

  for arg in $argv
    switch $arg
    case commit push
      set is_commit_or_push 1
    case --no-verify -n
      set has_no_verify 1
    end
  end

  if test $has_no_verify -eq 1 -a $is_commit_or_push -eq 1
    if not confirm-pam "Dangerous --no-verify option. Continue?"
      echo "❌ Authentication failed."
      return 1
    end
  end

  command git $argv
end
