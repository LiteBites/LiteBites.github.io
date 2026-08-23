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

# Prefer the Homebrew Ruby used by this project when it is available,
# without hard-coding an Intel- or Apple-Silicon-specific Homebrew path.
if command -v brew >/dev/null 2>&1; then
  if ruby_prefix="$(brew --prefix ruby@3.1 2>/dev/null)"; then
    export PATH="${ruby_prefix}/bin:${PATH}"
  fi
fi

if ! command -v ruby >/dev/null 2>&1 || ! command -v bundle >/dev/null 2>&1; then
  printf 'Ruby and Bundler are required. Install Ruby 3.1 and Bundler, then retry.\n' >&2
  exit 1
fi

TMP_ROOT="${TMPDIR:-/tmp}"
if [[ "$TMP_ROOT" != "/" ]]; then
  TMP_ROOT="${TMP_ROOT%/}"
fi
read -r REPO_KEY _ <<< "$(printf '%s' "$ROOT_DIR" | cksum)"
CACHE_ROOT="${TMP_ROOT}/litebites-preview-${REPO_KEY}"
DESTINATION="${CACHE_ROOT}/site-${PORT}"

mkdir -p "$CACHE_ROOT"
cp "$ROOT_DIR/Gemfile" "$CACHE_ROOT/Gemfile"

export BUNDLE_GEMFILE="${CACHE_ROOT}/Gemfile"
export BUNDLE_PATH="${CACHE_ROOT}/ruby-bundle"

cd "$ROOT_DIR"

printf 'LiteBites preview setup\n'
printf '  Ruby:  %s\n' "$(ruby --version)"
printf '  URL:   http://%s:%s/\n' "$HOST" "$PORT"
printf '  Build: %s\n' "$DESTINATION"
printf '  Stop:  press Ctrl+C in this terminal\n\n'

bundle check || bundle install

bundle exec jekyll serve \
  --source "$ROOT_DIR" \
  --host "$HOST" \
  --port "$PORT" \
  --destination "$DESTINATION"
