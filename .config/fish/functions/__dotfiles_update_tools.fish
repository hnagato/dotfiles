function __dotfiles_run_update_step
    set -l label $argv[1]
    set -e argv[1]

    echo "==> $label"
    $argv
    set -l exit_code $status

    if test $exit_code -ne 0
        echo "$label failed (exit code: $exit_code)" >&2
        return $exit_code
    end
end

function __dotfiles_update_tools
    __dotfiles_run_update_step "Update Mason packages" nvim --headless -c MasonUpdate -c "sleep 5" -c qall; or return $status
    __dotfiles_run_update_step "Update fisher plugins" fisher update; or return $status
    __dotfiles_run_update_step "Upgrade Homebrew packages" brew upgrade --greedy --no-ask; or return $status
    __dotfiles_run_update_step "Clean Homebrew cache" brew cleanup --prune=all; or return $status
    __dotfiles_run_update_step "Install locked mise tools" mise install --locked; or return $status
    __dotfiles_run_update_step "Upgrade App Store apps" mas upgrade; or return $status
    __dotfiles_run_update_step "Upgrade gh extensions" gh extension upgrade --all; or return $status
    __dotfiles_run_update_step "Update tmux plugins" "$HOME/.local/share/tmux/plugins/tpm/bin/update_plugins" all; or return $status
    __dotfiles_run_update_step "Update fish completions" fish_update_completions
end
