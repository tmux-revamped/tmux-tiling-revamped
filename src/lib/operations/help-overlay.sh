#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_HELP_OVERLAY_LOADED:-}" ]] && return 0
_TILING_REVAMPED_HELP_OVERLAY_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"

_resolved_key() {
  local owner="${1}" option="${2}" default="${3}" resolved record_owner record_key
  resolved=$(get_tmux_option "@tiling_revamped_bindings" "")
  if [[ -z "${resolved}" ]]; then
    get_tmux_option "${option}" "${default}"
    return 0
  fi
  while IFS=$'\t' read -r record_owner record_key; do
    if [[ "${record_owner}" == "${owner}" ]]; then
      printf '%s\n' "${record_key}"
      return 0
    fi
  done <<<"${resolved}"
  return 0
}

_help_lines() {
  local label owner option default key
  while IFS='|' read -r label owner option default; do
    [[ -z "${label}" ]] && continue
    key=$(_resolved_key "${owner}" "${option}" "${default}")
    [[ -z "${key}" ]] && continue
    printf '%-7s %s\n' "${key}" "${label}"
  done <<'ACTIONS'
Dwindle layout|dwindle|@tiling_revamped_key_dwindle|M-D
Spiral layout|spiral|@tiling_revamped_key_spiral|M-S
Main-vertical layout|main_vertical|@tiling_revamped_key_main_vertical|M-V
Main-horizontal layout|main_horizontal|@tiling_revamped_key_main_horizontal|M-H
Balance panes|balance|@tiling_revamped_key_balance|M-B
Equalize panes|equalize|@tiling_revamped_key_equalize|M-E
Promote to master|promote|@tiling_revamped_key_promote|M-M
Rotate layout|rotate|@tiling_revamped_key_rotate|M-R
Flip layout|flip|@tiling_revamped_key_flip|M-F
Circulate panes|circulate|@tiling_revamped_key_circulate|M-C
Autosplit|autotile|@tiling_revamped_key_autotile|M-A
Cycle layout|cycle|@tiling_revamped_key_cycle|M-O
Grow master|master_grow|@tiling_revamped_key_master_grow|M-G
Shrink master|master_shrink|@tiling_revamped_key_master_shrink|M-X
Toggle sync|sync|@tiling_revamped_key_sync|M-Y
Mark pane|mark|@tiling_revamped_key_mark|M-K
Jump to mark|jump|@tiling_revamped_key_jump|M-J
Scratchpad|scratchpad|@tiling_revamped_key_scratchpad|M-T
Layout picker|pick_layout|@tiling_revamped_key_pick_layout|M-L
Swap with biggest|swap_biggest|@tiling_revamped_key_swap_biggest|M-W
Undo layout|undo|@tiling_revamped_key_undo|M-U
Redo layout|redo|@tiling_revamped_key_redo|M-Z
Jump to any pane|pane_jump|@tiling_revamped_key_pane_jump|M-Q
Focus back|focus_back|@tiling_revamped_key_focus_back|M-P
Focus forward|focus_forward|@tiling_revamped_key_focus_forward|M-N
This overlay|help|@tiling_revamped_key_help|M-I
ACTIONS
}

_popup_supported() {
  local version major minor
  version=$(tmux -V 2>/dev/null | sed 's/[^0-9.]//g')
  [[ -z "${version}" ]] && return 1

  major="${version%%.*}"
  minor="${version#*.}"
  minor="${minor%%[a-z]*}"
  minor="${minor%%.*}"
  [[ "${minor}" =~ ^[0-9]+$ ]] || minor=0

  if (( major > 3 )); then
    return 0
  fi
  if (( major == 3 )) && (( minor >= 2 )); then
    return 0
  fi
  return 1
}

_shell_quote() {
  local rest="${1}" out=""
  while [[ "${rest}" == *\'* ]]; do
    out="${out}${rest%%\'*}'\\''"
    rest="${rest#*\'}"
  done
  printf "'%s%s'" "${out}" "${rest}"
}

show_help() {
  if ! _popup_supported; then
    tmux display-message "tmux-tiling-revamped: help overlay needs tmux 3.2+" 2>/dev/null
    return 0
  fi

  local width height
  width=$(get_tmux_option "@tiling_revamped_help_width" "50%")
  height=$(get_tmux_option "@tiling_revamped_help_height" "60%")

  local body conflicts
  body=$(_help_lines)
  conflicts=$(get_tmux_option "@tiling_revamped_conflicts" "")
  [[ -n "${conflicts}" ]] && body+=$'\n\nKey conflicts: '"${conflicts}"

  local escaped
  escaped="$(_shell_quote "${body}")"
  local popup_cmd
  popup_cmd="printf '%s\n' 'tmux-tiling-revamped keybindings'; printf '%s\n' ${escaped}; printf '\nPress any key to close\n'; read -r _"

  tmux display-popup -E -w "${width}" -h "${height}" "${popup_cmd}" 2>/dev/null || true
}

export -f _resolved_key
export -f _help_lines
export -f _shell_quote
export -f _popup_supported
export -f show_help
