#!/usr/bin/env bash
# Re-writes every data file in the canonical schema 0.2 layout
# (`openparts data fmt`); `./scripts/fmt.sh --check` only lists the
# files that are not formatted and fails if there are any (CI).
#
# OPENPARTS_CLI overrides the command, as in validate.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="${OPENPARTS_CLI:-cargo run --manifest-path "$ROOT/../openparts/Cargo.toml" -q -p openparts-cli --}"

exec $CLI data fmt "$@" "$ROOT"
