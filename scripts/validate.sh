#!/usr/bin/env bash
# Validates every Part in this dataset against its Device, Package and
# the dataset's Sources, in one `openparts validate --data` run (which
# also reports files that fail to load).
#
# OPENPARTS_CLI overrides the command (e.g. a prebuilt
# ../openparts/target/debug/openparts); by default the sibling
# openparts checkout is built and run with cargo.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="${OPENPARTS_CLI:-cargo run --manifest-path "$ROOT/../openparts/Cargo.toml" -q -p openparts-cli --}"

exec $CLI validate --data "$ROOT"
