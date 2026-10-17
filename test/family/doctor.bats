#!/usr/bin/env bats

setup() {
  DOCTOR="${BATS_TEST_DIRNAME}/../../family/bin/doctor"
  MEMBERS_FILE="${BATS_TEST_DIRNAME}/../../family/MEMBERS"
  DIR="${BATS_TEST_TMPDIR}/members"
  STUB="${BATS_TEST_TMPDIR}/stub"
  mkdir -p "${DIR}" "${STUB}/bin" "${STUB}/opts"
  : >"${STUB}/keys"
  write_tmux_stub
  PATH="${STUB}/bin:${PATH}"
  FIRST="$(member_at 1)"
  SECOND="$(member_at 2)"
}

member_at() {
  grep -vE '^[[:space:]]*(#|$)' "${MEMBERS_FILE}" | sed -n "${1}p"
}

write_tmux_stub() {
  cat >"${STUB}/bin/tmux" <<STUB
#!/usr/bin/env bash
case "\${1}" in
  list-keys) cat "${STUB}/keys" ;;
  show-option)
    file="${STUB}/opts/\${3}"
    [ -f "\${file}" ] && cat "\${file}"
    ;;
esac
exit 0
STUB
  chmod +x "${STUB}/bin/tmux"
}

option_of() {
  local slug="${1#tmux-}"
  printf '@%s_revamped_key' "${slug%-revamped}"
}

write_member() {
  mkdir -p "${DIR}/${1}"
  printf 'key="$(get_tmux_option "%s" "%s")"\ntmux bind-key "${key}" run-shell true\n' "$(option_of "${1}")" "${2}" >"${DIR}/${1}/plugin.tmux"
}

@test "doctor - live check ignores repeatable bindings that hold one key each" {
  # Arrange
  write_member "${FIRST}" a
  write_member "${SECOND}" b
  {
    printf 'bind-key -r -T prefix Up select-pane -U\n'
    printf 'bind-key -r -T prefix Down select-pane -D\n'
    printf 'bind-key -T prefix a run-shell first\n'
    printf 'bind-key -T prefix b run-shell second\n'
  } >"${STUB}/keys"

  # Act
  run "${DOCTOR}" --members-dir "${DIR}" --live

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"live server"* ]] || false
  [[ "${output}" == *"clean"* ]]
}

@test "doctor - live check reports two members claiming the same configured key" {
  # Arrange
  write_member "${FIRST}" a
  write_member "${SECOND}" b
  printf 'a' >"${STUB}/opts/$(option_of "${SECOND}")"
  printf 'bind-key -r -T prefix a run-shell second\n' >"${STUB}/keys"

  # Act
  run "${DOCTOR}" --members-dir "${DIR}" --live

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"live server: a in the prefix table is claimed by ${FIRST}, ${SECOND}"* ]]
}

@test "doctor - live check skips a shared key the server does not bind" {
  # Arrange
  write_member "${FIRST}" a
  write_member "${SECOND}" b
  printf 'a' >"${STUB}/opts/$(option_of "${SECOND}")"
  printf 'bind-key -T prefix z run-shell other\n' >"${STUB}/keys"

  # Act
  run "${DOCTOR}" --members-dir "${DIR}" --live

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" != *"live server"* ]]
}
