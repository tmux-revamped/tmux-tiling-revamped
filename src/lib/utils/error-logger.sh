#!/usr/bin/env bash
#
# error-logger.sh: opt-in structured logging.
#
# Logging is off by default and writes nothing unless the user sets
# @<plugin>_revamped_enable_logging to 1. Logs go to ~/.tmux/<ns>-logs, never to
# a temp dir, so they survive across tmux server restarts for debugging. A plugin
# sets PLUGIN_LOG_NS (e.g. "cpu-revamped") before sourcing.

[[ -n "${_TMUX_PLUGIN_ERROR_LOGGER_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_ERROR_LOGGER_LOADED=1

PLUGIN_LOG_NS="${PLUGIN_LOG_NS:-tmux-plugin}"
PLUGIN_LOG_DIR="${PLUGIN_LOG_DIR:-${HOME}/.tmux/${PLUGIN_LOG_NS}-logs}"
PLUGIN_LOG_FILE="${PLUGIN_LOG_FILE:-${PLUGIN_LOG_DIR}/${PLUGIN_LOG_NS}.log}"
PLUGIN_LOG_OPTION="${PLUGIN_LOG_OPTION:-@${PLUGIN_LOG_NS//-/_}_enable_logging}"
PLUGIN_MAX_LOG_SIZE="${PLUGIN_MAX_LOG_SIZE:-1048576}"
PLUGIN_MAX_LOG_LINES="${PLUGIN_MAX_LOG_LINES:-1000}"

_logging_enabled() {
  [[ "$(tmux show-option -gqv "${PLUGIN_LOG_OPTION}" 2>/dev/null)" == "1" ]]
}

_rotate_log() {
  [[ -f "${PLUGIN_LOG_FILE}" ]] || return 0
  local size
  size=$(stat -f%z "${PLUGIN_LOG_FILE}" 2>/dev/null \
    || stat -c%s "${PLUGIN_LOG_FILE}" 2>/dev/null \
    || echo 0)
  [[ "${size}" =~ ^[0-9]+$ ]] || return 0
  if (( size > PLUGIN_MAX_LOG_SIZE )); then
    tail -n "${PLUGIN_MAX_LOG_LINES}" "${PLUGIN_LOG_FILE}" \
      > "${PLUGIN_LOG_FILE}.rotated" 2>/dev/null \
      && mv "${PLUGIN_LOG_FILE}.rotated" "${PLUGIN_LOG_FILE}" 2>/dev/null \
      || true
  fi
}

# log_error COMPONENT MESSAGE -> append one line when logging is enabled.
log_error() {
  local component="${1:-unknown}"
  local message="${2:-}"
  [[ -z "${message}" ]] && return 0
  component="${component//[^a-zA-Z0-9_-]/}"
  _logging_enabled || return 0

  mkdir -p "${PLUGIN_LOG_DIR}" 2>/dev/null || return 0
  [[ -w "${PLUGIN_LOG_DIR}" ]] || return 0

  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "")
  [[ -z "${timestamp}" ]] && return 0

  echo "[${timestamp}] [${component}] ${message}" >> "${PLUGIN_LOG_FILE}" 2>/dev/null || true
  _rotate_log
}

export -f _logging_enabled
export -f _rotate_log
export -f log_error
