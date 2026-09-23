#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export PLUGIN_LOG_DIR="${TEST_TMPDIR}/logs"
  export PLUGIN_LOG_FILE="${PLUGIN_LOG_DIR}/tiling.log"
  export PLUGIN_MAX_LOG_SIZE="1048576"
  export PLUGIN_MAX_LOG_LINES="1000"
  # Reset source guard to allow sourcing with our custom log dir
  unset _TMUX_PLUGIN_ERROR_LOGGER_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/error-logger.sh"
}

teardown() {
  cleanup_test_environment
}

@test "error-logger.sh - log_error function exists" {
  function_exists log_error
}

@test "error-logger.sh - log_error returns 0 with empty message" {
  run log_error "test" ""
  [[ "${status}" -eq 0 ]]
}

@test "error-logger.sh - log_error returns 0 when logging disabled" {
  export MOCK_TILING_ENABLE_LOGGING="0"
  run log_error "test" "some error"
  [[ "${status}" -eq 0 ]]
}

@test "error-logger.sh - log_error writes to file when logging enabled" {
  export MOCK_TILING_ENABLE_LOGGING="1"
  log_error "test-component" "test error message"
  [[ -f "${PLUGIN_LOG_FILE}" ]]
  grep -q "test-component" "${PLUGIN_LOG_FILE}"
  grep -q "test error message" "${PLUGIN_LOG_FILE}"
}

@test "error-logger.sh - log_error sanitizes component name" {
  export MOCK_TILING_ENABLE_LOGGING="1"
  log_error 'bad/comp!name' "test message"
  [[ -f "${PLUGIN_LOG_FILE}" ]]
  grep -q "badcompname" "${PLUGIN_LOG_FILE}"
}

@test "error-logger.sh - log_error includes timestamp" {
  export MOCK_TILING_ENABLE_LOGGING="1"
  log_error "timer" "timestamped"
  grep -qE '\[.*\] \[timer\] timestamped' "${PLUGIN_LOG_FILE}"
}

@test "error-logger.sh - log_error creates log directory if missing" {
  rm -rf "${PLUGIN_LOG_DIR}"
  unset _TMUX_PLUGIN_ERROR_LOGGER_LOADED
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/error-logger.sh"
  [[ -d "${PLUGIN_LOG_DIR}" ]]
}
