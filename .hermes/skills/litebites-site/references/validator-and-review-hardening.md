# Validator and Review Hardening

Use when changing `_data/bite_schema.yml`, `scripts/validate_bites.rb`, the graph generator, or adding a content family, and when acting as an independent reviewer of such a change.

## Adversarial validator cases

One valid fixture proves little. Add tests (with temporary Markdown fixtures) that must be rejected:

- whitespace-only required strings; numeric, boolean, empty, or whitespace-only tags;
- dates that parse but are not exact `YYYY-MM-DD`;
- non-HTTPS or host-less URLs;
- the canonical source URL present only as visible text, a prefix/suffix, or a query-parameter substring of another link under `## Sources` (require exact normalized link-destination membership, never substring matching);
- missing, duplicated, reordered, or extra headings where the schema fixes them;
- unresolved `TODO`/`TBD`; bodies just outside the word range;
- `card_image` without alt text, or with traversal (`/assets/images/articles/../../x`): canonicalize the path *before* checking prefix and existence;
- remote images: Markdown image forms the renderer turns into `<img>` (including reference-style `![Label]` + `[Label]: https://…`), unquoted attributes (`src=https://…`), entity-encoded schemes (`https&#58;//`), a compliant figure that also contains a second local `<img>`, and any `<picture>`, `<source>`, or `srcset`.

Detect remote elements by rendering with the configured Markdown dialect and parsing the HTML with an HTML5 parser. Regex pre-scans are defense in depth only. Every demonstrated bypass becomes a permanent regression test. Validator error messages should say how to fix the problem.

## Adding a content family

Give it its own collection, layout, archive page, policy, schema entry, and graph node type (`<type>:<slug>`) instead of mixing it into `_posts/` (which would break Paper Bite previous/next). Keep the explicit Article, Paper, Data(, …) order on every surface. Work in test-first slices: collection registration and order → validator rules → graph integration in a temporary copy → browser checks. If the collection starts empty, keep an honest empty state; to exercise the detail layout, copy the repo to a temporary directory (excluding `.git`, `.hermes`, lockfiles, build output), add a labelled fixture there, and run validate, graph, build, and browser checks in that copy only.

## Independent review gate

- Review the complete uncommitted surface: list staged, unstaged, and untracked paths separately (`git status --porcelain=v1 -uall`) and read untracked files directly. A staged change makes plain `git diff` empty; untracked layouts, validators, and tests never show in it.
- Stay read-only. Fingerprint the status output before and after. Run anything that writes (graph generator, builds into the repo) only in an isolated copy. Inspect a script's argument handling before calling it with `--help`.
- Source-string assertions do not replace browser behaviour: run at least one rendered-DOM or browser check for ordering, filtering, and keyboard interaction.
- Clause-level evidence audit: artifact evidence can establish architecture, configuration, or license but not historical priority ("first", "only", "largest"). If the ledger marks part of a sentence as a provider claim, the prose must attribute that part.
- HTTP 200 shows a link is available, not that it supports the claim.
- A review describes the exact tree it saw. If anything changes afterwards, even fixes for its findings, re-run checks and request a fresh review.
- When a machine-readable verdict is requested, emit exactly the requested keys (commonly `passed`, `blocking_issues`, `nonblocking_notes`, `claim_checks` or `verification_evidence`, `files_modified_by_reviewer`). Fail closed: `passed` is false whenever a blocking issue exists. Review success never authorizes commit or push.
