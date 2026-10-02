#!/usr/bin/env bats

setup() {
  DRIFT="${BATS_TEST_DIRNAME}/../../family/bin/check-runner-drift"
  MEMBER="${BATS_TEST_TMPDIR}/member"
  IMAGES="${BATS_TEST_TMPDIR}/images.md"
  mkdir -p "${MEMBER}/.github/workflows"
  {
    printf '| Image | Architecture | YAML Label | Included Software |\n'
    printf '| Ubuntu 26.04 | x64 | `ubuntu-26.04` | [ubuntu-26.04] |\n'
    printf '| Ubuntu 26.04 Arm64 | arm64 | `ubuntu-26.04-arm` | [ubuntu-26.04-arm64] |\n'
    printf '| Ubuntu 24.04 | x64 | `ubuntu-latest` or `ubuntu-24.04` | [ubuntu-24.04] |\n'
    printf '| macOS 27 [![beta](x)] | arm64 | `macos-27` | [macOS-27] |\n'
    printf '| macOS 26 | x64 | `macos-26-intel`, `macos-26-large` | [macOS-26] |\n'
    printf '| macOS 26 Arm64 | arm64 | `macos-latest`, `macos-26` | [macOS-26-arm64] |\n'
  } >"${IMAGES}"
}

write_workflow() {
  printf 'jobs:\n  a:\n    runs-on: %s\n' "${1}" >"${MEMBER}/.github/workflows/ci.yml"
}

@test "check-runner-drift - reports a pin older than a generally available image" {
  write_workflow "ubuntu-24.04-arm"

  run "${DRIFT}" --images "${IMAGES}" "${MEMBER}"

  [ "${status}" -eq 1 ]
  [[ "${output}" == *"pins ubuntu-24.04-arm, ubuntu-26.04-arm is generally available"* ]]
}

@test "check-runner-drift - passes when every pin is the newest of its line" {
  write_workflow "ubuntu-26.04"

  run "${DRIFT}" --images "${IMAGES}" "${MEMBER}"

  [ "${status}" -eq 0 ]
  [[ "${output}" == *"every pinned runner is current"* ]]
}

@test "check-runner-drift - ignores a beta image newer than the pin" {
  write_workflow "macos-26"

  run "${DRIFT}" --images "${IMAGES}" "${MEMBER}"

  [ "${status}" -eq 0 ]
}

@test "check-runner-drift - keeps the intel line apart from the arm line" {
  write_workflow "macos-26-intel"
  printf '| macOS 28 Arm64 | arm64 | `macos-28` | [macOS-28-arm64] |\n' >>"${IMAGES}"

  run "${DRIFT}" --images "${IMAGES}" "${MEMBER}"

  [ "${status}" -eq 0 ]
}

@test "check-runner-drift - fails closed when the image list holds no label" {
  write_workflow "ubuntu-24.04"
  printf 'no table here\n' >"${IMAGES}"

  run "${DRIFT}" --images "${IMAGES}" "${MEMBER}"

  [ "${status}" -eq 2 ]
  [[ "${output}" == *"holds no recognisable runner label"* ]]
}

@test "check-runner-drift - fails closed when the image list cannot be read" {
  write_workflow "ubuntu-24.04"

  run "${DRIFT}" --images "${BATS_TEST_TMPDIR}/absent.md" "${MEMBER}"

  [ "${status}" -eq 2 ]
}

@test "check-runner-drift - rejects an unknown flag" {
  run "${DRIFT}" --bogus

  [ "${status}" -eq 2 ]
  [[ "${output}" == *"usage:"* ]]
}
