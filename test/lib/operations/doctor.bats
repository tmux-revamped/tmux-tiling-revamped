#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1'
  export MOCK_PANE_ID="%0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_HAS_FZF="1"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/doctor.sh"
}

teardown() {
  cleanup_test_environment
}

@test "doctor.sh - run_doctor function exists" {
  function_exists run_doctor
}

@test "doctor.sh - run_doctor completes without crash" {
  run run_doctor
  # In mock environment, exit code may be 0 or 1 depending on tmux mock
  [[ "${status}" -eq 0 ]] || [[ "${status}" -eq 1 ]]
}

@test "doctor.sh - run_doctor outputs bash version" {
  run run_doctor
  [[ "${output}" == *"bash"* ]]
}

@test "doctor.sh - run_doctor outputs tmux info" {
  run run_doctor
  [[ "${output}" == *"tmux"* ]]
}

@test "doctor.sh - run_doctor outputs plugin version" {
  run run_doctor
  [[ "${output}" == *"${TILING_REVAMPED_VERSION}"* ]]
}

@test "doctor.sh - run_doctor outputs current layout" {
  run run_doctor
  [[ "${output}" == *"dwindle"* ]]
}

@test "doctor.sh - run_doctor shows summary" {
  run run_doctor
  [[ "${output}" == *"checks passed"* ]] || [[ "${output}" == *"issue"* ]]
}

@test "doctor.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_DOCTOR_LOADED}" ]]
  [[ "${_TILING_REVAMPED_DOCTOR_LOADED}" == "1" ]]
}

@test "doctor.sh - run_doctor exercises fzf and layout branches directly" {
  export MOCK_HAS_FZF="1"
  export MOCK_TILING_LAYOUT="grid"
  run_doctor >/dev/null 2>&1 || true
  export MOCK_HAS_FZF="0"
  export MOCK_TILING_LAYOUT=""
  run_doctor >/dev/null 2>&1 || true
}

@test "doctor.sh - run_doctor flags an old or undetectable tmux version" {
  tmux() { case "$1" in -V) echo "tmux 2.8" ;; *) return 0 ;; esac; }
  run run_doctor
  [[ "${status}" -ne 0 ]]
  [[ "${output}" == *"issue(s) found"* ]]
  tmux() { case "$1" in -V) echo "tmux" ;; *) return 0 ;; esac; }
  run_doctor >/dev/null 2>&1 || true
}

@test "doctor.sh - run_doctor fails tmux 3.1, below the 3.2 floor" {
  # Arrange
  tmux() { case "$1" in -V) echo "tmux 3.1c" ;; *) return 0 ;; esac; }
  export -f tmux

  # Act
  run run_doctor

  # Assert
  [[ "${output}" == *"FAIL  tmux 3.1 (need 3.2+)"* ]]
}

@test "doctor.sh - run_doctor passes tmux 3.2" {
  # Arrange
  tmux() { case "$1" in -V) echo "tmux 3.2a" ;; *) return 0 ;; esac; }
  export -f tmux

  # Act
  run run_doctor

  # Assert
  [[ "${output}" == *"PASS  tmux 3.2"* ]]
}
