#!/usr/bin/env bash
# shellcheck disable=SC2034  # constants are sourced and used by other modules

[[ -n "${_TILING_REVAMPED_CONSTANTS_LOADED:-}" ]] && return 0
_TILING_REVAMPED_CONSTANTS_LOADED=1

readonly TILING_REVAMPED_VERSION="2.3.0"

# Default orientation flags for BSP layouts
# Format: [t|b][l|r][h|v][c|s]
#   t/b  = top/bottom corner
#   l/r  = left/right corner
#   h/v  = horizontal/vertical branches
#   c/s  = corner/spiral trajectory
readonly TILING_DEFAULT_ORIENTATION="brvc"
readonly TILING_DEFAULT_MASTER_RATIO="60"
readonly TILING_DEFAULT_SPLIT_RATIO="50"
readonly TILING_DEFAULT_FOCUS_RATIO="62"
readonly TILING_DEFAULT_SCRATCH_WIDTH="80%"
readonly TILING_DEFAULT_SCRATCH_HEIGHT="75%"
readonly TILING_DEFAULT_RESIZE_STEP="5"

# tmux option name constants
readonly OPT_LAYOUT="@tiling_revamped_layout"
readonly OPT_ENABLED="@tiling_revamped_enabled"
readonly OPT_APPLYING="@tiling_revamped_applying"
readonly OPT_ORIENTATION="@tiling_revamped_orientation"
readonly OPT_AUTO_APPLY="@tiling_revamped_auto_apply"
readonly OPT_FOCUS_RESIZE="@tiling_revamped_focus_resize"
readonly OPT_MARKS="@tiling_revamped_marks"
readonly OPT_DEFAULT_LAYOUT="@tiling_revamped_default_layout"
readonly OPT_MASTER_RATIO="@tiling_revamped_master_ratio"
readonly OPT_RESIZE_STEP="@tiling_revamped_resize_step"
readonly OPT_ALT_KEYS="@tiling_revamped_alt_keys"
readonly OPT_NAVIGATOR="@tiling_revamped_navigator"

readonly OPT_KEY_DWINDLE="@tiling_revamped_key_dwindle"
readonly OPT_KEY_SPIRAL="@tiling_revamped_key_spiral"
readonly OPT_KEY_BALANCE="@tiling_revamped_key_balance"
readonly OPT_KEY_EQUALIZE="@tiling_revamped_key_equalize"
readonly OPT_KEY_PROMOTE="@tiling_revamped_key_promote"
readonly OPT_KEY_ROTATE="@tiling_revamped_key_rotate"
readonly OPT_KEY_FLIP="@tiling_revamped_key_flip"
readonly OPT_KEY_CIRCULATE="@tiling_revamped_key_circulate"
readonly OPT_KEY_AUTOTILE="@tiling_revamped_key_autotile"
readonly OPT_KEY_CYCLE="@tiling_revamped_key_cycle"
readonly OPT_KEY_MARK="@tiling_revamped_key_mark"
readonly OPT_KEY_JUMP="@tiling_revamped_key_jump"
readonly OPT_KEY_SCRATCHPAD="@tiling_revamped_key_scratchpad"
readonly OPT_KEY_MAIN_VERTICAL="@tiling_revamped_key_main_vertical"
readonly OPT_KEY_MAIN_HORIZONTAL="@tiling_revamped_key_main_horizontal"
readonly OPT_KEY_MASTER_GROW="@tiling_revamped_key_master_grow"
readonly OPT_KEY_MASTER_SHRINK="@tiling_revamped_key_master_shrink"
readonly OPT_KEY_SYNC="@tiling_revamped_key_sync"
readonly OPT_KEY_SWAP_UP="@tiling_revamped_key_swap_up"
readonly OPT_KEY_SWAP_DOWN="@tiling_revamped_key_swap_down"
readonly OPT_KEY_SWAP_LEFT="@tiling_revamped_key_swap_left"
readonly OPT_KEY_SWAP_RIGHT="@tiling_revamped_key_swap_right"

