#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_MARKS_LOADED:-}" ]] && return 0
_TILING_REVAMPED_MARKS_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/has-command.sh"

# Marks store a named label on a pane option (@tiling_revamped_mark) and
# maintain a global semicolon-separated index (@tiling_revamped_marks)
# in "name:pane_id" format for fast lookup.

mark_pane() {
  local name="${1:-}"

  if [[ -z "${name}" ]]; then
    log_error "marks" "mark_pane requires a name argument"
    return 1
  fi

  name="${name//[^a-zA-Z0-9_-]/}"
  [[ -z "${name}" ]] && return 1

  local pane_id
  pane_id=$(get_current_pane)

  # Clear any existing mark with the same name
  local marks
  marks=$(get_tmux_option "@tiling_revamped_marks" "")

  # Remove stale entries for this name
  local cleaned=""
  while IFS= read -r entry; do
    [[ -z "${entry}" ]] && continue
    local entry_name="${entry%%:*}"
    [[ "${entry_name}" != "${name}" ]] && cleaned="${cleaned:+${cleaned};}${entry}"
  done < <(echo "${marks}" | tr ';' '\n')

  # Append new entry
  cleaned="${cleaned:+${cleaned};}${name}:${pane_id}"
  set_tmux_option "@tiling_revamped_marks" "${cleaned}"
  set_pane_option "@tiling_revamped_mark" "${name}"
}

unmark_pane() {
  local name="${1:-}"
  local pane_id

  if [[ -z "${name}" ]]; then
    # Unmark current pane
    pane_id=$(get_current_pane)
    name=$(get_pane_option "@tiling_revamped_mark" "")
    [[ -z "${name}" ]] && return 0
    set_pane_option "@tiling_revamped_mark" ""
  fi

  local marks
  marks=$(get_tmux_option "@tiling_revamped_marks" "")

  # Look up pane ID for the named mark so we can clear its pane option
  local target_pane=""
  local cleaned=""
  while IFS= read -r entry; do
    [[ -z "${entry}" ]] && continue
    local entry_name="${entry%%:*}"
    if [[ "${entry_name}" == "${name}" ]]; then
      target_pane="${entry##*:}"
    else
      cleaned="${cleaned:+${cleaned};}${entry}"
    fi
  done < <(echo "${marks}" | tr ';' '\n')

  set_tmux_option "@tiling_revamped_marks" "${cleaned}"

  # Clear the pane option on the target pane
  if [[ -n "${target_pane}" ]]; then
    set_pane_option "@tiling_revamped_mark" "" "${target_pane}"
  fi
}

_open_mark_picker() {
  if ! has_command fzf; then
    log_error "marks" "No mark name given and fzf is not installed"
    return 1
  fi

  local marks
  marks=$(get_tmux_option "@tiling_revamped_marks" "")
  [[ -z "${marks}" ]] && return 0

  tmux display-popup -E "$(tiling_popup_command "jump-pick")" 2>/dev/null || true
}

jump_pick() {
  local marks name
  marks=$(get_tmux_option "@tiling_revamped_marks" "")
  [[ -z "${marks}" ]] && return 0

  name=$(echo "${marks}" | tr ';' '\n' | grep -v '^$' \
    | cut -d: -f1 | fzf --prompt="Jump to mark: " --height=10) || return 0
  [[ -z "${name}" ]] && return 0

  jump_to_mark "${name}"
}

jump_to_mark() {
  local name="${1:-}"

  if [[ -z "${name}" ]]; then
    _open_mark_picker
    return
  fi

  local marks
  marks=$(get_tmux_option "@tiling_revamped_marks" "")

  local target_pane=""
  while IFS= read -r entry; do
    [[ -z "${entry}" ]] && continue
    local entry_name="${entry%%:*}"
    local entry_pane="${entry##*:}"
    if [[ "${entry_name}" == "${name}" ]]; then
      target_pane="${entry_pane}"
      break
    fi
  done < <(echo "${marks}" | tr ';' '\n')

  if [[ -n "${target_pane}" ]]; then
    tmux select-pane -t "${target_pane}" 2>/dev/null || true
  else
    log_error "marks" "Mark not found: ${name}"
    return 1
  fi
}

export -f mark_pane
export -f unmark_pane
export -f _open_mark_picker
export -f jump_pick
export -f jump_to_mark
