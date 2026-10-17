#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_PICKER_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PICKER_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/constants.sh"

_version_at_least() {
  local have="${1}" want="${2}"
  local -a have_parts want_parts
  IFS='.' read -ra have_parts <<< "${have}"
  IFS='.' read -ra want_parts <<< "${want}"

  local i have_part want_part
  for (( i = 0; i < 3; i++ )); do
    have_part="${have_parts[i]:-0}"
    have_part="${have_part%%[!0-9]*}"
    have_part="${have_part:-0}"
    want_part="${want_parts[i]:-0}"
    (( 10#${have_part} > 10#${want_part} )) && return 0
    (( 10#${have_part} < 10#${want_part} )) && return 1
  done
  return 0
}

_fzf_supports_tmux_popup() {
  local fzf_version version_pattern='^[0-9]+(\.[0-9]+)*$'
  fzf_version=$(fzf --version 2>/dev/null | cut -d' ' -f1)
  [[ "${fzf_version}" =~ ${version_pattern} ]] || return 1
  _version_at_least "${fzf_version}" "${TILING_FZF_TMUX_MIN_VERSION}"
}

picker_in_popup() {
  [[ "${TILING_REVAMPED_IN_POPUP:-0}" == "1" ]]
}

picker_open_popup() {
  local command="${1}" width="${2}" height="${3}"
  picker_in_popup && return 1
  _fzf_supports_tmux_popup && return 1

  tmux display-popup -E -w "${width}" -h "${height}" \
    "TILING_REVAMPED_IN_POPUP=1 $(tiling_popup_command "${command}")" 2>/dev/null || true
  return 0
}

picker_fzf() {
  local spec="${1}"
  shift
  if picker_in_popup; then
    fzf "$@"
  else
    fzf --tmux "${spec}" "$@"
  fi
}

export -f _version_at_least
export -f _fzf_supports_tmux_popup
export -f picker_in_popup
export -f picker_open_popup
export -f picker_fzf
