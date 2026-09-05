# LiteBites local Article pipeline

`litebites_pipeline.py` moves repetitive source work out of the LLM loop. It is intentionally a **pre-drafting** tool: it does not invent claims or write an Article. It fetches a source once, caches the raw bytes, extracts a compact evidence bundle, inventories candidate publisher images, and produces a review packet for the drafting/review agents.

## Cache location

The default cache is outside the repository:

```text
$XDG_CACHE_HOME/litebites/
# or, when XDG_CACHE_HOME is unset:
~/.cache/litebites/
```

Override it with `LITEBITES_CACHE_DIR` or `--cache-dir`. Never move this cache under the Git repository. Each source entry contains:

```text
<24-char URL hash>/
  source.bin          # exact fetched bytes
  metadata.json       # fetch time and transport metadata
  evidence.json       # deterministic structured extraction
  review-input.md     # compact packet for an LLM/subagent
```

`evidence.json` intentionally excludes fetch time, so it is byte-stable for unchanged source bytes. `metadata.json` retains fetch time for cache inspection.

## Commands

Collect or reuse a source:

```bash
python3 scripts/litebites_pipeline.py collect \
  https://example.com/technical-announcement
```

Force a fresh fetch:

```bash
python3 scripts/litebites_pipeline.py collect \
  --refresh \
  --cache-dir /tmp/litebites-cache \
  https://example.com/technical-announcement
```

Validate the cached source hash and deterministic evidence bundle:

```bash
python3 scripts/litebites_pipeline.py validate \
  ~/.cache/litebites/<entry>/evidence.json
```

Regenerate the compact review packet after a local evidence edit:

```bash
python3 scripts/litebites_pipeline.py review-input \
  ~/.cache/litebites/<entry>/evidence.json
```

The `collect` command prints JSON containing the cache entry, source hash, extracted title, image-candidate count, and review-packet path. A repeated call reuses the cache and reports `"cached": true`; it does not make another network request.

## Pipeline boundary

```text
collect → evidence.json + review-input.md → one drafting call → local Article validator
                                                   ↓
                                    parallel claim/editorial/image reviews
                                                   ↓
                                    targeted revision only when required
                                                   ↓
                                  graph generation, build, visual checkpoint
```

Local collection is deterministic but incomplete. A model or reviewer must still read the canonical source for consequential claims, corroborate where possible, and complete the Tier A image admission record before embedding any image. Extracted image candidates are leads, not approvals.

## Safety and limits

- Only absolute HTTP(S) URLs are accepted.
- Redirects are recorded in `final_url`; the original requested URL remains in the bundle.
- Responses are capped at 12 MiB.
- The cache stores exact bytes and SHA-256 hashes.
- HTML parsing is deliberately lightweight and dependency-free; it is not a substitute for browser inspection or source recovery for dynamic pages.
- The tool never calls an LLM, modifies `_articles/`, modifies the graph, installs dependencies, or creates `Gemfile.lock`.
- Do not treat `text_excerpt`, extracted dates, or image candidates as verified claims without checking the canonical source.
