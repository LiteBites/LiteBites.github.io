# Article Bite Validation Hardening

Use this checklist when changing `scripts/validate_article_bites.rb`, Article front matter, graph category behavior, or pre-publication tests.

## Adversarial metadata cases

A valid example is not enough. Add tests proving rejection of:

- whitespace-only required strings;
- numeric, boolean, empty, or whitespace-only tags;
- dates that are parseable but not exact `YYYY-MM-DD` values;
- non-HTTPS or malformed canonical and additional-source URLs;
- canonical `source_url` absent as an exact link destination under `## Sources`, including visible-text, prefix/suffix, and query-wrapper false positives;
- missing, duplicated, reordered, or extra level-two headings;
- unresolved `TODO` or `TBD` markers;
- bodies outside 400–800 words;
- `card_image` without non-empty alt text;
- `card_image` traversal such as `/assets/images/articles/../../...`;
- remote Markdown images, unquoted/entity-encoded remote markup that does not render as an inspectable image, or remote `<img>` elements outside `remote-publisher-image` figures;
- remote figures with anything other than exactly one `<img>`, or missing HTTPS `data-source-url`, exact source/full-resolution caption links, intrinsic dimensions, descriptive alt text, lazy/async loading, or image-request `no-referrer`;
- `<picture>`, `<source>`, or remote `srcset` variants and remote figure source pages absent as exact link destinations under `## Sources`.

Render the configured Markdown dialect and inspect its HTML with an HTML5 parser. Regex pre-scans may be used only as defense in depth for malformed raw markup that the renderer escapes; they must not be the primary detector for remote elements or source-link membership.

Canonicalize a local image candidate before checking its prefix and existence. A raw `start_with?` check before path normalization can accept `..` traversal.

## Graph category ordering

Do not alphabetically sort content types when the product order is semantic. Use an explicit rank:

```text
article: 0
paper: 1
dataset: 2
```

Apply it to every user-visible category surface, including navigation, filters, legends, accessible directories, and fallback content. Sorting labels with `localeCompare` produces Article, Data, Paper and violates the intended order.

## Accessibility checks

- Give related filter and view controls `role="group"` with accessible labels.
- Do not describe an SVG as a static image when it contains keyboard-focusable button nodes; expose it as an interactive group.
- Test keyboard node selection, filter state, no-JavaScript fallback, visible focus, and shape-based type distinctions.

## Review freshness

An asynchronous review describes the exact tree it inspected. If any file changes after dispatch—even to fix findings—the verdict is stale. Re-run tests and dispatch a fresh independent review against the current tree. Do not report the earlier verdict as approval.

For untracked implementation files, tell the reviewer to inspect those paths explicitly; `git diff` alone omits them.

## Fresh independent publication-readiness re-review

When asked to confirm that prior blockers are resolved, do not merely repeat the previous review. Re-open the current Article, policy, evidence ledger, and live canonical/supporting sources, then test each named correction against the exact current prose. For agent-product Articles, explicitly re-check timeline separation, launch tiers versus current documented choices, privacy-policy scope, exact connector/channel enumerations, and provider attribution.

Keep the review read-only. Run the Article validator and `git diff --check`, then enumerate staged, unstaged, and untracked paths separately so a nominal “three-file scope” or similar boundary is proven rather than inferred from `git diff` alone. Re-check status after validators/tests to prove the reviewer did not change scope. Verify all cited URLs resolve and inspect their live content; a saved ledger is context, not current-source proof.

Audit evidence classification at clause level, especially in the opening identity sentence. Artifact evidence can establish architecture, modalities, configuration, or license, but it does not by itself establish historical priority such as “first,” “only,” or “largest.” If the ledger classifies any part of a sentence as a provider claim, the published prose must attribute that part even when adjacent clauses are independently or artifact-supported.

Test graph determinism in an isolated temporary repository copy so the review cannot mutate the working tree. Run the generator twice, require both runs to report zero changed sources, and compare hashes before, after run one, and after run two. If the user literally forbids creating or modifying **any** files, do not create even a temporary checkout and do not run mutating generators; perform read-only JSON integrity checks instead and explicitly report determinism as not re-exercised. Separately parse both graph JSON files and check:

- exactly one expected Article node and exact public URL;
- duplicate node IDs and dangling edge endpoints;
- node and edge counts;
- absence of private authoring fields such as `sourcePath`, `sourceHash`, and `topicWeights` from public JSON.

Finish with a machine-readable verdict when requested. Use the caller’s exact keys; for the common fidelity-review shape include `passed`, `blocking_issues`, `nonblocking_notes`, `claim_checks`, and `files_observed` (or `verified_corrections` for a correction-specific re-review). Keep it compact and JSON-like, make `passed` false whenever `blocking_issues` is non-empty, identify issue locations precisely, and distinguish intended repository scope from policy/ledger review inputs. Keep intentional caveats—such as provider-only evidence—as nonblocking only when the Article states and attributes them accurately. State whether the reviewer created or modified any files and preserve the publication boundary: review success is not authorization to commit or push.
