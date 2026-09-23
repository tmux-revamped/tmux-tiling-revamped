#!/usr/bin/env bash
#
# Test helpers for tmux-tiling-revamped.
#
# Unit tests source this file for mock tmux and lifecycle helpers.
# Integration tests (layout tests) use tmux_helpers.bash instead,
# which manages a real tmux server per test.

setup_test_environment() {
  TEST_TMPDIR=$(mktemp -d)
  export TEST_TMPDIR

  TEST_SRC_DIR="${TEST_TMPDIR}/src"
  TEST_LIB_DIR="${TEST_SRC_DIR}/lib"
  mkdir -p "${TEST_LIB_DIR}"

  export SCRIPT_DIR="${TEST_SRC_DIR}"
  export LIB_DIR="${TEST_LIB_DIR}"
  export TMUX_TEST_MODE=1

  # Reset source guards so each test starts fresh
  # Reset ALL source guards so each test file starts fresh
  unset _TILING_REVAMPED_CONSTANTS_LOADED
  unset _TMUX_PLUGIN_ERROR_LOGGER_LOADED
  unset _TMUX_PLUGIN_HAS_COMMAND_LOADED
  unset _TMUX_PLUGIN_TMUX_OPS_LOADED
  unset _TILING_REVAMPED_TMUX_CONFIG_LOADED
  unset _TILING_REVAMPED_DWINDLE_LOADED
  unset _TILING_REVAMPED_SPIRAL_LOADED
  unset _TILING_REVAMPED_GRID_LOADED
  unset _TILING_REVAMPED_MAIN_CENTER_LOADED
  unset _TILING_REVAMPED_MAIN_VERTICAL_LOADED
  unset _TILING_REVAMPED_MAIN_HORIZONTAL_LOADED
  unset _TILING_REVAMPED_MONOCLE_LOADED
  unset _TILING_REVAMPED_DECK_LOADED
  unset _TILING_REVAMPED_PREVIEWS_LOADED
  unset _TILING_REVAMPED_AUTOSPLIT_LOADED
  unset _TILING_REVAMPED_BALANCE_LOADED
  unset _TILING_REVAMPED_CIRCULATE_LOADED
  unset _TILING_REVAMPED_EQUALIZE_LOADED
  unset _TILING_REVAMPED_FLIP_LOADED
  unset _TILING_REVAMPED_FOCUS_RESIZE_LOADED
  unset _TILING_REVAMPED_PROMOTE_LOADED
  unset _TILING_REVAMPED_RESIZE_MASTER_LOADED
  unset _TILING_REVAMPED_ROTATE_LOADED
  unset _TILING_REVAMPED_SYNC_LOADED
  unset _TILING_REVAMPED_SWAP_DIRECTION_LOADED
  unset _TILING_REVAMPED_PICK_LAYOUT_LOADED
  unset _TILING_REVAMPED_UNDO_LAYOUT_LOADED
  unset _TILING_REVAMPED_SWAP_PICK_LOADED
  unset _TILING_REVAMPED_VALIDATE_LOADED
  unset _TILING_REVAMPED_INFO_LOADED
  unset _TILING_REVAMPED_DOCTOR_LOADED
  unset _TILING_REVAMPED_CYCLE_LOADED
  unset _TILING_REVAMPED_PRESETS_LOADED
  unset _TILING_REVAMPED_MARKS_LOADED
  unset _TILING_REVAMPED_SCRATCHPAD_LOADED
  unset _TILING_REVAMPED_WORKSPACES_LOADED
  unset _TILING_REVAMPED_PROJECT_LAUNCHER_LOADED
  unset _TILING_REVAMPED_RESURRECT_LOADED
  unset _TILING_REVAMPED_PANE_GUARD_LOADED
  unset _TILING_REVAMPED_DEPRECATION_LOADED
  unset _TILING_REVAMPED_STATUS_LOADED
  unset _TILING_REVAMPED_HELP_OVERLAY_LOADED
  unset _TILING_REVAMPED_SMART_BORDERS_LOADED
  unset _TILING_REVAMPED_SWAP_BIGGEST_LOADED
  unset _TILING_REVAMPED_DYNAMIC_LAYOUT_LOADED
  unset _TILING_REVAMPED_APP_RULES_LOADED
  unset _TILING_REVAMPED_FOCUS_HISTORY_LOADED
  unset _TILING_REVAMPED_PANE_JUMPER_LOADED
}

cleanup_test_environment() {
  if [[ -n "${TEST_TMPDIR:-}" ]] && [[ -d "${TEST_TMPDIR}" ]]; then
    rm -rf "${TEST_TMPDIR}"
  fi
}

# Mock tmux function for unit tests.

_mock_opt_dir() {
  printf '%s' "${MOCK_OPTS_DIR:-${TEST_TMPDIR:-/tmp}/mock-opts}"
}

