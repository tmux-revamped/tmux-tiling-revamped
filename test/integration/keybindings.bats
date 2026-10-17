#!/usr/bin/env bats

setup() {
  PLUGIN_DIR="${BATS_TEST_DIRNAME}/../.."
  PLUGIN="${PLUGIN_DIR}/tmux-tiling-revamped.tmux"
  if ((BASH_VERSINFO[0] < 4)) && [[ "${BATS_TEST_DESCRIPTION}" != *"bash 3.2"* ]]; then
    skip "the plugin needs bash 4 or newer and bats runs under bash ${BASH_VERSION}"
  fi
  export TILING_SOCKET="/tmp/tiling-kb-${BASHPID}-${RANDOM}"

  tmux() { command tmux -S "${TILING_SOCKET}" "$@"; }
  export -f tmux
  export TILING_SOCKET

  command tmux -S "${TILING_SOCKET}" -f /dev/null \
    new-session -d -s test -x 200 -y 50 2>/dev/null
  local attempt
  for ((attempt = 0; attempt < 50; attempt++)); do
    command tmux -S "${TILING_SOCKET}" has-session -t test 2>/dev/null && return 0
    sleep 0.1
  done
  return 1
}

teardown() {
  command tmux -S "${TILING_SOCKET}" kill-server 2>/dev/null || true
  rm -f "${TILING_SOCKET}" 2>/dev/null || true
}

key_for() {
  command tmux -S "${TILING_SOCKET}" list-keys 2>/dev/null \
    | grep -E "tiling.sh ${1}( |\")" \
    | grep -oE 'prefix +[^ ]+' \
    | awk '{print $2}'
}

binding_line() {
  command tmux -S "${TILING_SOCKET}" list-keys 2>/dev/null \
    | awk -v table="${1}" -v key="${2}" '{
        i = 2
        if ($i == "-r") { i++ }
        if ($i == "-T" && $(i + 1) == table && $(i + 2) == key) { print }
      }'
}

count_tiling_binds() {
  command tmux -S "${TILING_SOCKET}" list-keys 2>/dev/null \
    | grep -c 'tiling.sh'
}

@test "entry point - default keybindings are registered when no options are set" {
  "${BASH}" "${PLUGIN}"

  [[ "$(key_for 'layout dwindle')" == "M-D" ]]
  [[ "$(key_for 'layout spiral')" == "M-S" ]]
  [[ "$(key_for 'balance')" == "M-B" ]]
  [[ "$(key_for 'circulate')" == "M-C" ]]
  [[ "$(key_for 'cycle')" == "M-O" ]]
  [[ "$(key_for 'scratchpad')" == "M-T" ]]
  [[ "$(key_for 'pick')" == "M-L" ]]
  [[ "$(key_for 'undo')" == "M-U" ]]
}

@test "entry point - a custom key overrides the default" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_dwindle "x"
  "${BASH}" "${PLUGIN}"

  [[ "$(key_for 'layout dwindle')" == "x" ]]
}

@test "entry point - no default binds a key outside the M- uppercase range" {
  # Arrange
  local outside

  # Act
  "${BASH}" "${PLUGIN}"

  # Assert
  outside=$(command tmux -S "${TILING_SOCKET}" list-keys 2>/dev/null \
    | grep 'tiling.sh' \
    | { grep -vE '^bind-key +(-r +)?-T prefix +M-[A-Z] ' || true; })
  [[ -z "${outside}" ]]
}

@test "entry point - stock tmux keys keep their stock commands" {
  # Arrange
  local bound

  # Act
  "${BASH}" "${PLUGIN}"

  # Assert
  bound=$(binding_line prefix d)
  [[ "${bound}" == *"detach-client"* ]] || false
  bound=$(binding_line prefix "?")
  [[ "${bound}" == *"list-keys"* ]]
}

@test "entry point - directional swap is unbound by default" {
  # Arrange
  local swaps

  # Act
  "${BASH}" "${PLUGIN}"

  # Assert
  swaps=$(command tmux -S "${TILING_SOCKET}" list-keys 2>/dev/null | grep -c 'tiling.sh swap ' || true)
  [[ "${swaps}" -eq 0 ]]
}

@test "entry point - alt keys bind an M- default as itself in the root table" {
  # Arrange
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_alt_keys "1"

  # Act
  "${BASH}" "${PLUGIN}"

  # Assert
  run binding_line root M-D
  [[ "${output}" == *"layout dwindle"* ]] || false
  [[ "${output}" != *"M-M-D"* ]]
}

@test "entry point - blank key disables a standard binding only" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_dwindle ""
  "${BASH}" "${PLUGIN}"

  [[ -z "$(key_for 'layout dwindle')" ]]
  [[ "$(key_for 'layout spiral')" == "M-S" ]]
}

@test "entry point - blank pick_layout key disables the layout picker" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout ""
  "${BASH}" "${PLUGIN}"

  [[ -z "$(key_for 'pick')" ]]
}

@test "entry point - blank undo key disables the undo binding" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_undo ""
  "${BASH}" "${PLUGIN}"

  [[ -z "$(key_for 'undo')" ]]
}

@test "entry point - blank key produces no 'unknown key' error" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_dwindle ""
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_mark ""

  run "${BASH}" "${PLUGIN}"

  [[ "${status}" -eq 0 ]]
  [[ "${output}" != *"unknown key"* ]]
}

