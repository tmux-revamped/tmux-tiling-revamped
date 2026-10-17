#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/features/dynamic-layout.sh"
  apply_layout_dwindle() { echo "dwindle:${1:-}"; }
  apply_layout_spiral() { echo "spiral:${1:-}"; }
  apply_layout_grid() { echo "grid"; }
  apply_layout_main_center() { echo "main-center"; }
  apply_layout_main_vertical() { echo "main-vertical"; }
  apply_layout_main_horizontal() { echo "main-horizontal"; }
  apply_layout_monocle() { echo "monocle"; }
  apply_layout_deck() { echo "deck"; }
  export -f apply_layout_dwindle apply_layout_spiral apply_layout_grid
  export -f apply_layout_main_center apply_layout_main_vertical
  export -f apply_layout_main_horizontal apply_layout_monocle apply_layout_deck
}

teardown() {
  cleanup_test_environment
}

@test "dynamic-layout.sh - functions exist" {
  function_exists _dynamic_layout_enabled
  function_exists resolve_dynamic_layout
  function_exists _apply_dynamic_resolved
  function_exists apply_dynamic_layout
}

@test "dynamic-layout.sh - source guard prevents double loading" {
  [[ "${_TILING_REVAMPED_DYNAMIC_LAYOUT_LOADED}" == "1" ]]
}

@test "dynamic-layout.sh - _dynamic_layout_enabled false when unset" {
  export MOCK_TMUX_OPTION_VALUE=""
  run _dynamic_layout_enabled
  [[ "${status}" -ne 0 ]]
}

@test "dynamic-layout.sh - _dynamic_layout_enabled true when set" {
  export MOCK_TMUX_OPTION_VALUE="2:grid"
  run _dynamic_layout_enabled
  [[ "${status}" -eq 0 ]]
}

@test "dynamic-layout.sh - resolve returns nothing when map empty" {
  export MOCK_TMUX_OPTION_VALUE=""
  run resolve_dynamic_layout 3
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}

@test "dynamic-layout.sh - resolve picks exact threshold match" {
  export MOCK_TMUX_OPTION_VALUE="1:monocle 2:main-vertical 3:dwindle 5:grid"
  run resolve_dynamic_layout 2
  [[ "${output}" == "main-vertical" ]]
}

@test "dynamic-layout.sh - resolve picks greatest threshold not exceeding count" {
  export MOCK_TMUX_OPTION_VALUE="1:monocle 2:main-vertical 3:dwindle 5:grid"
  run resolve_dynamic_layout 4
  [[ "${output}" == "dwindle" ]]
}

@test "dynamic-layout.sh - resolve saturates at the highest threshold" {
  export MOCK_TMUX_OPTION_VALUE="1:monocle 2:main-vertical 3:dwindle 5:grid"
  run resolve_dynamic_layout 9
  [[ "${output}" == "grid" ]]
}

@test "dynamic-layout.sh - resolve returns nothing below the lowest threshold" {
  export MOCK_TMUX_OPTION_VALUE="2:main-vertical 5:grid"
  run resolve_dynamic_layout 1
  [[ -z "${output}" ]]
}

@test "dynamic-layout.sh - resolve skips a non-numeric threshold" {
  export MOCK_TMUX_OPTION_VALUE="x:grid 2:dwindle"
  run resolve_dynamic_layout 3
  [[ "${output}" == "dwindle" ]]
}

@test "dynamic-layout.sh - resolve skips an entry with an empty layout" {
  export MOCK_TMUX_OPTION_VALUE="2: 1:monocle"
  run resolve_dynamic_layout 3
  [[ "${output}" == "monocle" ]]
}

@test "dynamic-layout.sh - resolve skips a bare numeric token with no colon" {
  export MOCK_TMUX_OPTION_VALUE="3 1:monocle"
  run resolve_dynamic_layout 5
  [[ "${output}" == "monocle" ]]
}

@test "dynamic-layout.sh - _apply_dynamic_resolved dispatches each layout" {
  run _apply_dynamic_resolved dwindle
  [[ "${output}" == "dwindle:" ]]
  run _apply_dynamic_resolved spiral
  [[ "${output}" == "spiral:" ]]
  run _apply_dynamic_resolved grid
  [[ "${output}" == "grid" ]]
  run _apply_dynamic_resolved main-center
  [[ "${output}" == "main-center" ]]
  run _apply_dynamic_resolved main-vertical
  [[ "${output}" == "main-vertical" ]]
  run _apply_dynamic_resolved main-horizontal
  [[ "${output}" == "main-horizontal" ]]
  run _apply_dynamic_resolved monocle
  [[ "${output}" == "monocle" ]]
  run _apply_dynamic_resolved deck
  [[ "${output}" == "deck" ]]
}

@test "dynamic-layout.sh - _apply_dynamic_resolved rejects unknown layout" {
  run _apply_dynamic_resolved bogus
  [[ "${status}" -eq 1 ]]
}

@test "dynamic-layout.sh - apply_dynamic_layout applies the resolved layout" {
  export MOCK_TMUX_OPTION_VALUE="1:monocle 3:grid"
  export MOCK_WINDOW_PANES="3"
  run apply_dynamic_layout
  [[ "${output}" == "grid" ]]
}

@test "dynamic-layout.sh - apply_dynamic_layout is a no-op when nothing resolves" {
  export MOCK_TMUX_OPTION_VALUE="5:grid"
  export MOCK_WINDOW_PANES="2"
  run apply_dynamic_layout
  [[ "${status}" -eq 0 ]]
  [[ -z "${output}" ]]
}
