#!/usr/bin/env bash
#
# has-command.sh: command availability probe.

[[ -n "${_TMUX_PLUGIN_HAS_COMMAND_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_HAS_COMMAND_LOADED=1

# has_command NAME -> 0 when NAME is on PATH, 1 otherwise.
has_command() {
  command -v "${1}" >/dev/null 2>&1
}

export -f has_command
