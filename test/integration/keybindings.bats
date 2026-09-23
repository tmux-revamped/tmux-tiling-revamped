#!/usr/bin/env bats
#
# Integration tests for the TPM entry point (tmux-tiling-revamped.tmux).
#
# These run the real plugin file against a real, isolated tmux server and
# inspect the resulting key bindings.  A mock tmux cannot reproduce the bug
# these guard against: an option set to an empty string must disable its
# binding rather than fall back to the default key.

setup() {
  PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."
  PLUGIN="${PLUGIN_DIR}/tmux-tiling-revamped.tmux"
  export TILING_SOCKET="/tmp/tiling-kb-${BASHPID}-${RANDOM}"

  # Route every tmux call (including those inside the plugin subshell) to the
  # isolated test socket.  Exported so the `bash "${PLUGIN}"` child inherits it.
  tmux() { command tmux -S "${TILING_SOCKET}" "$@"; }
  export -f tmux
  export TILING_SOCKET

  # -f /dev/null keeps the user's ~/.tmux.conf (and its own plugin copy) out.
  command tmux -S "${TILING_SOCKET}" -f /dev/null \
    new-session -d -s test -x 200 -y 50 2>/dev/null
  sleep 0.1
}

teardown() {
  command tmux -S "${TILING_SOCKET}" kill-server 2>/dev/null || true
  rm -f "${TILING_SOCKET}" 2>/dev/null || true
}

# Echo the prefix key bound to a tiling action, or nothing if unbound.
# Args: the trailing tiling.sh argument, e.g. "layout dwindle" or "pick".
key_for() {
  command tmux -S "${TILING_SOCKET}" list-keys 2>/dev/null \
    | grep -E "tiling.sh ${1}( |\")" \
    | grep -oE 'prefix +[^ ]+' \
    | awk '{print $2}'
}

count_tiling_binds() {
  command tmux -S "${TILING_SOCKET}" list-keys 2>/dev/null \
    | grep -c 'tiling.sh'
}

@test "entry point - default keybindings are registered when no options are set" {
  bash "${PLUGIN}"

  [[ "$(key_for 'layout dwindle')" == "d" ]]
  [[ "$(key_for 'layout spiral')" == "D" ]]
  [[ "$(key_for 'balance')" == "b" ]]
  [[ "$(key_for 'circulate')" == "C-r" ]]
  [[ "$(key_for 'cycle')" == "o" ]]
  [[ "$(key_for 'scratchpad')" == "g" ]]
  [[ "$(key_for 'pick')" == "p" ]]
  [[ "$(key_for 'undo')" == "u" ]]
}

@test "entry point - a custom key overrides the default" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_dwindle "x"
  bash "${PLUGIN}"

  [[ "$(key_for 'layout dwindle')" == "x" ]]
}

@test "entry point - blank key disables a standard binding only" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_dwindle ""
  bash "${PLUGIN}"

  [[ -z "$(key_for 'layout dwindle')" ]]
  [[ "$(key_for 'layout spiral')" == "D" ]]
}

@test "entry point - blank pick_layout key disables the layout picker" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout ""
  bash "${PLUGIN}"

  [[ -z "$(key_for 'pick')" ]]
}

@test "entry point - blank undo key disables the undo binding" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_undo ""
  bash "${PLUGIN}"

  [[ -z "$(key_for 'undo')" ]]
}

@test "entry point - blank key produces no 'unknown key' error" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_dwindle ""
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_mark ""

  run bash "${PLUGIN}"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" != *"unknown key"* ]]
}

@test "entry point - auto_apply hooks register by default" {
  bash "${PLUGIN}"

  run command tmux -S "${TILING_SOCKET}" show-hooks -g
  [[ "${output}" == *"tiling.sh hook split"* ]]
}

@test "entry point - auto_apply=0 registers no reapply hooks" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_auto_apply "0"
  bash "${PLUGIN}"

  run command tmux -S "${TILING_SOCKET}" show-hooks -g
  [[ "${output}" != *"tiling.sh hook"* ]]
}

@test "entry point - a set key wins over another feature's default on the same key" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout "P"
  bash "${PLUGIN}"

  [[ "$(key_for 'pick')" == "P" ]]
  [[ -z "$(key_for 'pane-jump')" ]]
}

@test "entry point - a resolved conflict names both features" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout "P"
  bash "${PLUGIN}"

  local reported
  reported=$(command tmux -S "${TILING_SOCKET}" show-option -gqv "@tiling_revamped_conflicts")
  [[ "${reported}" == *"pick_layout"* ]]
  [[ "${reported}" == *"pane_jump"* ]]
}

@test "entry point - a clean config reports no conflict" {
  bash "${PLUGIN}"

  local reported
  reported=$(command tmux -S "${TILING_SOCKET}" show-option -gqv "@tiling_revamped_conflicts")
  [[ -z "${reported}" ]]
}

@test "entry point - a key conflict binds the slot exactly once" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout "P"
  bash "${PLUGIN}"

  local bound
  bound=$(command tmux -S "${TILING_SOCKET}" list-keys -T prefix 2>/dev/null \
    | grep -cE '^bind-key +(-r )?-T prefix +P ')
  [[ "${bound}" -eq 1 ]]
}

@test "entry point - two set keys on one slot keep the first and drop the second" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_dwindle "z"
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_spiral "z"
  bash "${PLUGIN}"

  [[ "$(key_for 'layout dwindle')" == "z" ]]
  [[ -z "$(key_for 'layout spiral')" ]]
}

@test "entry point - conflict warnings are suppressible" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout "P"
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_warn_conflicts "0"
  run bash "${PLUGIN}"

  [[ "${status}" -eq 0 ]]
  [[ "$(key_for 'pick')" == "P" ]]
}

@test "entry point - no associative array is declared at file scope" {
  run grep -nE '^declare -g?A' "${PLUGIN}"

  [[ "${status}" -ne 0 ]]
}

@test "entry point - loads without error under bash 3.2" {
  command -v /bin/bash >/dev/null || skip "no /bin/bash"
  [[ "$(/bin/bash -c 'echo ${BASH_VERSINFO[0]}')" -lt 4 ]] || skip "/bin/bash is bash 4 or newer"

  run /bin/bash "${PLUGIN}"

  [[ "${output}" != *"invalid option"* ]]
  [[ "${output}" != *"declare:"* ]]
}