# Layout picker options
readonly OPT_KEY_PICK_LAYOUT="@tiling_revamped_key_pick_layout"
readonly OPT_KEY_PICK_LAYOUT_ALT="@tiling_revamped_key_pick_layout_alt"
readonly OPT_PICK_WIDTH="@tiling_revamped_pick_width"
readonly OPT_PICK_HEIGHT="@tiling_revamped_pick_height"
readonly OPT_PICK_PREVIEW_WIDTH="@tiling_revamped_pick_preview_width"

# Undo
readonly OPT_KEY_UNDO="@tiling_revamped_key_undo"
readonly OPT_LAYOUT_HISTORY="@tiling_revamped_layout_history"

# Split ratio
readonly OPT_SPLIT_RATIO="@tiling_revamped_split_ratio"

# Workspaces
readonly OPT_WORKSPACES="@tiling_revamped_workspaces"
readonly OPT_SHIFTNUM="@tiling_revamped_shiftnum"

# Project launcher
readonly OPT_PROJECT_DIR="@tiling_revamped_project_dir"
readonly OPT_PROJECT_DEPTH="@tiling_revamped_project_depth"
readonly OPT_KEY_PROJECT="@tiling_revamped_key_project"

# Layout picker defaults
readonly TILING_DEFAULT_PICK_WIDTH="60%"
readonly TILING_DEFAULT_PICK_HEIGHT="40%"
readonly TILING_DEFAULT_PICK_PREVIEW_WIDTH="60%"

# Redo (companion to undo)
readonly OPT_LAYOUT_REDO="@tiling_revamped_layout_redo"
readonly OPT_KEY_REDO="@tiling_revamped_key_redo"

# Help overlay
readonly OPT_KEY_HELP="@tiling_revamped_key_help"
readonly OPT_HELP_WIDTH="@tiling_revamped_help_width"
readonly OPT_HELP_HEIGHT="@tiling_revamped_help_height"

# Swap with biggest pane
readonly OPT_KEY_SWAP_BIGGEST="@tiling_revamped_key_swap_biggest"

# Smart borders
readonly OPT_SMART_BORDERS="@tiling_revamped_smart_borders"
readonly OPT_BORDER_STATUS="@tiling_revamped_border_status"

# Workspace back-and-forth
readonly OPT_LAST_WINDOW="@tiling_revamped_last_window"
readonly OPT_KEY_BACK_AND_FORTH="@tiling_revamped_key_back_and_forth"

# Dynamic layout by pane count
readonly OPT_DYNAMIC_LAYOUT="@tiling_revamped_dynamic_layout"

# App-aware tiling rules
readonly OPT_APP_RULES="@tiling_revamped_app_rules"
readonly OPT_PANE_FLOAT="@tiling_revamped_float"
readonly OPT_PANE_SCRATCHPAD="@tiling_revamped_scratchpad"

# Focus history stack
readonly OPT_FOCUS_HISTORY="@tiling_revamped_focus_history"
readonly OPT_FOCUS_STACK="@tiling_revamped_focus_stack"
readonly OPT_FOCUS_POS="@tiling_revamped_focus_pos"
readonly OPT_FOCUS_MAX="@tiling_revamped_focus_max"
readonly OPT_FOCUS_NAV="@tiling_revamped_focus_nav"
readonly OPT_KEY_FOCUS_BACK="@tiling_revamped_key_focus_back"
readonly OPT_KEY_FOCUS_FORWARD="@tiling_revamped_key_focus_forward"
readonly TILING_DEFAULT_FOCUS_MAX="20"

# Global pane jumper
readonly OPT_KEY_PANE_JUMP="@tiling_revamped_key_pane_jump"
readonly OPT_JUMP_WIDTH="@tiling_revamped_jump_width"
readonly OPT_JUMP_HEIGHT="@tiling_revamped_jump_height"
readonly OPT_JUMP_PREVIEW_WIDTH="@tiling_revamped_jump_preview_width"
readonly TILING_DEFAULT_JUMP_WIDTH="70%"
readonly TILING_DEFAULT_JUMP_HEIGHT="60%"
readonly TILING_DEFAULT_JUMP_PREVIEW_WIDTH="60%"
