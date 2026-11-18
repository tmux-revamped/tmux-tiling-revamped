#!/bin/sh
set -eu

version=${1:?version required}
root=$(cd "$(dirname "$0")/../.." && pwd)
constants="${root}/src/lib/utils/constants.sh"
pattern='^readonly [A-Z_]*(_REVAMPED|TMUX_PLUGIN_TEMPLATE)_VERSION="[0-9][0-9.]*"$'

case "${version}" in
*[!0-9.]* | .* | *. | *..*)
  printf 'not a release version: %s\n' "${version}" >&2
  exit 1
  ;;
*) ;;
esac

matches=$(grep -cE "${pattern}" "${constants}" || true)
if [ "${matches}" != 1 ]; then
  printf 'expected one version constant in %s, found %s\n' "${constants}" "${matches}" >&2
  exit 1
fi

tmp=$(mktemp "${constants}.XXXXXX")
sed -E "s/^(readonly [A-Z_]*(_REVAMPED|TMUX_PLUGIN_TEMPLATE)_VERSION=)\"[0-9.]*\"$/\\1\"${version}\"/" "${constants}" >"${tmp}"
mv -f "${tmp}" "${constants}"

grep -E "${pattern}" "${constants}"
