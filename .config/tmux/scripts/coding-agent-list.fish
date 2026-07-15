#!/usr/bin/env fish

function __coding_agent_rank --argument-names agent_status
    switch $agent_status
        case blocked
            echo 0
        case done
            echo 1
        case working
            echo 2
        case idle
            echo 3
        case '*'
            echo 4
    end
end

function __coding_agent_styled_status --argument-names agent_status
    switch $agent_status
        case blocked
            printf '%s%-7s%s' (set_color --bold red) blocked (set_color normal)
        case done
            printf '%s%-7s%s' (set_color --bold green) done (set_color normal)
        case working
            printf '%s%-7s%s' (set_color --bold yellow) working (set_color normal)
        case idle
            printf '%s%-7s%s' (set_color brblack) idle (set_color normal)
    end
end

function __coding_agent_title_is_working --argument-names title
    string match -qr '^[\x{2800}-\x{28FF}] ' -- "$title"
end

function __coding_agent_screen_status --argument-names agent stored_status title content
    set -l title_lower (string lower -- "$title")
    set -l content_lower (string lower -- "$content")

    if string match -q '*action required*' -- "$title_lower"
        echo blocked
        return
    end

    if test "$agent" = copilot
        if string match -q '*asking user:*' -- "$content_lower"
            or string match -q '*use ↑↓ or number keys to select*' -- "$content_lower"
            or begin
                string match -q '*esc to cancel*' -- "$content_lower"
                and string match -qr 'enter (to )?(select|confirm|submit)' -- "$content_lower"
            end
            echo blocked
            return
        end

        if string match -q '*esc to cancel*' -- "$content_lower"
            or string match -q '*esc interrupt*' -- "$content_lower"
            echo working
            return
        end
    else
        if string match -q '*press enter to confirm or esc to cancel*' -- "$content_lower"
            or string match -q '*enter to submit answer*' -- "$content_lower"
            or string match -q '*enter to submit all*' -- "$content_lower"
            or string match -q '*allow command?*' -- "$content_lower"
            or string match -q '*waiting for permission*' -- "$content_lower"
            or begin
                string match -q '*do you want to proceed?*' -- "$content_lower"
                and string match -q '*esc to cancel*' -- "$content_lower"
            end
            or begin
                string match -q '*enter to select*' -- "$content_lower"
                and string match -q '*esc to cancel*' -- "$content_lower"
            end
            echo blocked
            return
        end

        if __coding_agent_title_is_working "$title"
            echo working
            return
        end

        if string match -q '*esc to interrupt*' -- "$content_lower"
            or string match -q '*(esc to cancel*' -- "$content_lower"
            echo working
            return
        end
    end

    echo "$stored_status"
end

function __coding_agent_process_matches --argument-names agent command arguments
    set -l command_lower (string lower -- "$command")
    set -l arguments_lower (string lower -- "$arguments")

    switch $agent
        case claude
            string match -qr '(^|/)claude$' -- "$command_lower"; and return 0
            string match -qr '^([^ ]*/)?(claude|claude-code)( |$)|/claude/|@anthropic-ai/' -- "$arguments_lower"
        case codex
            string match -qr '(^|/)codex$' -- "$command_lower"; and return 0
            string match -qr '^([^ ]*/)?codex( |$)|/codex/|@openai/codex' -- "$arguments_lower"
        case copilot
            string match -qr '(^|/)copilot$' -- "$command_lower"; and return 0
            string match -qr '^([^ ]*/)?copilot( |$)|/copilot/|@github/copilot' -- "$arguments_lower"
    end
end

function __coding_agent_process_is_live --argument-names agent pane_pid
    set -l frontier "$pane_pid"
    set -l visited

    while set -q frontier[1]
        set -l next_frontier

        for row in $__coding_agent_process_rows
            set -l fields (string match -r --groups-only '^\s*([0-9]+)\s+([0-9]+)\s+(\S+)\s*(.*)$' -- "$row")
            test (count $fields) -eq 4; or continue

            set -l pid "$fields[1]"
            set -l parent_pid "$fields[2]"

            if contains -- "$pid" $frontier
                __coding_agent_process_matches "$agent" "$fields[3]" "$fields[4]"; and return 0
            end

            contains -- "$parent_pid" $frontier; or continue
            contains -- "$pid" $visited $frontier $next_frontier; or set -a next_frontier "$pid"
        end

        set -a visited $frontier
        set frontier $next_frontier
    end

    return 1
end

function __coding_agent_detect --argument-names pane_pid
    for candidate in claude codex copilot
        if __coding_agent_process_is_live "$candidate" "$pane_pid"
            echo "$candidate"
            return 0
        end
    end

    return 1
end

