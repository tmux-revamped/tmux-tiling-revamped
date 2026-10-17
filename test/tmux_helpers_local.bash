#!/usr/bin/env bash

TILING_CMD="${PLUGIN_DIR}/src/tiling.sh"
TMUX_SOCKET="/tmp/tiling-test-${BASHPID}-${RANDOM}"

setup_tmux_server() {
  command tmux -S "${TMUX_SOCKET}" -f /dev/null new-session -d -s test -x 200 -y 50 2>/dev/null
  sleep 0.1
}

teardown_tmux_server() {
  command tmux -S "${TMUX_SOCKET}" kill-server 2>/dev/null || true
  rm -f "${TMUX_SOCKET}" 2>/dev/null || true
  release_tmux_override
}

release_tmux_override() {
  export -nf tmux 2>/dev/null || true
  export -n TMUX_SOCKET TILING_SOCKET 2>/dev/null || true
}

create_panes() {
  local count="${1:-3}"
  local i
  for ((i = 1; i < count; i++)); do
    command tmux -S "${TMUX_SOCKET}" split-window -d 2>/dev/null || {
      command tmux -S "${TMUX_SOCKET}" split-window -dh 2>/dev/null || return 1
    }
    if ((i % 3 == 0)); then
      command tmux -S "${TMUX_SOCKET}" select-layout tiled 2>/dev/null || true
    fi
  done
  sleep 0.1
}

get_pane_count() {
  command tmux -S "${TMUX_SOCKET}" list-panes 2>/dev/null | wc -l | tr -d ' '
}

get_pane_dimensions() {
  local pane_id="${1:-%0}"
  command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_id}" \
    '#{pane_width}x#{pane_height}' 2>/dev/null || echo "0x0"
}

assert_pane_count() {
  local expected="${1}"
  local actual
  actual=$(get_pane_count)
  if [[ "${actual}" != "${expected}" ]]; then
    echo "Expected ${expected} panes, got ${actual}" >&2
    return 1
  fi
}

assert_pane_wider_than() {
  local pane_a="${1}"
  local pane_b="${2}"
  local width_a width_b
  width_a=$(command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_a}" \
    '#{pane_width}' 2>/dev/null || echo "0")
  width_b=$(command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_b}" \
    '#{pane_width}' 2>/dev/null || echo "0")
  if ((width_a <= width_b)); then
    echo "Pane ${pane_a} (width=${width_a}) not wider than pane ${pane_b} (width=${width_b})" >&2
    return 1
  fi
}

assert_pane_taller_than() {
  local pane_a="${1}"
  local pane_b="${2}"
  local height_a height_b
  height_a=$(command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_a}" \
    '#{pane_height}' 2>/dev/null || echo "0")
  height_b=$(command tmux -S "${TMUX_SOCKET}" display-message -p -t "${pane_b}" \
    '#{pane_height}' 2>/dev/null || echo "0")
  if ((height_a <= height_b)); then
    echo "Pane ${pane_a} (height=${height_a}) not taller than pane ${pane_b} (height=${height_b})" >&2
    return 1
  fi
}

run_tiling() {
  local quoted_cmd
  printf -v quoted_cmd '%q' "${TILING_CMD}"
  command tmux -S "${TMUX_SOCKET}" \
    run-shell "TMUX_SOCKET=${TMUX_SOCKET} bash ${quoted_cmd} $*" 2>/dev/null
  sleep 0.2
}

