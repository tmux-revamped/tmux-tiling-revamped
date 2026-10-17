#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_PROJECT_LAUNCHER_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PROJECT_LAUNCHER_LOADED=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/.."

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/has-command.sh"
source "${LIB_DIR}/utils/error-logger.sh"
source "${LIB_DIR}/utils/picker.sh"

# launch_project: open an fzf popup listing project directories.
# Selecting one creates a new tmux window in that directory.
launch_project() {
  if ! has_command fzf; then
    log_error "project-launcher" "fzf is not installed"
    return 1
  fi

  local project_dir
  project_dir=$(get_tmux_option "@tiling_revamped_project_dir" "")

  if [[ -z "${project_dir}" ]]; then
    log_error "project-launcher" "Set @tiling_revamped_project_dir to enable the project launcher"
    return 1
  fi

  # Expand ~ to $HOME
  project_dir="${project_dir/#\~/${HOME}}"

  if [[ ! -d "${project_dir}" ]]; then
    log_error "project-launcher" "Project directory not found: ${project_dir}"
    return 1
  fi

  local depth
  depth=$(get_tmux_option "@tiling_revamped_project_depth" "1")

  picker_open_popup "project" "${TILING_PROJECT_PICK_WIDTH}" "${TILING_PROJECT_PICK_HEIGHT}" && return 0

  local spec="center,${TILING_PROJECT_PICK_WIDTH},${TILING_PROJECT_PICK_HEIGHT}"
  local selected
  if has_command fd; then
    selected=$(fd --type d --max-depth "${depth}" --base-directory "${project_dir}" 2>/dev/null \
      | picker_fzf "${spec}" --prompt="Project: " 2>/dev/null)
  else
    selected=$(find "${project_dir}" -mindepth 1 -maxdepth "${depth}" -type d 2>/dev/null \
      | sed "s|^${project_dir}/||" \
      | sort \
      | picker_fzf "${spec}" --prompt="Project: " 2>/dev/null)
  fi

  [[ -z "${selected}" ]] && return 0

  local full_path="${project_dir}/${selected}"
  local window_name
  window_name=$(basename "${selected}")

  tmux new-window -n "${window_name}" -c "${full_path}" 2>/dev/null || return 1
}

export -f launch_project
