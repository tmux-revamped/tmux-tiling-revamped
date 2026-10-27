#!/usr/bin/env bats

setup() {
  SOURCE_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  FIXTURE="${BATS_TEST_TMPDIR}/$(basename "${SOURCE_ROOT}")"
  mkdir -p "${FIXTURE}"
  tar -C "${SOURCE_ROOT}" --exclude=./.git --exclude=./coverage -cf - . | tar -C "${FIXTURE}" -xf -
  rm -f "${FIXTURE}"/*.tmux
  git -C "${FIXTURE}" init --quiet
}

write_entry_point() {
  printf '#!/usr/bin/env bash\n' >"${FIXTURE}/probe.tmux"
  chmod "${1}" "${FIXTURE}/probe.tmux"
  git -C "${FIXTURE}" add -- probe.tmux
}

write_exception_under() {
  local section="${1}" name
  name="$(basename "${FIXTURE}")"
  printf '# Family Exceptions\n\n## %s\n\n### %s: LICENSE\n\n## Other\n' "${section}" "${name}" >"${FIXTURE}/family/EXCEPTIONS.md"
  printf 'diverged\n' >"${FIXTURE}/LICENSE"
}

@test "audit - an active exception excuses an owned file that differs" {
  # Arrange
  write_exception_under "Active exceptions"

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [[ "${output}" != *"LICENSE: content differs"* ]]
}

@test "audit - a retired exception no longer excuses an owned file that differs" {
  # Arrange
  write_exception_under "Retired exceptions"

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"LICENSE: content differs from the family copy"* ]]
}

@test "audit - reports an entry point git tracks without the executable bit" {
  # Arrange
  write_entry_point 755
  git -C "${FIXTURE}" update-index --chmod=-x -- probe.tmux

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"probe.tmux: tracked as mode 100644, so every clone gets a plugin that never loads"* ]]
}

@test "audit - reports an entry point that is not executable on disk" {
  # Arrange
  write_entry_point 644

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"probe.tmux: not executable, TPM runs the entry point directly"* ]]
}

@test "audit - accepts an entry point that is executable and tracked as 100755" {
  # Arrange
  write_entry_point 755

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"probe.tmux"* ]]
}

@test "audit - accepts a member with no entry point at the root" {
  # Arrange
  local name
  name="$(basename "${FIXTURE}")"

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" == "${name}: clean, contract version "* ]]
}
