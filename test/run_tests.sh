#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATS="${BATS:-bats}"

if ! command -v "${BATS}" >/dev/null 2>&1; then
  echo "bats-core is not installed. Install it with:" >&2
  echo "  brew install bats-core    (macOS)" >&2
  echo "  apt install bats          (Ubuntu)" >&2
  exit 1
fi

echo "Running test suite..."
echo ""

"${BATS}" --recursive "${SCRIPT_DIR}"
