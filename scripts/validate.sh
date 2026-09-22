#!/usr/bin/env bash
# Data PR validation (Testing and Quality Specification section 12):
# resolves every Part's device/package/sources references by `id:` and
# runs `openparts validate` against each triple.
#
# This is a best-effort grep-based YAML reader, not a real parser -- it
# is good enough for CI because Canonical Data Specification section 3.2
# asks for simple YAML (no anchors/aliases/multi-line flow), so `id:`,
# `device:`, `package:` and list items under `sources:` are always on
# their own line. It is not a substitute for openparts-validator, which
# does the real structural/semantic validation.
#
# Usage: scripts/validate.sh
# Env:   OPENPARTS_CLI - command to invoke the CLI (default: builds and
#        runs it from a sibling ../openparts checkout).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLI="${OPENPARTS_CLI:-cargo run --manifest-path "$ROOT/../openparts/Cargo.toml" -q -p openparts-cli --}"

extract_field() {
  # extract_field <file> <field-name>
  grep -m1 "^${2}:" "$1" | sed -E "s/^${2}:[[:space:]]*\"?([^\"[:space:]]+)\"?.*/\1/"
}

declare -A ID_TO_PATH
while IFS= read -r -d '' f; do
  id="$(extract_field "$f" id)"
  if [[ -n "$id" ]]; then
    ID_TO_PATH["$id"]="$f"
  fi
done < <(find "$ROOT/devices" "$ROOT/packages" "$ROOT/sources" -name '*.yaml' -print0 2>/dev/null)

status=0
part_count=0

while IFS= read -r -d '' part; do
  part_count=$((part_count + 1))
  device_id="$(extract_field "$part" device)"
  package_id="$(extract_field "$part" package)"
  device_path="${ID_TO_PATH[$device_id]:-}"
  package_path="${ID_TO_PATH[$package_id]:-}"

  if [[ -z "$device_path" || -z "$package_path" ]]; then
    echo "FAIL $part: could not resolve device (\"$device_id\") or package (\"$package_id\") to a file"
    status=1
    continue
  fi

  source_args=()
  in_sources=0
  while IFS= read -r line; do
    if [[ "$line" =~ ^sources: ]]; then
      in_sources=1
      continue
    fi
    if [[ $in_sources -eq 1 ]]; then
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.+)$ ]]; then
        src_id="${BASH_REMATCH[1]}"
        src_id="${src_id%\"}"
        src_id="${src_id#\"}"
        src_path="${ID_TO_PATH[$src_id]:-}"
        if [[ -n "$src_path" ]]; then
          source_args+=(--source "$src_path")
        else
          echo "WARN $part: source \"$src_id\" not found under sources/"
        fi
      else
        in_sources=0
      fi
    fi
  done < "$part"

  echo "Validating $part"
  if ! $CLI validate --part "$part" --device "$device_path" --package "$package_path" "${source_args[@]}"; then
    status=1
  fi
done < <(find "$ROOT/parts" -name '*.yaml' -print0)

echo "Checked $part_count part(s)."
exit $status
