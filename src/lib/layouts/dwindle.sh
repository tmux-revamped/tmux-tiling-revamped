#!/usr/bin/env bash

[[ -n "${_TILING_REVAMPED_DWINDLE_LOADED:-}" ]] && return 0
_TILING_REVAMPED_DWINDLE_LOADED=1

LIB_DIR="${TILING_REVAMPED_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

source "${LIB_DIR}/tmux/tmux-config.sh"

_layout_checksum() {
  local layout="$1"
  local csum=0
  local i ord
  for (( i=0; i<${#layout}; i++ )); do
    printf -v ord '%d' "'${layout:$i:1}"
    csum=$(( ((csum >> 1) + ((csum & 1) << 15) + ord) & 0xFFFF ))
  done
  printf '%04x' "$csum"
}

_bsp_pane_first() {
  local depth=$1
  local count=$((depth + 1))

  local is_hsplit=false
  (( count % 2 == modulo_hv )) && is_hsplit=true

  local pf=true
  if $is_hsplit; then
    if $is_spiral && (( count % 5 > 2 )); then
      [[ -n "$spiral_lr" ]] && pf=false || pf=true
    else
      [[ -n "$corner_lr" ]] && pf=false || pf=true
    fi
  else
    if $is_spiral && (( count % 5 > 2 )); then
      [[ -n "$spiral_tb" ]] && pf=false || pf=true
    else
      [[ -n "$corner_tb" ]] && pf=false || pf=true
    fi
  fi
  echo "$pf"
}

_bsp_leaf_permutation() {
  local n=$1
  local start_depth=$2

  if (( n == 1 )); then
    echo "$start_depth"
    return
  fi

  local pf
  pf=$(_bsp_pane_first "$start_depth")

  local rest_perm
  rest_perm=$(_bsp_leaf_permutation $((n - 1)) $((start_depth + 1)))

  if [[ "$pf" == "true" ]]; then
    echo "${start_depth} ${rest_perm}"
  else
    echo "${rest_perm} ${start_depth}"
  fi
}

_bsp_build() {
  local pane_ids_str="$1"
  local x=$2 y=$3 w=$4 h=$5
  local depth=$6

  local -a pane_ids
  read -ra pane_ids <<< "$pane_ids_str"

  if (( ${#pane_ids[@]} == 1 )); then
    echo "${w}x${h},${x},${y},${pane_ids[0]##%}"
    return
  fi

  local current="${pane_ids[0]}"
  local rest="${pane_ids[*]:1}"
  local count=$((depth + 1))

  local is_hsplit=false
  (( count % 2 == modulo_hv )) && is_hsplit=true

  local pane_first
  pane_first=$(_bsp_pane_first "$depth")

  local ratio=50
  if (( depth == 0 )); then
    ratio="${bsp_split_ratio:-50}"
  fi

  local first_str second_str

  if $is_hsplit; then
    local lw=$(( (w - 1) * ratio / 100 ))
    local rw=$(( w - lw - 1 ))
    local lx=$x
    local rx=$(( x + lw + 1 ))

    if [[ "$pane_first" == "true" ]]; then
      first_str=$(_bsp_build "${current}" "$lx" "$y" "$lw" "$h" $((depth + 1)))
      second_str=$(_bsp_build "${rest}" "$rx" "$y" "$rw" "$h" $((depth + 1)))
    else
      first_str=$(_bsp_build "${rest}" "$lx" "$y" "$lw" "$h" $((depth + 1)))
      second_str=$(_bsp_build "${current}" "$rx" "$y" "$rw" "$h" $((depth + 1)))
    fi
    echo "${w}x${h},${x},${y}{${first_str},${second_str}}"
  else
    local th=$(( (h - 1) * ratio / 100 ))
    local bh=$(( h - th - 1 ))
    local ty=$y
    local by=$(( y + th + 1 ))

    if [[ "$pane_first" == "true" ]]; then
      first_str=$(_bsp_build "${current}" "$x" "$ty" "$w" "$th" $((depth + 1)))
      second_str=$(_bsp_build "${rest}" "$x" "$by" "$w" "$bh" $((depth + 1)))
    else
      first_str=$(_bsp_build "${rest}" "$x" "$ty" "$w" "$th" $((depth + 1)))
      second_str=$(_bsp_build "${current}" "$x" "$by" "$w" "$bh" $((depth + 1)))
    fi
    echo "${w}x${h},${x},${y}[${first_str},${second_str}]"
  fi
}

_bsp_fix_pane_order() {
  local -a panes=("$@")
  local pane_count="${#panes[@]}"

  local -a perm
  read -ra perm <<< "$(_bsp_leaf_permutation "$pane_count" 0)"

  local needs_fix=false
  local i
  for (( i=0; i<pane_count; i++ )); do
    if (( perm[i] != i )); then
      needs_fix=true
      break
    fi
  done
  $needs_fix || return 0

  local -a inv
  for (( i=0; i<pane_count; i++ )); do
    inv[${perm[$i]}]=$i
  done

  local -a pane_to_leaf leaf_to_pane
  for (( i=0; i<pane_count; i++ )); do
    pane_to_leaf[$i]=$i
    leaf_to_pane[$i]=$i
  done

  for (( i=0; i<pane_count; i++ )); do
    local cur="${pane_to_leaf[$i]}"
    local tgt="${inv[$i]}"
    if (( cur != tgt )); then
      local other="${leaf_to_pane[$tgt]}"
      tmux swap-pane -d -s "${panes[$i]}" -t "${panes[$other]}" 2>/dev/null

      pane_to_leaf[$i]=$tgt
      pane_to_leaf[$other]=$cur
      leaf_to_pane[$tgt]=$i
      leaf_to_pane[$cur]=$other
    fi
  done
}

_apply_bsp_layout() {
  local is_spiral_arg="${1:-false}"
  local flags="${2:-}"

  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(tmux list-panes -F '#{pane_id}' 2>/dev/null)
  local pane_count="${#panes[@]}"

  (( pane_count <= 1 )) && return 0

  if [[ -z "${flags}" ]]; then
    flags=$(get_window_option "@tiling_revamped_orientation" "")
    [[ -z "${flags}" ]] && flags=$(get_tmux_option "@tiling_revamped_default_orientation" "brvc")
  fi

  local corner_tb='' spiral_tb='+' corner_lr='' spiral_lr='+' modulo_hv=1 is_spiral=false

  case "${flags}" in
    *t*) corner_tb='+'; spiral_tb='' ;;
    *)   corner_tb='';  spiral_tb='+' ;;
  esac
  case "${flags}" in
    *l*) corner_lr='+'; spiral_lr='' ;;
    *)   corner_lr='';  spiral_lr='+' ;;
  esac
  case "${flags}" in
    *h*) modulo_hv=0 ;;
    *)   modulo_hv=1 ;;
  esac
  case "${flags}" in
    *s*) is_spiral=true ;;
    *)   is_spiral=false ;;
  esac

  case "${is_spiral_arg}" in
    true)  is_spiral=true ;;
    false) is_spiral=false ;;
  esac

  local selected_pane
  selected_pane=$(tmux display-message -p '#{pane_id}' 2>/dev/null || echo "")

  local window_width window_height
  window_width=$(tmux display-message -p '#{window_width}' 2>/dev/null || echo "80")
  window_height=$(tmux display-message -p '#{window_height}' 2>/dev/null || echo "24")

  local bsp_split_ratio
  bsp_split_ratio=$(get_numeric_option "@tiling_revamped_split_ratio" "${TILING_DEFAULT_SPLIT_RATIO}" "20" "80")

  trap 'set_applying 0' RETURN
  set_applying 1

  local layout_body
  layout_body=$(_bsp_build "${panes[*]}" 0 0 "$window_width" "$window_height" 0)

  local checksum
  checksum=$(_layout_checksum "$layout_body")

  tmux select-layout "${checksum},${layout_body}" 2>/dev/null

  if $is_spiral; then
    _bsp_fix_pane_order "${panes[@]}"
  fi

  [[ -n "${selected_pane}" ]] && tmux select-pane -t "${selected_pane}" 2>/dev/null || true
}

apply_layout_dwindle() {
  local flags="${1:-}"
  _apply_bsp_layout "false" "${flags}"
  set_current_layout "dwindle"

  local stored_flags="${flags:-$(get_window_option "@tiling_revamped_orientation" "brvc")}"
  case "${stored_flags}" in
    *c*) ;;
    *s*) stored_flags="${stored_flags//s/c}" ;;
    *)   stored_flags="${stored_flags}c" ;;
  esac
  set_window_option "@tiling_revamped_orientation" "${stored_flags}"
}

export -f _layout_checksum
export -f _bsp_pane_first
export -f _bsp_leaf_permutation
export -f _bsp_build
export -f _bsp_fix_pane_order
export -f _apply_bsp_layout
export -f apply_layout_dwindle
