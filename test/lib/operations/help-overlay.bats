#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  export MOCK_TILING_LAYOUT="dwindle"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/operations/help-overlay.sh"
}

teardown() {
  cleanup_test_environment
}

@test "help-overlay.sh - show_help function exists" {
  function_exists show_help
}

@test "help-overlay.sh - _help_lines function exists" {
  function_exists _help_lines
}

@test "help-overlay.sh - _popup_supported function exists" {
  function_exists _popup_supported
}

@test "help-overlay.sh - source guard prevents double loading" {
  [[ "${_TILING_REVAMPED_HELP_OVERLAY_LOADED}" == "1" ]]
}

@test "help-overlay.sh - _help_lines lists default keys and action labels" {
  run _help_lines
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == *"Dwindle layout"* ]]
  [[ "${output}" == *"Undo layout"* ]]
  [[ "${output}" == *"Redo layout"* ]]
  [[ "${output}" == *"Swap with biggest"* ]]
}

@test "help-overlay.sh - _help_lines renders the resolved key, not the default" {
  get_tmux_option() {
    [[ "$1" == "@tiling_revamped_key_dwindle" ]] && { echo "X"; return 0; }
    echo "${2:-}"
  }
  export -f get_tmux_option
  run _help_lines
  [[ "${output}" == *"X"*"Dwindle layout"* ]]
  [[ "${output}" != *"d       Dwindle layout"* ]]
}

@test "help-overlay.sh - _help_lines omits a binding whose key resolves empty" {
  get_tmux_option() {
    [[ "$1" == "@tiling_revamped_key_dwindle" ]] && { echo ""; return 0; }
    echo "${2:-}"
  }
  export -f get_tmux_option
  run _help_lines
  [[ "${output}" != *"Dwindle layout"* ]]
  [[ "${output}" == *"Spiral layout"* ]]
}

@test "help-overlay.sh - _popup_supported accepts tmux 3.4" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 3.4"; return 0; }
  export -f tmux
  run _popup_supported
  [[ "${status}" -eq 0 ]]
}

@test "help-overlay.sh - _popup_supported accepts tmux 4.0" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 4.0"; return 0; }
  export -f tmux
  run _popup_supported
  [[ "${status}" -eq 0 ]]
}

@test "help-overlay.sh - _popup_supported accepts exactly tmux 3.2" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 3.2"; return 0; }
  export -f tmux
  run _popup_supported
  [[ "${status}" -eq 0 ]]
}

@test "help-overlay.sh - _popup_supported rejects tmux 3.1" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 3.1"; return 0; }
  export -f tmux
  run _popup_supported
  [[ "${status}" -ne 0 ]]
}

@test "help-overlay.sh - _popup_supported rejects tmux 2.9" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 2.9"; return 0; }
  export -f tmux
  run _popup_supported
  [[ "${status}" -ne 0 ]]
}

@test "help-overlay.sh - _popup_supported handles a letter suffix version" {
  tmux() { [[ "$1" == "-V" ]] && echo "tmux 3.2a"; return 0; }
  export -f tmux
  run _popup_supported
  [[ "${status}" -eq 0 ]]
}

@test "help-overlay.sh - _popup_supported fails when version is empty" {
  tmux() { [[ "$1" == "-V" ]] && echo ""; return 0; }
  export -f tmux
  run _popup_supported
  [[ "${status}" -ne 0 ]]
}

@test "help-overlay.sh - show_help builds a display-popup command on modern tmux" {
  local capture="${TEST_TMPDIR}/popup.txt"
  tmux() {
    if [[ "$1" == "-V" ]]; then echo "tmux 3.4"; return 0; fi
    if [[ "$1" == "show-option" ]]; then echo ""; return 0; fi
    if [[ "$1" == "display-popup" ]]; then printf '%s\n' "$*" > "${capture}"; return 0; fi
    return 0
  }
  export -f tmux
  run show_help
  [[ "${status}" -eq 0 ]]
  [[ -f "${capture}" ]]
  grep -q -- "-E" "${capture}"
  grep -q "Dwindle layout" "${capture}"
  grep -q "keybindings" "${capture}"
}

@test "help-overlay.sh - show_help falls back to a message on old tmux" {
  local capture="${TEST_TMPDIR}/msg.txt"
  tmux() {
    if [[ "$1" == "-V" ]]; then echo "tmux 3.0"; return 0; fi
    if [[ "$1" == "display-message" ]]; then printf '%s\n' "$*" > "${capture}"; return 0; fi
    if [[ "$1" == "display-popup" ]]; then printf 'POPUP' > "${TEST_TMPDIR}/leak"; return 0; fi
    return 0
  }
  export -f tmux
  run show_help
  [[ "${status}" -eq 0 ]]
  [[ -f "${capture}" ]]
  grep -q "3.2" "${capture}"
  [[ ! -f "${TEST_TMPDIR}/leak" ]]
}

@test "help-overlay.sh - _help_lines prefers the published binding map" {
  get_tmux_option() {
    if [[ "$1" == "@tiling_revamped_bindings" ]]; then
      printf 'dwindle\tZ\nspiral\tD\n'
      return 0
    fi
    echo "${2:-}"
  }
  export -f get_tmux_option
  run _help_lines
  [[ "${output}" == *"Z"*"Dwindle layout"* ]]
  [[ "${output}" != *"d       Dwindle layout"* ]]
}

@test "help-overlay.sh - _help_lines omits a feature the map left unbound" {
  get_tmux_option() {
    if [[ "$1" == "@tiling_revamped_bindings" ]]; then
      printf 'spiral\tD\n'
      return 0
    fi
    echo "${2:-}"
  }
  export -f get_tmux_option
  run _help_lines
  [[ "${output}" != *"Dwindle layout"* ]]
  [[ "${output}" == *"Spiral layout"* ]]
}

@test "help-overlay.sh - _help_lines covers the bindings added after 2.1" {
  run _help_lines
  [[ "${output}" == *"Jump to any pane"* ]]
  [[ "${output}" == *"Focus back"* ]]
  [[ "${output}" == *"Focus forward"* ]]
}

@test "help-overlay.sh - a feature name is matched whole, not as a substring" {
  get_tmux_option() {
    if [[ "$1" == "@tiling_revamped_bindings" ]]; then
      printf 'pane_jump\tP\njump\tj\n'
      return 0
    fi
    echo "${2:-}"
  }
  export -f get_tmux_option
  run _help_lines
  [[ "${output}" == *"j       Jump to mark"* ]]
  [[ "${output}" == *"P       Jump to any pane"* ]]
}
