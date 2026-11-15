#!/usr/bin/env bats

setup() {
  SOURCE_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  FIXTURE="${BATS_TEST_TMPDIR}/$(basename "${SOURCE_ROOT}")"
  mkdir -p "${FIXTURE}"
  tar -C "${SOURCE_ROOT}" --exclude=./.git --exclude=./coverage -cf - . | tar -C "${FIXTURE}" --no-same-owner -xf -
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

write_agent_guide() {
  local heading
  printf '# probe\n' >"${FIXTURE}/AGENTS.md"
  for heading in "$@"; do
    printf '\n%s\n\nText.\n' "${heading}" >>"${FIXTURE}/AGENTS.md"
  done
}

write_source_line() {
  mkdir -p "${FIXTURE}/src"
  printf '#!/usr/bin/env bash\n%s\n' "${1}" >"${FIXTURE}/src/probe.sh"
}

@test "audit - reports a substitution whose replacement is an unquoted expansion" {
  # Arrange
  write_source_line 'value="${value//${placeholder}/${command}}"'

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"src/probe.sh:2: a substitution replacement starts with an unquoted expansion"* ]]
}

@test "audit - accepts a substitution whose replacement is quoted" {
  # Arrange
  write_source_line 'value=${value//"{icon}"/"${icon}"}'

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [[ "${output}" != *"src/probe.sh"* ]]
}

@test "audit - accepts the hash doubling that only ever writes two hashes" {
  # Arrange
  write_source_line 'quoted="${quoted//"${hash}"/${hash}${hash}}"'

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [[ "${output}" != *"src/probe.sh"* ]]
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

@test "audit - reports an entry point whose mode git cannot read" {
  # Arrange
  write_entry_point 755
  export GIT_DIR="${BATS_TEST_TMPDIR}/no-such-git-dir"

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"probe.tmux: git could not read the mode it records: fatal:"* ]]
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

@test "audit - accepts an agent guide with the six headings in order" {
  # Arrange
  write_agent_guide '## Layout' '## Names' '## Behaviour' '## Domain rules' '## Release' '## Gaps against FAMILY.md'

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"AGENTS.md"* ]]
}

@test "audit - reports an agent guide missing a heading" {
  # Arrange
  write_agent_guide '## Layout' '## Names' '## Behaviour' '## Domain rules' '## Release'

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"AGENTS.md: its level-two headings must be exactly Layout, Names, Behaviour, Domain rules, Release and Gaps against FAMILY.md, in that order"* ]]
}

@test "audit - reports an agent guide whose headings are out of order" {
  # Arrange
  write_agent_guide '## Names' '## Layout' '## Behaviour' '## Domain rules' '## Release' '## Gaps against FAMILY.md'

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"AGENTS.md: its level-two headings must be exactly"* ]]
}

@test "audit - reports an agent guide with an extra heading" {
  # Arrange
  write_agent_guide '## Layout' '## Names' '## Behaviour' '## Domain rules' '## Release' '## Gaps against FAMILY.md' '## Never'

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"AGENTS.md: its level-two headings must be exactly"* ]]
}

@test "audit - ignores a heading inside a code fence in the agent guide" {
  # Arrange
  write_agent_guide '## Layout' '```' '## not a heading' '```' '## Names' '## Behaviour' '## Domain rules' '## Release' '## Gaps against FAMILY.md'

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"AGENTS.md"* ]]
}

@test "audit - reports a missing agent guide" {
  # Arrange
  rm -f "${FIXTURE}/AGENTS.md"

  # Act
  run "${FIXTURE}/family/bin/audit"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"AGENTS.md: named in family/OWNERSHIP but absent from this member"* ]]
}
