#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_APP_RULES_LOADED:-}" ]] && return 0
_TILING_REVAMPED_APP_RULES_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/error-logger.sh"
source "${LIB_DIR}/operations/promote.sh"

resolve_app_action() {
  local cmd="${1:-}"
  [[ -z "${cmd}" ]] && return 0

  local rules
  rules=$(get_tmux_option "@tiling_revamped_app_rules" "")
  [[ -z "${rules}" ]] && return 0

  local line pattern action
  while IFS= read -r line; do
    [[ -z "${line}" ]] && continue
    pattern="${line%%:*}"
    action="${line##*:}"
    [[ -z "${pattern}" || -z "${action}" || "${pattern}" == "${line}" ]] && continue
    # shellcheck disable=SC2254
    case "${cmd}" in
      ${pattern}) printf '%s\n' "${action}"; return 0 ;;
    esac
  done <<< "${rules}"

  return 0
}

_apply_app_action() {
  local action="${1:-}"
  local pane
  pane=$(get_current_pane)

  case "${action}" in
    master)
      promote_pane
      ;;
    float)
      set_pane_option "@tiling_revamped_float" "1" "${pane}"
      ;;
    scratchpad)
      set_pane_option "@tiling_revamped_scratchpad" "1" "${pane}"
      ;;
    *)
      log_error "app-rules" "Unknown action: ${action}"
      return 1
      ;;
  esac
}

apply_app_rules() {
  local cmd
  cmd=$(tmux display-message -p '#{pane_current_command}' 2>/dev/null || echo "")

  local action
  action=$(resolve_app_action "${cmd}")
  [[ -z "${action}" ]] && return 0

  _apply_app_action "${action}"
}

export -f resolve_app_action
export -f _apply_app_action
export -f apply_app_rules
