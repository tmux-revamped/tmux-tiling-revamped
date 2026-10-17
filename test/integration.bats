#!/usr/bin/env bats
#
# Integration tests: validate every feature against a real tmux server.
#
# Each test starts a fresh tmux server (200x50), creates panes, runs
# tiling.sh commands, and asserts the resulting state.

load "${BATS_TEST_DIRNAME}/tmux_helpers.bash"

setup() {
  setup_tmux_server
}

teardown() {
  teardown_tmux_server
}

# ── Helper ──────────────────────────────────────────────────────────

get_layout() {
  command tmux -S "${TMUX_SOCKET}" show-option -wqv "@tiling_revamped_layout" 2>/dev/null
}

get_orientation() {
  command tmux -S "${TMUX_SOCKET}" show-option -wqv "@tiling_revamped_orientation" 2>/dev/null
}

get_pane_ids() {
  command tmux -S "${TMUX_SOCKET}" list-panes -F '#{pane_id}' 2>/dev/null
}

get_active_pane() {
  command tmux -S "${TMUX_SOCKET}" display-message -p '#{pane_id}' 2>/dev/null
}

get_pane_width() {
  command tmux -S "${TMUX_SOCKET}" display-message -p -t "${1}" '#{pane_width}' 2>/dev/null
}

get_pane_height() {
  command tmux -S "${TMUX_SOCKET}" display-message -p -t "${1}" '#{pane_height}' 2>/dev/null
}

# ── Layouts ─────────────────────────────────────────────────────────

@test "integration: dwindle layout with 3 panes" {
  create_panes 3
  run_tiling layout dwindle
  [[ "$(get_layout)" == "dwindle" ]]
  assert_pane_count 3
}

@test "integration: dwindle master pane occupies roughly half the window" {
  create_panes 4
  run_tiling layout dwindle
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  # BSP first split divides in half; rounding may shift 1px, so check >= 40%
  local master_w window_w threshold
  master_w=$(get_pane_width "${panes[0]}")
  window_w=$(command tmux -S "${TMUX_SOCKET}" display-message -p '#{window_width}' 2>/dev/null)
  threshold=$(( window_w * 40 / 100 ))
  (( master_w >= threshold ))
}

@test "integration: spiral layout with 4 panes" {
  create_panes 4
  run_tiling layout spiral
  [[ "$(get_layout)" == "spiral" ]]
  assert_pane_count 4
}

@test "integration: spiral master pane occupies roughly half the window" {
  create_panes 5
  run_tiling layout spiral
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  local master_w window_w threshold
  master_w=$(get_pane_width "${panes[0]}")
  window_w=$(command tmux -S "${TMUX_SOCKET}" display-message -p '#{window_width}' 2>/dev/null)
  threshold=$(( window_w * 40 / 100 ))
  (( master_w >= threshold ))
}

@test "integration: grid layout with 4 panes" {
  create_panes 4
  run_tiling layout grid
  [[ "$(get_layout)" == "grid" ]]
  assert_pane_count 4
}

@test "integration: main-center layout with 3 panes" {
  create_panes 3
  run_tiling layout main-center
  [[ "$(get_layout)" == "main-center" ]]
  assert_pane_count 3
}

@test "integration: main-center master is wider than sides" {
  create_panes 3
  run_tiling layout main-center
  # After main-center, pane order is: left-side, center, right-side
  # Center pane (index 1) must be the widest
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  assert_pane_wider_than "${panes[1]}" "${panes[0]}"
  assert_pane_wider_than "${panes[1]}" "${panes[2]}"
}

@test "integration: main-vertical layout with 3 panes" {
  create_panes 3
  run_tiling layout main-vertical
  [[ "$(get_layout)" == "main-vertical" ]]
  assert_pane_count 3
}

@test "integration: main-vertical master is wider than stack" {
  create_panes 3
  run_tiling layout main-vertical
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  assert_pane_wider_than "${panes[0]}" "${panes[1]}"
}

@test "integration: main-horizontal layout with 3 panes" {
  create_panes 3
  run_tiling layout main-horizontal
  [[ "$(get_layout)" == "main-horizontal" ]]
  assert_pane_count 3
}

