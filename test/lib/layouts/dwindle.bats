#!/usr/bin/env bats
# shellcheck disable=SC2034

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  export MOCK_PANE_ID="%0"
  export MOCK_WINDOW_WIDTH="200"
  export MOCK_WINDOW_HEIGHT="50"
  export MOCK_TILING_APPLYING="0"
  export MOCK_TILING_ORIENTATION="brvc"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/layouts/dwindle.sh"
}

teardown() {
  cleanup_test_environment
}

@test "dwindle.sh - apply_layout_dwindle function exists" {
  function_exists apply_layout_dwindle
}

@test "dwindle.sh - _apply_bsp_layout function exists" {
  function_exists _apply_bsp_layout
}

@test "dwindle.sh - _layout_checksum function exists" {
  function_exists _layout_checksum
}

@test "dwindle.sh - _bsp_pane_first function exists" {
  function_exists _bsp_pane_first
}

@test "dwindle.sh - _bsp_leaf_permutation function exists" {
  function_exists _bsp_leaf_permutation
}

@test "dwindle.sh - _bsp_build function exists" {
  function_exists _bsp_build
}

@test "dwindle.sh - _layout_checksum produces 4-char hex output" {
  run _layout_checksum "100x50,0,0,0"
  [[ "${status}" -eq 0 ]]
  [[ "${#output}" -eq 4 ]]
  [[ "${output}" =~ ^[0-9a-f]{4}$ ]]
}

@test "dwindle.sh - _layout_checksum is deterministic for same input" {
  local first second
  first=$(_layout_checksum "200x50,0,0{100x50,0,0,0,99x50,101,0,1}")
  second=$(_layout_checksum "200x50,0,0{100x50,0,0,0,99x50,101,0,1}")
  [[ "${first}" == "${second}" ]]
}

@test "dwindle.sh - _layout_checksum differs for different inputs" {
  local a b
  a=$(_layout_checksum "200x50,0,0,0")
  b=$(_layout_checksum "200x50,0,0,1")
  [[ "${a}" != "${b}" ]]
}

@test "dwindle.sh - _layout_checksum handles empty string" {
  run _layout_checksum ""
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == "0000" ]]
}

@test "dwindle.sh - _bsp_pane_first returns true at depth 0 for brvc" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false
  run _bsp_pane_first 0
  [[ "${output}" == "true" ]]
}

@test "dwindle.sh - _bsp_pane_first returns true at depth 1 for brvc" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false
  run _bsp_pane_first 1
  [[ "${output}" == "true" ]]
}

@test "dwindle.sh - _bsp_pane_first returns true at all depths for corner trajectory" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false
  local d
  for d in 0 1 2 3 4 5 6 7; do
    local result
    result=$(_bsp_pane_first $d)
    [[ "${result}" == "true" ]]
  done
}

@test "dwindle.sh - _bsp_pane_first returns false at depth 2 for brvs spiral" {
  # Arrange
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=true
  local depth=2

  # Act
  run _bsp_pane_first "${depth}"

  # Assert
  [[ "${output}" == "false" ]]
}

@test "dwindle.sh - _bsp_pane_first returns false at depth 3 for brvs spiral" {
  # Arrange
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=true
  local depth=3

  # Act
  run _bsp_pane_first "${depth}"

  # Assert
  [[ "${output}" == "false" ]]
}

@test "dwindle.sh - _bsp_pane_first returns true at depth 4 for brvs spiral" {
  # Arrange
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=true
  local depth=4

  # Act
  run _bsp_pane_first "${depth}"

  # Assert
  [[ "${output}" == "true" ]]
}

@test "dwindle.sh - _bsp_pane_first handles left corner flag" {
  # Arrange
  local corner_tb='' spiral_tb='+' corner_lr='+' spiral_lr='' modulo_hv=1 is_spiral=false
  local depth=0

  # Act
  run _bsp_pane_first "${depth}"

  # Assert
  [[ "${output}" == "false" ]]
}

@test "dwindle.sh - _bsp_pane_first handles top corner flag" {
  # Arrange
  local corner_tb='+' spiral_tb='' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false
  local depth=1

  # Act
  run _bsp_pane_first "${depth}"

  # Assert
  [[ "${output}" == "false" ]]
}

@test "dwindle.sh - _bsp_pane_first handles horizontal branch direction" {
  # Arrange
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=0 is_spiral=false
  local depth=0

  # Act
  run _bsp_pane_first "${depth}"

  # Assert
  [[ "${output}" == "true" ]]
}

