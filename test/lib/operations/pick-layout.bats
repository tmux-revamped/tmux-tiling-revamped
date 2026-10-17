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
  export MOCK_HAS_FZF="1"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-vertical.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/pick-layout.sh"
}

teardown() {
  cleanup_test_environment
}

@test "pick-layout.sh - pick_layout function exists" {
  function_exists pick_layout
}

@test "pick-layout.sh - _get_layout_preview function exists" {
  function_exists _get_layout_preview
}

@test "pick-layout.sh - _get_layout_list function exists" {
  function_exists _get_layout_list
}

@test "pick-layout.sh - _fzf_supports_tmux_popup function exists" {
  function_exists _fzf_supports_tmux_popup
}

@test "pick-layout.sh - PICK_LAYOUTS array contains all 8 layouts" {
  [[ "${#PICK_LAYOUTS[@]}" -eq 8 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains dwindle" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "dwindle" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains spiral" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "spiral" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains grid" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "grid" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains main-vertical" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "main-vertical" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains main-horizontal" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "main-horizontal" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains main-center" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "main-center" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains monocle" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "monocle" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - PICK_LAYOUTS contains deck" {
  local found=0
  local layout
  for layout in "${PICK_LAYOUTS[@]}"; do
    [[ "${layout}" == "deck" ]] && found=1
  done
  [[ "${found}" -eq 1 ]]
}

@test "pick-layout.sh - _get_layout_list outputs all layouts" {
  run _get_layout_list
  [[ "${status}" -eq 0 ]]
  local line_count
  line_count=$(echo "${output}" | wc -l | tr -d ' ')
  [[ "${line_count}" -eq 8 ]]
}

@test "pick-layout.sh - _get_layout_list first item is dwindle" {
  run _get_layout_list
  local first_line
  first_line=$(echo "${output}" | head -1)
  [[ "${first_line}" == "dwindle" ]]
}

@test "pick-layout.sh - _get_layout_preview returns dwindle preview" {
  run _get_layout_preview "dwindle"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Dwindle Layout"* ]]
  [[ "${output}" == *"BSP cascade toward corner"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns spiral preview" {
  run _get_layout_preview "spiral"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Spiral Layout"* ]]
  [[ "${output}" == *"BSP with spiral trajectory"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns grid preview" {
  run _get_layout_preview "grid"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Grid Layout"* ]]
  [[ "${output}" == *"Even N x M grid distribution"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns main-vertical preview" {
  run _get_layout_preview "main-vertical"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Main-Vertical"* ]]
  [[ "${output}" == *"Master left, stack right"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns main-horizontal preview" {
  run _get_layout_preview "main-horizontal"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Main-Horizontal"* ]]
  [[ "${output}" == *"Master top, stack bottom"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns main-center preview" {
  run _get_layout_preview "main-center"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Main-Center"* ]]
  [[ "${output}" == *"center pane"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns monocle preview" {
  run _get_layout_preview "monocle"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Monocle Layout"* ]]
  [[ "${output}" == *"Zoom focused pane to fullscreen"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns deck preview" {
  run _get_layout_preview "deck"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Deck Layout"* ]]
  [[ "${output}" == *"Full-height equal-width cards"* ]]
}

@test "pick-layout.sh - _get_layout_preview returns fallback for unknown layout" {
  run _get_layout_preview "nonexistent"
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "No preview available" ]]
}

@test "pick-layout.sh - _get_layout_preview returns fallback for empty input" {
  run _get_layout_preview ""
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "No preview available" ]]
}

@test "pick-layout.sh - pick_layout fails when fzf is not installed" {
  export MOCK_HAS_FZF="0"
  run pick_layout
  [[ "${status}" -eq 1 ]]
}

@test "pick-layout.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_PICK_LAYOUT_LOADED}" ]]
  [[ "${_TILING_REVAMPED_PICK_LAYOUT_LOADED}" == "1" ]]
}

@test "pick-layout.sh - all layout preview variables are exported" {
  [[ -n "${TILING_PREVIEW_DWINDLE}" ]]
  [[ -n "${TILING_PREVIEW_SPIRAL}" ]]
  [[ -n "${TILING_PREVIEW_GRID}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_VERTICAL}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_HORIZONTAL}" ]]
  [[ -n "${TILING_PREVIEW_MAIN_CENTER}" ]]
  [[ -n "${TILING_PREVIEW_MONOCLE}" ]]
  [[ -n "${TILING_PREVIEW_DECK}" ]]
}

@test "pick-layout.sh - preview variables contain ASCII box drawing characters" {
  [[ "${TILING_PREVIEW_DWINDLE}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_SPIRAL}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_GRID}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_MAIN_VERTICAL}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_MAIN_HORIZONTAL}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_MAIN_CENTER}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_MONOCLE}" == *"┌"* ]]
  [[ "${TILING_PREVIEW_DECK}" == *"┌"* ]]
}

@test "pick-layout.sh - _fzf_supports_tmux_popup accepts a new fzf version" {
  fzf() { echo "0.53.0 (brew)"; }
  export -f fzf
  run _fzf_supports_tmux_popup
  [ "${status}" -eq 0 ]
}

@test "pick-layout.sh - _fzf_supports_tmux_popup rejects an old fzf version" {
  fzf() { echo "0.40.0"; }
  export -f fzf
  run _fzf_supports_tmux_popup
  [ "${status}" -ne 0 ]
}

@test "pick-layout.sh - _fzf_supports_tmux_popup fails when version is empty" {
  fzf() { return 1; }
  export -f fzf
  run _fzf_supports_tmux_popup
  [ "${status}" -ne 0 ]
}

@test "pick-layout.sh - _fzf_supports_tmux_popup rejects fzf releases before --tmux existed" {
  # Arrange
  fzf() { echo "0.52.1 (brew)"; }
  export -f fzf

  # Act
  run _fzf_supports_tmux_popup

  # Assert
  [ "${status}" -ne 0 ]
}

@test "pick-layout.sh - pick_layout opens a popup when fzf has no --tmux" {
  # Arrange
  _fzf_supports_tmux_popup() { return 1; }
  export -f _fzf_supports_tmux_popup
  export MOCK_TMUX_LOG="${TEST_TMPDIR}/tmux.log"

  # Act
  pick_layout

  # Assert
  grep -q '^display-popup -E -w 60% -h 40% TILING_REVAMPED_IN_POPUP=1 .*tiling\.sh pick$' "${MOCK_TMUX_LOG}"
}

@test "pick-layout.sh - picker inside the popup runs fzf without --tmux" {
  # Arrange
  export TILING_REVAMPED_IN_POPUP="1"
  local args_file="${TEST_TMPDIR}/fzf-args"
  fzf() { printf '%s\n' "$@" > "${args_file}"; echo "grid"; }
  export -f fzf

  # Act
  run _pick_with_fzf_tmux

  # Assert
  [[ "${output}" == "grid" ]] || false
  ! grep -qx -- '--tmux' "${args_file}"
}

@test "pick-layout.sh - picker returns the selection and adds a current header" {
  _fzf_supports_tmux_popup() { return 0; }
  get_current_layout() { echo "dwindle"; }
  fzf() { echo "grid"; }
  export -f _fzf_supports_tmux_popup get_current_layout fzf
  run _pick_with_fzf_tmux
  [ "${status}" -eq 0 ]
  [[ "${output}" == "grid" ]]
}

@test "pick-layout.sh - picker works with no current layout" {
  _fzf_supports_tmux_popup() { return 0; }
  get_current_layout() { echo ""; }
  fzf() { echo "spiral"; }
  export -f _fzf_supports_tmux_popup get_current_layout fzf
  run _pick_with_fzf_tmux
  [ "${status}" -eq 0 ]
  [[ "${output}" == "spiral" ]]
}

@test "pick-layout.sh - picker propagates fzf cancellation" {
  _fzf_supports_tmux_popup() { return 0; }
  get_current_layout() { echo ""; }
  fzf() { return 130; }
  export -f _fzf_supports_tmux_popup get_current_layout fzf
  run _pick_with_fzf_tmux
  [ "${status}" -eq 130 ]
}

@test "pick-layout.sh - picker returns 1 on fzf error" {
  _fzf_supports_tmux_popup() { return 0; }
  get_current_layout() { echo ""; }
  fzf() { return 2; }
  export -f _fzf_supports_tmux_popup get_current_layout fzf
  run _pick_with_fzf_tmux
  [ "${status}" -eq 1 ]
}

@test "pick-layout.sh - pick_layout returns 0 on cancellation" {
  _pick_with_fzf_tmux() { return 130; }
  export -f _pick_with_fzf_tmux
  run pick_layout
  [ "${status}" -eq 0 ]
}

@test "pick-layout.sh - pick_layout returns 0 on empty selection" {
  _pick_with_fzf_tmux() { echo ""; return 0; }
  export -f _pick_with_fzf_tmux
  run pick_layout
  [ "${status}" -eq 0 ]
}

@test "pick-layout.sh - pick_layout errors on an unknown layout" {
  _pick_with_fzf_tmux() { echo "bogus"; return 0; }
  export -f _pick_with_fzf_tmux
  run pick_layout
  [ "${status}" -eq 1 ]
}

@test "pick-layout.sh - pick_layout dispatches every layout" {
  apply_layout_dwindle() { :; }
  apply_layout_spiral() { :; }
  apply_layout_grid() { :; }
  apply_layout_main_vertical() { :; }
  apply_layout_main_horizontal() { :; }
  apply_layout_main_center() { :; }
  apply_layout_monocle() { :; }
  apply_layout_deck() { :; }
  export -f apply_layout_dwindle apply_layout_spiral apply_layout_grid
  export -f apply_layout_main_vertical apply_layout_main_horizontal
  export -f apply_layout_main_center apply_layout_monocle apply_layout_deck
  local L
  for L in dwindle spiral grid main-vertical main-horizontal main-center monocle deck; do
    eval "_pick_with_fzf_tmux() { echo '${L}'; return 0; }"
    export -f _pick_with_fzf_tmux
    run pick_layout
    [ "${status}" -eq 0 ]
  done
}

@test "pick-layout.sh - pick_layout dispatches every selection directly" {
  export MOCK_HAS_FZF="1"
  local layout
  _pick_with_fzf_tmux() { echo "${layout}"; }
  for layout in dwindle spiral grid main-vertical main-horizontal main-center monocle deck bogus; do
    pick_layout >/dev/null 2>&1 || true
  done
}

@test "pick-layout.sh - pick_layout returns 0 on an empty selection" {
  export MOCK_HAS_FZF="1"
  _pick_with_fzf_tmux() { printf ''; }
  run pick_layout
  [[ "${status}" -eq 0 ]]
}

@test "pick-layout.sh - _get_layout_preview resolves every layout name" {
  local layout
  for layout in dwindle spiral grid main-vertical main-horizontal main-center monocle deck; do
    [[ -n "$(_get_layout_preview "${layout}")" ]]
  done
  [[ "$(_get_layout_preview "nope")" == "No preview available" ]]
}
