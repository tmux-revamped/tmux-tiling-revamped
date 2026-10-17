#!/usr/bin/env bats

setup() {
  REPO_DIR="${BATS_TEST_DIRNAME}/.."
}

@test "docs - every option the README documents is read by the plugin" {
  # Arrange
  local runtime_named="@tiling_revamped_enable_logging"
  local option missing=""

  # Act
  for option in $(grep -oE '@tiling_revamped_[a-z_]+' "${REPO_DIR}/README.md" | sort -u); do
    [[ "${option}" == "${runtime_named}" ]] && continue
    grep -rqF -- "${option}" "${REPO_DIR}/src" "${REPO_DIR}/tmux-tiling-revamped.tmux" \
      || missing="${missing} ${option}"
  done

  # Assert
  [[ -z "${missing}" ]]
}
