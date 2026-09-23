#!/usr/bin/env bash

[[ -n "${_FAMILY_COMMON_LOADED:-}" ]] && return 0
_FAMILY_COMMON_LOADED=1

family_root() {
	local dir
	dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
	printf '%s\n' "${dir}"
}

family_die() {
	printf 'error: %s\n' "${1}" >&2
	exit 1
}

family_warn() {
	printf 'warning: %s\n' "${1}" >&2
}

family_hash_command() {
	if command -v sha256sum >/dev/null 2>&1; then
		printf 'sha256sum\n'
	elif command -v shasum >/dev/null 2>&1; then
		printf 'shasum -a 256\n'
	else
		return 1
	fi
}

family_hash_file() {
	local file="${1}"
	local cmd
	cmd="$(family_hash_command)" || family_die "no sha256 implementation on PATH"
	${cmd} "${file}" | awk '{print $1}'
}

family_strip_blank_and_hash_lines() {
	grep -vE '^[[:space:]]*(#|$)' "${1}"
}

family_version() {
	local root="${1}"
	local file="${root}/family/VERSION"
	[[ -f "${file}" ]] || return 1
	tr -d '[:space:]' <"${file}"
}

family_members() {
	local root="${1}"
	local file="${root}/family/MEMBERS"
	[[ -f "${file}" ]] || family_die "missing ${file}"
	family_strip_blank_and_hash_lines "${file}"
}

family_owned_paths() {
	family_paths_of_class "${1}" owned
}

family_shaped_paths() {
	family_paths_of_class "${1}" shaped
}

family_paths_of_class() {
	local root="${1}"
	local want="${2}"
	local file="${root}/family/OWNERSHIP"
	local class pattern
	[[ -f "${file}" ]] || family_die "missing ${file}"

	while IFS=$'\t' read -r class pattern; do
		[[ "${class}" == "${want}" ]] || continue
		family_expand_pattern "${root}" "${pattern}"
	done < <(family_strip_blank_and_hash_lines "${file}") | LC_ALL=C sort -u
}

family_pattern_is_glob() {
	case "${1}" in
	*'*'* | *'?'* | *'['*) return 0 ;;
	*) return 1 ;;
	esac
}

family_expand_pattern() {
	local root="${1}"
	local pattern="${2}"
	local match
	local found=0

	if family_pattern_is_glob "${pattern}"; then
		while IFS= read -r match; do
			found=1
			printf '%s\n' "${match}"
		done < <(cd "${root}" && find . -path "./${pattern}" -type f 2>/dev/null | sed 's|^\./||')
	elif [[ -f "${root}/${pattern}" ]]; then
		found=1
		printf '%s\n' "${pattern}"
	fi

	if [[ "${found}" -eq 0 ]]; then
		printf 'MISSING:%s\n' "${pattern}"
	fi
}

family_exception_exists() {
	local root="${1}"
	local repo="${2}"
	local path="${3}"
	local file="${root}/family/EXCEPTIONS.md"
	[[ -f "${file}" ]] || return 1
	grep -qF "### ${repo}: ${path}" "${file}"
}

family_repo_name() {
	basename "${1}"
}

family_unshallow_if_needed() {
	local dir="${1}"
	local shallow
	shallow="$(git -C "${dir}" rev-parse --is-shallow-repository 2>/dev/null || printf 'false\n')"
	[[ "${shallow}" == "true" ]] || return 0
	git -C "${dir}" fetch --unshallow --quiet 2>/dev/null || return 1
}
