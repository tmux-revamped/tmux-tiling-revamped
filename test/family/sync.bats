#!/usr/bin/env bats

setup() {
  SYNC="${BATS_TEST_DIRNAME}/../../family/bin/sync"
}

@test "sync - a member that cannot be cloned is a finding" {
  # Arrange
  local base="file://${BATS_TEST_TMPDIR}/nonexistent"

  # Act
  run "${SYNC}" --check --remote-base "${base}"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"could not be cloned from ${base}"* ]] || false
  [[ "${output}" != *"every member agrees"* ]]
}

@test "sync - a member missing from the members dir is a finding" {
  # Arrange
  local dir="${BATS_TEST_TMPDIR}/members"
  mkdir -p "${dir}"

  # Act
  run "${SYNC}" --check --members-dir "${dir}"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"not found under ${dir}"* ]]
}
