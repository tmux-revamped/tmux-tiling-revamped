#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  export MOCK_TILING_LAYOUT_HISTORY=""
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-vertical.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/undo-layout.sh"
}

teardown() {
  cleanup_test_environment
}

@test "undo-layout.sh - undo_layout function exists" {
  function_exists undo_layout
}

@test "undo-layout.sh - push_layout_history function exists" {
  function_exists push_layout_history
}

@test "undo-layout.sh - undo_layout returns 0 with empty history" {
  export MOCK_TILING_LAYOUT_HISTORY=""
  run undo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - push_layout_history succeeds" {
  run push_layout_history
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - push_layout_history does nothing when no layout set" {
  export MOCK_TILING_LAYOUT=""
  run push_layout_history
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - undo_layout succeeds with valid history" {
  export MOCK_TILING_LAYOUT_HISTORY="grid:brvc"
  run undo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - undo_layout succeeds with multi-entry history" {
  export MOCK_TILING_LAYOUT_HISTORY="grid:brvc|dwindle:brvc|spiral:brvs"
  run undo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - undo_layout fails with unknown layout in history" {
  export MOCK_TILING_LAYOUT_HISTORY="nonexistent:brvc"
  run undo_layout
  [[ "${status}" -eq 1 ]]
}

@test "undo-layout.sh - TILING_MAX_UNDO_DEPTH is set to 10" {
  [[ "${TILING_MAX_UNDO_DEPTH}" -eq 10 ]]
}

@test "undo-layout.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_UNDO_LAYOUT_LOADED}" ]]
  [[ "${_TILING_REVAMPED_UNDO_LAYOUT_LOADED}" == "1" ]]
}

@test "undo-layout.sh - undo_layout dispatches every layout directly" {
  local layout
  for layout in dwindle spiral grid main-vertical main-horizontal main-center monocle deck bogus; do
    export MOCK_TILING_LAYOUT_HISTORY="${layout}:brvc|prev:brvc"
    undo_layout >/dev/null 2>&1 || true
  done
}

@test "undo-layout.sh - push_layout_history trims beyond the max depth" {
  # Arrange
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_LAYOUT_HISTORY="a:b|a:b|a:b|a:b|a:b|a:b|a:b|a:b|a:b|a:b|a:b|a:b"
  local cap="${TEST_TMPDIR}/trimmed-history.txt"
  set_window_option() {
    [[ "$1" == "@tiling_revamped_layout_history" ]] && printf '%s\n' "$2" > "${cap}"
    return 0
  }

  # Act
  push_layout_history

  # Assert
  [[ "$(tr '|' '\n' < "${cap}" | grep -c .)" -eq 10 ]] || false
  grep -q '^dwindle:brvc|a:b|' "${cap}"
}

@test "undo-layout.sh - redo_layout function exists" {
  function_exists redo_layout
}

@test "undo-layout.sh - _stack_push function exists" {
  function_exists _stack_push
}

@test "undo-layout.sh - _current_entry function exists" {
  function_exists _current_entry
}

@test "undo-layout.sh - _apply_layout_entry function exists" {
  function_exists _apply_layout_entry
}

@test "undo-layout.sh - redo_layout returns 0 with empty redo stack" {
  export MOCK_TILING_LAYOUT_REDO=""
  run redo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - redo_layout succeeds with a valid redo entry" {
  export MOCK_TILING_LAYOUT_REDO="grid:brvc"
  run redo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - redo_layout succeeds with a multi-entry redo stack" {
  export MOCK_TILING_LAYOUT_REDO="spiral:brvs|dwindle:brvc"
  run redo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - redo_layout fails with an unknown layout" {
  export MOCK_TILING_LAYOUT_REDO="bogus:brvc"
  run redo_layout
  [[ "${status}" -eq 1 ]]
}

@test "undo-layout.sh - redo_layout returns 0 when the entry has no layout" {
  export MOCK_TILING_LAYOUT_REDO=":brvc"
  run redo_layout
  [[ "${status}" -eq 0 ]]
}

@test "undo-layout.sh - _current_entry renders layout and flags" {
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  run _current_entry
  [[ "${output}" == "dwindle:brvc" ]]
}

@test "undo-layout.sh - _current_entry is empty with no layout" {
  export MOCK_TILING_LAYOUT=""
  run _current_entry
  [[ -z "${output}" ]]
}