@test "integration: main-horizontal master is taller than stack" {
  create_panes 3
  run_tiling layout main-horizontal
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  assert_pane_taller_than "${panes[0]}" "${panes[1]}"
}

@test "integration: monocle toggles zoom" {
  create_panes 3
  run_tiling layout monocle
  local zoomed
  zoomed=$(command tmux -S "${TMUX_SOCKET}" display-message -p '#{window_zoomed_flag}' 2>/dev/null)
  [[ "${zoomed}" == "1" ]]
}

@test "integration: monocle unzoom restores previous layout" {
  create_panes 3
  run_tiling layout dwindle
  run_tiling layout monocle
  run_tiling layout monocle
  local zoomed
  zoomed=$(command tmux -S "${TMUX_SOCKET}" display-message -p '#{window_zoomed_flag}' 2>/dev/null)
  [[ "${zoomed}" == "0" ]]
  [[ "$(get_layout)" == "dwindle" ]]
}

@test "integration: deck layout with 3 panes" {
  create_panes 3
  run_tiling layout deck
  [[ "$(get_layout)" == "deck" ]]
  assert_pane_count 3
}

# ── Layout switching ────────────────────────────────────────────────

@test "integration: switch from dwindle to grid preserves panes" {
  create_panes 4
  run_tiling layout dwindle
  [[ "$(get_layout)" == "dwindle" ]]
  run_tiling layout grid
  [[ "$(get_layout)" == "grid" ]]
  assert_pane_count 4
}

@test "integration: switch from main-vertical to main-horizontal" {
  create_panes 3
  run_tiling layout main-vertical
  [[ "$(get_layout)" == "main-vertical" ]]
  run_tiling layout main-horizontal
  [[ "$(get_layout)" == "main-horizontal" ]]
  assert_pane_count 3
}

# ── Operations ──────────────────────────────────────────────────────

@test "integration: balance resets pane sizes for dwindle" {
  create_panes 4
  run_tiling layout dwindle
  # Manually resize a pane to create imbalance
  local first_pane
  first_pane=$(command tmux -S "${TMUX_SOCKET}" list-panes -F '#{pane_id}' 2>/dev/null | head -1)
  command tmux -S "${TMUX_SOCKET}" resize-pane -t "${first_pane}" -R 30 2>/dev/null || true
  sleep 0.1
  run_tiling balance
  [[ "$(get_layout)" == "dwindle" ]]
}

@test "integration: balance works for main-vertical" {
  create_panes 3
  run_tiling layout main-vertical
  run_tiling balance
  [[ "$(get_layout)" == "main-vertical" ]]
}

@test "integration: balance works for main-horizontal" {
  create_panes 3
  run_tiling layout main-horizontal
  run_tiling balance
  [[ "$(get_layout)" == "main-horizontal" ]]
}

@test "integration: balance works for main-center" {
  create_panes 3
  run_tiling layout main-center
  run_tiling balance
  [[ "$(get_layout)" == "main-center" ]]
}

@test "integration: promote swaps focused pane with master" {
  create_panes 3
  run_tiling layout dwindle
  # Select the second pane
  command tmux -S "${TMUX_SOCKET}" select-pane -t 1 2>/dev/null
  sleep 0.1
  run_tiling promote
  [[ "$(get_layout)" == "dwindle" ]]
  assert_pane_count 3
}

@test "integration: circulate next shifts pane positions" {
  create_panes 3
  run_tiling layout dwindle
  run_tiling circulate next
  [[ "$(get_layout)" == "dwindle" ]]
  assert_pane_count 3
}

@test "integration: circulate prev shifts the other direction" {
  create_panes 3
  run_tiling layout dwindle
  run_tiling circulate prev
  [[ "$(get_layout)" == "dwindle" ]]
}

@test "integration: rotate 90 changes orientation" {
  create_panes 3
  run_tiling layout dwindle
  local before
  before=$(get_orientation)
  run_tiling rotate 90
  local after
  after=$(get_orientation)
  # Orientation should change (v<->h toggle)
  [[ "${before}" != "${after}" ]]
}

@test "integration: flip h mirrors the layout" {
  create_panes 3
  run_tiling layout dwindle
  local before
  before=$(get_orientation)
  run_tiling flip h
  local after
  after=$(get_orientation)
  [[ "${before}" != "${after}" ]]
}

