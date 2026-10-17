#!/usr/bin/env bash
#
# Unit test helpers for plugins built from tmux-plugin-template.
#
# Provides a mock tmux that keeps options in a temp directory, one file per
# option. A directory store works on Bash 3.2, which is what macOS ships, and it
# survives subshells, so values set inside a bats `run` are visible afterwards.
# Time is mocked so cache ages are deterministic.

setup_test_environment() {
  TEST_TMPDIR=$(mktemp -d)
  export TEST_TMPDIR
  export TMUX_TEST_MODE=1

  # On-disk tmux option store. Reset per test for isolation.
  MOCK_OPTS_DIR="${TEST_TMPDIR}/opts"
  export MOCK_OPTS_DIR
  mkdir -p "${MOCK_OPTS_DIR}"

  # Deterministic clock. Tests advance MOCK_EPOCH to simulate elapsed time.
  export MOCK_EPOCH=1000000

  # Reset source guards so each test re-sources fresh.
  unset _TMUX_PLUGIN_CONSTANTS_LOADED
  unset _TMUX_PLUGIN_HAS_COMMAND_LOADED
  unset _TMUX_PLUGIN_ERROR_LOGGER_LOADED
  unset _TMUX_PLUGIN_PLATFORM_LOADED
  unset _TMUX_PLUGIN_CACHE_LOADED
  unset _TMUX_PLUGIN_TMUX_OPS_LOADED
  unset _TMUX_PLUGIN_PUBLISH_LOADED
  unset _TMUX_PLUGIN_TICKER_LOADED

  if declare -f setup_test_environment_local >/dev/null; then
    setup_test_environment_local
  fi
}

cleanup_test_environment() {
  if [ -n "${TEST_TMPDIR:-}" ] && [ -d "${TEST_TMPDIR}" ]; then
    rm -rf "${TEST_TMPDIR}"
  fi
}

_mock_opt_file() {
  printf '%s/%s' "${MOCK_OPTS_DIR}" "$(printf '%s' "$1" | tr -c 'A-Za-z0-9_.-' '_')"
}

# Mock tmux: only the option verbs the libraries use. set-option writes a file,
# show-option reads it, and if-shell -F runs its commands when an option equals
# a value. Everything else is a no-op success.
tmux() {
  local verb="$1"
  shift || true
  case "${verb}" in
    set-option)
      local unset_flag=0
      local args=()
      while [ $# -gt 0 ]; do
        case "$1" in
          -gqu|-gu|-u) unset_flag=1 ;;
          -g|-q|-w|-p|-gq|-wq|-pq|-ga|-wqv|-gqv) ;;
          -t) shift ;;
          *) args+=("$1") ;;
        esac
        shift
      done
      local name="${args[0]:-}"
      [ -z "${name}" ] && return 0
      local file
      file="$(_mock_opt_file "${name}")"
      if [ "${unset_flag}" -eq 1 ]; then
        rm -f "${file}"
      else
        printf '%s' "${args[1]:-}" > "${file}"
      fi
      return 0
      ;;
    show-option)
      local name=""
      while [ $# -gt 0 ]; do
        case "$1" in
          -t) shift ;;
          -*) ;;
          *) name="$1" ;;
        esac
        shift
      done
      local file
      file="$(_mock_opt_file "${name}")"
      [ -f "${file}" ] && cat "${file}"
      return 0
      ;;
    if-shell)
      [ "${1:-}" = "-F" ] || return 0
      _mock_if_option_equals "${2:-}" || return 0
      _mock_run_commands "${3:-}"
      return 0
      ;;
    *)
      return 0
      ;;
  esac
}

_mock_if_option_equals() {
  local open='#{==:#{' name expected file current=""
  case "${1}" in
    "${open}"*) ;;
    *) return 1 ;;
  esac
  name="${1#"${open}"}"
  name="${name%%\}*}"
  expected="${1#*\},}"
  expected="${expected%\}}"
  file="$(_mock_opt_file "${name}")"
  [ -f "${file}" ] && current="$(cat "${file}")"
  [ "${current}" = "${expected}" ]
}

_mock_run_commands() {
  local rest="${1}" part
  local -a words
  while [ -n "${rest}" ]; do
    part="${rest%% ; *}"
    if [ "${part}" = "${rest}" ]; then
      rest=""
    else
      rest="${rest#* ; }"
    fi
    read -r -a words <<< "${part}"
    tmux "${words[@]}"
  done
}

# Mock date: +%s returns the controllable epoch; the log timestamp format
# returns a fixed string; everything else defers to the real date.
date() {
  case "$1" in
    +%s) echo "${MOCK_EPOCH:-1000000}" ;;
    '+%Y-%m-%d %H:%M:%S') echo "${MOCK_TIMESTAMP:-2026-01-15 14:30:00}" ;;
    *) command date "$@" ;;
  esac
}

function_exists() {
  declare -f "$1" >/dev/null
}

variable_exists() {
  [ -n "${!1:-}" ]
}

export -f _mock_opt_file
export -f _mock_if_option_equals
export -f _mock_run_commands
export -f tmux
export -f date

_HELPERS_LOCAL="$(dirname "${BASH_SOURCE[0]}")/helpers_local.bash"
if [ -f "${_HELPERS_LOCAL}" ]; then
  # shellcheck source=/dev/null
  source "${_HELPERS_LOCAL}"
fi
