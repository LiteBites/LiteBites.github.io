# shellcheck shell=bash
# Shared Jekyll environment for scripts/preview.sh and scripts/build.sh.
# Expects ROOT_DIR and CACHE_SUFFIX to be set by the caller. Exports
# BUNDLE_GEMFILE/BUNDLE_PATH and DESTINATION, keeping every generated file
# outside the repository (no Gemfile.lock, .bundle/, or _site/ in the tree).

export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

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
DESTINATION="${CACHE_ROOT}/site-${CACHE_SUFFIX}"

mkdir -p "$CACHE_ROOT"
cp "$ROOT_DIR/Gemfile" "$CACHE_ROOT/Gemfile"

export BUNDLE_GEMFILE="${CACHE_ROOT}/Gemfile"
export BUNDLE_PATH="${CACHE_ROOT}/ruby-bundle"

bundle check >/dev/null 2>&1 || bundle install