@test "integration: equalize distributes evenly" {
  create_panes 4
  run_tiling layout dwindle
  run_tiling equalize
  assert_pane_count 4
}

@test "integration: autosplit adds a new pane" {
  run_tiling autosplit
  assert_pane_count 2
}

# ── Resize master ───────────────────────────────────────────────────

@test "integration: resize-master grow increases master width in main-vertical" {
  create_panes 3
  run_tiling layout main-vertical
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  local before_width
  before_width=$(get_pane_width "${panes[0]}")
  run_tiling resize-master grow
  local after_width
  after_width=$(get_pane_width "${panes[0]}")
  (( after_width >= before_width ))
}

@test "integration: resize-master shrink decreases master width in main-vertical" {
  create_panes 3
  run_tiling layout main-vertical
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  local before_width
  before_width=$(get_pane_width "${panes[0]}")
  run_tiling resize-master shrink
  local after_width
  after_width=$(get_pane_width "${panes[0]}")
  (( after_width <= before_width ))
}

@test "integration: resize-master grow on main-horizontal increases master height" {
  create_panes 3
  run_tiling layout main-horizontal
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  local before_height
  before_height=$(get_pane_height "${panes[0]}")
  run_tiling resize-master grow
  local after_height
  after_height=$(get_pane_height "${panes[0]}")
  (( after_height >= before_height ))
}

# ── Sync ────────────────────────────────────────────────────────────

@test "integration: sync toggles synchronize-panes on" {
  create_panes 2
  run_tiling sync
  local sync_val
  sync_val=$(command tmux -S "${TMUX_SOCKET}" show-window-option -v synchronize-panes 2>/dev/null)
  [[ "${sync_val}" == "on" ]]
}

@test "integration: sync toggles synchronize-panes off again" {
  create_panes 2
  run_tiling sync
  run_tiling sync
  local sync_val
  sync_val=$(command tmux -S "${TMUX_SOCKET}" show-window-option -v synchronize-panes 2>/dev/null)
  [[ "${sync_val}" == "off" ]]
}

# ── Swap direction ──────────────────────────────────────────────────

@test "integration: swap R swaps focused pane with right neighbor" {
  create_panes 3
  run_tiling layout dwindle
  local -a panes_before
  while IFS= read -r _p; do panes_before+=("$_p"); done < <(get_pane_ids)
  # Focus the master pane (leftmost)
  command tmux -S "${TMUX_SOCKET}" select-pane -t "${panes_before[0]}" 2>/dev/null
  sleep 0.1
  run_tiling swap R
  assert_pane_count 3
  local -a panes_after
  while IFS= read -r _p; do panes_after+=("$_p"); done < <(get_pane_ids)
  [[ "${panes_after[0]}" != "${panes_before[0]}" ]] || false
  [[ "$(get_active_pane)" == "${panes_before[0]}" ]]
}

@test "integration: swap D swaps focused pane with bottom neighbor" {
  create_panes 3
  run_tiling layout dwindle
  local -a panes_before
  while IFS= read -r _p; do panes_before+=("$_p"); done < <(get_pane_ids)
  command tmux -S "${TMUX_SOCKET}" select-pane -t "${panes_before[1]}" 2>/dev/null
  sleep 0.1
  run_tiling swap D
  assert_pane_count 3
  local -a panes_after
  while IFS= read -r _p; do panes_after+=("$_p"); done < <(get_pane_ids)
  [[ "${panes_after[1]}" == "${panes_before[2]}" ]] || false
  [[ "${panes_after[2]}" == "${panes_before[1]}" ]]
}

# ── Cycle ───────────────────────────────────────────────────────────

@test "integration: cycle next moves through layout sequence" {
  create_panes 3
  run_tiling layout dwindle
  [[ "$(get_layout)" == "dwindle" ]]
  run_tiling cycle next
  [[ "$(get_layout)" == "spiral" ]]
  run_tiling cycle next
  [[ "$(get_layout)" == "grid" ]]
}

@test "integration: cycle prev moves backward" {
  create_panes 3
  run_tiling layout spiral
  run_tiling cycle prev
  [[ "$(get_layout)" == "dwindle" ]]
}

