#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_MAIN_CENTER_LOADED:-}" ]] && return 0
_TILING_REVAMPED_MAIN_CENTER_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"
source "${LIB_DIR}/layouts/dwindle.sh"

_main_center_vstack() {
  local pane_ids_str="$1"
  local x=$2 y=$3 w=$4 h=$5

  local -a pane_ids
  read -ra pane_ids <<< "${pane_ids_str}"
  local count="${#pane_ids[@]}"

  if (( count == 1 )); then
    echo "${w}x${h},${x},${y},${pane_ids[0]##%}"
    return
  fi

  local base_h=$(( (h - (count - 1)) / count ))
  local extra=$(( (h - (count - 1)) - base_h * count ))

  local parts=""
  local cy="${y}"
  local i
  for (( i = 0; i < count; i++ )); do
    local ph="${base_h}"
    (( i < extra )) && (( ph++ ))

    local leaf="${w}x${ph},${x},${cy},${pane_ids[i]##%}"
    if [[ -n "${parts}" ]]; then
      parts="${parts},${leaf}"
    else
      parts="${leaf}"
    fi
    cy=$(( cy + ph + 1 ))
  done

  echo "${w}x${h},${x},${y}[${parts}]"
}

_main_center_build() {
  local panes_str="$1"
  local ww=$2 wh=$3 ratio=$4

  local -a panes
  read -ra panes <<< "${panes_str}"
  local pane_count="${#panes[@]}"

  local main_w=$(( ww * ratio / 100 ))
  local side_total=$(( ww - main_w ))

  if (( pane_count == 2 )); then
    local left_w="${main_w}"
    local right_w=$(( ww - left_w - 1 ))
    local left="${left_w}x${wh},0,0,${panes[0]##%}"
    local right="${right_w}x${wh},$(( left_w + 1 )),0,${panes[1]##%}"
    echo "${ww}x${wh},0,0{${left},${right}}"
    return
  fi

  local secondary_count=$(( pane_count - 1 ))
  local left_count=$(( secondary_count / 2 ))
  local right_count=$(( secondary_count - left_count ))

  local left_w=$(( (side_total - 2) / 2 ))
  local right_w=$(( side_total - left_w - 2 ))
  local center_x=$(( left_w + 1 ))
  local right_x=$(( center_x + main_w + 1 ))

  local center_str="${main_w}x${wh},${center_x},0,${panes[0]##%}"

  local left_panes="${panes[*]:1:${left_count}}"
  local left_str
  left_str=$(_main_center_vstack "${left_panes}" 0 0 "${left_w}" "${wh}")

  local right_start=$(( left_count + 1 ))
  local right_panes="${panes[*]:${right_start}:${right_count}}"
  local right_str
  right_str=$(_main_center_vstack "${right_panes}" "${right_x}" 0 "${right_w}" "${wh}")

  echo "${ww}x${wh},0,0{${left_str},${center_str},${right_str}}"
}

apply_layout_main_center() {
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(tmux list-panes -F '#{pane_id}' 2>/dev/null)
  local pane_count="${#panes[@]}"

  (( pane_count <= 1 )) && { set_current_layout "main-center"; return 0; }

  local selected_pane
  selected_pane=$(get_current_pane)

  local window_width window_height
  window_width=$(get_window_width)
  window_height=$(get_window_height)

  local main_ratio
  main_ratio=$(get_numeric_option "@tiling_revamped_main_center_ratio" "60" "20" "90")

  trap 'set_applying 0' RETURN
  set_applying 1

  local layout_body
  layout_body=$(_main_center_build "${panes[*]}" "${window_width}" "${window_height}" "${main_ratio}")

  local checksum
  checksum=$(_layout_checksum "${layout_body}")

  tmux select-layout "${checksum},${layout_body}" 2>/dev/null || true

  [[ -n "${selected_pane}" ]] && tmux select-pane -t "${selected_pane}" 2>/dev/null || true

  set_current_layout "main-center"
}

export -f _main_center_vstack
export -f _main_center_build
export -f apply_layout_main_center
