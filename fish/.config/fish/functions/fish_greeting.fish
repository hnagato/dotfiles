function fish_greeting
    if test -z "$FZF_PROJECTS_ROOT"
        eval (op signin)

        set -U FZF_PROJECTS_ROOT (op item get "shell-env" --format=json | jq -r '.fields[] | select(.label=="FZF_PROJECTS_ROOT").value')
    end
end
