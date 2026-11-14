#!/usr/bin/env bash
# Checks every Source's url and prints a Markdown report of the ones
# that don't answer 2xx/3xx. Report only: many vendors refuse automated
# clients (Cloudflare checks, 403s), so a failure here means "look at
# it", not "the link is dead". Uses curl's own user agent -- never a
# spoofed one.
#   scripts/check-links.sh > report.md   (exit 0 always; count on stderr)
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
broken=0
echo "| Source | URL | Result |"
echo "|---|---|---|"
while IFS= read -r -d '' f; do
  url="$(grep -m1 '^url:' "$f" | sed -E 's/^url:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/')"
  id="$(grep -m1 '^id:' "$f" | sed -E 's/^id:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/')"
  [ -z "$url" ] && continue
  code="$(curl -sS -L -o /dev/null -r 0-0 --max-time 30 -w '%{http_code}' "$url" 2>/dev/null || echo "error")"
  case "$code" in
    2??|3??) ;;
    *) broken=$((broken + 1)); echo "| \`$id\` | $url | $code |" ;;
  esac
  sleep 0.5
done < <(find "$ROOT/sources" -name '*.yaml' -print0 | sort -z)
echo "$broken source link(s) did not answer 2xx/3xx" >&2
