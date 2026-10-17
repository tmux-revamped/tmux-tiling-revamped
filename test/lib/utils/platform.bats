#!/usr/bin/env bats

load "${BATS_TEST_DIRNAME}/../../helpers.bash"

setup() {
  setup_test_environment
  source "${BATS_TEST_DIRNAME}/../../../src/lib/utils/platform.sh"
}

teardown() {
  cleanup_test_environment
}

@test "platform.sh - functions are defined" {
  function_exists platform_os
  function_exists platform_arch
  function_exists is_apple_silicon
  function_exists is_macos
  function_exists is_linux
  function_exists is_bsd
}

@test "platform.sh - platform_arch echoes a non-empty string" {
  [[ -n "$(platform_arch)" ]]
}

@test "platform.sh - is_apple_silicon is true on arm64 Darwin" {
  _PLATFORM_OS_CACHE="Darwin"
  _PLATFORM_ARCH_CACHE="arm64"
  is_apple_silicon
}

@test "platform.sh - is_apple_silicon is false on Intel Darwin" {
  _PLATFORM_OS_CACHE="Darwin"
  _PLATFORM_ARCH_CACHE="x86_64"
  ! is_apple_silicon
}

@test "platform.sh - is_apple_silicon is false on Linux arm64" {
  _PLATFORM_OS_CACHE="Linux"
  _PLATFORM_ARCH_CACHE="aarch64"
  ! is_apple_silicon
}

@test "platform.sh - platform_os echoes a non-empty string" {
  [[ -n "$(platform_os)" ]]
}

@test "platform.sh - platform_os is stable across calls" {
  [[ "$(platform_os)" == "$(platform_os)" ]]
}

@test "platform.sh - is_macos is true on Darwin" {
  _PLATFORM_OS_CACHE="Darwin"
  is_macos
  ! is_linux || false
  ! is_bsd
}

@test "platform.sh - is_linux is true on Linux" {
  _PLATFORM_OS_CACHE="Linux"
  is_linux
  ! is_macos || false
  ! is_bsd
}

@test "platform.sh - is_bsd is true on FreeBSD" {
  _PLATFORM_OS_CACHE="FreeBSD"
  is_bsd
}

@test "platform.sh - is_bsd is true on DragonFly" {
  _PLATFORM_OS_CACHE="DragonFly"
  is_bsd
}
