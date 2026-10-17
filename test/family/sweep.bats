#!/usr/bin/env bats

setup() {
  SWEEP="${BATS_TEST_DIRNAME}/../../family/bin/sweep"
  MEMBERS_FILE="${BATS_TEST_DIRNAME}/../../family/MEMBERS"
  DIR="${BATS_TEST_TMPDIR}/members"
  mkdir -p "${DIR}"
}

make_member_checkouts() {
  local member
  while IFS= read -r member; do
    mkdir -p "${DIR}/${member}"
    printf 'nothing to see\n' >"${DIR}/${member}/file.sh"
  done < <(grep -vE '^[[:space:]]*(#|$)' "${MEMBERS_FILE}")
}

first_member() {
  grep -vE '^[[:space:]]*(#|$)' "${MEMBERS_FILE}" | head -n 1
}

@test "sweep - rejects an invalid regular expression before searching" {
  # Arrange
  make_member_checkouts

  # Act
  run "${SWEEP}" --pattern 'broken(' --members-dir "${DIR}"

  # Assert
  [ "${status}" -eq 2 ]
  [[ "${output}" == *"not a valid extended regular expression: broken("* ]] || false
  [[ "${output}" != *"clean"* ]]
}

@test "sweep - reports a member whose file matches as affected" {
  # Arrange
  make_member_checkouts
  printf 'defect here\n' >"${DIR}/$(first_member)/file.sh"

  # Act
  run "${SWEEP}" --pattern 'defect' --members-dir "${DIR}"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"1 affected,"* ]]
}

@test "sweep - a path glob that matches nothing in a member is clean" {
  # Arrange
  make_member_checkouts

  # Act
  run "${SWEEP}" --pattern 'defect' --paths 'absent/*.sh' --members-dir "${DIR}"

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"0 affected,"*"0 not checked"* ]]
}
