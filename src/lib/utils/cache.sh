#!/usr/bin/env bash

[[ -n "${_TMUX_PLUGIN_CACHE_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_CACHE_LOADED=1

_CACHE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_CACHE_SCRIPT_DIR}/../tmux/tmux-ops.sh"

CACHE_PREFIX="${CACHE_PREFIX:-tmux_plugin}"
CACHE_MAX_RUN_DEFAULT=20
CACHE_MAX_RUN="${CACHE_MAX_RUN:-${CACHE_MAX_RUN_DEFAULT}}"
CACHE_NEVER_AGE=999999999

_cache_now() {
  date +%s 2>/dev/null || echo 0
}

_cache_opt() {
  echo "@${CACHE_PREFIX}_${1}"
}

cache_get() {
  get_tmux_option "$(_cache_opt "${1}")" ""
}

cache_set() {
  local key="${1}"
  set_tmux_option "$(_cache_opt "${key}")" "${2}"
  set_tmux_option "$(_cache_opt "${key}_ts")" "$(_cache_now)"
}

cache_age() {
  local ts
  ts=$(get_tmux_option "$(_cache_opt "${1}_ts")" "")
  if [[ -z "${ts}" || ! "${ts}" =~ ^[0-9]+$ ]]; then
    echo "${CACHE_NEVER_AGE}"
    return 0
  fi
  local now
  now=$(_cache_now)
  echo "$(( now - ts ))"
}

cache_is_fresh() {
  local max_age="${2:-}"
  [[ "${max_age}" =~ ^[0-9]+$ ]] || return 1
  local age
  age=$(cache_age "${1}")
  (( age <= max_age ))
}

_cache_clear_lock() {
  set_tmux_option "$(_cache_opt "${1}_lock")" "0"
}

cache_should_refresh() {
  local key="${1}" max_age="${2}"
  cache_is_fresh "${key}" "${max_age}" && return 1
  if [[ "$(cache_get "${key}_lock")" == "1" ]]; then
    local lock_age max_run="${CACHE_MAX_RUN}"
    [[ "${max_run}" =~ ^[0-9]+$ ]] || max_run="${CACHE_MAX_RUN_DEFAULT}"
    lock_age=$(cache_age "${key}_lock")
    (( lock_age < max_run )) && return 1
  fi
  return 0
}

cache_refresh_if_stale() {
  local key="${1}" max_age="${2}"
  shift 2
  cache_should_refresh "${key}" "${max_age}" || return 0

  cache_set "${key}_lock" "1"

  if [[ -n "${CACHE_SYNC:-}" ]]; then
    "$@"
    _cache_clear_lock "${key}"
    return 0
  fi

  _cache_spawn "${key}" "$@"
  return 0
}

_cache_spawn() {
  local key="${1}"
  shift
  (
    trap '_cache_clear_lock "'"${key}"'"' EXIT
    "$@"
  ) >/dev/null 2>&1 &
  disown 2>/dev/null || true
}

cache_render() {
  local key="${1}" max_age="${2}"
  shift 2
  cache_refresh_if_stale "${key}" "${max_age}" "$@"
  cache_get "${key}"
}

cache_set_if_stale() {
  local key="${1}" max_age="${2}"
  shift 2
  cache_is_fresh "${key}" "${max_age}" && return 0
  cache_set "${key}" "$("$@")"
  return 0
}

export -f _cache_now
export -f _cache_opt
export -f cache_get
export -f cache_set
export -f cache_age
export -f cache_is_fresh
export -f _cache_clear_lock
export -f cache_should_refresh
export -f cache_refresh_if_stale
export -f _cache_spawn
export -f cache_render
export -f cache_set_if_stale
