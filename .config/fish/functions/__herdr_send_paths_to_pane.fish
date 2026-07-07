function __herdr_send_paths_to_pane
    set -l target_pane $argv[1]
    set -l paths $argv[2..-1]

    if test -z "$target_pane"; or not set -q paths[1]
        return 1
    end

    command -sq jq; or return 1

    set -l pane_agent (herdr pane get "$target_pane" 2>/dev/null | jq -r '.result.pane.agent // ""')
    set -l pane_processes (
        herdr pane process-info --pane "$target_pane" 2>/dev/null |
            jq -r '[.result.process_info.foreground_processes[]? | .name, .argv0, .cmdline] | join(" ")'
    )

    set -l use_agent_paths false
    if string match -qir 'claude|gemini|codex|copilot' -- "$pane_agent $pane_processes"
        set use_agent_paths true
    end

    set -l output ""
    if test "$use_agent_paths" = true
        for path in $paths
            set output "$output@$path "
        end
    else
        for path in $paths
            set output "$output"(string escape -- $path)" "
        end
    end

    herdr pane send-text "$target_pane" "$output" >/dev/null
end
