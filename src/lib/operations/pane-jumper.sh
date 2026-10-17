#!/usr/bin/env bash
#
# pane-jumper.sh: fuzzy jump to any pane across every session.
#
# An fzf popup lists every pane in the server with a live capture-pane preview.
# Selecting an entry switches the client to that session, window, and pane.  The
# popup needs fzf plus tmux 3.2+; when either is missing the jumper degrades to
# tmux's built-in choose-tree so the key still does something useful.

[[ -n "${_TILING_REVAMPED_PANE_JUMPER_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PANE_JUMPER_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/constants.sh"
source "${LIB_DIR}/utils/has-command.sh"
source "${LIB_DIR}/utils/picker.sh"

# _pane_jumper_has_popup: true when tmux is new enough for display-popup (3.2+).
_pane_jumper_has_popup() {
  local version major minor
  version=$(tmux -V 2>/dev/null | sed 's/[^0-9.]//g')
  [[ -z "${version}" ]] && return 1

  major="${version%%.*}"
  minor="${version#*.}"
  minor="${minor%%[a-z]*}"
  minor="${minor%%.*}"
  [[ "${minor}" =~ ^[0-9]+$ ]] || minor=0

  (( major > 3 )) && return 0
  (( major == 3 )) && (( minor >= 2 )) && return 0
  return 1
}

# _pane_jumper_list: one line per pane, "location pane_id command title".
_pane_jumper_list() {
  tmux list-panes -a -F \
    '#{pane_id}|#{session_id}|#{window_id}|#{session_name}:#{window_index}.#{pane_index} #{pane_current_command} #{pane_title}' \
    2>/dev/null
}

# _pane_jumper_fallback: built-in tree picker when the popup is unavailable.
_pane_jumper_fallback() {
  tmux choose-tree -Zw 2>/dev/null || true
}

# _pane_jumper_select: switch to the session, window, and pane of a selection.
_pane_jumper_select() {
  local selection="${1:-}"
  [[ -z "${selection}" ]] && return 0

  local pane_id session_id window_id rest
  pane_id="${selection%%|*}"
  rest="${selection#*|}"
  session_id="${rest%%|*}"
  rest="${rest#*|}"
  window_id="${rest%%|*}"

  local id_pattern='^[%$@][0-9]+$'
  [[ "${pane_id}" =~ ${id_pattern} ]] || return 0
  [[ "${session_id}" =~ ${id_pattern} ]] || return 0
  [[ "${window_id}" =~ ${id_pattern} ]] || return 0

  tmux switch-client -t "${session_id}" 2>/dev/null || true
  tmux select-window -t "${window_id}" 2>/dev/null || true
  tmux select-pane -t "${pane_id}" 2>/dev/null || true
}

# pane_jumper: main entry point.
pane_jumper() {
  if ! has_command fzf || ! _pane_jumper_has_popup; then
    _pane_jumper_fallback
    return 0
  fi

  local width height preview_width
  width=$(get_tmux_option "@tiling_revamped_jump_width" "${TILING_DEFAULT_JUMP_WIDTH}")
  height=$(get_tmux_option "@tiling_revamped_jump_height" "${TILING_DEFAULT_JUMP_HEIGHT}")
  preview_width=$(get_tmux_option "@tiling_revamped_jump_preview_width" "${TILING_DEFAULT_JUMP_PREVIEW_WIDTH}")

  local pane_list
  pane_list=$(_pane_jumper_list)
  [[ -z "${pane_list}" ]] && return 0

  picker_open_popup "pane-jump" "${width}" "${height}" && return 0

  local selected
  selected=$(printf '%s\n' "${pane_list}" \
    | picker_fzf "center,${width},${height}" \
        --prompt="Jump to pane: " \
        --delimiter='[|]' \
        --with-nth='4..' \
        --preview="tmux capture-pane -p -t {1}" \
        --preview-window="right:${preview_width}" 2>/dev/null)

  [[ -z "${selected}" ]] && return 0

  _pane_jumper_select "${selected}"
}

export -f _pane_jumper_has_popup
export -f _pane_jumper_list
export -f _pane_jumper_fallback
export -f _pane_jumper_select
export -f pane_jumper
