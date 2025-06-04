function fish_greeting
  if test -z "$FZF_PROJECTS_ROOT"
    eval (op signin)

    set -U FZF_PROJECTS_ROOT (op item get "shell-env" --format=json | jq -r '.fields[] | select(.label=="FZF_PROJECTS_ROOT").value')
    set -U HOMEBREW_GITHUB_API_TOKEN (op item get "shell-env" --format=json | jq -r '.fields[] | select(.label=="HOMEBREW_GITHUB_API_TOKEN").value')
  end
end
