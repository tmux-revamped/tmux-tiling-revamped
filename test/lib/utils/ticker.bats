#!/usr/bin/env bats
# shellcheck disable=SC1090,SC2034

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

TICKER_LIB="${BATS_TEST_DIRNAME}/../../../src/lib/utils/ticker.sh"

setup() {
  setup_test_environment
  unset _TMUX_PLUGIN_TICKER_LOADED
  source "${TICKER_LIB}"
  TICK_LOG="${TEST_TMPDIR}/ticks"
  export TICK_LOG
  _ticker_sleep() { printf 'sleep %s\n' "${1}" >> "${TICK_LOG}"; }
}

teardown() {
  cleanup_test_environment
}

count_ticks() {
  if [[ -f "${TICK_LOG}" ]]; then
    grep -c '^tick$' "${TICK_LOG}"
  else
    printf '0'
  fi
}

record_tick() {
  printf 'tick\n' >> "${TICK_LOG}"
}

hand_over_after_two() {
  record_tick
  if [[ "$(count_ticks)" -ge 2 ]]; then
    tmux set-option -gq "@demo_ticker_pid" "other"
  fi
}

stub_status_interval() {
  export STUB_INTERVAL="${1}"
  _ticker_tmux() {
    if [[ "$*" == *"status-interval"* ]]; then
      printf '%s' "${STUB_INTERVAL}"
      return 0
    fi
    tmux "$@"
  }
}

wait_for_file() {
  local attempt
  for attempt in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
    [[ -f "${1}" ]] && return 0
    sleep 0.1
  done
  return 1
}

@test "ticker - run claims ownership for its pid" {
  TICKER_MAX_TICKS=1

  ticker_run demo record_tick 4242

  [[ "$(tmux show-option -gqv @demo_ticker_pid)" == "4242" ]]
}

@test "ticker - run stops at the tick limit and reports it still owns the ticker" {
  TICKER_MAX_TICKS=3

  run ticker_run demo record_tick 4242

  [ "${status}" -eq 0 ]
  [[ "$(count_ticks)" == "3" ]]
}

@test "ticker - run stops when another ticker takes over" {
  TICKER_MAX_TICKS=10

  run ticker_run demo hand_over_after_two 4242

  [ "${status}" -eq 1 ]
  [[ "$(count_ticks)" == "2" ]]
}

@test "ticker - run stops when the server is gone" {
  TICKER_MAX_TICKS=10
  _ticker_tmux() { return 1; }

  run ticker_run demo record_tick 4242

  [ "${status}" -eq 1 ]
  [[ "$(count_ticks)" == "0" ]]
}

@test "ticker - the interval follows status-interval" {
  stub_status_interval 7

  run ticker_interval

  [[ "${output}" == "7" ]]
}

@test "ticker - a missing interval falls back to the default" {
  run ticker_interval

  [[ "${output}" == "${TICKER_DEFAULT_INTERVAL}" ]]
}

@test "ticker - a zero interval falls back to the default" {
  stub_status_interval 0

  run ticker_interval

  [[ "${output}" == "${TICKER_DEFAULT_INTERVAL}" ]]
}

@test "ticker - each tick sleeps for the interval" {
  TICKER_MAX_TICKS=2
  stub_status_interval 3

  ticker_run demo record_tick 4242

  [[ "$(grep -c '^sleep 3$' "${TICK_LOG}")" == "2" ]]
}

@test "ticker - start spawns the daemon subcommand" {
  _ticker_spawn() { printf 'spawn %s\n' "${1}" >> "${TICK_LOG}"; }

  ticker_start "/plugin/src/demo.sh"

  [[ "$(cat "${TICK_LOG}")" == "spawn /plugin/src/demo.sh" ]]
}

@test "ticker - spawn runs the script with the daemon argument in the background" {
  local script="${TEST_TMPDIR}/demo.sh"
  printf '#!/usr/bin/env bash\nprintf "%%s" "$1" > "%s/spawned"\n' "${TEST_TMPDIR}" > "${script}"
  chmod +x "${script}"

  _ticker_spawn "${script}"

  wait_for_file "${TEST_TMPDIR}/spawned"
  [[ "$(cat "${TEST_TMPDIR}/spawned")" == "daemon" ]]
}

@test "ticker - spawn detaches the daemon from the caller's stdin" {
  # Arrange
  local script="${TEST_TMPDIR}/reader.sh"
  printf '#!/usr/bin/env bash\ncat > "%s/stdin"\n: > "%s/read"\n' "${TEST_TMPDIR}" "${TEST_TMPDIR}" > "${script}"
  chmod +x "${script}"

  # Act
  (
    set -m
    _ticker_spawn "${script}"
  ) <<<"leaked"

  # Assert
  wait_for_file "${TEST_TMPDIR}/read"
  [[ "$(cat "${TEST_TMPDIR}/stdin")" == "" ]]
}

@test "ticker - the sleep seam is callable" {
  unset _TMUX_PLUGIN_TICKER_LOADED
  source "${TICKER_LIB}"

  run _ticker_sleep 0

  [ "${status}" -eq 0 ]
}

@test "ticker - a plugin interval option wins over the fallback" {
  tmux set-option -gq "@demo_interval" "12"

  run ticker_interval demo 30

  [[ "${output}" == "12" ]]
}

@test "ticker - the fallback applies when the plugin sets no interval" {
  run ticker_interval demo 30

  [[ "${output}" == "30" ]]
}

@test "ticker - an invalid plugin interval falls back to status-interval" {
  tmux set-option -gq "@demo_interval" "soon"
  stub_status_interval 4

  run ticker_interval demo ""

  [[ "${output}" == "4" ]]
}

