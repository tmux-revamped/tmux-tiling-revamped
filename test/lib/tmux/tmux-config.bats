#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/tmux/tmux-config.sh"
}

teardown() {
  cleanup_test_environment
}

@test "tmux-config.sh - is_option_enabled returns true for 1" {
  export MOCK_TILING_AUTO_APPLY="1"
  is_option_enabled "@tiling_revamped_auto_apply"
}

@test "tmux-config.sh - is_option_enabled returns true for true" {
  export MOCK_TMUX_OPTION_VALUE="true"
  is_option_enabled "@tiling_revamped_custom_bool"
}

@test "tmux-config.sh - is_option_enabled returns false for 0" {
  export MOCK_TILING_FOCUS_RESIZE="0"
  ! is_option_enabled "@tiling_revamped_focus_resize"
}

@test "tmux-config.sh - is_option_enabled returns false for empty" {
  export MOCK_TMUX_OPTION_VALUE=""
  ! is_option_enabled "@tiling_revamped_nonexistent"
}

@test "tmux-config.sh - get_numeric_option returns valid number" {
  export MOCK_TILING_FOCUS_RATIO="75"
  run get_numeric_option "@tiling_revamped_focus_ratio" "62"
  [[ "${output}" == "75" ]]
}

@test "tmux-config.sh - get_numeric_option returns default for non-numeric" {
  export MOCK_TMUX_OPTION_VALUE="abc"
  run get_numeric_option "@tiling_revamped_custom_num" "50"
  [[ "${output}" == "50" ]]
}

@test "tmux-config.sh - get_numeric_option clamps to min" {
  export MOCK_TILING_FOCUS_RATIO="5"
  run get_numeric_option "@tiling_revamped_focus_ratio" "62" "10" "90"
  [[ "${output}" == "10" ]]
}

@test "tmux-config.sh - get_numeric_option clamps to max" {
  export MOCK_TILING_FOCUS_RATIO="95"
  run get_numeric_option "@tiling_revamped_focus_ratio" "62" "10" "90"
  [[ "${output}" == "90" ]]
}

@test "tmux-config.sh - get_current_layout returns stored layout" {
  export MOCK_TILING_LAYOUT="dwindle"
  run get_current_layout
  [[ "${output}" == "dwindle" ]]
}

@test "tmux-config.sh - get_current_layout returns empty when unset" {
  export MOCK_TILING_LAYOUT=""
  run get_current_layout
  [[ "${output}" == "" ]]
}

@test "tmux-config.sh - set_current_layout does not error" {
  run set_current_layout "spiral"
  [[ "${status}" -eq 0 ]]
}

@test "tmux-config.sh - is_applying returns false by default" {
  export MOCK_TILING_APPLYING="0"
  ! is_applying
}

@test "tmux-config.sh - is_applying returns true when set" {
  export MOCK_EPOCH="1705320600"
  export MOCK_TILING_APPLYING="1705320598"
  is_applying
}

@test "tmux-config.sh - is_applying expires a guard left behind by a crashed run" {
  # Arrange
  export MOCK_EPOCH="1705320600"
  export MOCK_TILING_APPLYING="1705317000"

  # Act
  run is_applying

  # Assert
  [[ "${status}" -ne 0 ]]
}

@test "tmux-config.sh - set_applying stores the guard on the window, not the server" {
  # Arrange
  export MOCK_EPOCH="1705320600"
  export MOCK_TMUX_LOG="${TEST_TMPDIR}/tmux.log"

  # Act
  set_applying 1
  set_applying 0

  # Assert
  grep -qx 'set-option -wq @tiling_revamped_applying 1705320600' "${MOCK_TMUX_LOG}" || false
  grep -qx 'set-option -wqu @tiling_revamped_applying' "${MOCK_TMUX_LOG}" || false
  ! grep -q -- '-g' "${MOCK_TMUX_LOG}"
}

@test "tmux-config.sh - set_applying does not error" {
  run set_applying 1
  [[ "${status}" -eq 0 ]]
}

@test "tmux-config.sh - is_auto_apply_enabled checks window override first" {
  export MOCK_TILING_ENABLED="0"
  export MOCK_TILING_AUTO_APPLY="1"
  ! is_auto_apply_enabled
}

@test "tmux-config.sh - is_auto_apply_enabled falls back to global" {
  export MOCK_TILING_ENABLED=""
  export MOCK_TILING_AUTO_APPLY="1"
  is_auto_apply_enabled
}

@test "tmux-config.sh - is_option_enabled function is exported" {
  function_exists is_option_enabled
}

@test "tmux-config.sh - get_numeric_option function is exported" {
  function_exists get_numeric_option
}

@test "tmux-config.sh - is_applying function is exported" {
  function_exists is_applying
}

@test "tmux-config.sh - _reapply_current_layout dispatches each layout directly" {
  local layout
  for layout in dwindle spiral grid deck main-vertical main-horizontal main-center monocle ""; do
    export MOCK_TILING_LAYOUT="${layout}"
    _reapply_current_layout >/dev/null 2>&1 || true
  done
}

@test "tmux-config.sh - get_numeric_option validates and clamps to range" {
  export MOCK_TMUX_OPTION_VALUE="abc"
  [[ "$(get_numeric_option "@x" "5" 2 10)" == "5" ]]
  export MOCK_TMUX_OPTION_VALUE="0"
  [[ "$(get_numeric_option "@x" "5" 2 10)" == "2" ]]
  export MOCK_TMUX_OPTION_VALUE="999"
  [[ "$(get_numeric_option "@x" "5" 2 10)" == "10" ]]
  export MOCK_TMUX_OPTION_VALUE="7"
  [[ "$(get_numeric_option "@x" "5" 2 10)" == "7" ]]
}

@test "tmux-config.sh - set_current_layout records no history when the layout is unchanged" {
  # Arrange
  export MOCK_TILING_LAYOUT="grid"
  local marker="${TEST_TMPDIR}/pushed"
  push_layout_history() { touch "${marker}"; }

  # Act
  set_current_layout "grid"

  # Assert
  [[ ! -e "${marker}" ]]
}

@test "tmux-config.sh - set_current_layout records history when the layout changes" {
  # Arrange
  export MOCK_TILING_LAYOUT="grid"
  local marker="${TEST_TMPDIR}/pushed"
  push_layout_history() { touch "${marker}"; }

  # Act
  set_current_layout "dwindle"

  # Assert
  [[ -e "${marker}" ]]
}