@test "dwindle.sh - _bsp_leaf_permutation returns identity for 1 pane" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false
  run _bsp_leaf_permutation 1 0
  [[ "${output}" == "0" ]]
}

@test "dwindle.sh - _bsp_leaf_permutation returns identity for dwindle 3 panes" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false
  run _bsp_leaf_permutation 3 0
  [[ "${output}" == "0 1 2" ]]
}

@test "dwindle.sh - _bsp_leaf_permutation returns identity for dwindle 6 panes" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false
  run _bsp_leaf_permutation 6 0
  [[ "${output}" == "0 1 2 3 4 5" ]]
}

@test "dwindle.sh - _bsp_leaf_permutation returns non-identity for spiral 5 panes" {
  # Arrange
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=true
  local pane_count=5

  # Act
  run _bsp_leaf_permutation "${pane_count}" 0

  # Assert
  [[ "${output}" != "0 1 2 3 4" ]]
}

@test "dwindle.sh - _bsp_leaf_permutation for spiral 6 panes" {
  # Arrange
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=true
  local pane_count=6

  # Act
  run _bsp_leaf_permutation "${pane_count}" 0

  # Assert
  [[ "${output}" == "0 1 4 5 3 2" ]]
}

@test "dwindle.sh - _bsp_leaf_permutation starts from correct depth" {
  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false
  run _bsp_leaf_permutation 3 2
  [[ "${output}" == "2 3 4" ]]
}

@test "dwindle.sh - _bsp_build single pane produces leaf node" {
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  run _bsp_build "%5" 0 0 200 50 0
  [[ "${output}" == "200x50,0,0,5" ]]
}

@test "dwindle.sh - _bsp_build strips percent from pane IDs" {
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  run _bsp_build "%42" 10 20 80 30 0
  [[ "${output}" == "80x30,10,20,42" ]]
}

@test "dwindle.sh - _bsp_build 2 panes produces H-split for vertical branch" {
  # Arrange
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1"

  # Act
  run _bsp_build "${panes}" 0 0 200 50 0

  # Assert
  [[ "${output}" == *"{"* ]] || false
  [[ "${output}" == *",0"* ]] || false
  [[ "${output}" == *",1"* ]]
}

@test "dwindle.sh - _bsp_build 2 panes produces V-split for horizontal branch" {
  # Arrange
  local modulo_hv=0 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1"

  # Act
  run _bsp_build "${panes}" 0 0 200 50 0

  # Assert
  [[ "${output}" == *"["* ]]
}

@test "dwindle.sh - _bsp_build 3 panes produces nested structure" {
  # Arrange
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1 %2"

  # Act
  run _bsp_build "${panes}" 0 0 200 50 0

  # Assert
  [[ "${status}" -eq 0 ]] || false
  [[ "${output}" == 200x50,0,0* ]] || false
  [[ "${output}" == *",0,"* || "${output}" == *",0}" || "${output}" == *",0]" ]] || false
  [[ "${output}" == *",1,"* || "${output}" == *",1}" || "${output}" == *",1]" ]] || false
  [[ "${output}" == *",2"* ]]
}

@test "dwindle.sh - _bsp_build geometry sums match parent dimensions" {
  # Arrange
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1" result

  # Act
  result=$(_bsp_build "${panes}" 0 0 200 50 0)

  # Assert
  [[ "${result}" == *"99x50,0,0,0"* ]] || false
  [[ "${result}" == *"100x50,100,0,1"* ]]
}

@test "dwindle.sh - _bsp_build V-split geometry sums match parent" {
  # Arrange
  local modulo_hv=0 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1" result

  # Act
  result=$(_bsp_build "${panes}" 0 0 200 50 0)

  # Assert
  [[ "${result}" == *"200x24,0,0,0"* ]] || false
  [[ "${result}" == *"200x25,0,25,1"* ]]
}

@test "dwindle.sh - _bsp_build spiral reverses pane placement" {
  # Arrange
  local modulo_hv=1 is_spiral=true corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1 %2 %3 %4"

  # Act
  run _bsp_build "${panes}" 0 0 200 50 0

  # Assert
  [[ "${status}" -eq 0 ]] || false
  [[ "${output}" == 200x50,0,0* ]]
}

@test "dwindle.sh - _bsp_build with 6 panes produces valid layout" {
  # Arrange
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1 %2 %3 %4 %5"

  # Act
  run _bsp_build "${panes}" 0 0 200 50 0

  # Assert
  [[ "${status}" -eq 0 ]] || false
  [[ "${output}" == *",0,"* || "${output}" == *",0}" || "${output}" == *",0]" ]] || false
  [[ "${output}" == *",5"* ]]
}