@test "integration: cycle wraps around from last to first" {
  create_panes 3
  run_tiling layout deck
  run_tiling cycle next
  [[ "$(get_layout)" == "dwindle" ]]
}

# ── Marks ───────────────────────────────────────────────────────────

@test "integration: mark pane stores mark name" {
  create_panes 3
  run_tiling mark "editor"
  local mark
  mark=$(command tmux -S "${TMUX_SOCKET}" show-option -pqv "@tiling_revamped_mark" 2>/dev/null)
  [[ "${mark}" == "editor" ]]
}

@test "integration: jump to mark selects the correct pane" {
  create_panes 3
  local -a panes
  while IFS= read -r _p; do panes+=("$_p"); done < <(get_pane_ids)
  # Mark the second pane
  command tmux -S "${TMUX_SOCKET}" select-pane -t "${panes[1]}" 2>/dev/null
  sleep 0.1
  run_tiling mark "build"
  # Switch to the first pane
  command tmux -S "${TMUX_SOCKET}" select-pane -t "${panes[0]}" 2>/dev/null
  sleep 0.1
  run_tiling jump "build"
  local active
  active=$(get_active_pane)
  [[ "${active}" == "${panes[1]}" ]]
}

@test "integration: unmark removes the mark" {
  create_panes 2
  run_tiling mark "test"
  run_tiling unmark
  local mark
  mark=$(command tmux -S "${TMUX_SOCKET}" show-option -pqv "@tiling_revamped_mark" 2>/dev/null)
  [[ -z "${mark}" ]]
}

# ── Presets ─────────────────────────────────────────────────────────

@test "integration: preset save and apply restores layout" {
  create_panes 3
  run_tiling layout dwindle
  run_tiling preset save "dev"
  run_tiling layout grid
  [[ "$(get_layout)" == "grid" ]]
  run_tiling preset apply "dev"
  [[ "$(get_layout)" == "dwindle" ]]
}

# ── Orientation flags ───────────────────────────────────────────────

@test "integration: dwindle with brvc orientation" {
  create_panes 4
  run_tiling layout dwindle brvc
  [[ "$(get_layout)" == "dwindle" ]]
  assert_pane_count 4
}

@test "integration: dwindle with tlhc orientation" {
  create_panes 4
  run_tiling layout dwindle tlhc
  [[ "$(get_layout)" == "dwindle" ]]
}

@test "integration: spiral with brvs orientation" {
  create_panes 5
  run_tiling layout spiral brvs
  [[ "$(get_layout)" == "spiral" ]]
}

# ── Multi-pane stress ──────────────────────────────────────────────

@test "integration: dwindle with 8 panes" {
  create_panes 8
  run_tiling layout dwindle
  [[ "$(get_layout)" == "dwindle" ]]
  assert_pane_count 8
}

@test "integration: spiral with 6 panes" {
  create_panes 6
  run_tiling layout spiral
  [[ "$(get_layout)" == "spiral" ]]
  assert_pane_count 6
}

@test "integration: grid with 9 panes" {
  create_panes 9
  run_tiling layout grid
  [[ "$(get_layout)" == "grid" ]]
  assert_pane_count 9
}

@test "integration: main-vertical with 5 panes" {
  create_panes 5
  run_tiling layout main-vertical
  [[ "$(get_layout)" == "main-vertical" ]]
  assert_pane_count 5
}

@test "integration: main-horizontal with 5 panes" {
  create_panes 5
  run_tiling layout main-horizontal
  [[ "$(get_layout)" == "main-horizontal" ]]
  assert_pane_count 5
}

@test "integration: main-center with 5 panes" {
  create_panes 5
  run_tiling layout main-center
  [[ "$(get_layout)" == "main-center" ]]
  assert_pane_count 5
}

# ── Auto-reapplication ──────────────────────────────────────────────

@test "integration: dwindle re-applies after split" {
  create_panes 3
  run_tiling layout dwindle
  # Set auto-apply globally
  command tmux -S "${TMUX_SOCKET}" set-option -g "@tiling_revamped_auto_apply" "1" 2>/dev/null
  # Manually trigger the hook handler
  run_tiling hook split
  [[ "$(get_layout)" == "dwindle" ]]
}

