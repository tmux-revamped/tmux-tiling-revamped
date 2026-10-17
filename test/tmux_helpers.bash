#!/usr/bin/env bash

PLUGIN_DIR="${BATS_TEST_DIRNAME}"
while [[ "${PLUGIN_DIR}" != "/" ]] && [[ ! -d "${PLUGIN_DIR}/src" ]]; do
  PLUGIN_DIR="$(dirname "${PLUGIN_DIR}")"
done

TMUX_SOCKET="/tmp/tmux-plugin-test-${BASHPID}-${RANDOM}"

setup_tmux_server() {
  command tmux -S "${TMUX_SOCKET}" -f /dev/null new-session -d -s test -x 200 -y 50 2>/dev/null
  sleep 0.1
}

teardown_tmux_server() {
  command tmux -S "${TMUX_SOCKET}" kill-server 2>/dev/null || true
  rm -f "${TMUX_SOCKET}" 2>/dev/null || true
}

tmux() {
  command tmux -S "${TMUX_SOCKET}" "$@"
}

get_option() {
  command tmux -S "${TMUX_SOCKET}" show-option -gqv "${1}" 2>/dev/null
}

set_option() {
  command tmux -S "${TMUX_SOCKET}" set-option -gq "${1}" "${2}" 2>/dev/null
}

export -f tmux
export TMUX_SOCKET
export PLUGIN_DIR

_TMUX_HELPERS_LOCAL="$(dirname "${BASH_SOURCE[0]}")/tmux_helpers_local.bash"
if [ -f "${_TMUX_HELPERS_LOCAL}" ]; then
  # shellcheck source=/dev/null
  source "${_TMUX_HELPERS_LOCAL}"
fi
