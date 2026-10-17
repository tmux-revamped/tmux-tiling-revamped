#!/usr/bin/env bash
#
# app-rules.sh: app-aware tiling rules for new panes.
#
# The user lists newline-delimited "command:action" rules in one option:
#   set -g @tiling_revamped_app_rules "$(printf 'vim:master\nlazygit:float\nncdu:scratchpad')"
#
# When a pane is created the auto-split hook runs app-rules, which matches the
# pane's #{pane_current_command} against each rule pattern with bash 3.2 case
# globbing and applies the first matching action.  Supported actions:
#   master     - promote the pane to the master slot
#   float      - tag the pane for the floating-pane pass (@tiling_revamped_float)
#   scratchpad - tag the pane as a scratchpad (@tiling_revamped_scratchpad)

[[ -n "${_TILING_REVAMPED_APP_RULES_LOADED:-}" ]] && return 0
_TILING_REVAMPED_APP_RULES_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/error-logger.sh"
source "${LIB_DIR}/operations/promote.sh"

# resolve_app_action: echo the action mapped to <command>, or nothing.
# Rules are matched top to bottom; the first pattern that matches wins.
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
    # Intentional glob match of the live command against the rule pattern.
    # shellcheck disable=SC2254
    case "${cmd}" in
      ${pattern}) printf '%s\n' "${action}"; return 0 ;;
    esac
  done <<< "${rules}"

  return 0
}

# _apply_app_action: dispatch a resolved action to a concrete pane operation.
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

# apply_app_rules: inspect the newly created pane and run its matched action.
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
