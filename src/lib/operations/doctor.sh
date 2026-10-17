#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_DOCTOR_LOADED:-}" ]] && return 0
_TILING_REVAMPED_DOCTOR_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/has-command.sh"
source "${LIB_DIR}/utils/constants.sh"

run_doctor() {
  local issues=0

  if (( BASH_VERSINFO[0] >= 4 )); then
    echo "PASS  bash ${BASH_VERSION}"
  else
    echo "FAIL  bash ${BASH_VERSION} (need 4.0+)"
    issues=$(( issues + 1 ))
  fi

  local tmux_version
  tmux_version=$(tmux -V 2>/dev/null | sed 's/[^0-9.]//g')
  if [[ -n "${tmux_version}" ]]; then
    local major="${tmux_version%%.*}"
    local minor="${tmux_version#*.}"
    minor="${minor%%.*}"
    [[ "${minor}" =~ ^[0-9]+$ ]] || minor=0
    [[ "${tmux_version}" == *.* ]] || minor=0
    if [[ -n "${major}" ]] && { (( major > 3 )) || { (( major == 3 )) && (( minor >= 2 )); }; }; then
      echo "PASS  tmux ${tmux_version}"
    elif [[ -n "${major}" ]]; then
      echo "FAIL  tmux ${tmux_version} (need 3.2+)"
      issues=$(( issues + 1 ))
    else
      echo "PASS  tmux detected"
    fi
  else
    echo "PASS  tmux detected"
  fi

  if has_command fzf; then
    local fzf_version
    fzf_version=$(fzf --version 2>/dev/null | cut -d' ' -f1)
    echo "PASS  fzf ${fzf_version}"
  else
    echo "WARN  fzf not installed (layout picker, marks, presets disabled)"
  fi

  if has_command fd; then
    echo "PASS  fd installed (fast project listing)"
  else
    echo "INFO  fd not installed (project launcher will use find)"
  fi

  echo "INFO  tmux-tiling-revamped ${TILING_REVAMPED_VERSION}"

  local layout
  layout=$(get_current_layout)
  if [[ -n "${layout}" ]]; then
    echo "INFO  current layout: ${layout}"
  else
    echo "INFO  no layout active"
  fi

  local auto_apply
  auto_apply=$(get_tmux_option "@tiling_revamped_auto_apply" "1")
  echo "INFO  auto-apply: ${auto_apply}"

  if (( issues > 0 )); then
    echo ""
    echo "${issues} issue(s) found"
    return 1
  fi

  echo ""
  echo "All checks passed"
  return 0
}

export -f run_doctor