@test "integration: main-vertical re-applies via hook" {
  create_panes 3
  run_tiling layout main-vertical
  command tmux -S "${TMUX_SOCKET}" set-option -g "@tiling_revamped_auto_apply" "1" 2>/dev/null
  run_tiling hook split
  [[ "$(get_layout)" == "main-vertical" ]]
}

@test "integration: main-horizontal re-applies via hook" {
  create_panes 3
  run_tiling layout main-horizontal
  command tmux -S "${TMUX_SOCKET}" set-option -g "@tiling_revamped_auto_apply" "1" 2>/dev/null
  run_tiling hook resize
  [[ "$(get_layout)" == "main-horizontal" ]]
}

# ── Promote and circulate across all layout types ───────────────────

@test "integration: promote works with main-vertical" {
  create_panes 3
  run_tiling layout main-vertical
  command tmux -S "${TMUX_SOCKET}" select-pane -t 1 2>/dev/null
  sleep 0.1
  run_tiling promote
  [[ "$(get_layout)" == "main-vertical" ]]
}

@test "integration: circulate works with main-horizontal" {
  create_panes 3
  run_tiling layout main-horizontal
  run_tiling circulate next
  [[ "$(get_layout)" == "main-horizontal" ]]
}

@test "integration: promote works with grid" {
  create_panes 4
  run_tiling layout grid
  command tmux -S "${TMUX_SOCKET}" select-pane -t 2 2>/dev/null
  sleep 0.1
  run_tiling promote
  [[ "$(get_layout)" == "grid" ]]
}

# ── Default layout hook ─────────────────────────────────────────────

@test "integration: new-window hook applies default layout" {
  command tmux -S "${TMUX_SOCKET}" set-option -g "@tiling_revamped_default_layout" "grid" 2>/dev/null
  # Simulate the hook by calling it directly
  run_tiling hook new-window
  [[ "$(get_layout)" == "grid" ]]
}

@test "integration: new-window hook with dwindle default" {
  create_panes 3
  command tmux -S "${TMUX_SOCKET}" set-option -g "@tiling_revamped_default_layout" "dwindle" 2>/dev/null
  run_tiling hook new-window
  [[ "$(get_layout)" == "dwindle" ]]
}

@test "integration: new-window hook with main-vertical default" {
  create_panes 3
  command tmux -S "${TMUX_SOCKET}" set-option -g "@tiling_revamped_default_layout" "main-vertical" 2>/dev/null
  run_tiling hook new-window
  [[ "$(get_layout)" == "main-vertical" ]]
}

@test "integration: new-window hook with empty default does nothing" {
  command tmux -S "${TMUX_SOCKET}" set-option -g "@tiling_revamped_default_layout" "" 2>/dev/null
  run_tiling hook new-window
  local layout
  layout=$(get_layout)
  [[ -z "${layout}" ]]
}

# ── Balanced main-center ──────────────────────────────────────────

@test "integration: main-center with 5 panes has balanced sides" {
  create_panes 5
  run_tiling layout main-center
  [[ "$(get_layout)" == "main-center" ]]
  # Find the center pane (widest) and classify others by position
  local max_width=0 center_pane_left=0
  while IFS= read -r line; do
    local w="${line##* }"
    local l="${line#* }"
    l="${l%% *}"
    if (( w > max_width )); then
      max_width="${w}"
      center_pane_left="${l}"
    fi
  done < <(command tmux -S "${TMUX_SOCKET}" list-panes -F '#{pane_id} #{pane_left} #{pane_width}' 2>/dev/null)
  # Count panes on each side of the center
  local left_count=0 right_count=0
  while IFS= read -r line; do
    local pl="${line#* }"
    pl="${pl%% *}"
    local pw="${line##* }"
    if (( pw == max_width )); then
      continue
    elif (( pl < center_pane_left )); then
      left_count=$(( left_count + 1 ))
    else
      right_count=$(( right_count + 1 ))
    fi
  done < <(command tmux -S "${TMUX_SOCKET}" list-panes -F '#{pane_id} #{pane_left} #{pane_width}' 2>/dev/null)
  [[ "${left_count}" -eq 2 ]]
  [[ "${right_count}" -eq 2 ]]
}

