# Safe Local Jekyll Preview Lifecycle

Use this pattern when an editor wants a repeatable one-command preview without repository-local dependency/build artifacts.

## Launcher properties

A repository-owned `scripts/preview.sh` should:

- use `#!/usr/bin/env bash` and `set -euo pipefail`;
- derive the repository root from `BASH_SOURCE[0]`, so invocation works from any directory;
- bind to `127.0.0.1` by default and print the exact URL;
- accept an optional validated port, with a documented default;
- prefer a compatible Ruby via the available version manager rather than hard-coding one machine's Homebrew prefix;
- put a copied `Gemfile`, generated lockfile, `BUNDLE_PATH`, and Jekyll `--destination` under `${TMPDIR:-/tmp}`;
- key the temporary cache by repository and use a port-specific Jekyll destination;
- export `BUNDLE_GEMFILE` to the temporary copy so Bundler never creates, edits, or removes the repository lockfile;
- run `bundle check || bundle install` before `bundle exec jekyll serve`;
- print `Ctrl+C` as the normal stop method;
- never expose `0.0.0.0`, a LAN address, or a tunnel interface without fresh authorization.

A robust core is:

```bash
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="127.0.0.1"
RAW_PORT="${1:-${PORT:-4179}}"

usage() {
  printf 'Usage: %s [port]\n' "$0" >&2
  printf 'Port must be an integer between 1 and 65535 without leading zeros.\n' >&2
}

# Reject extra arguments and leading-zero forms before Bash arithmetic. Bare
# arithmetic after only a digits regex interprets 08/09 as invalid octal.
if (( $# > 1 )) || [[ ! "$RAW_PORT" =~ ^[1-9][0-9]{0,4}$ ]]; then
  usage
  exit 2
fi
PORT="$RAW_PORT"
if (( PORT > 65535 )); then
  usage
  exit 2
fi

TMP_ROOT="${TMPDIR:-/tmp}"
[[ "$TMP_ROOT" != "/" ]] && TMP_ROOT="${TMP_ROOT%/}"
read -r REPO_KEY _ <<< "$(printf '%s' "$ROOT_DIR" | cksum)"
CACHE_ROOT="$TMP_ROOT/site-preview-$REPO_KEY"
DESTINATION="$CACHE_ROOT/site-$PORT"
mkdir -p "$CACHE_ROOT"
cp "$ROOT_DIR/Gemfile" "$CACHE_ROOT/Gemfile"
export BUNDLE_GEMFILE="$CACHE_ROOT/Gemfile"
export BUNDLE_PATH="$CACHE_ROOT/ruby-bundle"

cd "$ROOT_DIR"
bundle check || bundle install
bundle exec jekyll serve \
  --source "$ROOT_DIR" \
  --host "$HOST" \
  --port "$PORT" \
  --destination "$DESTINATION"
```

Add a compatible-Ruby check around this core. A temporary `BUNDLE_GEMFILE` is safer than repository-lockfile cleanup: the generated lockfile lives beside the temporary Gemfile, so the launcher cannot delete a lockfile created concurrently by a user or another process. Preserve the temporary dependency cache between runs for fast restarts; rendered output remains separated by port.

## Verification

Before handing the launcher to the user:

1. `chmod 755 scripts/preview.sh` and run `bash -n` (plus `shellcheck` when available).
2. Verify zero, overflow, non-numeric, leading-zero (`08`/`09`), and extra-argument cases fail immediately with a usage message and nonzero status—before Bundler or Jekyll runs.
3. Start it from outside the repository to prove root resolution.
4. Fetch a representative rendered page from the printed URL.
5. Confirm the listener is exactly `127.0.0.1:<port>`.
6. Test real foreground shutdown through a PTY by sending `Ctrl+C`; verify exit and port closure.
7. While the server is running, confirm the repository's `Gemfile.lock` is neither created nor removed; verify the generated lockfile is beside the temporary `BUNDLE_GEMFILE` instead.
8. Confirm no new `Gemfile.lock`, `_site/`, `.bundle/`, or `vendor/` appears in the repository before, during, or after the run.
9. Keep the launcher uncommitted until publication is explicitly approved.

## Stale listener fallback

The user-facing fallback should be targeted:

```bash
lsof -nP -iTCP:4179 -sTCP:LISTEN
kill <specific-PID>
```

Do not recommend broad `killall ruby` or `pkill -f jekyll` commands because they can terminate unrelated work.
