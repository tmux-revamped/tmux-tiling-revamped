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
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-vertical.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/resurrect.sh"
}

teardown() {
  cleanup_test_environment
}

@test "resurrect.sh - restore_layouts function exists" {
  function_exists restore_layouts
}

@test "resurrect.sh - restore_layouts succeeds" {
  run restore_layouts
  [[ "${status}" -eq 0 ]]
}

@test "resurrect.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_RESURRECT_LOADED}" ]]
  [[ "${_TILING_REVAMPED_RESURRECT_LOADED}" == "1" ]]
}

_resurrect_tmux_for() {
  export RESURRECT_LOG="${TEST_TMPDIR}/resurrect.log"
  export RESURRECT_LAYOUT="${1}"
  export RESURRECT_FLAGS="${2-brvc}"
  tmux() {
    printf '%s\n' "$*" >> "${RESURRECT_LOG}"
    case "$1" in
      list-windows) printf '%s\n' '@1|%1|1' ;;
      show-option)
        case "$*" in
          *@tiling_revamped_layout*) printf '%s\n' "${RESURRECT_LAYOUT}" ;;
          *@tiling_revamped_orientation*) printf '%s\n' "${RESURRECT_FLAGS}" ;;
          *) printf '\n' ;;
        esac ;;
      select-window) return "${RESURRECT_SELECT_RC:-0}" ;;
    esac
    return 0
  }
  export -f tmux
}

_record_applies() {
  _apply_bsp_layout() { printf 'applied bsp %s %s %s\n' "$1" "$2" "${TMUX_PANE}" >> "${RESURRECT_LOG}"; }
  apply_layout_grid() { printf 'applied grid %s\n' "${TMUX_PANE}" >> "${RESURRECT_LOG}"; }
  apply_layout_main_vertical() { printf 'applied main-vertical %s\n' "${TMUX_PANE}" >> "${RESURRECT_LOG}"; }
  apply_layout_main_horizontal() { printf 'applied main-horizontal %s\n' "${TMUX_PANE}" >> "${RESURRECT_LOG}"; }
  apply_layout_main_center() { printf 'applied main-center %s\n' "${TMUX_PANE}" >> "${RESURRECT_LOG}"; }
  apply_layout_deck() { printf 'applied deck %s\n' "${TMUX_PANE}" >> "${RESURRECT_LOG}"; }
  export -f _apply_bsp_layout apply_layout_grid apply_layout_main_vertical \
    apply_layout_main_horizontal apply_layout_main_center apply_layout_deck
}

@test "resurrect.sh - restore_layouts direct call with no windows" {
  # Arrange
  export MOCK_TMUX_LOG="${TEST_TMPDIR}/tmux.log"

  # Act
  restore_layouts

  # Assert
  ! grep -q '^select-window' "${MOCK_TMUX_LOG}"
}

@test "resurrect.sh - restore_layouts re-applies dwindle layout" {
  # Arrange
  _resurrect_tmux_for "dwindle" "brvc"
  _record_applies

  # Act
  restore_layouts

  # Assert
  grep -qx 'applied bsp false brvc %1' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts re-applies spiral layout" {
  # Arrange
  _resurrect_tmux_for "spiral" "brvs"
  _record_applies

  # Act
  restore_layouts

  # Assert
  grep -qx 'applied bsp true brvs %1' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts re-applies grid layout" {
  # Arrange
  _resurrect_tmux_for "grid"
  _record_applies

  # Act
  restore_layouts

  # Assert
  grep -qx 'applied grid %1' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts re-applies main-vertical layout" {
  # Arrange
  _resurrect_tmux_for "main-vertical"
  _record_applies

  # Act
  restore_layouts

  # Assert
  grep -qx 'applied main-vertical %1' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts re-applies main-horizontal layout" {
  # Arrange
  _resurrect_tmux_for "main-horizontal"
  _record_applies

  # Act
  restore_layouts

  # Assert
  grep -qx 'applied main-horizontal %1' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts re-applies main-center layout" {
  # Arrange
  _resurrect_tmux_for "main-center"
  _record_applies

  # Act
  restore_layouts

  # Assert
  grep -qx 'applied main-center %1' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts re-applies deck layout" {
  # Arrange
  _resurrect_tmux_for "deck"
  _record_applies

  # Act
  restore_layouts

  # Assert
  grep -qx 'applied deck %1' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts skips monocle layout" {
  # Arrange
  _resurrect_tmux_for "monocle"
  _record_applies

  # Act
  restore_layouts

  # Assert
  ! grep -q '^applied ' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts skips window with empty layout" {
  # Arrange
  _resurrect_tmux_for ""
  _record_applies

  # Act
  restore_layouts

  # Assert
  ! grep -q '^applied ' "${RESURRECT_LOG}" || false
  ! grep -q 'show-option -wqv -t @1 @tiling_revamped_orientation' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts defaults orientation when flags empty" {
  # Arrange
  _resurrect_tmux_for "dwindle" ""
  _record_applies

  # Act
  restore_layouts

  # Assert
  grep -qx 'applied bsp false brvc %1' "${RESURRECT_LOG}"
}

@test "resurrect.sh - restore_layouts continues when select-window fails" {
  # Arrange
  _resurrect_tmux_for "dwindle" "brvc"
  _record_applies
  export RESURRECT_SELECT_RC=1

  # Act
  run restore_layouts

  # Assert
  [[ "${status}" -eq 0 ]] || false
  ! grep -q '^applied ' "${RESURRECT_LOG}"
}

_resurrect_logging_tmux() {
  export RESURRECT_LOG="${TEST_TMPDIR}/resurrect.log"
  export RESURRECT_LAYOUT="${1}"
  export RESURRECT_FLAGS="${2-brvc}"
  tmux() {
    printf '%s\n' "$*" >> "${RESURRECT_LOG}"
    case "$1" in
      list-windows) printf '%s\n' '@1|%1|0' '@2|%4|1' ;;
      show-option)
        case "$*" in
          *@tiling_revamped_layout*) printf '%s\n' "${RESURRECT_LAYOUT}" ;;
          *@tiling_revamped_orientation*) printf '%s\n' "${RESURRECT_FLAGS}" ;;
          *) printf '\n' ;;
        esac ;;
      select-window) return "${RESURRECT_SELECT_RC:-0}" ;;
    esac
    return 0
  }
  export -f tmux
}

@test "resurrect.sh - restore_layouts covers every session and returns to the starting window" {
  # Arrange
  _resurrect_logging_tmux "grid"
  apply_layout_grid() { printf 'applied grid %s\n' "${TMUX_PANE}" >> "${RESURRECT_LOG}"; }
  export -f apply_layout_grid

  # Act
  restore_layouts

  # Assert
  grep -q '^list-windows -a ' "${RESURRECT_LOG}" || false
  grep -qx 'applied grid %1' "${RESURRECT_LOG}" || false
  grep -qx 'applied grid %4' "${RESURRECT_LOG}" || false
  [[ "$(grep '^select-window' "${RESURRECT_LOG}" | tail -n 1)" == "select-window -t @2" ]]
}
