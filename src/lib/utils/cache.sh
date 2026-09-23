#!/usr/bin/env bash
#
# cache.sh: async, temp-file-free value cache.
#
# Every cached value lives in a tmux server user-option, never on disk. The hot
# path reads the cached option and returns instantly. When a value is stale, a
# detached background worker recomputes it and writes it back, so the tmux status
# render never blocks on slow work.
#
# State per key KEY (namespaced by CACHE_PREFIX):
#   @<CACHE_PREFIX>_<KEY>           the value
#   @<CACHE_PREFIX>_<KEY>_ts        unix epoch when it was written
#   @<CACHE_PREFIX>_<KEY>_lock      "1" while a worker is in flight
#   @<CACHE_PREFIX>_<KEY>_lock_ts   unix epoch when the lock was taken
#
# A plugin sets CACHE_PREFIX (e.g. "cpu_revamped") before using these helpers.
# Tests set CACHE_SYNC=1 to run the worker inline instead of in the background.

[[ -n "${_TMUX_PLUGIN_CACHE_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_CACHE_LOADED=1

_CACHE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "${_CACHE_SCRIPT_DIR}/../tmux/tmux-ops.sh"

# Default namespace and guard tuning. A plugin overrides CACHE_PREFIX.
CACHE_PREFIX="${CACHE_PREFIX:-tmux_plugin}"
# Seconds after which a held lock is treated as a dead worker and ignored.
CACHE_MAX_RUN="${CACHE_MAX_RUN:-20}"
# Sentinel age returned for a key that was never written.
CACHE_NEVER_AGE=999999999

_cache_now() {
  date +%s 2>/dev/null || echo 0
}

_cache_opt() {
  echo "@${CACHE_PREFIX}_${1}"
}

# cache_get KEY -> the cached value, empty when unset.
cache_get() {
  get_tmux_option "$(_cache_opt "${1}")" ""
}

# cache_set KEY VALUE -> store VALUE and stamp the write time.
cache_set() {
  local key="${1}"
  set_tmux_option "$(_cache_opt "${key}")" "${2}"
  set_tmux_option "$(_cache_opt "${key}_ts")" "$(_cache_now)"
}

# cache_age KEY -> seconds since KEY was written, or CACHE_NEVER_AGE if never.
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

# cache_is_fresh KEY MAX_AGE -> 0 when KEY is at most MAX_AGE seconds old.
cache_is_fresh() {
  local age
  age=$(cache_age "${1}")
  (( age <= ${2} ))
}

_cache_clear_lock() {
  set_tmux_option "$(_cache_opt "${1}_lock")" "0"
}

# cache_should_refresh KEY MAX_AGE -> 0 when a refresh is warranted.
# A refresh is warranted when the value is stale AND no live worker holds the
# lock. A lock older than CACHE_MAX_RUN is treated as a dead worker.
cache_should_refresh() {
  local key="${1}" max_age="${2}"
  cache_is_fresh "${key}" "${max_age}" && return 1
  if [[ "$(cache_get "${key}_lock")" == "1" ]]; then
    local lock_age
    lock_age=$(cache_age "${key}_lock")
    (( lock_age < CACHE_MAX_RUN )) && return 1
  fi
  return 0
}

# cache_refresh_if_stale KEY MAX_AGE WORKER [ARGS...]
# Echoes nothing and never blocks. When KEY is stale and unlocked, it takes the
# lock and runs WORKER detached. WORKER is expected to call cache_set KEY VALUE.
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

# _cache_spawn KEY WORKER [ARGS...] -> run WORKER detached, clearing the lock on
# exit. Isolated so the background glue can be exercised on its own.
_cache_spawn() {
  local key="${1}"
  shift
  (
    trap '_cache_clear_lock "'"${key}"'"' EXIT
    "$@"
  ) >/dev/null 2>&1 &
  disown 2>/dev/null || true
}

# cache_render KEY MAX_AGE WORKER [ARGS...]
# The hot-path helper a placeholder calls: trigger a background refresh when
# stale, then echo whatever value is currently cached.
cache_render() {
  local key="${1}" max_age="${2}"
  shift 2
  cache_refresh_if_stale "${key}" "${max_age}" "$@"
  cache_get "${key}"
}

# cache_set_if_stale KEY MAX_AGE PRODUCER [ARGS...]
# Recompute KEY synchronously from the PRODUCER stdout, but only when KEY is
# older than MAX_AGE. A value piggybacked inside another key's worker gets its
# own refresh cadence this way: the worker runs often to keep the fast value
# current, while a value behind this guard refreshes on its own slower schedule.
# Always returns 0 so a caller chaining several guards never trips on a false.
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
