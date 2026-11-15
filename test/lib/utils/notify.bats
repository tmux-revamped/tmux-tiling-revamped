#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  NOTIFY_BIN="${TEST_TMPDIR}/bin"
  NOTIFY_CALLS="${TEST_TMPDIR}/calls"
  mkdir -p "${NOTIFY_BIN}"
  export NOTIFY_CALLS
  NOTIFY_ORIGINAL_PATH="${PATH}"
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/notify.sh"
}

teardown() {
  PATH="${NOTIFY_ORIGINAL_PATH}"
  cleanup_test_environment
}

stub_notifier() {
  unset -f "${1}"
  printf '#!/bin/sh\nfor a in "$@"; do printf "%%s\\n" "$a"; done >>"%s"\n' "${NOTIFY_CALLS}" >"${NOTIFY_BIN}/${1}"
  chmod +x "${NOTIFY_BIN}/${1}"
}

hide_system_notifiers() {
  local tool
  NOTIFY_BIN_ONLY="${TEST_TMPDIR}/only"
  mkdir -p "${NOTIFY_BIN_ONLY}"
  unset -f osascript notify-send
  for tool in uname cat tail head grep tr; do
    ln -s "$(type -P "${tool}")" "${NOTIFY_BIN_ONLY}/${tool}"
  done
  PATH="${NOTIFY_BIN}:${NOTIFY_BIN_ONLY}"
}

@test "notify.sh - backend is osascript on macOS when osascript exists" {
  # Arrange
  stub_notifier osascript
  stub_notifier notify-send
  hide_system_notifiers
  _PLATFORM_OS_CACHE="Darwin"

  # Act
  backend="$(notify_backend)"

  # Assert
  [ "${backend}" = "osascript" ]
}

@test "notify.sh - backend is notify-send on Linux even when osascript exists" {
  # Arrange
  stub_notifier osascript
  stub_notifier notify-send
  hide_system_notifiers
  _PLATFORM_OS_CACHE="Linux"

  # Act
  backend="$(notify_backend)"

  # Assert
  [ "${backend}" = "notify-send" ]
}

@test "notify.sh - backend is none without a notifier" {
  # Arrange
  hide_system_notifiers
  _PLATFORM_OS_CACHE="Linux"

  # Act
  backend="$(notify_backend)"

  # Assert
  [ "${backend}" = "none" ]
}

@test "notify.sh - notify_enabled is false when the option is unset" {
  # Arrange
  option="@cpu_revamped_notify"

  # Act
  run notify_enabled "${option}"

  # Assert
  [ "${status}" -eq 1 ]
}

@test "notify.sh - notify_enabled is true only for 1" {
  # Arrange
  tmux set-option -gq "@cpu_revamped_notify" "1"

  # Act
  run notify_enabled "@cpu_revamped_notify"

  # Assert
  [ "${status}" -eq 0 ]
}

@test "notify.sh - notify_send passes quotes and backslashes to osascript as arguments" {
  # Arrange
  stub_notifier osascript
  hide_system_notifiers
  _PLATFORM_OS_CACHE="Darwin"
  title='Disk "x"'
  message='mount /Volumes/a\b "quoted"'

  # Act
  notify_send "${title}" "${message}"

  # Assert
  [ "$(tail -n 2 "${NOTIFY_CALLS}" | head -n 1)" = 'Disk "x"' ]
  [ "$(tail -n 1 "${NOTIFY_CALLS}")" = 'mount /Volumes/a\b "quoted"' ]
  ! grep -q 'display notification "' "${NOTIFY_CALLS}"
}

@test "notify.sh - notify_send ends notify-send options before the title" {
  # Arrange
  stub_notifier notify-send
  hide_system_notifiers
  _PLATFORM_OS_CACHE="Linux"

  # Act
  notify_send "-title" "body"

  # Assert
  [ "$(cat "${NOTIFY_CALLS}")" = "$(printf '%s\n%s\n%s' '--' '-title' 'body')" ]
}

@test "notify.sh - notify_send succeeds with no notifier" {
  # Arrange
  hide_system_notifiers
  _PLATFORM_OS_CACHE="Linux"

  # Act
  run notify_send "title" "body"

  # Assert
  [ "${status}" -eq 0 ]
  [ ! -e "${NOTIFY_CALLS}" ]
}

@test "notify.sh - notify_if_enabled sends nothing while the option is off" {
  # Arrange
  stub_notifier notify-send
  hide_system_notifiers
  _PLATFORM_OS_CACHE="Linux"

  # Act
  notify_if_enabled "@cpu_revamped_notify" "title" "body"

  # Assert
  [ ! -e "${NOTIFY_CALLS}" ]
}

@test "notify.sh - notify_if_enabled sends once the option is 1" {
  # Arrange
  stub_notifier notify-send
  hide_system_notifiers
  _PLATFORM_OS_CACHE="Linux"
  tmux set-option -gq "@cpu_revamped_notify" "1"

  # Act
  notify_if_enabled "@cpu_revamped_notify" "title" "body"

  # Assert
  [ "$(cat "${NOTIFY_CALLS}")" = "$(printf '%s\n%s\n%s' '--' 'title' 'body')" ]
}
