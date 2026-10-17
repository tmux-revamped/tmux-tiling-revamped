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

# Direct-call coverage. The default mock tmux does not emit windows for
# list-windows, so restore_layouts loops over nothing. These tests install a
# per-test tmux that emits a window plus a stored layout, driving every branch
# of the case statement inside the loop body.

# _resurrect_tmux_factory LAYOUT FLAGS: print a tmux override that emits one
# window for list-windows and the given layout/flags for show-option.
_resurrect_tmux_for() {
  local layout="$1" flags="${2:-brvc}"
  eval "tmux() {
    case \"\$1\" in
      list-windows) printf '%s\\n' '@1' ;;
      show-option)
        case \"\$*\" in
          *@tiling_revamped_layout*) printf '%s\\n' '${layout}' ;;
          *@tiling_revamped_orientation*) printf '%s\\n' '${flags}' ;;
          *) printf '%s\\n' '' ;;
        esac ;;
      select-window) return 0 ;;
      *) return 0 ;;
    esac
  }"
  export -f tmux
}

@test "resurrect.sh - restore_layouts direct call with no windows" {
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts re-applies dwindle layout" {
  _apply_bsp_layout() { return 0; }
  export -f _apply_bsp_layout
  _resurrect_tmux_for "dwindle" "brvc"
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts re-applies spiral layout" {
  _apply_bsp_layout() { return 0; }
  export -f _apply_bsp_layout
  _resurrect_tmux_for "spiral" "brvs"
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts re-applies grid layout" {
  apply_layout_grid() { return 0; }
  export -f apply_layout_grid
  _resurrect_tmux_for "grid"
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts re-applies main-vertical layout" {
  apply_layout_main_vertical() { return 0; }
  export -f apply_layout_main_vertical
  _resurrect_tmux_for "main-vertical"
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts re-applies main-horizontal layout" {
  apply_layout_main_horizontal() { return 0; }
  export -f apply_layout_main_horizontal
  _resurrect_tmux_for "main-horizontal"
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts re-applies main-center layout" {
  apply_layout_main_center() { return 0; }
  export -f apply_layout_main_center
  _resurrect_tmux_for "main-center"
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts re-applies deck layout" {
  apply_layout_deck() { return 0; }
  export -f apply_layout_deck
  _resurrect_tmux_for "deck"
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts skips monocle layout" {
  _resurrect_tmux_for "monocle"
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts skips window with empty layout" {
  tmux() {
    case "$1" in
      list-windows) printf '%s\n' '@1' ;;
      show-option) printf '%s\n' '' ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts defaults orientation when flags empty" {
  _apply_bsp_layout() { return 0; }
  export -f _apply_bsp_layout
  tmux() {
    case "$1" in
      list-windows) printf '%s\n' '@1' ;;
      show-option)
        case "$*" in
          *@tiling_revamped_layout*) printf '%s\n' 'dwindle' ;;
          *) printf '%s\n' '' ;;
        esac ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  restore_layouts >/dev/null 2>&1
}

@test "resurrect.sh - restore_layouts continues when select-window fails" {
  _apply_bsp_layout() { return 0; }
  export -f _apply_bsp_layout
  tmux() {
    case "$1" in
      list-windows) printf '%s\n' '@1' ;;
      show-option)
        case "$*" in
          *@tiling_revamped_layout*) printf '%s\n' 'dwindle' ;;
          *@tiling_revamped_orientation*) printf '%s\n' 'brvc' ;;
          *) printf '%s\n' '' ;;
        esac ;;
      select-window) return 1 ;;
      *) return 0 ;;
    esac
  }
  export -f tmux
  restore_layouts >/dev/null 2>&1
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
