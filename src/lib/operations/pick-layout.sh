#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_PICK_LAYOUT_LOADED:-}" ]] && return 0
_TILING_REVAMPED_PICK_LAYOUT_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/utils/constants.sh"
source "${LIB_DIR}/utils/has-command.sh"
source "${LIB_DIR}/utils/error-logger.sh"
source "${LIB_DIR}/utils/picker.sh"
source "${LIB_DIR}/layouts/dwindle.sh"
source "${LIB_DIR}/layouts/spiral.sh"
source "${LIB_DIR}/layouts/grid.sh"
source "${LIB_DIR}/layouts/main-center.sh"
source "${LIB_DIR}/layouts/main-vertical.sh"
source "${LIB_DIR}/layouts/main-horizontal.sh"
source "${LIB_DIR}/layouts/monocle.sh"
source "${LIB_DIR}/layouts/deck.sh"
source "${LIB_DIR}/layouts/previews.sh"

PICK_LAYOUTS=(
  "dwindle"
  "spiral"
  "grid"
  "main-vertical"
  "main-horizontal"
  "main-center"
  "monocle"
  "deck"
)

_get_layout_list() {
  printf '%s\n' "${PICK_LAYOUTS[@]}"
}

_get_layout_preview() {
  local layout="${1:-}"
  local upper
  upper=$(printf '%s' "${layout}" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
  local varname="TILING_PREVIEW_${upper}"
  echo "${!varname:-No preview available}"
}

_pick_with_fzf_tmux() {
  local width height preview_width
  width=$(get_tmux_option "@tiling_revamped_pick_width" "${TILING_DEFAULT_PICK_WIDTH}")
  height=$(get_tmux_option "@tiling_revamped_pick_height" "${TILING_DEFAULT_PICK_HEIGHT}")
  preview_width=$(get_tmux_option "@tiling_revamped_pick_preview_width" "${TILING_DEFAULT_PICK_PREVIEW_WIDTH}")

  local current
  current=$(get_current_layout)

  local fzf_args=(
    --prompt="Select layout: "
    --exit-0
    --preview="bash -c 'u=\$(printf \"%s\" \"\$1\" | tr \"[:lower:]\" \"[:upper:]\" | tr \"-\" \"_\"); n=\"TILING_PREVIEW_\${u}\"; echo \"\${!n:-No preview available}\"' -- {}"
    --preview-window="right:${preview_width}"
  )

  [[ -n "${current}" ]] && fzf_args+=(
    --header="Current: ${current}"
  )

  local selected
  selected=$(_get_layout_list | picker_fzf "center,${width},${height}" "${fzf_args[@]}" 2>/dev/null)

  local exit_code=$?
  [[ ${exit_code} -eq 130 ]] && return 130
  [[ ${exit_code} -ne 0 ]] && return 1

  echo "${selected}"
}

pick_layout() {
  if ! has_command fzf; then
    log_error "pick-layout" "fzf is not installed"
    return 1
  fi

  local width height
  width=$(get_tmux_option "@tiling_revamped_pick_width" "${TILING_DEFAULT_PICK_WIDTH}")
  height=$(get_tmux_option "@tiling_revamped_pick_height" "${TILING_DEFAULT_PICK_HEIGHT}")
  picker_open_popup "pick" "${width}" "${height}" && return 0

  local selected
  local pick_exit_code=0

  selected=$(_pick_with_fzf_tmux)
  pick_exit_code=$?

  [[ ${pick_exit_code} -eq 130 ]] && return 0
  [[ -z "${selected}" ]] && return 0

  local layout_name="${selected}"

  case "${layout_name}" in
    dwindle)
      apply_layout_dwindle ""
      ;;
    spiral)
      apply_layout_spiral ""
      ;;
    grid)
      apply_layout_grid
      ;;
    main-vertical)
      apply_layout_main_vertical
      ;;
    main-horizontal)
      apply_layout_main_horizontal
      ;;
    main-center)
      apply_layout_main_center
      ;;
    monocle)
      apply_layout_monocle
      ;;
    deck)
      apply_layout_deck
      ;;
    *)
      log_error "pick-layout" "Unknown layout: ${layout_name}"
      return 1
      ;;
  esac
}

export -f _get_layout_preview
export -f pick_layout
