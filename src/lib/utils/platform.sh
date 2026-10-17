#!/usr/bin/env bash
#
# platform.sh: operating-system detection, memoized for one process.

[[ -n "${_TMUX_PLUGIN_PLATFORM_LOADED:-}" ]] && return 0
_TMUX_PLUGIN_PLATFORM_LOADED=1

_PLATFORM_OS_CACHE=""
_PLATFORM_ARCH_CACHE=""

_platform_detect_os() {
  if [[ -z "${_PLATFORM_OS_CACHE}" ]]; then
    _PLATFORM_OS_CACHE="$(uname -s 2>/dev/null || echo "unknown")"
  fi
}

_platform_detect_arch() {
  if [[ -z "${_PLATFORM_ARCH_CACHE}" ]]; then
    _PLATFORM_ARCH_CACHE="$(uname -m 2>/dev/null || echo "unknown")"
  fi
}

# platform_os -> uname -s, computed once per process.
platform_os() {
  _platform_detect_os
  echo "${_PLATFORM_OS_CACHE}"
}

# platform_arch -> uname -m, computed once per process.
platform_arch() {
  _platform_detect_arch
  echo "${_PLATFORM_ARCH_CACHE}"
}

# is_apple_silicon -> 0 on an arm64 Mac.
is_apple_silicon() {
  _platform_detect_os
  _platform_detect_arch
  [[ "${_PLATFORM_OS_CACHE}" == "Darwin" && "${_PLATFORM_ARCH_CACHE}" == "arm64" ]]
}

# is_macos -> 0 on Darwin.
is_macos() {
  _platform_detect_os
  [[ "${_PLATFORM_OS_CACHE}" == "Darwin" ]]
}

# is_linux -> 0 on Linux.
is_linux() {
  _platform_detect_os
  [[ "${_PLATFORM_OS_CACHE}" == "Linux" ]]
}

# is_bsd -> 0 on any *BSD kernel.
is_bsd() {
  _platform_detect_os
  case "${_PLATFORM_OS_CACHE}" in
    *BSD) return 0 ;;
    DragonFly) return 0 ;;
    *) return 1 ;;
  esac
}

export -f _platform_detect_os
export -f _platform_detect_arch
export -f platform_os
export -f platform_arch
export -f is_apple_silicon
export -f is_macos
export -f is_linux
export -f is_bsd
