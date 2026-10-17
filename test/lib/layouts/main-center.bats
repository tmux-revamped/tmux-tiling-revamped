#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_MAIN_CENTER_RATIO="60"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
}

teardown() {
  cleanup_test_environment
}

@test "main-center.sh - apply_layout_main_center function exists" {
  function_exists apply_layout_main_center
}

@test "main-center.sh - apply_layout_main_center succeeds with 3 panes" {
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 4 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 7 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center succeeds with 8 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6\n%7'
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - apply_layout_main_center respects custom ratio" {
  export MOCK_TILING_MAIN_CENTER_RATIO="80"
  run apply_layout_main_center
  [[ "${status}" -eq 0 ]]
}

@test "main-center.sh - _main_center_build produces balanced sides with 5 panes" {
  # Arrange
  local panes="%0 %1 %2 %3 %4"

  # Act
  run _main_center_build "${panes}" 200 50 60

  # Assert
  [[ "${status}" -eq 0 ]] || false
  [[ "${output}" == *",1"* ]] || false
  [[ "${output}" == *",2"* ]] || false
  [[ "${output}" == *",3"* ]] || false
  [[ "${output}" == *",4"* ]]
}

@test "main-center.sh - _main_center_build produces balanced sides with 7 panes" {
  # Arrange
  local panes="%0 %1 %2 %3 %4 %5 %6"

  # Act
  run _main_center_build "${panes}" 200 50 60

  # Assert
  [[ "${status}" -eq 0 ]] || false
  [[ "${output}" == *",0"* ]] || false
  [[ "${output}" == *",6"* ]]
}

@test "main-center.sh - _main_center_vstack produces vertical stack" {
  # Arrange
  local panes="%1 %2 %3"

  # Act
  run _main_center_vstack "${panes}" 0 0 40 50

  # Assert
  [[ "${status}" -eq 0 ]] || false
  [[ "${output}" == *"["* ]] || false
  [[ "${output}" == *",1"* ]] || false
  [[ "${output}" == *",2"* ]] || false
  [[ "${output}" == *",3"* ]]
}

@test "main-center.sh - _main_center_vstack single pane has no brackets" {
  run _main_center_vstack "%1" 0 0 40 50
  [[ "${status}" -eq 0 ]]
  [[ "${output}" != *"["* ]]
  [[ "${output}" == "40x50,0,0,1" ]]
}

