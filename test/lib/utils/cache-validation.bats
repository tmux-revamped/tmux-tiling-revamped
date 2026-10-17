#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export CACHE_PREFIX="cache_validation"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/cache.sh"
  MARKER="${TEST_TMPDIR}/evaluated"
}

teardown() {
  cleanup_test_environment
}

@test "cache-validation - a non-numeric max age is never evaluated" {
  # Arrange
  cache_set key value
  local max_age="x[\$(touch ${MARKER})]"

  # Act
  run cache_is_fresh key "${max_age}"

  # Assert
  [ "${status}" -eq 1 ]
  [ ! -e "${MARKER}" ]
}

@test "cache-validation - a numeric max age still decides freshness" {
  # Arrange
  cache_set key value
  MOCK_EPOCH=$((MOCK_EPOCH + 5))

  # Act
  run cache_is_fresh key 10

  # Assert
  [ "${status}" -eq 0 ]
}

@test "cache-validation - a non-numeric max run falls back to the default" {
  # Arrange
  cache_set key_lock 1
  MOCK_EPOCH=$((MOCK_EPOCH + 100))
  export CACHE_MAX_RUN="x[\$(touch ${MARKER})]"

  # Act
  run cache_should_refresh key 10

  # Assert
  [ "${status}" -eq 0 ]
  [ ! -e "${MARKER}" ]
}
