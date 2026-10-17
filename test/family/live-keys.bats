#!/usr/bin/env bats

setup() {
  LIVE="${BATS_TEST_DIRNAME}/../../family/bin/live-keys"
  MEMBERS_FILE="${BATS_TEST_DIRNAME}/../../family/MEMBERS"
  DIR="${BATS_TEST_TMPDIR}/members"
  STUB="${BATS_TEST_TMPDIR}/stub"
  mkdir -p "${DIR}" "${STUB}/bin" "${STUB}/keys"
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
[ "\${1}" = "-S" ] && shift 2
case "\${1}" in
  list-keys) cat "${STUB}/keys/\${3}" 2>/dev/null ;;
  run-shell) bash -c "\${2}" ;;
esac
exit 0
STUB
  chmod +x "${STUB}/bin/tmux"
}

write_member() {
  mkdir -p "${DIR}/${1}"
  printf '#!/usr/bin/env bash\nprintf "%%s\\n" %q >>%q\n' "${3}" "${STUB}/keys/${2}" >"${DIR}/${1}/plugin.tmux"
}

@test "live-keys - reports two members binding the same root key" {
  # Arrange
  write_member "${FIRST}" root 'bind-key -T root M-x run-shell first'
  write_member "${SECOND}" root 'bind-key -T root M-x run-shell second'

  # Act
  run "${LIVE}" --members-dir "${DIR}"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"clash"$'\t'"root:M-x"$'\t'"${FIRST},${SECOND}"* ]]
}

@test "live-keys - reports a member taking a stock copy-mode key" {
  # Arrange
  printf 'bind-key -T copy-mode q send-keys -X cancel\n' >"${STUB}/keys/copy-mode"
  write_member "${FIRST}" copy-mode 'bind-key -T copy-mode q send-keys -X other'

  # Act
  run "${LIVE}" --members-dir "${DIR}"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"stock"$'\t'"copy-mode:q"* ]] || false
  [[ "${output}" == *"steals"$'\t'"copy-mode:q"$'\t'"${FIRST}"* ]]
}

@test "live-keys - a repeatable prefix binding is attributed to its key" {
  # Arrange
  write_member "${FIRST}" prefix 'bind-key -r -T prefix Up select-pane -U'

  # Act
  run "${LIVE}" --members-dir "${DIR}"

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"bound"$'\t'"prefix:Up"$'\t'"${FIRST}"* ]]
}

@test "live-keys - a root key KEYS.md declares for its member is an override" {
  # Arrange
  printf 'bind-key -T root MouseDown1Status select-window -t =\n' >"${STUB}/keys/root"
  write_member tmux-reorder-revamped root 'bind-key -T root MouseDown1Status run-shell reorder'

  # Act
  run "${LIVE}" --members-dir "${DIR}"

  # Assert
  [ "${status}" -eq 0 ]
  [[ "${output}" == *"override"$'\t'"root:MouseDown1Status"$'\t'"tmux-reorder-revamped"* ]]
}

@test "live-keys - a declared root key taken by another member still steals" {
  # Arrange
  printf 'bind-key -T root MouseDown1Status select-window -t =\n' >"${STUB}/keys/root"
  write_member "${FIRST}" root 'bind-key -T root MouseDown1Status run-shell first'

  # Act
  run "${LIVE}" --members-dir "${DIR}"

  # Assert
  [ "${status}" -eq 1 ]
  [[ "${output}" == *"steals"$'\t'"root:MouseDown1Status"$'\t'"${FIRST}"* ]]
}
