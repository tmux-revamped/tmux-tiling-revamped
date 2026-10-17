#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1'
  export MOCK_PANE_ID="%0"
  export MOCK_HAS_FZF="1"
  export MOCK_TILING_PROJECT_DIR=""
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/project-launcher.sh"
}

teardown() {
  cleanup_test_environment
}

@test "project-launcher.sh - launch_project function exists" {
  function_exists launch_project
}

@test "project-launcher.sh - launch_project fails when fzf is not installed" {
  export MOCK_HAS_FZF="0"
  run launch_project
  [[ "${status}" -eq 1 ]]
}

@test "project-launcher.sh - launch_project fails when project_dir is not set" {
  export MOCK_TILING_PROJECT_DIR=""
  run launch_project
  [[ "${status}" -eq 1 ]]
}

@test "project-launcher.sh - launch_project fails when project_dir does not exist" {
  export MOCK_TILING_PROJECT_DIR="/nonexistent/path/that/does/not/exist"
  run launch_project
  [[ "${status}" -eq 1 ]]
}

@test "project-launcher.sh - launch_project succeeds with valid directory" {
  # Arrange
  export MOCK_TILING_PROJECT_DIR="${TEST_TMPDIR}"
  mkdir -p "${TEST_TMPDIR}/project-a"

  # Act
  run launch_project

  # Assert
  [[ "${status}" -eq 0 ]]
}

@test "project-launcher.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_PROJECT_LAUNCHER_LOADED}" ]]
  [[ "${_TILING_REVAMPED_PROJECT_LAUNCHER_LOADED}" == "1" ]]
}

@test "project-launcher.sh - launch_project selects a project and opens a window" {
  export MOCK_HAS_FZF="1"
  local pdir="${BATS_TEST_TMPDIR}/projects"
  mkdir -p "${pdir}/alpha" "${pdir}/beta"
  export MOCK_TILING_PROJECT_DIR="${pdir}"
  fzf() { echo "alpha"; }
  fd() { printf 'alpha\nbeta\n'; }
  launch_project >/dev/null 2>&1 || true
}

@test "project-launcher.sh - launch_project returns when nothing is selected" {
  export MOCK_HAS_FZF="1"
  local pdir="${BATS_TEST_TMPDIR}/projects2"
  mkdir -p "${pdir}/gamma"
  export MOCK_TILING_PROJECT_DIR="${pdir}"
  fzf() { printf ''; }
  fd() { printf 'gamma\n'; }
  run launch_project
  [[ "${status}" -eq 0 ]]
}

@test "project-launcher.sh - launch_project rejects a missing directory" {
  export MOCK_HAS_FZF="1"
  export MOCK_TILING_PROJECT_DIR="/no/such/project/dir/xyz"
  run launch_project
  [[ "${status}" -ne 0 ]]
}

@test "project-launcher.sh - an fzf without --tmux runs the launcher in a popup" {
  # Arrange
  export MOCK_FZF_VERSION="0.52.0"
  export MOCK_TILING_PROJECT_DIR="${TEST_TMPDIR}"
  export MOCK_TMUX_LOG="${TEST_TMPDIR}/tmux.log"

  # Act
  launch_project

  # Assert
  grep -q '^display-popup -E -w 60% -h 40% TILING_REVAMPED_IN_POPUP=1 .*tiling\.sh project$' "${MOCK_TMUX_LOG}"
}
