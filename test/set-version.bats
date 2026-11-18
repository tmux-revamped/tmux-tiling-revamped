#!/usr/bin/env bats
# shellcheck disable=SC2016,SC2030,SC2031

setup() {
  SOURCE="$(cd "${BATS_TEST_DIRNAME:-.}/.." && pwd)/.github/scripts/set-version.sh"
  WORK="$(mktemp -d "${BATS_TMPDIR:-/tmp}/set-version.XXXXXX")"
  mkdir -p "${WORK}/.github/scripts" "${WORK}/src/lib/utils"
  cp -f "${SOURCE}" "${WORK}/.github/scripts/set-version.sh"
  CONSTANTS="${WORK}/src/lib/utils/constants.sh"
}

teardown() {
  rm -rf "${WORK:?}"
}

write_constants() {
  printf '%s\n' "$@" >"${CONSTANTS}"
}

stamp() {
  run sh "${WORK}/.github/scripts/set-version.sh" "$1"
}

@test "stamps a member's version constant and leaves the other lines alone" {
  # Arrange
  write_constants '#!/usr/bin/env bash' 'readonly CPU_REVAMPED_VERSION="1.3.0"' 'readonly CPU_FZF_MIN_VERSION="0.53.0"'

  # Act
  stamp 1.4.0

  # Assert
  [[ "${status}" -eq 0 ]]
  [[ "${output}" == 'readonly CPU_REVAMPED_VERSION="1.4.0"' ]]
  expected="$(printf '%s\n' '#!/usr/bin/env bash' 'readonly CPU_REVAMPED_VERSION="1.4.0"' 'readonly CPU_FZF_MIN_VERSION="0.53.0"')"
  actual="$(cat "${CONSTANTS}")"
  [[ "${actual}" == "${expected}" ]]
}

@test "stamps the template's version constant" {
  # Arrange
  write_constants 'readonly SCROLL_REVAMPED_VERSION="1.0.0"'

  # Act
  stamp 1.1.0

  # Assert
  [[ "${status}" -eq 0 ]]
  actual="$(cat "${CONSTANTS}")"
  [[ "${actual}" == 'readonly SCROLL_REVAMPED_VERSION="1.1.0"' ]]
}

@test "refuses a version that is not dotted digits" {
  # Arrange
  write_constants 'readonly CPU_REVAMPED_VERSION="1.3.0"'

  # Act
  stamp '1.4.0/evil'

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == 'not a release version: 1.4.0/evil' ]]
  actual="$(cat "${CONSTANTS}")"
  [[ "${actual}" == 'readonly CPU_REVAMPED_VERSION="1.3.0"' ]]
}

@test "refuses a version with an empty part" {
  # Arrange
  write_constants 'readonly CPU_REVAMPED_VERSION="1.3.0"'

  # Act
  stamp '1..0'

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == 'not a release version: 1..0' ]]
}

@test "fails when no version constant exists" {
  # Arrange
  write_constants 'readonly CPU_FZF_MIN_VERSION="0.53.0"'

  # Act
  stamp 1.4.0

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "expected one version constant in ${CONSTANTS}, found 0" ]]
}

@test "fails when two version constants exist" {
  # Arrange
  write_constants 'readonly CPU_REVAMPED_VERSION="1.3.0"' 'readonly RAM_REVAMPED_VERSION="2.0.0"'

  # Act
  stamp 1.4.0

  # Assert
  [[ "${status}" -eq 1 ]]
  [[ "${output}" == "expected one version constant in ${CONSTANTS}, found 2" ]]
}
