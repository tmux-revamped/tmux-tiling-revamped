#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export CACHE_PREFIX="test_rev"
  export CACHE_SYNC=1
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/cache.sh"
}

teardown() {
  cleanup_test_environment
}

@test "cache.sh - public functions are defined" {
  function_exists cache_get
  function_exists cache_set
  function_exists cache_age
  function_exists cache_is_fresh
  function_exists cache_should_refresh
  function_exists cache_refresh_if_stale
  function_exists cache_render
  function_exists cache_set_if_stale
}

@test "cache.sh - _cache_opt namespaces the option name" {
  [[ "$(_cache_opt percent)" == "@test_rev_percent" ]]
}

@test "cache.sh - cache_get is empty for an unset key" {
  [[ -z "$(cache_get percent)" ]]
}

@test "cache.sh - cache_set then cache_get round-trips the value" {
  cache_set percent "42"
  [[ "$(cache_get percent)" == "42" ]]
}

@test "cache.sh - cache_set stamps the write time" {
  cache_set percent "42"
  [[ "$(get_tmux_option @test_rev_percent_ts)" == "1000000" ]]
}

@test "cache.sh - cache_age is the sentinel for a never-written key" {
  [[ "$(cache_age percent)" == "999999999" ]]
}

@test "cache.sh - cache_age reflects elapsed time" {
  cache_set percent "42"
  export MOCK_EPOCH=1000010
  [[ "$(cache_age percent)" == "10" ]]
}

@test "cache.sh - cache_age returns the sentinel for a non-numeric timestamp" {
  set_tmux_option @test_rev_percent_ts "garbage"
  [[ "$(cache_age percent)" == "999999999" ]]
}

@test "cache.sh - cache_is_fresh is true within max age" {
  cache_set percent "42"
  export MOCK_EPOCH=1000003
  cache_is_fresh percent 5
}

@test "cache.sh - cache_is_fresh is false beyond max age" {
  cache_set percent "42"
  export MOCK_EPOCH=1000010
  ! cache_is_fresh percent 5
}

@test "cache.sh - cache_should_refresh is false when fresh" {
  cache_set percent "42"
  export MOCK_EPOCH=1000001
  ! cache_should_refresh percent 5
}

@test "cache.sh - cache_should_refresh is true when stale and unlocked" {
  cache_set percent "42"
  export MOCK_EPOCH=1000010
  cache_should_refresh percent 5
}

@test "cache.sh - cache_should_refresh is false when a fresh lock is held" {
  cache_set percent "42"
  export MOCK_EPOCH=1000010
  cache_set percent_lock "1"
  ! cache_should_refresh percent 5
}

@test "cache.sh - cache_should_refresh is true when the lock is stale" {
  cache_set percent "42"
  cache_set percent_lock "1"
  export MOCK_EPOCH=1000030
  cache_should_refresh percent 5
}

@test "cache.sh - cache_refresh_if_stale runs the worker when stale" {
  cache_set percent "old"
  export MOCK_EPOCH=1000010
  _worker() { cache_set percent "new"; }
  cache_refresh_if_stale percent 5 _worker
  [[ "$(cache_get percent)" == "new" ]]
}

@test "cache.sh - cache_refresh_if_stale clears the lock after a sync run" {
  cache_set percent "old"
  export MOCK_EPOCH=1000010
  _worker() { :; }
  cache_refresh_if_stale percent 5 _worker
  [[ "$(cache_get percent_lock)" == "0" ]]
}

@test "cache.sh - cache_refresh_if_stale is a no-op when fresh" {
  cache_set percent "keep"
  export MOCK_EPOCH=1000001
  _worker() { cache_set percent "changed"; }
  cache_refresh_if_stale percent 5 _worker
  [[ "$(cache_get percent)" == "keep" ]]
}

@test "cache.sh - cache_render echoes the value and refreshes when stale" {
  cache_set percent "10"
  export MOCK_EPOCH=1000010
  _worker() { cache_set percent "20"; }
  run cache_render percent 5 _worker
  [[ "${output}" == "20" ]]
}

@test "cache.sh - cache_render on cold start refreshes then echoes" {
  export MOCK_EPOCH=1000010
  _worker() { cache_set percent "fresh"; }
  run cache_render percent 5 _worker
  [[ "${output}" == "fresh" ]]
}

@test "cache.sh - _cache_spawn runs the worker in the background" {
  unset CACHE_SYNC
  local marker="${TEST_TMPDIR}/ran"
  _worker() { echo "done" > "$1"; }
  _cache_spawn percent _worker "${marker}"
  local i
  for (( i=0; i<50; i++ )); do
    [[ -f "${marker}" ]] && break
    sleep 0.05
  done
  [[ -f "${marker}" ]]
}

@test "cache.sh - cache_refresh_if_stale backgrounds the worker without sync mode" {
  unset CACHE_SYNC
  cache_set percent "old"
  export MOCK_EPOCH=1000010
  local marker="${TEST_TMPDIR}/bg"
  _worker() { echo hi > "$1"; }
  cache_refresh_if_stale percent 5 _worker "${marker}"
  local i
  for (( i=0; i<50; i++ )); do
    [[ -f "${marker}" ]] && break
    sleep 0.05
  done
  [[ -f "${marker}" ]]
}

@test "cache.sh - cache_set_if_stale keeps a fresh value" {
  cache_set percent "keep"
  export MOCK_EPOCH=1000003
  _probe() { echo "changed"; }
  cache_set_if_stale percent 5 _probe
  [[ "$(cache_get percent)" == "keep" ]]
}

@test "cache.sh - cache_set_if_stale recomputes a stale value" {
  cache_set percent "keep"
  export MOCK_EPOCH=1000010
  _probe() { echo "changed"; }
  cache_set_if_stale percent 5 _probe
  [[ "$(cache_get percent)" == "changed" ]]
}

@test "cache.sh - cache_set_if_stale computes a never-written value" {
  _probe() { echo "fresh"; }
  cache_set_if_stale percent 5 _probe
  [[ "$(cache_get percent)" == "fresh" ]]
}

@test "cache.sh - cache_set_if_stale forwards args to the producer" {
  export MOCK_EPOCH=1000010
  _probe() { echo "v=${1}"; }
  cache_set_if_stale percent 5 _probe hello
  [[ "$(cache_get percent)" == "v=hello" ]]
}