@test "entry point - auto_apply hooks register by default" {
  "${BASH}" "${PLUGIN}"

  run command tmux -S "${TILING_SOCKET}" show-hooks -g
  [[ "${output}" == *"tiling.sh hook split"* ]]
}

@test "entry point - auto_apply=0 registers no reapply hooks" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_auto_apply "0"
  "${BASH}" "${PLUGIN}"

  run command tmux -S "${TILING_SOCKET}" show-hooks -g
  [[ "${output}" != *"tiling.sh hook"* ]]
}

@test "entry point - a set key wins over another feature's default on the same key" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout "M-Q"
  "${BASH}" "${PLUGIN}"

  [[ "$(key_for 'pick')" == "M-Q" ]]
  [[ -z "$(key_for 'pane-jump')" ]]
}

@test "entry point - a resolved conflict names both features" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout "M-Q"
  "${BASH}" "${PLUGIN}"

  local reported
  reported=$(command tmux -S "${TILING_SOCKET}" show-option -gqv "@tiling_revamped_conflicts")
  [[ "${reported}" == *"pick_layout"* ]]
  [[ "${reported}" == *"pane_jump"* ]]
}

@test "entry point - a clean config reports no conflict" {
  "${BASH}" "${PLUGIN}"

  local reported
  reported=$(command tmux -S "${TILING_SOCKET}" show-option -gqv "@tiling_revamped_conflicts")
  [[ -z "${reported}" ]]
}

@test "entry point - a key conflict binds the slot exactly once" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout "M-Q"
  "${BASH}" "${PLUGIN}"

  local bound
  bound=$(command tmux -S "${TILING_SOCKET}" list-keys -T prefix 2>/dev/null \
    | grep -cE '^bind-key +(-r )?-T prefix +M-Q ')
  [[ "${bound}" -eq 1 ]]
}

@test "entry point - two set keys on one slot keep the first and drop the second" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_dwindle "z"
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_spiral "z"
  "${BASH}" "${PLUGIN}"

  [[ "$(key_for 'layout dwindle')" == "z" ]]
  [[ -z "$(key_for 'layout spiral')" ]]
}

@test "entry point - conflict warnings are suppressible" {
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_key_pick_layout "M-Q"
  command tmux -S "${TILING_SOCKET}" set -g @tiling_revamped_warn_conflicts "0"
  run "${BASH}" "${PLUGIN}"

  [[ "${status}" -eq 0 ]]
  [[ "$(key_for 'pick')" == "M-Q" ]]
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
  [[ "${output}" != *"can only \`return'"* ]]
}

stage_plugin_with_stub() {
  local root="${1}" marker="${2}"
  mkdir -p "${root}/src"
  cp "${PLUGIN}" "${root}/tmux-tiling-revamped.tmux"
  printf '#!/bin/sh\nprintf "%%s\\n" "$*" > %q\n' "${marker}" > "${root}/src/tiling.sh"
  chmod +x "${root}/src/tiling.sh"
}

wait_for_file() {
  local attempt
  for (( attempt = 0; attempt < 30; attempt++ )); do
    [[ -s "${1}" ]] && return 0
    sleep 0.1
  done
  return 1
}

@test "entry point - a hook runs from a plugin path containing a space" {
  # Arrange
  local root="${BATS_TEST_TMPDIR}/plugin dir"
  local marker="${BATS_TEST_TMPDIR}/hook-ran"
  stage_plugin_with_stub "${root}" "${marker}"
  "${BASH}" "${root}/tmux-tiling-revamped.tmux"

  # Act
  command tmux -S "${TILING_SOCKET}" set-hook -R after-split-window
  wait_for_file "${marker}" || true

  # Assert
  [[ "$(cat "${marker}" 2>/dev/null)" == "hook split"* ]]
}

@test "entry point - a key binding runs from a plugin path containing a space" {
  # Arrange
  local root="${BATS_TEST_TMPDIR}/plugin dir"
  local marker="${BATS_TEST_TMPDIR}/key-ran"
  local bound="${BATS_TEST_TMPDIR}/bound.conf"
  stage_plugin_with_stub "${root}" "${marker}"
  "${BASH}" "${root}/tmux-tiling-revamped.tmux"
  binding_line prefix M-D \
    | sed -E 's/^bind-key +-T prefix +M-D +//' > "${bound}"

  # Act
  command tmux -S "${TILING_SOCKET}" source-file "${bound}"
  wait_for_file "${marker}" || true

  # Assert
  [[ "$(cat "${marker}" 2>/dev/null)" == "layout dwindle" ]]
}

@test "entry point - the mark prompt substitutes the escaped response" {
  # Arrange
  local bound

  # Act
  "${BASH}" "${PLUGIN}"

  # Assert
  bound=$(binding_line prefix M-K)
  [[ "${bound}" == *"mark '%%%'"* ]]
}

@test "entry point - a re-tile hook passes the window it fired for" {
  # Arrange
  local root="${BATS_TEST_TMPDIR}/plugin"
  local marker="${BATS_TEST_TMPDIR}/hook-window"
  stage_plugin_with_stub "${root}" "${marker}"
  "${BASH}" "${root}/tmux-tiling-revamped.tmux"

  # Act
  command tmux -S "${TILING_SOCKET}" set-hook -R pane-exited
  wait_for_file "${marker}" || true

  # Assert
  [[ "$(cat "${marker}" 2>/dev/null)" =~ ^hook\ exit\ @[0-9]+$ ]]
}
