#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_LAYOUT="dwindle"
  export MOCK_TILING_ORIENTATION="brvc"
  export MOCK_TILING_MAIN_CENTER_RATIO="60"
  export MOCK_HAS_FZF="0"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/spiral.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/grid.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-center.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-vertical.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/main-horizontal.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/monocle.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/deck.sh"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/presets.sh"
}

teardown() {
  cleanup_test_environment
}

@test "presets.sh - save_preset function exists" {
  function_exists save_preset
}

@test "presets.sh - apply_preset function exists" {
  function_exists apply_preset
}

@test "presets.sh - save_preset succeeds with valid name" {
  run save_preset "dev"
  [[ "${status}" -eq 0 ]]
}

@test "presets.sh - save_preset fails with empty name" {
  run save_preset ""
  [[ "${status}" -ne 0 ]]
}

@test "presets.sh - save_preset sanitizes special characters" {
  run save_preset 'my preset!'
  [[ "${status}" -eq 0 ]]
}

@test "presets.sh - apply_preset fails with empty name and no fzf" {
  export MOCK_HAS_FZF="0"
  run apply_preset ""
  [[ "${status}" -ne 0 ]]
}

@test "presets.sh - apply_preset fails with nonexistent preset" {
  export MOCK_TMUX_OPTION_VALUE=""
  run apply_preset "nonexistent"
  [[ "${status}" -ne 0 ]]
}

@test "presets.sh - apply_preset dispatches every layout in a saved preset" {
  # Arrange
  local applied="${TEST_TMPDIR}/applied"
  apply_layout_dwindle() { printf 'dwindle ' >> "${applied}"; }
  apply_layout_spiral() { printf 'spiral ' >> "${applied}"; }
  apply_layout_grid() { printf 'grid ' >> "${applied}"; }
  apply_layout_main_vertical() { printf 'main-vertical ' >> "${applied}"; }
  apply_layout_main_horizontal() { printf 'main-horizontal ' >> "${applied}"; }
  apply_layout_main_center() { printf 'main-center ' >> "${applied}"; }
  apply_layout_monocle() { printf 'monocle ' >> "${applied}"; }
  apply_layout_deck() { printf 'deck ' >> "${applied}"; }
  local layout

  # Act
  for layout in dwindle spiral grid main-vertical main-horizontal main-center monocle deck; do
    export MOCK_TMUX_OPTION_VALUE="${layout}:brvc:60"
    apply_preset "p"
  done

  # Assert
  [[ "$(cat "${applied}")" == "dwindle spiral grid main-vertical main-horizontal main-center monocle deck " ]]
}

@test "presets.sh - apply_preset rejects an unknown layout in the preset" {
  export MOCK_TMUX_OPTION_VALUE="bogus-layout:brvc:60"
  run apply_preset "weird"
  [[ "${status}" -ne 0 ]]
}

@test "presets.sh - save_preset records the current layout as a preset" {
  export MOCK_TILING_LAYOUT="grid"
  save_preset "work" >/dev/null 2>&1
}

@test "presets.sh - apply_preset with no name opens the picker in a popup" {
  # Arrange
  export MOCK_HAS_FZF="1"
  export MOCK_TMUX_LOG="${TEST_TMPDIR}/tmux.log"

  # Act
  apply_preset ""

  # Assert
  grep -q '^display-popup -E .*tiling\.sh preset-pick$' "${MOCK_TMUX_LOG}"
}

@test "presets.sh - preset_pick applies the picked preset" {
  # Arrange
  export MOCK_HAS_FZF="1"
  export MOCK_FZF_SELECTION="dev"
  export MOCK_TMUX_OPTION_VALUE="grid:brvc:60"
  export MOCK_TMUX_LOG="${TEST_TMPDIR}/tmux.log"

  # Act
  preset_pick

  # Assert
  grep -qx 'select-layout tiled' "${MOCK_TMUX_LOG}"
}
