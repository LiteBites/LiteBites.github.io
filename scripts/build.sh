#!/usr/bin/env bash
# Build the site once into a temporary folder and print its path on the last
# line. Used by `scripts/litebites build` and `scripts/litebites check`.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CACHE_SUFFIX="build"
# shellcheck source=lib/jekyll_env.sh
source "$ROOT_DIR/scripts/lib/jekyll_env.sh"

cd "$ROOT_DIR"
bundle exec jekyll build --source "$ROOT_DIR" --destination "$DESTINATION" >&2
printf '%s\n' "$DESTINATION"
