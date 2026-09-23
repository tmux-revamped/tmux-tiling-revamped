#!/usr/bin/env bash
#
# tiling.sh: command dispatcher for tmux-tiling-revamped.
#
# Called by keybindings and hooks via `run-shell`.  Sources all library
# modules and routes the first argument to the appropriate function.
#
# Usage:
#   tiling.sh layout dwindle [flags]
#   tiling.sh layout spiral  [flags]
#   tiling.sh layout grid
#   tiling.sh layout main-center
#   tiling.sh layout main-vertical
#   tiling.sh layout main-horizontal
#   tiling.sh layout monocle
#   tiling.sh layout deck
#   tiling.sh balance
#   tiling.sh equalize
#   tiling.sh rotate  [90|180|270]
#   tiling.sh flip    [h|v]
#   tiling.sh promote
#   tiling.sh circulate [next|prev]
#   tiling.sh autosplit
#   tiling.sh focus-resize
#   tiling.sh resize-master [grow|shrink]
#   tiling.sh sync
#   tiling.sh swap    [U|D|L|R]
#   tiling.sh cycle   [next|prev]
#   tiling.sh pick
#   tiling.sh undo
#   tiling.sh workspace <number>
#   tiling.sh move-to-workspace <number>
#   tiling.sh project
#   tiling.sh swap-pick
#   tiling.sh validate [fix]
#   tiling.sh info
#   tiling.sh doctor
#   tiling.sh restore-layouts
#   tiling.sh help
#   tiling.sh mark    <name>
#   tiling.sh unmark  [name]
#   tiling.sh jump    [name]
#   tiling.sh scratchpad [name] [cmd]
#   tiling.sh preset  save <name>
#   tiling.sh preset  apply [name]
#   tiling.sh hook    split|kill|exit|resize|focus|new-window

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

source "${PLUGIN_DIR}/src/lib/utils/constants.sh"
export PLUGIN_LOG_NS="tiling-revamped"
source "${PLUGIN_DIR}/src/lib/utils/error-logger.sh"
source "${PLUGIN_DIR}/src/lib/utils/has-command.sh"
source "${PLUGIN_DIR}/src/lib/tmux/tmux-ops.sh"
source "${PLUGIN_DIR}/src/lib/tmux/tmux-config.sh"
source "${PLUGIN_DIR}/src/lib/layouts/dwindle.sh"
source "${PLUGIN_DIR}/src/lib/layouts/spiral.sh"
source "${PLUGIN_DIR}/src/lib/layouts/grid.sh"
source "${PLUGIN_DIR}/src/lib/layouts/main-center.sh"
source "${PLUGIN_DIR}/src/lib/layouts/main-vertical.sh"
source "${PLUGIN_DIR}/src/lib/layouts/main-horizontal.sh"
source "${PLUGIN_DIR}/src/lib/layouts/monocle.sh"
source "${PLUGIN_DIR}/src/lib/layouts/deck.sh"
source "${PLUGIN_DIR}/src/lib/operations/balance.sh"
source "${PLUGIN_DIR}/src/lib/operations/equalize.sh"
source "${PLUGIN_DIR}/src/lib/operations/rotate.sh"
source "${PLUGIN_DIR}/src/lib/operations/flip.sh"
source "${PLUGIN_DIR}/src/lib/operations/promote.sh"
source "${PLUGIN_DIR}/src/lib/operations/circulate.sh"
source "${PLUGIN_DIR}/src/lib/operations/autosplit.sh"
source "${PLUGIN_DIR}/src/lib/operations/focus-resize.sh"
source "${PLUGIN_DIR}/src/lib/operations/resize-master.sh"
source "${PLUGIN_DIR}/src/lib/operations/sync.sh"
source "${PLUGIN_DIR}/src/lib/operations/swap-direction.sh"
source "${PLUGIN_DIR}/src/lib/operations/pick-layout.sh"
source "${PLUGIN_DIR}/src/lib/operations/undo-layout.sh"
source "${PLUGIN_DIR}/src/lib/features/marks.sh"
source "${PLUGIN_DIR}/src/lib/features/scratchpad.sh"
source "${PLUGIN_DIR}/src/lib/features/presets.sh"
source "${PLUGIN_DIR}/src/lib/features/cycle.sh"
source "${PLUGIN_DIR}/src/lib/features/workspaces.sh"
source "${PLUGIN_DIR}/src/lib/features/project-launcher.sh"
source "${PLUGIN_DIR}/src/lib/features/resurrect.sh"
source "${PLUGIN_DIR}/src/lib/operations/validate.sh"
source "${PLUGIN_DIR}/src/lib/operations/swap-pick.sh"
source "${PLUGIN_DIR}/src/lib/operations/info.sh"
source "${PLUGIN_DIR}/src/lib/operations/doctor.sh"
source "${PLUGIN_DIR}/src/lib/utils/pane-guard.sh"
source "${PLUGIN_DIR}/src/lib/features/status.sh"
source "${PLUGIN_DIR}/src/lib/operations/help-overlay.sh"
source "${PLUGIN_DIR}/src/lib/operations/swap-biggest.sh"
source "${PLUGIN_DIR}/src/lib/operations/smart-borders.sh"
source "${PLUGIN_DIR}/src/lib/features/dynamic-layout.sh"
source "${PLUGIN_DIR}/src/lib/features/app-rules.sh"
source "${PLUGIN_DIR}/src/lib/features/focus-history.sh"
source "${PLUGIN_DIR}/src/lib/operations/pane-jumper.sh"

