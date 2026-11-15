#!/usr/bin/env bash

[[ -n "${_TMUX_PLUGIN_NOTIFY_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_NOTIFY_LOADED=1

_NOTIFY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_NOTIFY_DIR}/platform.sh"
# shellcheck source=/dev/null
source "${_NOTIFY_DIR}/has-command.sh"
# shellcheck source=/dev/null
source "${_NOTIFY_DIR}/../tmux/tmux-ops.sh"

notify_backend() {
  if is_macos && has_command osascript; then
    echo "osascript"
    return 0
  fi
  if has_command notify-send; then
    echo "notify-send"
    return 0
  fi
  echo "none"
}

notify_enabled() {
  [[ "$(get_tmux_option "${1}" "0")" == "1" ]]
}

notify_send() {
  local title="${1}" message="${2}"
  case "$(notify_backend)" in
    osascript)
      osascript -e 'on run argv' \
        -e 'display notification (item 2 of argv) with title (item 1 of argv)' \
        -e 'end run' "${title}" "${message}" >/dev/null 2>&1
      ;;
    notify-send)
      notify-send -- "${title}" "${message}" >/dev/null 2>&1
      ;;
    *) : ;;
  esac
  return 0
}

notify_if_enabled() {
  local option="${1}" title="${2}" message="${3}"
  notify_enabled "${option}" || return 0
  notify_send "${title}" "${message}"
}

export -f notify_backend
export -f notify_enabled
export -f notify_send
export -f notify_if_enabled
