#!/usr/bin/env bash

[[ -n "${_TMUX_PLUGIN_PUBLISH_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_PUBLISH_LOADED=1

_PUBLISH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_PUBLISH_SCRIPT_DIR}/../tmux/tmux-ops.sh"

PUBLISH_BATCH=()
PUBLISH_PENDING=0

_publish_tmux() { tmux "$@"; }

publish_escape() {
  local hash="#"
  printf '%s' "${1//"${hash}"/${hash}${hash}}"
}

publish_chars() {
  local LC_ALL=C
  local value="${1//[$'\200'-$'\277']/}"
  printf '%s' "${#value}"
}

publish_pad() {
  local value="${1}" width="${2:-0}" chars
  [[ "${width}" =~ ^[0-9]+$ ]] || width=0
  if ((width > 0)); then
    chars="$(publish_chars "${value}")"
    ((chars < width)) && printf '%*s' "$((width - chars))" ""
  fi
  printf '%s' "${value}"
}

publish_width() {
  local prefix="${1}" metric="${2}" natural="${3:-0}" own
  own="$(get_tmux_option "@${prefix}_${metric}_width" "")"
  if [[ "${own}" =~ ^[0-9]+$ ]]; then
    printf '%s' "${own}"
  elif [[ "$(get_tmux_option "@${prefix}_fixed_width" "off")" == "on" ]]; then
    printf '%s' "${natural}"
  else
    printf '0'
  fi
}

publish_add_raw() {
  local option="${1}" value="${2}" pane="${3:-}"
  if [[ "${value}" == *";" ]]; then
    value="${value%;}\\;"
  fi
  if ((PUBLISH_PENDING > 0)); then
    PUBLISH_BATCH+=(";")
  fi
  if [[ -n "${pane}" ]]; then
    PUBLISH_BATCH+=(set-option -pq -t "${pane}" "${option}" "${value}")
  else
    PUBLISH_BATCH+=(set-option -gq "${option}" "${value}")
  fi
  PUBLISH_PENDING=$((PUBLISH_PENDING + 1))
}

publish_add() {
  publish_add_raw "${1}" "${2//%/%%}" "${3:-}"
}

publish_commit() {
  local client rc
  ((PUBLISH_PENDING > 0)) || return 0
  while IFS= read -r client; do
    [[ -n "${client}" ]] && PUBLISH_BATCH+=(";" refresh-client -S -t "${client}")
  done <<<"$(_publish_tmux list-clients -F '#{client_name}' 2>/dev/null)"
  _publish_tmux "${PUBLISH_BATCH[@]}" >/dev/null 2>&1
  rc=$?
  PUBLISH_BATCH=()
  PUBLISH_PENDING=0
  return "${rc}"
}
