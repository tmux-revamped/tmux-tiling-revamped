#!/usr/bin/env bash

[[ -n "${_TMUX_PLUGIN_TICKER_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_TICKER_LOADED=1

TICKER_MAX_TICKS="${TICKER_MAX_TICKS:-100000}"
TICKER_DEFAULT_INTERVAL=5
TICKER_SEP=$'\x1f'
TICKER_PREFIX=""
TICKER_FOUND=""
TICKER_MAIN_PID=""
TICKER_OPT_NAMES=()
TICKER_OPT_VALUES=()
TICKER_OPT_COUNT=0

_ticker_tmux() { tmux "$@"; }
_ticker_sleep() { sleep "${1}"; }
_ticker_spawn() {
  nohup "${1}" daemon </dev/null >/dev/null 2>&1 &
  disown 2>/dev/null || true
}

ticker_owner() {
  _ticker_tmux show-option -gqv "@${1}_ticker_pid" 2>/dev/null
}

ticker_claim() {
  _ticker_tmux set-option -gq "@${1}_ticker_pid" "${2}" 2>/dev/null
}

ticker_owns() {
  [[ "$(ticker_owner "${1}")" == "${2}" ]]
}

_ticker_second_of_minute() { date +%S; }

ticker_seconds_to_next_minute() {
  local second
  second="$(_ticker_second_of_minute)"
  [[ "${second}" =~ ^[0-9]+$ ]] || second=0
  printf '%s' "$(( 61 - 10#${second} ))"
}

ticker_interval() {
  local prefix="${1:-}" fallback="${2:-}" interval=""
  if [[ -n "${prefix}" ]]; then
    interval="$(_ticker_tmux show-option -gqv "@${prefix}_interval" 2>/dev/null)"
  fi
  [[ -n "${interval}" ]] || interval="${fallback}"
  if [[ "${interval}" == "minute" ]]; then
    ticker_seconds_to_next_minute
    return 0
  fi
  if [[ ! "${interval}" =~ ^[0-9]+$ ]] || ((interval < 1)); then
    interval="$(_ticker_tmux show-option -gqv status-interval 2>/dev/null)"
  fi
  if [[ ! "${interval}" =~ ^[0-9]+$ ]] || ((interval < 1)); then
    interval="${TICKER_DEFAULT_INTERVAL}"
  fi
  printf '%s' "${interval}"
}

ticker_option_find() {
  local i
  for ((i = 0; i < TICKER_OPT_COUNT; i++)); do
    if [[ "${TICKER_OPT_NAMES[i]}" == "${1}" ]]; then
      TICKER_FOUND="${TICKER_OPT_VALUES[i]}"
      return 0
    fi
  done
  return 1
}

ticker_option_store() {
  local i
  for ((i = 0; i < TICKER_OPT_COUNT; i++)); do
    if [[ "${TICKER_OPT_NAMES[i]}" == "${1}" ]]; then
      TICKER_OPT_VALUES[i]="${2}"
      return 0
    fi
  done
  TICKER_OPT_NAMES[TICKER_OPT_COUNT]="${1}"
  TICKER_OPT_VALUES[TICKER_OPT_COUNT]="${2}"
  TICKER_OPT_COUNT=$((TICKER_OPT_COUNT + 1))
}

ticker_get_option() {
  local name="${1}" default="${2:-}"
  if ! ticker_option_find "${name}"; then
    TICKER_FOUND="$(_ticker_tmux show-option -gqv "${name}" 2>/dev/null)"
    ticker_option_store "${name}" "${TICKER_FOUND}"
    _ticker_tmux set-option -gqa "@${TICKER_PREFIX}_option_names" " ${name}" 2>/dev/null
  fi
  if [[ -z "${TICKER_FOUND}" ]]; then
    printf '%s\n' "${default}"
  else
    printf '%s\n' "${TICKER_FOUND}"
  fi
}

ticker_in_main_shell() {
  [[ -n "${TICKER_MAIN_PID}" && "${BASHPID:-}" == "${TICKER_MAIN_PID}" ]]
}

ticker_set_option() {
  ticker_option_store "${1}" "${2}"
  if ticker_in_main_shell && declare -F publish_add_raw >/dev/null; then
    publish_add_raw "${1}" "${2}"
  else
    _ticker_tmux set-option -gq "${1}" "${2}" 2>/dev/null
  fi
}

ticker_reset_options() {
  TICKER_OPT_NAMES=()
  TICKER_OPT_VALUES=()
  TICKER_OPT_COUNT=0
}

ticker_prefetch() {
  local names name seen=" " format="" values rest expected=0
  ticker_reset_options
  names="$(_ticker_tmux show-option -gqv "@${TICKER_PREFIX}_option_names" 2>/dev/null)"
  for name in ${names}; do
    case "${seen}" in *" ${name} "*) continue ;; esac
    seen="${seen}${name} "
    format="${format}#{${name}}${TICKER_SEP}"
    expected=$((expected + 1))
  done
  ((expected > 0)) || return 0
  values="$(_ticker_tmux display-message -p "${format}" 2>/dev/null)" || return 0
  rest="${values}"
  for name in ${seen}; do
    [[ "${rest}" == *"${TICKER_SEP}"* ]] || {
      ticker_reset_options
      return 0
    }
    ticker_option_store "${name}" "${rest%%"${TICKER_SEP}"*}"
    rest="${rest#*"${TICKER_SEP}"}"
  done
}

ticker_unexport_functions() {
  local name
  while IFS= read -r name; do
    [[ -n "${name}" ]] && export -fn "${name?}"
  done <<<"$(compgen -A function)"
}

ticker_install() {
  TICKER_PREFIX="${1}"
  TICKER_MAIN_PID="${BASHPID:-}"
  ticker_unexport_functions
  get_tmux_option() { ticker_get_option "$@"; }
  set_tmux_option() { ticker_set_option "$@"; }
  if [[ -n "${EPOCHSECONDS:-}" ]]; then
    _cache_now() { printf '%s\n' "${EPOCHSECONDS}"; }
  fi
  if declare -F platform_os >/dev/null; then
    platform_os >/dev/null
    platform_arch >/dev/null
  fi
}

ticker_start() {
  _ticker_spawn "${1}"
}

ticker_run() {
  local prefix="${1}" tick="${2}" pid="${3}" fallback="${4:-}" count=0
  ticker_claim "${prefix}" "${pid}"
  ticker_install "${prefix}"
  while ((count < TICKER_MAX_TICKS)) && ticker_owns "${prefix}" "${pid}"; do
    ticker_prefetch
    "${tick}"
    _ticker_sleep "$(ticker_interval "${prefix}" "${fallback}")"
    count=$((count + 1))
  done
  ((count >= TICKER_MAX_TICKS)) && ticker_owns "${prefix}" "${pid}"
}
