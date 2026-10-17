#!/usr/bin/env bats

setup() {
  GEN="${BATS_TEST_DIRNAME}/../../family/bin/gen-readme"
  MEMBERS_FILE="${BATS_TEST_DIRNAME}/../../family/MEMBERS"
  DIR="${BATS_TEST_TMPDIR}/members"
  TARGET="${BATS_TEST_TMPDIR}/target"
  SCRATCH="${BATS_TEST_TMPDIR}/scratch"
  FIRST="$(grep -vE '^[[:space:]]*(#|$)' "${MEMBERS_FILE}" | head -n 1)"
  mkdir -p "${DIR}/${FIRST}" "${TARGET}" "${SCRATCH}"
}

write_marked_readme() {
  printf '# target\n\n<!-- family:begin -->\nold\n<!-- family:end -->\ntail\n' >"${TARGET}/README.md"
}

@test "gen-readme - replaces the marked section with an escaped pipe intact" {
  # Arrange
  printf '# member\n\nsplits a | b\n' >"${DIR}/${FIRST}/README.md"
  write_marked_readme

  # Act
  run env TMPDIR="${SCRATCH}" "${GEN}" --members-dir "${DIR}" "${TARGET}"

  # Assert
  [ "${status}" -eq 0 ]
  grep -qF 'splits a \| b |' "${TARGET}/README.md"
  [[ "$(tail -n 1 "${TARGET}/README.md")" == "tail" ]] || false
  [[ "$(grep -c 'family:begin' "${TARGET}/README.md")" -eq 1 ]] || false
  [ -z "$(ls -A "${SCRATCH}")" ]
}

@test "gen-readme - a rewritten section is current on the next check" {
  # Arrange
  printf '# member\n\nsplits a | b\n' >"${DIR}/${FIRST}/README.md"
  write_marked_readme
  TMPDIR="${SCRATCH}" "${GEN}" --members-dir "${DIR}" "${TARGET}"

  # Act
  run env TMPDIR="${SCRATCH}" "${GEN}" --check --members-dir "${DIR}" "${TARGET}"

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"README family section is current"* ]]
}
