#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_SCRATCHPAD_LOADED:-}" ]] && return 0
_TILING_REVAMPED_SCRATCHPAD_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

# Named scratchpads backed by persistent detached tmux sessions.
# Each scratchpad is a popup that attaches to a dedicated session named
# "_scratch_<name>".  The popup is shown via display-popup (tmux 3.2+).
#
# Usage:
#   toggle_scratchpad                  - toggle the "default" scratchpad
#   toggle_scratchpad <name>           - toggle a named scratchpad
#   toggle_scratchpad <name> <cmd>     - open scratchpad running <cmd>
toggle_scratchpad() {
  local name="${1:-default}"
  local cmd="${2:-}"

  name="${name//[^a-zA-Z0-9_-]/}"
  [[ -z "${name}" ]] && name="default"

  local session_name="_scratch_${name}"

  local width
  width=$(get_tmux_option "@tiling_revamped_scratch_width" "80%")
  local height
  height=$(get_tmux_option "@tiling_revamped_scratch_height" "75%")

  local popup_cmd
  if [[ -n "${cmd}" ]]; then
    popup_cmd="tmux new-session -A -s '${session_name}' '${cmd}'"
  else
    popup_cmd="tmux new-session -A -s '${session_name}'"
  fi

  tmux display-popup \
    -E \
    -w "${width}" \
    -h "${height}" \
    "${popup_cmd}" 2>/dev/null || true
}

export -f toggle_scratchpad