assert_balanced_columns() {
  local layout="${1}"

  case "${layout}" in
  monocle | grid | deck) return 0 ;;
  esac

  local -a pane_data=()
  while IFS= read -r line; do
    pane_data+=("${line}")
  done < <(command tmux -S "${TMUX_SOCKET}" list-panes -F '#{pane_left} #{pane_width}' 2>/dev/null)

  local pane_count="${#pane_data[@]}"
  ((pane_count <= 2)) && return 0

  local max_width=0 center_left=0
  local entry pl pw
  for entry in "${pane_data[@]}"; do
    pl="${entry%% *}"
    pw="${entry##* }"
    if ((pw > max_width)); then
      max_width="${pw}"
      center_left="${pl}"
    fi
  done

  case "${layout}" in
  main-vertical | main-horizontal | dwindle | spiral) return 0 ;;
  esac

  local left_count=0 right_count=0
  for entry in "${pane_data[@]}"; do
    pl="${entry%% *}"
    pw="${entry##* }"
    if ((pw == max_width)); then
      continue
    elif ((pl < center_left)); then
      left_count=$((left_count + 1))
    else
      right_count=$((right_count + 1))
    fi
  done

  local diff=$((left_count - right_count))
  ((diff < 0)) && diff=$((-diff))

  if ((diff > 1)); then
    echo "Unbalanced columns: left=${left_count} right=${right_count} (diff=${diff})" >&2
    return 1
  fi
}

assert_balanced_rows() {
  local layout="${1}"

  case "${layout}" in
  monocle | grid | deck) return 0 ;;
  esac

  local -a pane_data=()
  while IFS= read -r line; do
    pane_data+=("${line}")
  done < <(command tmux -S "${TMUX_SOCKET}" list-panes -F '#{pane_top} #{pane_height} #{pane_left} #{pane_width}' 2>/dev/null)

  local pane_count="${#pane_data[@]}"
  ((pane_count <= 2)) && return 0

  if [[ "${layout}" == "main-vertical" ]]; then
    local -a stack_heights=()
    local max_width=0
    local entry
    for entry in "${pane_data[@]}"; do
      local pw
      pw=$(echo "${entry}" | awk '{print $4}')
      if ((pw > max_width)); then
        max_width="${pw}"
      fi
    done
    for entry in "${pane_data[@]}"; do
      local pw ph
      pw=$(echo "${entry}" | awk '{print $4}')
      ph=$(echo "${entry}" | awk '{print $2}')
      if ((pw < max_width)); then
        stack_heights+=("${ph}")
      fi
    done
    if ((${#stack_heights[@]} >= 2)); then
      local min_h=999999 max_h=0
      local h
      for h in "${stack_heights[@]}"; do
        ((h < min_h)) && min_h="${h}"
        ((h > max_h)) && max_h="${h}"
      done
      local hdiff=$((max_h - min_h))
      if ((hdiff > 3)); then
        echo "Unbalanced stack heights in main-vertical: min=${min_h} max=${max_h} (diff=${hdiff})" >&2
        return 1
      fi
    fi
    return 0
  fi

  if [[ "${layout}" == "main-horizontal" ]]; then
    local -a stack_widths=()
    local max_height=0
    local entry
    for entry in "${pane_data[@]}"; do
      local ph
      ph=$(echo "${entry}" | awk '{print $2}')
      if ((ph > max_height)); then
        max_height="${ph}"
      fi
    done
    for entry in "${pane_data[@]}"; do
      local ph pw
      ph=$(echo "${entry}" | awk '{print $2}')
      pw=$(echo "${entry}" | awk '{print $4}')
      if ((ph < max_height)); then
        stack_widths+=("${pw}")
      fi
    done
    if ((${#stack_widths[@]} >= 2)); then
      local min_w=999999 max_w=0
      local w
      for w in "${stack_widths[@]}"; do
        ((w < min_w)) && min_w="${w}"
        ((w > max_w)) && max_w="${w}"
      done
      local wdiff=$((max_w - min_w))
      if ((wdiff > 3)); then
        echo "Unbalanced stack widths in main-horizontal: min=${min_w} max=${max_w} (diff=${wdiff})" >&2
        return 1
      fi
    fi
    return 0
  fi
}

assert_layout_applies() {
  local layout="${1}"
  local count="${2}"
  create_panes "${count}"
  local actual_count
  actual_count=$(get_pane_count)
  if ((actual_count < count)); then
    skip "terminal too small for ${count} panes (created ${actual_count})"
  fi
  run_tiling layout "${layout}"
  [[ "$(command tmux -S "${TMUX_SOCKET}" show-option -wqv "@tiling_revamped_layout" 2>/dev/null)" == "${layout}" ]]
  assert_pane_count "${count}"
}

export TILING_CMD