@test "dwindle.sh - _bsp_build with 8 panes produces valid layout" {
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  run _bsp_build "%0 %1 %2 %3 %4 %5 %6 %7" 0 0 200 50 0
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *",7"* ]]
}

@test "dwindle.sh - apply_layout_dwindle succeeds with multiple panes" {
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle exits early with single pane" {
  export MOCK_PANE_LIST="%0"
  run apply_layout_dwindle
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - _apply_bsp_layout with is_spiral false uses corner trajectory" {
  run _apply_bsp_layout "false" "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - _apply_bsp_layout with is_spiral true uses spiral trajectory" {
  run _apply_bsp_layout "true" "brvs"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle accepts top-left orientation" {
  run apply_layout_dwindle "tlvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle accepts horizontal branch direction" {
  run apply_layout_dwindle "brhc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle works with 5 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4'
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle works with 2 panes" {
  export MOCK_PANE_LIST=$'%0\n%1'
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle works with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle works with 8 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6\n%7'
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle works with 10 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5\n%6\n%7\n%8\n%9'
  run apply_layout_dwindle "brvc"
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - apply_layout_dwindle reads orientation from options when no arg" {
  export MOCK_TILING_ORIENTATION="tlhc"
  export MOCK_PANE_LIST=$'%0\n%1\n%2'
  run apply_layout_dwindle
  [[ "${status}" -eq 0 ]]
}

@test "dwindle.sh - all 16 BSP orientations succeed" {
  local orientations=(
    tlvc trvc blvc brvc
    tlvs trvs blvs brvs
    tlhc trhc blhc brhc
    tlhs trhs blhs brhs
  )
  for orient in "${orientations[@]}"; do
    run apply_layout_dwindle "${orient}"
    [[ "${status}" -eq 0 ]]
  done
}

@test "dwindle.sh - all 16 BSP orientations succeed with 6 panes" {
  export MOCK_PANE_LIST=$'%0\n%1\n%2\n%3\n%4\n%5'
  local orientations=(
    tlvc trvc blvc brvc
    tlvs trvs blvs brvs
    tlhc trhc blhc brhc
    tlhs trhs blhs brhs
  )
  for orient in "${orientations[@]}"; do
    run apply_layout_dwindle "${orient}"
    [[ "${status}" -eq 0 ]]
  done
}

@test "dwindle.sh - layout string has matching braces" {
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local result
  result=$(_bsp_build "%0 %1 %2 %3" 0 0 200 50 0)
  local open_curly close_curly open_square close_square
  open_curly=$(echo "${result}" | tr -cd '{' | wc -c | tr -d ' ')
  close_curly=$(echo "${result}" | tr -cd '}' | wc -c | tr -d ' ')
  open_square=$(echo "${result}" | tr -cd '[' | wc -c | tr -d ' ')
  close_square=$(echo "${result}" | tr -cd ']' | wc -c | tr -d ' ')
  [[ "${open_curly}" -eq "${close_curly}" ]]
  [[ "${open_square}" -eq "${close_square}" ]]
}

@test "dwindle.sh - layout string contains all pane IDs for 5 panes" {
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local result
  result=$(_bsp_build "%10 %20 %30 %40 %50" 0 0 200 50 0)
  [[ "${result}" == *",10"* ]]
  [[ "${result}" == *",20"* ]]
  [[ "${result}" == *",30"* ]]
  [[ "${result}" == *",40"* ]]
  [[ "${result}" == *",50"* ]]
}

@test "dwindle.sh - layout string root dimensions match window" {
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local result
  result=$(_bsp_build "%0 %1 %2" 0 0 300 80 0)
  [[ "${result}" == 300x80,0,0* ]]
}

@test "dwindle.sh - layout string H-split root for modulo_hv=1" {
  # Arrange
  local modulo_hv=1 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1" result

  # Act
  result=$(_bsp_build "${panes}" 0 0 200 50 0)

  # Assert
  local after_coords="${result#*,0,0}"
  [[ "${after_coords:0:1}" == "{" ]]
}

@test "dwindle.sh - layout string V-split root for modulo_hv=0" {
  # Arrange
  local modulo_hv=0 is_spiral=false corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+'
  local panes="%0 %1" result

  # Act
  result=$(_bsp_build "${panes}" 0 0 200 50 0)

  # Assert
  local after_coords="${result#*,0,0}"
  [[ "${after_coords:0:1}" == "[" ]]
}