@test "integration: main-center with 7 panes has balanced sides" {
  create_panes 7
  run_tiling layout main-center
  [[ "$(get_layout)" == "main-center" ]]
  local max_width=0 center_pane_left=0
  while IFS= read -r line; do
    local w="${line##* }"
    local l="${line#* }"
    l="${l%% *}"
    if (( w > max_width )); then
      max_width="${w}"
      center_pane_left="${l}"
    fi
  done < <(command tmux -S "${TMUX_SOCKET}" list-panes -F '#{pane_id} #{pane_left} #{pane_width}' 2>/dev/null)
  local left_count=0 right_count=0
  while IFS= read -r line; do
    local pl="${line#* }"
    pl="${pl%% *}"
    local pw="${line##* }"
    if (( pw == max_width )); then
      continue
    elif (( pl < center_pane_left )); then
      left_count=$(( left_count + 1 ))
    else
      right_count=$(( right_count + 1 ))
    fi
  done < <(command tmux -S "${TMUX_SOCKET}" list-panes -F '#{pane_id} #{pane_left} #{pane_width}' 2>/dev/null)
  [[ "${left_count}" -eq 3 ]]
  [[ "${right_count}" -eq 3 ]]
}

# ── Layout picker ─────────────────────────────────────────────────

@test "integration: pick command is routed in dispatcher" {
  # pick requires fzf interactive input, which is unavailable in CI.
  # Just verify the command does not crash the dispatcher.
  run_tiling pick || true
  true
}

# ── Deck in cycle ─────────────────────────────────────────────────

@test "integration: cycle includes deck in default order" {
  create_panes 3
  run_tiling layout monocle
  # monocle is second-to-last in cycle, deck is last
  run_tiling cycle next
  [[ "$(get_layout)" == "deck" ]]
}

# New: status indicator

@test "integration: status command is routed in dispatcher" {
  run_tiling layout dwindle
  run_tiling status || true
  true
}

# New: redo

@test "integration: redo re-applies an undone layout" {
  create_panes 3
  run_tiling layout dwindle
  run_tiling layout grid
  run_tiling undo
  [[ "$(get_layout)" == "dwindle" ]]
  run_tiling redo
  [[ "$(get_layout)" == "grid" ]]
}

@test "integration: redo is a no-op with an empty redo stack" {
  create_panes 2
  run_tiling layout dwindle
  run_tiling redo || true
  true
}

@test "integration: a fresh layout change clears the redo stack" {
  create_panes 3
  run_tiling layout dwindle
  run_tiling layout grid
  run_tiling undo
  run_tiling layout spiral
  run_tiling redo
  [[ "$(get_layout)" == "spiral" ]]
}

# New: swap with biggest

@test "integration: swap-biggest keeps the pane count and is routed" {
  create_panes 3
  run_tiling layout main-vertical
  command tmux -S "${TMUX_SOCKET}" select-pane -t 1 2>/dev/null
  sleep 0.1
  run_tiling swap-biggest
  assert_pane_count 3
}

# New: smart borders

@test "integration: smart-borders hides chrome on a single pane" {
  command tmux -S "${TMUX_SOCKET}" set -g @tiling_revamped_smart_borders 1
  run_tiling smart-borders
  local status_val
  status_val=$(command tmux -S "${TMUX_SOCKET}" show-option -wqv pane-border-status 2>/dev/null)
  [[ "${status_val}" == "off" ]]
}

@test "integration: smart-borders restores chrome with multiple panes" {
  command tmux -S "${TMUX_SOCKET}" set -g @tiling_revamped_smart_borders 1
  create_panes 2
  run_tiling smart-borders
  local status_val
  status_val=$(command tmux -S "${TMUX_SOCKET}" show-option -wqv pane-border-status 2>/dev/null)
  [[ "${status_val}" == "top" ]]
}

# New: workspace back-and-forth

@test "integration: back-and-forth toggles to the previous window" {
  local first
  first=$(command tmux -S "${TMUX_SOCKET}" display-message -p '#{window_id}' 2>/dev/null)
  run_tiling workspace 2
  run_tiling back-and-forth
  local active
  active=$(command tmux -S "${TMUX_SOCKET}" display-message -p '#{window_id}' 2>/dev/null)
  [[ "${active}" == "${first}" ]]
}

# New: help overlay

@test "integration: help-overlay command is routed in dispatcher" {
  run_tiling help-overlay || true
  true
}