@test "undo-layout.sh - _apply_layout_entry dispatches every known layout" {
  local layout
  for layout in dwindle spiral grid main-vertical main-horizontal main-center monocle deck; do
    run _apply_layout_entry "${layout}" "brvc"
    [[ "${status}" -eq 0 ]]
  done
}

@test "undo-layout.sh - _apply_layout_entry fails on an unknown layout" {
  run _apply_layout_entry "nope" "brvc"
  [[ "${status}" -eq 1 ]]
}

@test "undo-layout.sh - _stack_push ignores an empty entry" {
  set_window_option() { echo "set $1" >> "${TEST_TMPDIR}/sp.txt"; }
  export -f set_window_option
  run _stack_push "@tiling_revamped_layout_redo" ""
  [[ "${status}" -eq 0 ]]
  [[ ! -f "${TEST_TMPDIR}/sp.txt" ]]
}

@test "undo-layout.sh - _stack_push trims to the max depth" {
  export MOCK_TILING_LAYOUT_REDO="a:b|a:b|a:b|a:b|a:b|a:b|a:b|a:b|a:b|a:b"
  local cap="${TEST_TMPDIR}/trim.txt"
  set_window_option() { printf '%s\n' "$2" > "${cap}"; }
  export -f set_window_option
  run _stack_push "@tiling_revamped_layout_redo" "new:x"
  [[ "${status}" -eq 0 ]]
  local entries
  entries=$(tr '|' '\n' < "${cap}" | grep -c .)
  [[ "${entries}" -eq 10 ]]
  grep -q '^new:x|' "${cap}"
}

@test "undo-layout.sh - undo_layout records the prior layout on the redo stack" {
  export MOCK_TILING_LAYOUT_HISTORY="grid:brvc"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  local cap="${TEST_TMPDIR}/redo.txt"
  set_window_option() { printf '%s|%s\n' "$1" "$2" >> "${cap}"; }
  export -f set_window_option
  run undo_layout
  [[ "${status}" -eq 0 ]]
  grep -q '@tiling_revamped_layout_redo|dwindle:brvc' "${cap}"
}

@test "undo-layout.sh - a fresh layout change clears the redo stack" {
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  local cap="${TEST_TMPDIR}/clear.txt"
  set_window_option() { printf '%s=[%s]\n' "$1" "$2" >> "${cap}"; }
  export -f set_window_option
  run push_layout_history
  [[ "${status}" -eq 0 ]]
  grep -q '@tiling_revamped_layout_redo=\[\]' "${cap}"
}

@test "undo-layout.sh - push_layout_history is a no-op during replay" {
  export TILING_REVAMPED_REPLAYING="1"
  export MOCK_TILING_LAYOUT="dwindle"
  local cap="${TEST_TMPDIR}/replay.txt"
  set_window_option() { echo "$1" >> "${cap}"; }
  export -f set_window_option
  run push_layout_history
  [[ "${status}" -eq 0 ]]
  [[ ! -f "${cap}" ]]
}

@test "undo-layout.sh - redo_layout pushes the prior layout back onto history" {
  export MOCK_TILING_LAYOUT_REDO="grid:brvc"
  export MOCK_TILING_LAYOUT="spiral"
  export MOCK_TILING_ORIENTATION="brvs"
  local cap="${TEST_TMPDIR}/hist.txt"
  set_window_option() { printf '%s|%s\n' "$1" "$2" >> "${cap}"; }
  export -f set_window_option
  run redo_layout
  [[ "${status}" -eq 0 ]]
  grep -q '@tiling_revamped_layout_history|spiral:brvs' "${cap}"
}

@test "undo-layout.sh - push_layout_history skips an entry already at the head" {
  # Arrange
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  export MOCK_TILING_LAYOUT_HISTORY="dwindle:brvc|grid:brvc"
  local cap="${TEST_TMPDIR}/dedupe.txt"
  set_window_option() { printf '%s=[%s]\n' "$1" "$2" >> "${cap}"; }

  # Act
  push_layout_history

  # Assert
  [[ ! -e "${cap}" ]]
}

@test "undo-layout.sh - push_layout_history records nothing for automatic re-tiling" {
  # Arrange
  export TILING_REVAMPED_AUTOMATIC="1"
  export MOCK_TILING_LAYOUT="grid"
  local cap="${TEST_TMPDIR}/automatic.txt"
  set_window_option() { printf '%s=[%s]\n' "$1" "$2" >> "${cap}"; }

  # Act
  push_layout_history

  # Assert
  [[ ! -e "${cap}" ]]
}
