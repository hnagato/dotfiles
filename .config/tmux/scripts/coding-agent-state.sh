#!/bin/sh

# Keep Coding Agent lifecycle state on the tmux pane that owns the process.

set -u

status_option='@coding_agent_status'
agent_option='@coding_agent'
updated_option='@coding_agent_updated_at'

valid_agent() {
  case "$1" in
  claude | codex | copilot) return 0 ;;
  *) return 1 ;;
  esac
}

valid_status() {
  case "$1" in
  blocked | done | working | idle) return 0 ;;
  *) return 1 ;;
  esac
}

has_tmux_pane() {
  case "$1" in
  %*)
    pane_number=${1#%}
    case "$pane_number" in
    '' | *[!0-9]*) return 1 ;;
    esac
    ;;
  *) return 1 ;;
  esac

  command -v tmux >/dev/null 2>&1 && tmux display-message -p -t "$1" '#{pane_id}' >/dev/null 2>&1
}

clear_status() {
  pane="$1"
  has_tmux_pane "$pane" || return 0

  tmux set-option -pu -t "$pane" "$status_option" 2>/dev/null || true
  tmux set-option -pu -t "$pane" "$agent_option" 2>/dev/null || true
  tmux set-option -pu -t "$pane" "$updated_option" 2>/dev/null || true
}

set_status() {
  pane="$1"
  agent="$2"
  status="$3"
  valid_agent "$agent" || return 0
  valid_status "$status" || return 0
  has_tmux_pane "$pane" || return 0

  tmux set-option -p -t "$pane" "$agent_option" "$agent" 2>/dev/null || return 0
  tmux set-option -p -t "$pane" "$status_option" "$status" 2>/dev/null || return 0
  tmux set-option -p -t "$pane" "$updated_option" "$(date +%s)" 2>/dev/null || true
}

register_status() {
  pane="$1"
  agent="$2"
  valid_agent "$agent" || return 0
  has_tmux_pane "$pane" || return 0

  current_agent=$(tmux show-options -pqv -t "$pane" "$agent_option" 2>/dev/null)
  [ -z "$current_agent" ] || return 0
  set_status "$pane" "$agent" idle
}

reconcile_status() {
  pane="$1"
  agent="$2"
  status="$3"
  valid_agent "$agent" || return 0
  valid_status "$status" || return 0
  has_tmux_pane "$pane" || return 0

  current_agent=$(tmux show-options -pqv -t "$pane" "$agent_option" 2>/dev/null)
  [ "$current_agent" = "$agent" ] || return 0
  current_status=$(tmux show-options -pqv -t "$pane" "$status_option" 2>/dev/null)
  [ "$current_status" = "$status" ] && return 0

  set_status "$pane" "$agent" "$status"
}

pane_is_visible() {
  pane="$1"
  visibility=$(tmux display-message -p -t "$pane" '#{pane_active} #{window_active} #{session_attached}' 2>/dev/null) || return 1

  case "$visibility" in
  '1 1 '[1-9]*) return 0 ;;
  *) return 1 ;;
  esac
}

completion_status() {
  if pane_is_visible "$1"; then
    printf '%s\n' idle
  else
    printf '%s\n' 'done'
  fi
}

mark_seen() {
  pane="$1"
  has_tmux_pane "$pane" || return 0

  status=$(tmux show-options -pqv -t "$pane" "$status_option" 2>/dev/null)
  [ "$status" = 'done' ] || return 0

  agent=$(tmux show-options -pqv -t "$pane" "$agent_option" 2>/dev/null)
  [ -n "$agent" ] || return 0
  set_status "$pane" "$agent" idle
}

report() {
  agent="$1"
  event="$2"
  pane=${TMUX_PANE:-}
  hook_input=''

  [ -n "$pane" ] || {
    cat >/dev/null 2>&1 || true
    return 0
  }

  valid_agent "$agent" || {
    cat >/dev/null 2>&1 || true
    return 0
  }

  if { [ "$agent" = claude ] && [ "$event" = Stop ]; } ||
    { [ "$agent" = copilot ] && [ "$event" = ErrorOccurred ]; }; then
    hook_input=$(cat 2>/dev/null || true)
  else
    cat >/dev/null 2>&1 || true
  fi

  case "$event" in
  SessionStart)
    set_status "$pane" "$agent" idle
    ;;
  UserPromptSubmit | PreToolUse | PostToolUse)
    set_status "$pane" "$agent" working
    ;;
  PermissionRequest)
    [ "$agent" = copilot ] || set_status "$pane" "$agent" blocked
    ;;
  Notification)
    set_status "$pane" "$agent" blocked
    ;;
  Stop | AgentStop)
    if [ "$agent" = claude ]; then
      command -v jq >/dev/null 2>&1 || return 0
      printf '%s' "$hook_input" | jq -e 'type == "object"' >/dev/null 2>&1 || return 0

      if printf '%s' "$hook_input" | jq -e '.background_tasks | type == "array" and length > 0' >/dev/null 2>&1; then
        set_status "$pane" "$agent" working
      else
        set_status "$pane" "$agent" "$(completion_status "$pane")"
      fi
    else
      set_status "$pane" "$agent" "$(completion_status "$pane")"
    fi
    ;;
  StopFailure)
    set_status "$pane" "$agent" "$(completion_status "$pane")"
    ;;
  ErrorOccurred)
    if [ "$agent" = copilot ]; then
      command -v jq >/dev/null 2>&1 || return 0
      printf '%s' "$hook_input" | jq -e 'type == "object" and (.recoverable | type == "boolean")' >/dev/null 2>&1 || return 0

      if printf '%s' "$hook_input" | jq -e '.recoverable' >/dev/null 2>&1; then
        set_status "$pane" "$agent" working
      else
        set_status "$pane" "$agent" "$(completion_status "$pane")"
      fi
    fi
    ;;
  SessionEnd)
    clear_status "$pane"
    ;;
  esac
}

case "${1:-}" in
report)
  report "${2:-}" "${3:-}"
  ;;
seen)
  mark_seen "${2:-${TMUX_PANE:-}}"
  ;;
register)
  register_status "${2:-}" "${3:-}"
  ;;
reconcile)
  reconcile_status "${2:-}" "${3:-}" "${4:-}"
  ;;
clear)
  clear_status "${2:-${TMUX_PANE:-}}"
  ;;
*)
  cat >/dev/null 2>&1 || true
  ;;
esac

exit 0
