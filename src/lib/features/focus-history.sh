#!/usr/bin/env bash
#
# focus-history.sh: a capped back/forward stack of focused pane ids.
#
# The stack lives in the window option @tiling_revamped_focus_stack (oldest to
# newest, space separated) with a cursor in @tiling_revamped_focus_pos.  A
# pane-focus-in hook records each focus; the back and forward keys walk the
# stack.  Every id is validated against list-panes before it is selected, so a
# closed pane is skipped rather than selected.  Recording is suppressed for the
# one focus event our own navigation triggers via the @tiling_revamped_focus_nav
# guard, which the next record clears.

[[ -n "${_TILING_REVAMPED_FOCUS_HISTORY_LOADED:-}" ]] && return 0
_TILING_REVAMPED_FOCUS_HISTORY_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/constants.sh"

# _focus_pane_alive: true when <id> is a live pane in the current window.
_focus_pane_alive() {
  local id="${1:-}"
  [[ -z "${id}" ]] && return 1
  tmux list-panes -F '#{pane_id}' 2>/dev/null | grep -qx "${id}"
}

# focus_history_record: push the focused pane, capping and resetting forward.
focus_history_record() {
  local nav
  nav=$(get_window_option "@tiling_revamped_focus_nav" "0")
  if [[ "${nav}" == "1" ]]; then
    set_window_option "@tiling_revamped_focus_nav" "0"
    return 0
  fi

  local pane
  pane=$(get_current_pane)
  [[ -z "${pane}" ]] && return 0

  local max
  max=$(get_numeric_option "@tiling_revamped_focus_max" "${TILING_DEFAULT_FOCUS_MAX}" "2" "500")

  local stack pos
  stack=$(get_window_option "@tiling_revamped_focus_stack" "")
  pos=$(get_window_option "@tiling_revamped_focus_pos" "-1")

  local -a ids
  read -ra ids <<< "${stack}"

  # Drop any forward history: keep entries up to and including the cursor.
  local -a kept=()
  if [[ "${pos}" =~ ^[0-9]+$ ]]; then
    local i
    for (( i = 0; i <= pos && i < ${#ids[@]}; i++ )); do
      kept+=("${ids[i]}")
    done
  else
    kept=("${ids[@]}")
  fi

  # Skip a duplicate of the current tail.
  local last_idx=$(( ${#kept[@]} - 1 ))
  if (( last_idx >= 0 )) && [[ "${kept[last_idx]}" == "${pane}" ]]; then
    return 0
  fi

  kept+=("${pane}")

  # Cap the stack length, dropping the oldest entries first.
  while (( ${#kept[@]} > max )); do
    kept=("${kept[@]:1}")
  done

  set_window_option "@tiling_revamped_focus_stack" "${kept[*]}"
  set_window_option "@tiling_revamped_focus_pos" "$(( ${#kept[@]} - 1 ))"
}

# _focus_history_step: move the cursor by <dir> to the nearest live pane.
_focus_history_step() {
  local dir="${1}"

  local stack pos
  stack=$(get_window_option "@tiling_revamped_focus_stack" "")
  pos=$(get_window_option "@tiling_revamped_focus_pos" "-1")
  [[ "${pos}" =~ ^[0-9]+$ ]] || return 0

  local -a ids
  read -ra ids <<< "${stack}"
  local count="${#ids[@]}"
  (( count == 0 )) && return 0

  local idx target=""
  for (( idx = pos + dir; idx >= 0 && idx < count; idx += dir )); do
    if _focus_pane_alive "${ids[idx]}"; then
      target="${ids[idx]}"
      break
    fi
  done

  [[ -z "${target}" ]] && return 0

  set_window_option "@tiling_revamped_focus_nav" "1"
  tmux select-pane -t "${target}" 2>/dev/null || true
  set_window_option "@tiling_revamped_focus_pos" "${idx}"
}

# focus_history_back: select the previous pane in the history.
focus_history_back() {
  _focus_history_step -1
}

# focus_history_forward: select the next pane in the history.
focus_history_forward() {
  _focus_history_step 1
}

export -f _focus_pane_alive
export -f focus_history_record
export -f _focus_history_step
export -f focus_history_back
export -f focus_history_forward
