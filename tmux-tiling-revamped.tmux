#!/usr/bin/env bash
#
# tmux-tiling-revamped.tmux: TPM entry point.
#
# Responsibilities:
#   1. Register default keybindings (all configurable via @tiling_revamped_key_*).
#   2. Register hooks for auto-reapplication (when @tiling_revamped_auto_apply=1).
#   3. Register focus-resize hook (when @tiling_revamped_focus_resize=1).
#
# Library sourcing and layout application happen in src/tiling.sh, which is
# invoked on-demand by run-shell.  This keeps startup fast.

PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TILING_CMD="${PLUGIN_DIR}/src/tiling.sh"

# Minimum bash version: 4.0 (required for associative arrays, ${var^^}, etc.)
_check_bash_version() {
  if (( BASH_VERSINFO[0] < 4 )); then
    tmux display-message "tmux-tiling-revamped: bash 4.0+ required (found ${BASH_VERSION})" 2>/dev/null
    return 1
  fi
  return 0
}

# TPM invokes this file through run-shell, which executes it rather than
# sourcing it, and `return` outside a function is an error in that case. The
# guard below therefore has to leave by whichever route is valid, or it prints
# an error, keeps running, and reaches bash 4 syntax on a bash 3.2 that macOS
# still ships as /bin/bash.
_tiling_is_sourced() {
  [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

_tiling_bail() {
  _tiling_is_sourced && return 0
  exit 0
}

if ! _check_bash_version; then
  _tiling_bail
  return 0
fi

# Minimum tmux version: 3.2 (required for display-popup, hooks with priority)
_check_tmux_version() {
  local tmux_version
  tmux_version=$(tmux -V 2>/dev/null | sed 's/[^0-9.]//g')
  [[ -z "${tmux_version}" ]] && return 0

  local major="${tmux_version%%.*}"
  local minor="${tmux_version#*.}"
  minor="${minor%%[a-z]*}"
  minor="${minor%%.*}"

  if (( major < 3 )) || { (( major == 3 )) && (( minor < 2 )); }; then
    tmux display-message "tmux-tiling-revamped: tmux 3.2+ required (found ${tmux_version})" 2>/dev/null
    return 1
  fi
  return 0
}

_GLOBAL_OPTIONS=""

_load_global_options() {
  _GLOBAL_OPTIONS=$(tmux show-options -g 2>/dev/null)
}

_option_is_set() {
  grep -qE "^${1}( |$)" <<<"${_GLOBAL_OPTIONS}"
}

_get_option() {
  # Resolve a user option across three distinct states:
  #   unset          -> the supplied default
  #   set to a value -> that value
  #   set to ""      -> empty, so a key option set to "" disables its binding
  #
  # Testing the value for emptiness cannot tell an unset option from one set to
  # "", so both would collapse to the default and an explicit blank could never
  # disable anything. Detect membership in the global option list instead, which
  # separates set from unset on every tmux version.
  local name="${1}" default="${2:-}"
  if _option_is_set "${name}"; then
    tmux show-option -gqv "${name}" 2>/dev/null
  else
    printf '%s\n' "${default}"
  fi
}

_key_priority() {
  # A key the user set outranks one this plugin defaulted, so a remap that
  # lands on another feature's default key wins instead of losing to whichever
  # binding happens to be registered later.
  if _option_is_set "@tiling_revamped_key_${1}"; then
    printf '1'
  else
    printf '0'
  fi
}

# Every binding is collected here and written to tmux in one pass at the end of
# setup. Calling bind-key at each site let the last writer win with no signal,
# so a remapped key that collided with another feature's default replaced it
# silently and the feature simply stopped responding.
_BINDING_ARGV=()
_BINDING_CONFLICTS=()

# Associative arrays are a bash 4 builtin, so declaring them at file scope runs
# before _check_bash_version can return. On the bash 3.2 that macOS ships that
# prints a raw usage error into the user's terminal at load, leaves the arrays
# undefined, and makes every later _register_binding a silent no-op. Creating
# them here keeps the declaration behind the version guard.
_init_binding_registry() {
  declare -gA _BINDING_SLOT=()
  declare -gA _BINDING_OWNER=()
  declare -gA _BINDING_PRIORITY=()
}

_register_binding() {
  # _register_binding <owner> <priority> <table> <key> <bind-key args...>
  local owner="${1}" priority="${2}" table="${3}" key="${4}"
  shift 4
  [[ -n "${key}" ]] || return 0

  local slot="${table} ${key}"
  local holder="${_BINDING_OWNER[${slot}]:-}"

  if [[ -n "${holder}" ]]; then
    if (( priority > ${_BINDING_PRIORITY[${slot}]} )); then
      _BINDING_CONFLICTS+=("${key} -> ${owner} (set), dropped ${holder}")
    else
      _BINDING_CONFLICTS+=("${key} -> ${holder}, dropped ${owner}")
      return 0
    fi
  else
    _BINDING_SLOT[${slot}]="${#_BINDING_ARGV[@]}"
    _BINDING_ARGV+=("")
  fi

  _BINDING_OWNER[${slot}]="${owner}"
  _BINDING_PRIORITY[${slot}]="${priority}"
  _BINDING_ARGV[${_BINDING_SLOT[${slot}]}]=$(printf '%q ' "$@")
}

_bind() {
  # _bind <alt_keys> <key> <cmd> <owner>
  # An empty key means the option was set to "" to disable this binding.
  # Passing "" to bind-key fails with "unknown key:".
  local alt_keys="${1}" key="${2}" cmd="${3}" owner="${4}"
  [[ -n "${key}" ]] || return 0
  local priority; priority=$(_key_priority "${owner}")
  if [[ "${alt_keys}" == "1" ]]; then
    _register_binding "${owner}" "${priority}" root "M-${key}" -n "M-${key}" run-shell "${cmd}"
  else
    _register_binding "${owner}" "${priority}" prefix "${key}" "${key}" run-shell "${cmd}"
  fi
}

_flush_bindings() {
  local spec
  for spec in "${_BINDING_ARGV[@]}"; do
    [[ -n "${spec}" ]] && eval "tmux bind-key ${spec}"
  done
  _publish_bindings
  return 0
}

_publish_bindings() {
  # The help overlay reads this rather than re-resolving the key options, so it
  # shows the key that actually answers rather than the one that was asked for.
  # One record per line, owner and key split on the first tab, because a tmux
  # key name can itself be a semicolon or a space.
  local slot resolved=""
  for slot in "${!_BINDING_OWNER[@]}"; do
    printf -v resolved '%s%s\t%s\n' "${resolved}" "${_BINDING_OWNER[${slot}]}" "${slot#* }"
  done
  tmux set-option -gq "@tiling_revamped_bindings" "${resolved}" 2>/dev/null || true
  return 0
}

_report_conflicts() {
  # The resolved conflicts stay readable in @tiling_revamped_conflicts after the
  # transient message is gone, which is what makes a silent clobber diagnosable.
  local joined=""
  if (( ${#_BINDING_CONFLICTS[@]} )); then
    printf -v joined '%s; ' "${_BINDING_CONFLICTS[@]}"
    joined="${joined%; }"
  fi
  tmux set-option -gq "@tiling_revamped_conflicts" "${joined}" 2>/dev/null || true

  [[ -n "${joined}" ]] || return 0
  [[ "$(_get_option "@tiling_revamped_warn_conflicts" "1")" == "1" ]] || return 0
  tmux display-message "tmux-tiling-revamped: key conflict: ${joined}" 2>/dev/null || true
  return 0
}

_setup_keybindings() {
  local alt_keys
  alt_keys=$(_get_option "@tiling_revamped_alt_keys" "0")

  local key_dwindle;        key_dwindle=$(       _get_option "@tiling_revamped_key_dwindle"         "d")
  local key_spiral;         key_spiral=$(        _get_option "@tiling_revamped_key_spiral"          "D")
  local key_balance;        key_balance=$(       _get_option "@tiling_revamped_key_balance"         "b")
  local key_equalize;       key_equalize=$(      _get_option "@tiling_revamped_key_equalize"        "B")
  local key_promote;        key_promote=$(       _get_option "@tiling_revamped_key_promote"         "m")
  local key_rotate;         key_rotate=$(        _get_option "@tiling_revamped_key_rotate"          ".")
  local key_flip;           key_flip=$(          _get_option "@tiling_revamped_key_flip"            ",")
  local key_circulate;      key_circulate=$(     _get_option "@tiling_revamped_key_circulate"       "C-r")
  local key_autotile;       key_autotile=$(      _get_option "@tiling_revamped_key_autotile"        "C-d")
  local key_cycle;          key_cycle=$(         _get_option "@tiling_revamped_key_cycle"           "o")
  local key_mark;           key_mark=$(          _get_option "@tiling_revamped_key_mark"            "M")
  local key_jump;           key_jump=$(          _get_option "@tiling_revamped_key_jump"            "j")
  local key_scratchpad;     key_scratchpad=$(    _get_option "@tiling_revamped_key_scratchpad"      "g")
  local key_main_vertical;  key_main_vertical=$( _get_option "@tiling_revamped_key_main_vertical"   "v")
  local key_main_horizontal;key_main_horizontal=$(_get_option "@tiling_revamped_key_main_horizontal" "V")
  local key_master_grow;    key_master_grow=$(   _get_option "@tiling_revamped_key_master_grow"     "+")
  local key_master_shrink;  key_master_shrink=$( _get_option "@tiling_revamped_key_master_shrink"   "-")
  local key_sync;           key_sync=$(          _get_option "@tiling_revamped_key_sync"            "S")
  local key_swap_up;        key_swap_up=$(       _get_option "@tiling_revamped_key_swap_up"         "")
  local key_swap_down;      key_swap_down=$(     _get_option "@tiling_revamped_key_swap_down"       "")
  local key_swap_left;      key_swap_left=$(     _get_option "@tiling_revamped_key_swap_left"       "")
  local key_swap_right;     key_swap_right=$(    _get_option "@tiling_revamped_key_swap_right"      "")
  local key_pick_layout;    key_pick_layout=$(   _get_option "@tiling_revamped_key_pick_layout"    "p")
  local key_undo;           key_undo=$(          _get_option "@tiling_revamped_key_undo"            "u")
  local key_redo;           key_redo=$(          _get_option "@tiling_revamped_key_redo"            "r")
  local key_help;           key_help=$(          _get_option "@tiling_revamped_key_help"            "?")
  local key_swap_biggest;   key_swap_biggest=$(  _get_option "@tiling_revamped_key_swap_biggest"    "=")
  local key_focus_back;     key_focus_back=$(    _get_option "@tiling_revamped_key_focus_back"     "[")
  local key_focus_forward;  key_focus_forward=$( _get_option "@tiling_revamped_key_focus_forward"  "]")
  local key_pane_jump;      key_pane_jump=$(     _get_option "@tiling_revamped_key_pane_jump"      "P")

  _bind "${alt_keys}" "${key_dwindle}"        "${TILING_CMD} layout dwindle" "dwindle"
  _bind "${alt_keys}" "${key_spiral}"         "${TILING_CMD} layout spiral" "spiral"
  _bind "${alt_keys}" "${key_balance}"        "${TILING_CMD} balance" "balance"
  _bind "${alt_keys}" "${key_equalize}"       "${TILING_CMD} equalize" "equalize"
  _bind "${alt_keys}" "${key_promote}"        "${TILING_CMD} promote" "promote"
  _bind "${alt_keys}" "${key_rotate}"         "${TILING_CMD} rotate" "rotate"
  _bind "${alt_keys}" "${key_flip}"           "${TILING_CMD} flip" "flip"
  _bind "${alt_keys}" "${key_circulate}"      "${TILING_CMD} circulate" "circulate"
  _bind "${alt_keys}" "${key_autotile}"       "${TILING_CMD} autosplit" "autotile"
  _bind "${alt_keys}" "${key_cycle}"          "${TILING_CMD} cycle" "cycle"
  _bind "${alt_keys}" "${key_main_vertical}"  "${TILING_CMD} layout main-vertical" "main_vertical"
  _bind "${alt_keys}" "${key_main_horizontal}" "${TILING_CMD} layout main-horizontal" "main_horizontal"
  _bind "${alt_keys}" "${key_master_grow}"    "${TILING_CMD} resize-master grow" "master_grow"
  _bind "${alt_keys}" "${key_master_shrink}"  "${TILING_CMD} resize-master shrink" "master_shrink"
  _bind "${alt_keys}" "${key_sync}"           "${TILING_CMD} sync" "sync"

  # Mark uses command-prompt, so always prefix-based (empty key = disabled)
  [[ -n "${key_mark}" ]] && _register_binding "mark" "$(_key_priority mark)" \
    prefix "${key_mark}" "${key_mark}" command-prompt \
    -p "Mark name:" "run-shell '${TILING_CMD} mark %%'"
  _bind "${alt_keys}" "${key_jump}" "${TILING_CMD} jump" "jump"
  _bind "${alt_keys}" "${key_scratchpad}" "${TILING_CMD} scratchpad" "scratchpad"

  # Directional swap bindings (empty key = disabled)
  [[ -n "${key_swap_up}" ]]    && _bind "${alt_keys}" "${key_swap_up}"    "${TILING_CMD} swap U" "swap_up"
  [[ -n "${key_swap_down}" ]]  && _bind "${alt_keys}" "${key_swap_down}"  "${TILING_CMD} swap D" "swap_down"
  [[ -n "${key_swap_left}" ]]  && _bind "${alt_keys}" "${key_swap_left}"  "${TILING_CMD} swap L" "swap_left"
  [[ -n "${key_swap_right}" ]] && _bind "${alt_keys}" "${key_swap_right}" "${TILING_CMD} swap R" "swap_right"

  # Layout picker binding (empty key = disabled)
  [[ -n "${key_pick_layout}" ]] && _bind "${alt_keys}" "${key_pick_layout}" "${TILING_CMD} pick" "pick_layout"

  # Undo binding (empty key = disabled)
  [[ -n "${key_undo}" ]] && _bind "${alt_keys}" "${key_undo}" "${TILING_CMD} undo" "undo"

  # Redo binding (empty key = disabled)
  [[ -n "${key_redo}" ]] && _bind "${alt_keys}" "${key_redo}" "${TILING_CMD} redo" "redo"

  # Help overlay binding (empty key = disabled)
  [[ -n "${key_help}" ]] && _bind "${alt_keys}" "${key_help}" "${TILING_CMD} help-overlay" "help"

  # Swap-with-biggest binding (empty key = disabled)
  [[ -n "${key_swap_biggest}" ]] && _bind "${alt_keys}" "${key_swap_biggest}" "${TILING_CMD} swap-biggest" "swap_biggest"

  # Focus-history navigation bindings (empty key = disabled)
  [[ -n "${key_focus_back}" ]] && _bind "${alt_keys}" "${key_focus_back}" "${TILING_CMD} focus-back" "focus_back"
  [[ -n "${key_focus_forward}" ]] && _bind "${alt_keys}" "${key_focus_forward}" "${TILING_CMD} focus-forward" "focus_forward"

  # Global pane jumper binding (empty key = disabled)
  [[ -n "${key_pane_jump}" ]] && _bind "${alt_keys}" "${key_pane_jump}" "${TILING_CMD} pane-jump" "pane_jump"
}

_setup_hooks() {
  # Clear previous tiling hooks to prevent accumulation on config reload
  tmux set-hook -gu "after-split-window[100]" 2>/dev/null || true
  tmux set-hook -gu "after-kill-pane[100]" 2>/dev/null || true
  tmux set-hook -gu "pane-exited[100]" 2>/dev/null || true
  tmux set-hook -gu "window-resized[100]" 2>/dev/null || true
  tmux set-hook -gu "after-new-window[100]" 2>/dev/null || true
  tmux set-hook -gu "pane-focus-in[100]" 2>/dev/null || true
  tmux set-hook -gu "after-split-window[110]" 2>/dev/null || true
  tmux set-hook -gu "after-split-window[130]" 2>/dev/null || true
  tmux set-hook -gu "pane-focus-in[130]" 2>/dev/null || true
  tmux set-hook -gu "after-kill-pane[110]" 2>/dev/null || true
  tmux set-hook -gu "pane-exited[110]" 2>/dev/null || true

  local auto_apply
  auto_apply=$(_get_option "@tiling_revamped_auto_apply" "1")

  if [[ "${auto_apply}" == "1" ]]; then
    tmux set-hook -ga "after-split-window[100]" \
      "run-shell '${TILING_CMD} hook split'"
    tmux set-hook -ga "after-kill-pane[100]" \
      "run-shell '${TILING_CMD} hook kill'"
    tmux set-hook -ga "pane-exited[100]" \
      "run-shell '${TILING_CMD} hook exit'"
    tmux set-hook -ga "window-resized[100]" \
      "run-shell '${TILING_CMD} hook resize'"
  fi

  # Default layout for new windows
  local default_layout
  default_layout=$(_get_option "@tiling_revamped_default_layout" "")
  if [[ -n "${default_layout}" ]]; then
    tmux set-hook -ga "after-new-window[100]" \
      "run-shell '${TILING_CMD} hook new-window'"
  fi

  # Smart borders: hide pane chrome on a single-pane window
  local smart_borders
  smart_borders=$(_get_option "@tiling_revamped_smart_borders" "0")

  if [[ "${smart_borders}" == "1" ]]; then
    tmux set-hook -ga "after-split-window[110]" \
      "run-shell '${TILING_CMD} smart-borders'"
    tmux set-hook -ga "after-kill-pane[110]" \
      "run-shell '${TILING_CMD} smart-borders'"
    tmux set-hook -ga "pane-exited[110]" \
      "run-shell '${TILING_CMD} smart-borders'"
  fi

  # App-aware tiling rules: assign an action to each newly created pane
  local app_rules
  app_rules=$(_get_option "@tiling_revamped_app_rules" "")
  if [[ -n "${app_rules}" ]]; then
    tmux set-hook -ga "after-split-window[130]" \
      "run-shell '${TILING_CMD} app-rules'"
  fi

  # Focus history: record every pane focus for back/forward navigation
  local focus_history
  focus_history=$(_get_option "@tiling_revamped_focus_history" "0")
  if [[ "${focus_history}" == "1" ]]; then
    tmux set-hook -ga "pane-focus-in[130]" \
      "run-shell '${TILING_CMD} focus-record'"
  fi

  local focus_resize
  focus_resize=$(_get_option "@tiling_revamped_focus_resize" "0")

  if [[ "${focus_resize}" == "1" ]]; then
    tmux set-hook -ga "pane-focus-in[100]" \
      "run-shell '${TILING_CMD} focus-resize'"
  fi
}

_setup_navigation() {
  local navigator
  navigator=$(_get_option "@tiling_revamped_navigator" "0")

  [[ "${navigator}" != "1" ]] && return 0

  local is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"

  local dir key
  for dir in "h L" "j D" "k U" "l R"; do
    key="${dir%% *}"
    _register_binding "navigator" 1 root "M-${key}" \
      -n "M-${key}" if-shell "${is_vim}" "send-keys M-${key}" "select-pane -${dir##* }"
  done
}

_setup_workspaces() {
  local workspaces
  workspaces=$(_get_option "@tiling_revamped_workspaces" "0")
  [[ "${workspaces}" != "1" ]] && return 0

  local alt_keys
  alt_keys=$(_get_option "@tiling_revamped_alt_keys" "0")

  # Shift+number characters for the "move pane to workspace" bindings
  local shiftnum
  shiftnum=$(_get_option "@tiling_revamped_shiftnum" '!@#$%^&*()')

  local i key shift_key
  for (( i = 1; i <= 9; i++ )); do
    key="${i}"
    shift_key="${shiftnum:$((i - 1)):1}"

    if [[ "${alt_keys}" == "1" ]]; then
      # Alt+N switches to workspace N
      _register_binding "workspace ${i}" 1 root "M-${key}" \
        -n "M-${key}" run-shell "${TILING_CMD} workspace ${i}"
      # Alt+Shift+N moves pane to workspace N
      [[ -n "${shift_key}" ]] && \
        _register_binding "move-to-workspace ${i}" 1 root "M-${shift_key}" \
          -n "M-${shift_key}" run-shell "${TILING_CMD} move-to-workspace ${i}"
    else
      # Prefix+N is already used by tmux for window selection.
      # In prefix mode, use Shift+N for workspace switch and
      # the workspace move is not bound by default.
      :
    fi
  done

  # Window 0 (mapped to key 0)
  local shift_zero="${shiftnum:9:1}"
  if [[ "${alt_keys}" == "1" ]]; then
    _register_binding "workspace 10" 1 root "M-0" \
      -n "M-0" run-shell "${TILING_CMD} workspace 10"
    [[ -n "${shift_zero}" ]] && \
      _register_binding "move-to-workspace 10" 1 root "M-${shift_zero}" \
        -n "M-${shift_zero}" run-shell "${TILING_CMD} move-to-workspace 10"
  fi

  # Back-and-forth toggle between the current and last window (empty = disabled)
  local key_back_and_forth
  key_back_and_forth=$(_get_option "@tiling_revamped_key_back_and_forth" "Tab")
  if [[ -n "${key_back_and_forth}" ]] && [[ "${alt_keys}" == "1" ]]; then
    _register_binding "back_and_forth" "$(_key_priority back_and_forth)" root "M-${key_back_and_forth}" \
      -n "M-${key_back_and_forth}" run-shell "${TILING_CMD} back-and-forth"
  fi
}

_setup_project_launcher() {
  local project_dir
  project_dir=$(_get_option "@tiling_revamped_project_dir" "")
  [[ -z "${project_dir}" ]] && return 0

  local alt_keys
  alt_keys=$(_get_option "@tiling_revamped_alt_keys" "0")

  local key_project
  key_project=$(_get_option "@tiling_revamped_key_project" "")
  [[ -z "${key_project}" ]] && return 0

  _bind "${alt_keys}" "${key_project}" "${TILING_CMD} project" "project"
}

_setup_pick_layout_binding() {
  local key_pick_layout_alt
  key_pick_layout_alt=$(_get_option "@tiling_revamped_key_pick_layout_alt" "")

  [[ -z "${key_pick_layout_alt}" ]] && return 0

  # Vim detection pattern (same as navigator)
  local is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"

  # Generate vim-aware Alt binding
  _register_binding "pick_layout_alt" 1 root "M-${key_pick_layout_alt}" \
    -n "M-${key_pick_layout_alt}" \
    if-shell "${is_vim}" \
    "send-keys M-${key_pick_layout_alt}" \
    "run-shell '${TILING_CMD} pick'"
}

chmod +x "${TILING_CMD}" 2>/dev/null || true

if ! _check_tmux_version; then
  _tiling_bail
  return 0
fi

_init_binding_registry
_load_global_options

_setup_keybindings
_setup_hooks
_setup_navigation
_setup_pick_layout_binding
_setup_workspaces
_setup_project_launcher
_flush_bindings
_report_conflicts