_mock_opt_path() {
  local dir
  dir="$(_mock_opt_dir)"
  mkdir -p "${dir}" 2>/dev/null || true
  printf '%s/%s' "${dir}" "$(printf '%s' "${1}" | tr -c 'A-Za-z0-9_.-' '_')"
}

_mock_opt_read() {
  local file
  file="$(_mock_opt_path "${1}")"
  if [[ -f "${file}" ]]; then
    cat "${file}"
  else
    printf '%s' "${MOCK_TMUX_OPTION_VALUE:-}"
  fi
}

_mock_opt_write() {
  local file
  file="$(_mock_opt_path "${1}")"
  if [[ "${3}" -eq 1 ]]; then
    rm -f "${file}"
  else
    printf '%s' "${2}" > "${file}"
  fi
}

# Controlled via MOCK_* environment variables.
tmux() {
  case "$1" in
    -V)
      echo "tmux 3.4"
      return 0
      ;;
    show-option)
      local option_name=""
      shift
      while [[ $# -gt 0 ]]; do
        case "$1" in
          -gqv|-gq|-g|-wqv|-wq|-w|-pqv|-pq|-p) ;;
          -t) shift ;;
          @*) option_name="$1" ;;
        esac
        shift
      done
      case "${option_name}" in
        @tiling_revamped_layout)
          echo "${MOCK_TILING_LAYOUT:-}" ;;
        @tiling_revamped_enabled)
          echo "${MOCK_TILING_ENABLED:-}" ;;
        @tiling_revamped_applying)
          echo "${MOCK_TILING_APPLYING:-0}" ;;
        @tiling_revamped_auto_apply)
          echo "${MOCK_TILING_AUTO_APPLY:-1}" ;;
        @tiling_revamped_orientation)
          echo "${MOCK_TILING_ORIENTATION:-brvc}" ;;
        @tiling_revamped_default_orientation)
          echo "${MOCK_TILING_DEFAULT_ORIENTATION:-brvc}" ;;
        @tiling_revamped_focus_resize)
          echo "${MOCK_TILING_FOCUS_RESIZE:-0}" ;;
        @tiling_revamped_focus_ratio)
          echo "${MOCK_TILING_FOCUS_RATIO:-62}" ;;
        @tiling_revamped_main_center_ratio)
          echo "${MOCK_TILING_MAIN_CENTER_RATIO:-60}" ;;
        @tiling_revamped_marks)
          echo "${MOCK_TILING_MARKS:-}" ;;
        @tiling_revamped_mark)
          echo "${MOCK_TILING_MARK:-}" ;;
        @tiling_revamped_enable_logging)
          echo "${MOCK_TILING_ENABLE_LOGGING:-0}" ;;
        @tiling_revamped_cycle_layouts)
          echo "${MOCK_TILING_CYCLE_LAYOUTS:-dwindle spiral grid main-vertical main-horizontal main-center monocle}" ;;
        @tiling_revamped_scratch_width)
          echo "${MOCK_TILING_SCRATCH_WIDTH:-80%}" ;;
        @tiling_revamped_scratch_height)
          echo "${MOCK_TILING_SCRATCH_HEIGHT:-75%}" ;;
        @tiling_revamped_monocle_prev_layout)
          echo "${MOCK_TILING_MONOCLE_PREV:-dwindle}" ;;
        @tiling_revamped_master_ratio)
          echo "${MOCK_TILING_MASTER_RATIO:-60}" ;;
        @tiling_revamped_resize_step)
          echo "${MOCK_TILING_RESIZE_STEP:-5}" ;;
        @tiling_revamped_default_layout)
          echo "${MOCK_TILING_DEFAULT_LAYOUT:-}" ;;
        @tiling_revamped_layout_history)
          echo "${MOCK_TILING_LAYOUT_HISTORY:-}" ;;
        @tiling_revamped_layout_redo)
          echo "${MOCK_TILING_LAYOUT_REDO:-}" ;;
        @tiling_revamped_last_window)
          echo "${MOCK_TILING_LAST_WINDOW:-}" ;;
        @tiling_revamped_split_ratio)
          echo "${MOCK_TILING_SPLIT_RATIO:-50}" ;;
        @tiling_revamped_project_dir)
          echo "${MOCK_TILING_PROJECT_DIR:-}" ;;
        @tiling_revamped_project_depth)
          echo "${MOCK_TILING_PROJECT_DEPTH:-1}" ;;
        @tiling_revamped_pick_width)
          echo "${MOCK_TILING_PICK_WIDTH:-60%}" ;;
        @tiling_revamped_pick_height)
          echo "${MOCK_TILING_PICK_HEIGHT:-40%}" ;;
        @tiling_revamped_pick_preview_width)
          echo "${MOCK_TILING_PICK_PREVIEW_WIDTH:-60%}" ;;
        *)
          _mock_opt_read "${option_name}" ;;
      esac
      return 0
      ;;
    set-option)
      local opt_name="" opt_value="" opt_unset=0
      shift
      while [[ $# -gt 0 ]]; do
        case "$1" in
          -gqu|-wqu|-pqu|-u) opt_unset=1 ;;
          -gqv|-gq|-g|-wqv|-wq|-w|-pqv|-pq|-p|-q) ;;
          -t) shift ;;
          @*)
            opt_name="$1"
            shift
            [[ $# -gt 0 ]] && opt_value="$1"
            continue
            ;;
        esac
        shift
      done
      _mock_opt_write "${opt_name}" "${opt_value}" "${opt_unset}"
      return 0
      ;;
    set-hook)
      return 0
      ;;
    set-window-option)
      return 0
      ;;
    display-message)
      shift
      while [[ $# -gt 0 ]]; do
        case "$1" in
          -p)
            shift
            case "$1" in
              '#{pane_id}')    echo "${MOCK_PANE_ID:-%0}" ;;
              '#{pane_width}') echo "${MOCK_PANE_WIDTH:-200}" ;;
              '#{pane_height}') echo "${MOCK_PANE_HEIGHT:-50}" ;;
              '#{window_id}')  echo "${MOCK_WINDOW_ID:-@0}" ;;
              '#{window_width}') echo "${MOCK_WINDOW_WIDTH:-200}" ;;
              '#{window_height}') echo "${MOCK_WINDOW_HEIGHT:-50}" ;;
              '#{window_panes}') echo "${MOCK_WINDOW_PANES:-1}" ;;
              '#{window_zoomed_flag}') echo "${MOCK_WINDOW_ZOOMED:-0}" ;;
              *) echo "" ;;
            esac
            return 0
            ;;
          -t) shift ;;
          *) ;;
        esac
        shift
      done
      ;;
    list-panes)
      if [[ -n "${MOCK_PANE_LIST:-}" ]]; then
        echo "${MOCK_PANE_LIST}"
      else
        echo "%0"
      fi
      return 0
      ;;
    last-pane)
      return "${MOCK_LAST_PANE_RC:-1}"
      ;;
    select-pane|resize-pane|move-pane|swap-pane|rotate-window|split-window)
      return 0
      ;;
    select-layout)
      return 0
      ;;
    bind-key)
      return 0
      ;;
    has-session)
      return "${MOCK_HAS_SESSION_RC:-1}"
      ;;
    display-popup)
      return 0
      ;;
    command-prompt)
      return 0
      ;;
    kill-server)
      return 0
      ;;
  esac
  return 0
}