_handle_hook() {
  local event="${1:-}"

  # Handle new-window: apply default layout if configured
  if [[ "${event}" == "new-window" ]]; then
    local default_layout
    default_layout=$(get_tmux_option "@tiling_revamped_default_layout" "")
    [[ -z "${default_layout}" ]] && return 0

    case "${default_layout}" in
      dwindle)         apply_layout_dwindle "" ;;
      spiral)          apply_layout_spiral "" ;;
      grid)            apply_layout_grid ;;
      main-center)     apply_layout_main_center ;;
      main-vertical)   apply_layout_main_vertical ;;
      main-horizontal) apply_layout_main_horizontal ;;
      monocle)         apply_layout_monocle ;;
      deck)            apply_layout_deck ;;
      *)               log_error "hook" "Unknown default layout: ${default_layout}" ;;
    esac
    return 0
  fi

  # Recursion guard: skip if a layout is currently being applied
  is_applying && return 0

  # Check if auto-apply is enabled for this window
  is_auto_apply_enabled || return 0

  # Dynamic layout by pane count overrides stored-layout reapplication.
  if _dynamic_layout_enabled; then
    apply_dynamic_layout
    return 0
  fi

  local current_layout
  current_layout=$(get_current_layout)

  # No layout stored for this window: nothing to reapply
  [[ -z "${current_layout}" ]] && return 0

  local flags
  flags=$(get_window_option "@tiling_revamped_orientation" "brvc")

  case "${current_layout}" in
    dwindle)         _apply_bsp_layout "false" "${flags}" ;;
    spiral)          _apply_bsp_layout "true"  "${flags}" ;;
    grid)            apply_layout_grid ;;
    main-center)     apply_layout_main_center ;;
    main-vertical)   apply_layout_main_vertical ;;
    main-horizontal) apply_layout_main_horizontal ;;
    deck)            apply_layout_deck ;;
    monocle)         ;;
    *)               log_error "hook" "Unknown layout for reapplication: ${current_layout}" ;;
  esac
}

main() {
  local cmd="${1:-}"
  shift || true

  case "${cmd}" in
    layout)
      local layout_name="${1:-}"
      local layout_flags="${2:-}"
      case "${layout_name}" in
        dwindle)         apply_layout_dwindle "${layout_flags}" ;;
        spiral)          apply_layout_spiral  "${layout_flags}" ;;
        grid)            apply_layout_grid ;;
        main-center)     apply_layout_main_center ;;
        main-vertical)   apply_layout_main_vertical ;;
        main-horizontal) apply_layout_main_horizontal ;;
        monocle)         apply_layout_monocle ;;
        deck)            apply_layout_deck ;;
        *)
          log_error "tiling" "Unknown layout: ${layout_name}"
          exit 1
          ;;
      esac
      ;;
    balance)    balance_panes ;;
    equalize)   equalize_panes ;;
    rotate)     rotate_layout "${1:-90}" ;;
    flip)       flip_layout "${1:-h}" ;;
    promote)    promote_pane ;;
    circulate)  circulate_panes "${1:-next}" ;;
    autosplit)  autosplit_pane ;;
    focus-resize) focus_resize_pane ;;
    resize-master) resize_master "${1:-grow}" ;;
    sync)       sync_panes ;;
    swap)       swap_pane_direction "${1:-R}" ;;
    cycle)      cycle_layout "${1:-next}" ;;
    pick)       pick_layout ;;
    undo)       undo_layout ;;
    redo)       redo_layout ;;
    workspace)  switch_workspace "${1:-1}" ;;
    move-to-workspace) move_to_workspace "${1:-1}" ;;
    back-and-forth) workspace_back_and_forth ;;
    project)    launch_project ;;
    swap-pick)  swap_pick ;;
    swap-biggest) swap_biggest ;;
    dynamic-layout) apply_dynamic_layout ;;
    app-rules)      apply_app_rules ;;
    focus-record)   focus_history_record ;;
    focus-back)     focus_history_back ;;
    focus-forward)  focus_history_forward ;;
    pane-jump)      pane_jumper ;;
    smart-borders) smart_borders ;;
    status)     layout_status ;;
    help-overlay) show_help ;;
    validate)   validate_layout "${1:-check}" ;;
    info)       show_info ;;
    doctor)     run_doctor ;;
    restore-layouts) restore_layouts ;;
    help)
      cat <<'HELP'
