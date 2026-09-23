#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export PLUGIN_LOG_NS="tiling-revamped"
  export PLUGIN_LOG_DIR="${TEST_TMPDIR}/logs"
  export PLUGIN_LOG_FILE="${PLUGIN_LOG_DIR}/tiling.log"
  export PLUGIN_LOG_OPTION="@tiling_revamped_enable_logging"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/error-logger.sh"
}

teardown() {
  cleanup_test_environment
}

@test "error-logger.sh - functions are defined" {
  function_exists log_error
  function_exists _logging_enabled
  function_exists _rotate_log
}

@test "error-logger.sh - log_error is a no-op for an empty message" {
  log_error comp ""
  [[ ! -f "${PLUGIN_LOG_FILE}" ]]
}

@test "error-logger.sh - log_error writes nothing when logging is disabled" {
  log_error comp "hello"
  [[ ! -f "${PLUGIN_LOG_FILE}" ]]
}

@test "error-logger.sh - log_error writes a line when logging is enabled" {
  export MOCK_TILING_ENABLE_LOGGING="1"
  log_error startup "hello world"
  [[ -f "${PLUGIN_LOG_FILE}" ]]
  grep -q "startup" "${PLUGIN_LOG_FILE}"
  grep -q "hello world" "${PLUGIN_LOG_FILE}"
}

@test "error-logger.sh - log_error sanitizes the component name" {
  export MOCK_TILING_ENABLE_LOGGING="1"
  log_error "bad;rm /" "msg"
  grep -q "badrm" "${PLUGIN_LOG_FILE}"
}

@test "error-logger.sh - _rotate_log trims an oversized log" {
  export MOCK_TILING_ENABLE_LOGGING="1"
  PLUGIN_MAX_LOG_SIZE=10
  PLUGIN_MAX_LOG_LINES=2
  export MOCK_FILE_SIZE=4096
  mkdir -p "${PLUGIN_LOG_DIR}"
  printf 'l1\nl2\nl3\nl4\nl5\n' > "${PLUGIN_LOG_FILE}"
  log_error comp "trigger"
  local lines
  lines=$(wc -l < "${PLUGIN_LOG_FILE}" | tr -d ' ')
  [[ "${lines}" -le 2 ]]
}
