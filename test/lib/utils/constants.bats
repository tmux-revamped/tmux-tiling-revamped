#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/constants.sh"
}

teardown() {
  cleanup_test_environment
}

@test "constants.sh - TILING_REVAMPED_VERSION is a semantic version" {
  [[ -n "${TILING_REVAMPED_VERSION}" ]]
  [[ "${TILING_REVAMPED_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "constants.sh - TILING_REVAMPED_VERSION matches the changelog" {
  local changelog
  changelog="$(grep -m1 -E '^## \[[0-9]' "${BATS_TEST_DIRNAME}/../../../CHANGELOG.md" \
    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"

  [[ "${TILING_REVAMPED_VERSION}" == "${changelog}" ]]
}

@test "constants.sh - TILING_DEFAULT_ORIENTATION is set" {
  [[ -n "${TILING_DEFAULT_ORIENTATION}" ]]
  [[ "${TILING_DEFAULT_ORIENTATION}" == "brvc" ]]
}

@test "constants.sh - TILING_DEFAULT_MASTER_RATIO is set" {
  [[ -n "${TILING_DEFAULT_MASTER_RATIO}" ]]
  [[ "${TILING_DEFAULT_MASTER_RATIO}" == "60" ]]
}

@test "constants.sh - TILING_DEFAULT_SPLIT_RATIO is set" {
  [[ -n "${TILING_DEFAULT_SPLIT_RATIO}" ]]
  [[ "${TILING_DEFAULT_SPLIT_RATIO}" == "50" ]]
}

@test "constants.sh - TILING_DEFAULT_FOCUS_RATIO is set" {
  [[ -n "${TILING_DEFAULT_FOCUS_RATIO}" ]]
  [[ "${TILING_DEFAULT_FOCUS_RATIO}" == "62" ]]
}

@test "constants.sh - OPT_LAYOUT is set" {
  [[ -n "${OPT_LAYOUT}" ]]
  [[ "${OPT_LAYOUT}" == "@tiling_revamped_layout" ]]
}

@test "constants.sh - OPT_APPLYING is set" {
  [[ -n "${OPT_APPLYING}" ]]
  [[ "${OPT_APPLYING}" == "@tiling_revamped_applying" ]]
}

@test "constants.sh - OPT_AUTO_APPLY is set" {
  [[ -n "${OPT_AUTO_APPLY}" ]]
  [[ "${OPT_AUTO_APPLY}" == "@tiling_revamped_auto_apply" ]]
}

@test "constants.sh - TILING_DEFAULT_RESIZE_STEP is set" {
  [[ -n "${TILING_DEFAULT_RESIZE_STEP}" ]]
  [[ "${TILING_DEFAULT_RESIZE_STEP}" == "5" ]]
}

@test "constants.sh - new option constants are set" {
  [[ -n "${OPT_DEFAULT_LAYOUT}" ]]
  [[ "${OPT_DEFAULT_LAYOUT}" == "@tiling_revamped_default_layout" ]]
  [[ -n "${OPT_MASTER_RATIO}" ]]
  [[ "${OPT_MASTER_RATIO}" == "@tiling_revamped_master_ratio" ]]
  [[ -n "${OPT_RESIZE_STEP}" ]]
  [[ "${OPT_RESIZE_STEP}" == "@tiling_revamped_resize_step" ]]
  [[ -n "${OPT_ALT_KEYS}" ]]
  [[ "${OPT_ALT_KEYS}" == "@tiling_revamped_alt_keys" ]]
  [[ -n "${OPT_NAVIGATOR}" ]]
  [[ "${OPT_NAVIGATOR}" == "@tiling_revamped_navigator" ]]
}

@test "constants.sh - all keybinding option constants are set" {
  [[ -n "${OPT_KEY_DWINDLE}" ]]
  [[ -n "${OPT_KEY_SPIRAL}" ]]
  [[ -n "${OPT_KEY_BALANCE}" ]]
  [[ -n "${OPT_KEY_EQUALIZE}" ]]
  [[ -n "${OPT_KEY_PROMOTE}" ]]
  [[ -n "${OPT_KEY_ROTATE}" ]]
  [[ -n "${OPT_KEY_FLIP}" ]]
  [[ -n "${OPT_KEY_CIRCULATE}" ]]
  [[ -n "${OPT_KEY_AUTOTILE}" ]]
  [[ -n "${OPT_KEY_CYCLE}" ]]
  [[ -n "${OPT_KEY_MARK}" ]]
  [[ -n "${OPT_KEY_JUMP}" ]]
  [[ -n "${OPT_KEY_SCRATCHPAD}" ]]
  [[ -n "${OPT_KEY_MAIN_VERTICAL}" ]]
  [[ -n "${OPT_KEY_MAIN_HORIZONTAL}" ]]
  [[ -n "${OPT_KEY_MASTER_GROW}" ]]
  [[ -n "${OPT_KEY_MASTER_SHRINK}" ]]
  [[ -n "${OPT_KEY_SYNC}" ]]
  [[ -n "${OPT_KEY_SWAP_UP}" ]]
  [[ -n "${OPT_KEY_SWAP_DOWN}" ]]
  [[ -n "${OPT_KEY_SWAP_LEFT}" ]]
  [[ -n "${OPT_KEY_SWAP_RIGHT}" ]]
}

@test "constants.sh - layout picker option constants are set" {
  [[ -n "${OPT_KEY_PICK_LAYOUT}" ]]
  [[ "${OPT_KEY_PICK_LAYOUT}" == "@tiling_revamped_key_pick_layout" ]]
  [[ -n "${OPT_KEY_PICK_LAYOUT_ALT}" ]]
  [[ "${OPT_KEY_PICK_LAYOUT_ALT}" == "@tiling_revamped_key_pick_layout_alt" ]]
  [[ -n "${OPT_PICK_WIDTH}" ]]
  [[ "${OPT_PICK_WIDTH}" == "@tiling_revamped_pick_width" ]]
  [[ -n "${OPT_PICK_HEIGHT}" ]]
  [[ "${OPT_PICK_HEIGHT}" == "@tiling_revamped_pick_height" ]]
  [[ -n "${OPT_PICK_PREVIEW_WIDTH}" ]]
  [[ "${OPT_PICK_PREVIEW_WIDTH}" == "@tiling_revamped_pick_preview_width" ]]
}

@test "constants.sh - layout picker default values are set" {
  [[ -n "${TILING_DEFAULT_PICK_WIDTH}" ]]
  [[ "${TILING_DEFAULT_PICK_WIDTH}" == "60%" ]]
  [[ -n "${TILING_DEFAULT_PICK_HEIGHT}" ]]
  [[ "${TILING_DEFAULT_PICK_HEIGHT}" == "40%" ]]
  [[ -n "${TILING_DEFAULT_PICK_PREVIEW_WIDTH}" ]]
  [[ "${TILING_DEFAULT_PICK_PREVIEW_WIDTH}" == "60%" ]]
}

@test "constants.sh - pass-2 feature option constants are set" {
  [[ "${OPT_DYNAMIC_LAYOUT}" == "@tiling_revamped_dynamic_layout" ]]
  [[ "${OPT_APP_RULES}" == "@tiling_revamped_app_rules" ]]
  [[ "${OPT_FOCUS_HISTORY}" == "@tiling_revamped_focus_history" ]]
  [[ "${OPT_FOCUS_STACK}" == "@tiling_revamped_focus_stack" ]]
  [[ "${OPT_FOCUS_POS}" == "@tiling_revamped_focus_pos" ]]
  [[ "${OPT_FOCUS_MAX}" == "@tiling_revamped_focus_max" ]]
  [[ "${OPT_FOCUS_NAV}" == "@tiling_revamped_focus_nav" ]]
  [[ "${OPT_KEY_FOCUS_BACK}" == "@tiling_revamped_key_focus_back" ]]
  [[ "${OPT_KEY_FOCUS_FORWARD}" == "@tiling_revamped_key_focus_forward" ]]
  [[ "${OPT_KEY_PANE_JUMP}" == "@tiling_revamped_key_pane_jump" ]]
  [[ "${TILING_DEFAULT_FOCUS_MAX}" == "20" ]]
  [[ "${TILING_DEFAULT_JUMP_WIDTH}" == "70%" ]]
}

@test "constants.sh - source guard prevents double loading" {
  [[ -n "${_TILING_REVAMPED_CONSTANTS_LOADED}" ]]
  [[ "${_TILING_REVAMPED_CONSTANTS_LOADED}" == "1" ]]
}