tmux-tiling-revamped: BSP tiling window manager for tmux

Layouts:
  layout dwindle [flags]    BSP cascade toward corner
  layout spiral [flags]     BSP with spiral trajectory
  layout grid               Even N x M grid
  layout main-vertical      Master left, stack right
  layout main-horizontal    Master top, stack bottom
  layout main-center        Wide center, balanced sides
  layout monocle            Zoom toggle
  layout deck               Full-height cards side by side

Operations:
  balance          Reset splits to 50%
  equalize         Even distribution ignoring topology
  rotate [deg]     Rotate orientation (90/180/270)
  flip [h|v]       Mirror orientation
  promote          Swap focused pane with master
  circulate [dir]  Shift pane positions (next/prev)
  autosplit        Split along longest axis
  focus-resize     Expand focused pane to golden ratio
  resize-master    Grow or shrink master (grow/shrink)
  sync             Toggle synchronize-panes
  swap [dir]       Swap with neighbor (U/D/L/R)
  swap-pick        Swap with fzf-selected pane
  swap-biggest     Swap focused pane with the largest pane
  pick             Layout picker (fzf popup)
  cycle [dir]      Cycle through layout list (next/prev)
  undo             Revert to previous layout
  redo             Re-apply an undone layout
  smart-borders    Hide pane borders when only one pane remains
  pane-jump        Jump to any pane across sessions (fzf popup)

Features:
  mark <name>      Label a pane
  unmark [name]    Remove a label
  jump [name]      Jump to labeled pane (fzf if no name)
  scratchpad       Toggle floating scratchpad
  preset save <n>  Save current layout as preset
  preset apply [n] Apply a saved preset (fzf if no name)
  workspace <N>    Switch to window N (create if missing)
  move-to-workspace <N>  Move pane to window N
  back-and-forth   Toggle between current and last window
  project          Open project in new window (fzf)
  focus-back       Step back through the focused-pane history
  focus-forward    Step forward through the focused-pane history

Automation:
  dynamic-layout   Apply a layout chosen by live pane count
  app-rules        Auto-assign an action to a new pane by command
  focus-record     Record the focused pane (auto-apply hook)

Diagnostics:
  info             Show current layout state
  status           Print the active layout for the status line
  help-overlay     Show resolved keybindings in a popup (tmux 3.2+)
  doctor           Check environment health
  validate [fix]   Check layout metadata consistency
  restore-layouts  Re-apply all stored layouts
  help             This message
HELP
      ;;
    mark)       mark_pane "${1:-}" ;;
    unmark)     unmark_pane "${1:-}" ;;
    jump)       jump_to_mark "${1:-}" ;;
    scratchpad) toggle_scratchpad "${1:-default}" "${2:-}" ;;
    preset)
      local preset_cmd="${1:-}"
      local preset_name="${2:-}"
      case "${preset_cmd}" in
        save)  save_preset "${preset_name}" ;;
        apply) apply_preset "${preset_name}" ;;
        *)
          log_error "tiling" "Unknown preset command: ${preset_cmd}"
          exit 1
          ;;
      esac
      ;;
    hook)       _handle_hook "${1:-}" ;;
    *)
      log_error "tiling" "Unknown command: ${cmd}"
      exit 1
      ;;
  esac
}

main "$@"