@test "ticker - minute wakes one second after the next minute starts" {
  _ticker_second_of_minute() { printf '08'; }

  run ticker_interval demo minute

  [[ "${output}" == "53" ]]
}

@test "ticker - an unreadable second still yields a full minute" {
  _ticker_second_of_minute() { printf 'xx'; }

  run ticker_seconds_to_next_minute

  [[ "${output}" == "61" ]]
}

@test "ticker - run sleeps for the plugin fallback interval" {
  TICKER_MAX_TICKS=1

  ticker_run demo record_tick 4242 30

  [[ "$(grep -c '^sleep 30$' "${TICK_LOG}")" == "1" ]]
}

@test "ticker - the second-of-minute seam reads the clock" {
  run _ticker_second_of_minute

  [[ "${output}" =~ ^[0-9]{2}$ ]]
}

stub_ticker_tmux() {
  export TMUX_LOG="${TEST_TMPDIR}/tmux.log"
  _ticker_tmux() {
    printf '%s\n' "$*" >> "${TMUX_LOG}"
    case "${1} ${2:-} ${3:-}" in
      "show-option -gqv @demo_option_names") printf '%s' "${STUB_NAMES:-}" ;;
      "show-option -gqv @alpha") printf 'one' ;;
      "display-message -p "*) printf '%s' "${STUB_VALUES:-}" ;;
    esac
    return 0
  }
}

@test "ticker - an option is read from tmux once and its name is learned" {
  stub_ticker_tmux
  TICKER_PREFIX="demo"

  ticker_get_option "@alpha" "fallback" >/dev/null

  [[ "$(paste -sd'|' "${TMUX_LOG}")" == "show-option -gqv @alpha|set-option -gqa @demo_option_names  @alpha" ]]
}

@test "ticker - a learned option is served from memory" {
  stub_ticker_tmux
  TICKER_PREFIX="demo"
  ticker_get_option "@alpha" "" >/dev/null
  : > "${TMUX_LOG}"

  run ticker_get_option "@alpha" ""

  [[ "${output}" == "one" ]]
  [ ! -s "${TMUX_LOG}" ]
}

@test "ticker - an empty option returns the default" {
  stub_ticker_tmux
  TICKER_PREFIX="demo"

  run ticker_get_option "@empty" "fallback"

  [[ "${output}" == "fallback" ]]
}

@test "ticker - a write reaches tmux and the memory copy" {
  stub_ticker_tmux
  ticker_set_option "@beta" "two"

  run ticker_get_option "@beta" ""

  [[ "${output}" == "two" ]]
  [[ "$(head -1 "${TMUX_LOG}")" == "set-option -gq @beta two" ]]
}

@test "ticker - prefetch reads every learned option in one call" {
  stub_ticker_tmux
  TICKER_PREFIX="demo"
  export STUB_NAMES=" @a @b @a"
  export STUB_VALUES=$'1\x1f2 two\x1f'

  ticker_prefetch

  [[ "${TICKER_OPT_COUNT}" == "2" ]]
  [[ "${TICKER_OPT_VALUES[1]}" == "2 two" ]]
  [[ "$(grep -c '^display-message' "${TMUX_LOG}")" == "1" ]]
}

@test "ticker - prefetch drops the snapshot when fields are missing" {
  stub_ticker_tmux
  TICKER_PREFIX="demo"
  export STUB_NAMES=" @a @b"
  export STUB_VALUES=$'1\x1f'

  ticker_prefetch

  [[ "${TICKER_OPT_COUNT}" == "0" ]]
}

@test "ticker - prefetch with no learned names makes no display call" {
  stub_ticker_tmux
  TICKER_PREFIX="demo"

  ticker_prefetch

  [[ "$(grep -c '^display-message' "${TMUX_LOG}")" == "0" ]]
}

@test "ticker - install routes option reads through the snapshot" {
  stub_ticker_tmux
  ticker_install demo

  run get_tmux_option "@alpha" ""

  [[ "${output}" == "one" ]]
}

@test "ticker - install reads the clock from EPOCHSECONDS when bash has it" {
  stub_ticker_tmux
  EPOCHSECONDS="${EPOCHSECONDS:-1700000000}"

  ticker_install demo

  [[ "$(declare -f _cache_now)" == *'EPOCHSECONDS'* ]]
}

@test "ticker - unexport keeps functions defined but out of the environment" {
  demo_exported() { return 0; }
  export -f demo_exported

  ticker_unexport_functions

  declare -F demo_exported >/dev/null
  [[ -z "$(env | grep '^BASH_FUNC_demo_exported')" ]]
}

@test "ticker - a write outside the main shell goes straight to tmux" {
  stub_ticker_tmux
  TICKER_MAIN_PID=""

  ticker_set_option "@gamma" "3"

  [[ "$(head -1 "${TMUX_LOG}")" == "set-option -gq @gamma 3" ]]
}

@test "ticker - a write in the main shell joins the publish batch" {
  stub_ticker_tmux
  publish_add_raw() { printf '%s=%s\n' "${1}" "${2}" >> "${TEST_TMPDIR}/batch"; }
  TICKER_MAIN_PID="${BASHPID:-main}"
  [[ -n "${BASHPID:-}" ]] || skip "this bash has no BASHPID"

  ticker_set_option "@gamma" "3"

  [[ "$(cat "${TEST_TMPDIR}/batch")" == "@gamma=3" ]]
  [ ! -s "${TMUX_LOG}" ]
}
