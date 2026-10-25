#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="127.0.0.1"
RAW_PORT="${1:-${PORT:-4179}}"

if (( $# > 1 )); then
  printf 'Usage: %s [port]\n' "$0" >&2
  exit 2
fi

# Reject leading zeros so Bash cannot interpret the value as octal.
if [[ ! "$RAW_PORT" =~ ^[1-9][0-9]{0,4}$ ]]; then
  printf 'Usage: %s [port]\n' "$0" >&2
  printf 'Port must be an integer between 1 and 65535 without leading zeros.\n' >&2
  exit 2
fi

PORT="$RAW_PORT"
if (( PORT > 65535 )); then
  printf 'Usage: %s [port]\n' "$0" >&2
  printf 'Port must be an integer between 1 and 65535.\n' >&2
  exit 2
fi

CACHE_SUFFIX="$PORT"
# shellcheck source=lib/jekyll_env.sh
source "$ROOT_DIR/scripts/lib/jekyll_env.sh"

cd "$ROOT_DIR"

printf 'LiteBites preview setup\n'
printf '  Ruby:  %s\n' "$(ruby --version)"
printf '  URL:   http://%s:%s/\n' "$HOST" "$PORT"
printf '  Build: %s\n' "$DESTINATION"
printf '  Stop:  press Ctrl+C in this terminal\n\n'

bundle exec jekyll serve \
  --source "$ROOT_DIR" \
  --host "$HOST" \
  --port "$PORT" \
  --destination "$DESTINATION"