date() {
  if [[ "$1" == "+%Y-%m-%d %H:%M:%S" ]]; then
    echo "${MOCK_TIMESTAMP:-2024-01-15 14:30:00}"
  elif [[ "$1" == "+%s" ]]; then
    echo "${MOCK_EPOCH:-1705320600}"
  else
    command date "$@"
  fi
}

stat() {
  if [[ "$1" == "-f%z" ]] || [[ "$1" == "-f" && "$2" == "%z" ]]; then
    echo "${MOCK_FILE_SIZE:-0}"
  elif [[ "$1" == "-c%s" ]] || [[ "$1" == "-c" && "$2" == "%s" ]]; then
    echo "${MOCK_FILE_SIZE:-0}"
  else
    command stat "$@"
  fi
}

command() {
  if [[ "$1" == "-v" ]] && [[ -n "${2:-}" ]]; then
    local cmd="$2"
    case "${cmd}" in
      fzf)
        [[ "${MOCK_HAS_FZF:-0}" == "1" ]] && return 0 || return 1
        ;;
      *)
        builtin command -v "${cmd}" >/dev/null 2>&1
        return $?
        ;;
    esac
  else
    builtin command "$@"
  fi
}

# Mock fzf so tests never launch the real interactive picker. The real
# `fzf --tmux` opens a tmux popup on whatever client is attached, which leaks
# onto the developer's own session when the suite runs inside tmux, and blocks
# waiting for input. The mock drains stdin and returns MOCK_FZF_SELECTION
# (empty by default, meaning "no selection").
fzf() {
  cat >/dev/null 2>&1
  [[ -n "${MOCK_FZF_SELECTION:-}" ]] && printf '%s\n' "${MOCK_FZF_SELECTION}"
  return 0
}

load_lib() {
  local lib_file="$1"
  local real_lib_path="${BATS_TEST_DIRNAME}/../../src/lib/${lib_file}"

  if [[ ! -f "${real_lib_path}" ]]; then
    return 0
  fi

  # shellcheck source=/dev/null
  source "${real_lib_path}" 2>/dev/null || true
}

function_exists() {
  declare -f "$1" > /dev/null
}

variable_exists() {
  [[ -n "${!1:-}" ]]
}

export -f tmux
export -f date
export -f stat
export -f command
export -f fzf