function __coding_agent_short_path --argument-names path
    if string match -q "$HOME*" -- "$path"
        printf '~%s' (string sub --start (math (string length -- "$HOME") + 1) -- "$path")
    else
        printf '%s' "$path"
    end
end

function __coding_agent_single_line --argument-names value
    string replace -ar '[\x00-\x1F\x7F]' ' ' -- "$value"
end

function __coding_agent_list --argument-names filter
    contains -- "$filter" all blocked done working idle; or set filter all

    set -l separator \x1f
    set -l format (string join '' \
        '#{session_name}' $separator \
        '#{session_id}' $separator \
        '#{window_id}' $separator \
        '#{window_index}' $separator \
        '#{window_name}' $separator \
        '#{pane_id}' $separator \
        '#{pane_index}' $separator \
        '#{pane_current_path}' $separator \
        '#{pane_title}' $separator \
        '#{pane_pid}' $separator \
        '#{@coding_agent}' $separator \
        '#{@coding_agent_status}' $separator \
        '#{@coding_agent_updated_at}' $separator \
        '#{pane_dead}')
    set -l reporter "$HOME/.config/tmux/scripts/coding-agent-state.sh"
    set -l rows
    set -g __coding_agent_process_rows (ps -axo pid=,ppid=,comm=,args= 2>/dev/null)

    for line in (tmux list-panes -a -F "$format" 2>/dev/null)
        set -l fields (string split $separator -- "$line")
        test (count $fields) -eq 14; or continue

        set -l session_name "$fields[1]"
        set -l session_id "$fields[2]"
        set -l window_id "$fields[3]"
        set -l window_index "$fields[4]"
        set -l window_name "$fields[5]"
        set -l pane_id "$fields[6]"
        set -l pane_index "$fields[7]"
        set -l path "$fields[8]"
        set -l title "$fields[9]"
        set -l pane_pid "$fields[10]"
        set -l agent "$fields[11]"
        set -l stored_status "$fields[12]"
        set -l updated_at "$fields[13]"
        set -l pane_dead "$fields[14]"

        if test "$pane_dead" = 1
            test -n "$agent"; and "$reporter" clear "$pane_id"
            continue
        end

        set -l agent_was_discovered 0
        if test -z "$agent"
            set -q __coding_agent_process_rows[1]; or continue
            set agent (__coding_agent_detect "$pane_pid")
            test -n "$agent"; or continue

            "$reporter" register "$pane_id" "$agent"
            set agent (tmux show-options -pqv -t "$pane_id" '@coding_agent' 2>/dev/null)
            set stored_status (tmux show-options -pqv -t "$pane_id" '@coding_agent_status' 2>/dev/null)
            set updated_at (tmux show-options -pqv -t "$pane_id" '@coding_agent_updated_at' 2>/dev/null)
            set agent_was_discovered 1
        end

        contains -- "$agent" claude codex copilot; or begin
            "$reporter" clear "$pane_id"
            continue
        end

        if test "$agent_was_discovered" = 0; and set -q __coding_agent_process_rows[1]
            if not __coding_agent_process_is_live "$agent" "$pane_pid"
                "$reporter" clear "$pane_id"
                continue
            end
        end

        if not contains -- "$stored_status" blocked done working idle
            set stored_status idle
            "$reporter" reconcile "$pane_id" "$agent" "$stored_status"
            set updated_at (tmux show-options -pqv -t "$pane_id" '@coding_agent_updated_at' 2>/dev/null)
        end

        set -l content (tmux capture-pane -p -J -t "$pane_id" -S 0 2>/dev/null | string collect)
        set -l agent_status (__coding_agent_screen_status "$agent" "$stored_status" "$title" "$content")

        if test "$agent_status" != "$stored_status"
            "$reporter" reconcile "$pane_id" "$agent" "$agent_status"
            set updated_at (tmux show-options -pqv -t "$pane_id" '@coding_agent_updated_at' 2>/dev/null)
        end

        if test "$filter" != all; and test "$agent_status" != "$filter"
            continue
        end

        string match -qr '^[0-9]+$' -- "$updated_at"; or set updated_at 0
        set -l rank (__coding_agent_rank "$agent_status")
        set -l styled_status (__coding_agent_styled_status "$agent_status")
        set -l location (__coding_agent_single_line "$session_name:$window_index.$pane_index $window_name")
        set -l short_path (__coding_agent_single_line (__coding_agent_short_path "$path"))
        set -l identity "$session_id/$pane_id"

        set -a rows (string join \t -- \
            "$rank" "$updated_at" "$styled_status" "$agent" "$location" "$short_path" \
            "$pane_id" "$window_id" "$session_id" "$identity" "$agent_status")
    end

    if set -q rows[1]
        printf '%s\n' $rows | sort -k1,1n -k2,2nr
    end

    return 0
end

__coding_agent_list "$argv[1]"
