#!/usr/bin/env bats

setup() {
  SOURCE_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  SELF="${BATS_TEST_TMPDIR}/self"
  EMPTY="${BATS_TEST_TMPDIR}/members"
  mkdir -p "${SELF}" "${EMPTY}"
  (cd "${SOURCE_ROOT}" && tar cf - --exclude=.git .) | (cd "${SELF}" && tar xf -)
  "${SELF}/family/bin/checksums" >/dev/null
  PROPAGATE="${SELF}/family/bin/propagate"
  VERSION_BEFORE="$(tr -d '[:space:]' <"${SELF}/family/VERSION")"
  CHECKSUMS_BEFORE="$(cat "${SELF}/family/CHECKSUMS")"
}

@test "propagate - a dry run writes nothing even after an owned file changed" {
  # Arrange
  printf '\nchanged\n' >>"${SELF}/FAMILY.md"

  # Act
  run "${PROPAGATE}" --message "chore: sync" --members-dir "${EMPTY}" --dry-run --no-push

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"contract version would move ${VERSION_BEFORE} -> $((VERSION_BEFORE + 1))"* ]] || false
  [[ "$(tr -d '[:space:]' <"${SELF}/family/VERSION")" == "${VERSION_BEFORE}" ]] || false
  [[ "$(cat "${SELF}/family/CHECKSUMS")" == "${CHECKSUMS_BEFORE}" ]]
}

@test "propagate - keeps the version when no owned file changed" {
  # Arrange
  local message="chore: sync"

  # Act
  run "${PROPAGATE}" --message "${message}" --members-dir "${EMPTY}" --no-push

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"contract version stays ${VERSION_BEFORE}"* ]] || false
  [[ "$(tr -d '[:space:]' <"${SELF}/family/VERSION")" == "${VERSION_BEFORE}" ]]
}

@test "propagate - bumps the version once when an owned file changed" {
  # Arrange
  printf '\nchanged\n' >>"${SELF}/FAMILY.md"
  "${PROPAGATE}" --message "chore: sync" --members-dir "${EMPTY}" --no-push

  # Act
  run "${PROPAGATE}" --message "chore: sync" --members-dir "${EMPTY}" --no-push

  # Assert
  [ "${status}" -eq 0 ]
  [[ "$(tr -d '[:space:]' <"${SELF}/family/VERSION")" == "$((VERSION_BEFORE + 1))" ]] || false
  [[ "$(cat "${SELF}/family/CHECKSUMS")" != "${CHECKSUMS_BEFORE}" ]]
}

@test "propagate - --no-bump keeps the version after an owned file changed" {
  # Arrange
  printf '\nchanged\n' >>"${SELF}/FAMILY.md"

  # Act
  run "${PROPAGATE}" --message "chore: sync" --members-dir "${EMPTY}" --no-push --no-bump

  # Assert
  [ "${status}" -eq 0 ]
  [[ "$(tr -d '[:space:]' <"${SELF}/family/VERSION")" == "${VERSION_BEFORE}" ]] || false
  [[ "$(cat "${SELF}/family/CHECKSUMS")" != "${CHECKSUMS_BEFORE}" ]]
}
