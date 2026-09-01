# Remote image embedding review

Use this checklist when a LiteBites Article renders an optional publisher-hosted original instead of storing a repository copy. The goal is a fail-closed local publication verdict, not merely confirmation that the Markdown looks plausible.

## Scope and policy

1. Review the complete working-tree scope: staged, unstaged, and untracked files.
2. Confirm the feature stays narrow: an informative image, HTTPS, exact canonical-page provenance, publisher media infrastructure, inline use only, and never `card_image`. Require the validator-enforced `remote-publisher-image` and `data-source-url` contract; reject remote Markdown image syntax and `srcset`.
3. Require the prose to explain the useful content without the image. A remote asset is mutable and may disappear.
4. Treat the third-party request as an explicit privacy tradeoff. `referrerpolicy="no-referrer"` removes the page referrer but does not hide the visitor IP address, user agent, or request timing from the publisher/CDN.
5. When reviewing an admission/rejection ledger, independently test both sides. An admission needs complete positive evidence; a rejection is correct when restrictive terms are found or compatible permission remains unresolved after checking the canonical source, likely asset host, and publisher terms. Do not weaken a fail-closed rejection merely because an asset is technically accessible, useful, or publisher-hosted.
6. If no original-source candidate is admissible, require no inline image. Reject screenshots, downloaded publisher copies, and locally created presentation substitutes unless the user separately and explicitly requested an original visualization.

## Origin, permission, and asset verification

- Inspect the canonical publisher page itself. Confirm that its live DOM references the exact remote media URL; lazy-loading implementations may store it in `data-src` or `srcset` rather than `src`. Resolve relative DOM references against the canonical page URL before comparing them with an absolute proposed asset URL—a byte-for-byte search of raw HTML can otherwise produce a false rejection.
- Compare the publisher's figure caption and alt text with the proposed embed. Adaptation is acceptable, but provenance and meaning must remain accurate.
- Inspect the publisher's live terms, robots/access behavior, and any asset-specific media guidance. Record the exact controlling language or permission evidence. A technically accessible image is not automatically licensed for public embedding; if public display or reuse is prohibited or permission remains unclear, fail closed and use a descriptive source link unless written or asset-specific permission is available.
- Resolve permission at the asset's controlling layer. A model card's license metadata does not necessarily govern an image stored in a separate repository; inspect the asset repository's license and notices directly. Record the operative grant (for example, an express right to publicly display), relevant conditions, and whether embedding triggers redistribution obligations. Do not rely only on a hosting platform's inferred license badge.
- When the canonical page and asset repository use separate services, corroborate publisher control through matching organization namespaces, live canonical-page use of the exact asset URL, repository metadata, and the asset blob/path. This combined evidence is stronger than hostname resemblance alone.
- Fetch the asset directly and verify HTTP success, HTTPS, media content type, decoded file type, byte size, actual pixel dimensions, content SHA-256, and—when available—repository blob SHA. These identifiers make later upstream mutation detectable even when the public URL follows a mutable branch.
- Confirm the declared HTML `width` and `height` match the decoded dimensions.
- Do not infer publisher ownership from a plausible-looking hostname alone; the canonical page's exact asset reference is stronger evidence.

## Multi-Article migration reviews

When reviewing several existing Articles against an original-source-URL-or-skip migration, classify every Article explicitly as either **admitted remote original** or **image-free skip**; do not review only the files that still contain figures.

- For admitted figures, apply the full origin, permission, intrinsic-dimension, rendered-output, privacy, and failure checks independently to each asset.
- For image-free outcomes, search the Article, front matter, layouts, CSS/data references, and complete tracked/untracked tree for the removed filename and asset directory. Require zero rendered images and coherent prose that does not refer readers to a missing figure.
- Check every retained canonical and supporting source link. HTTP success is useful availability evidence but does not establish permission or ownership.
- Build all reviewed Articles together and report a per-Article rendered image/figure count so omissions and unexpected discovery-surface images are visible.
- Run source-hash/generator checks only in an isolated copy, twice, and compare both graph files byte-for-byte.
- Fingerprint the complete `git status --porcelain=v1 -uall` before and after review. A matching digest is concise evidence that a read-only review did not alter pre-existing staged, unstaged, deleted, or untracked work.

## Validator bypass-resistance checks

Do not infer fail-closed behavior from the happy-path fixture or from regex coverage alone. Before approving a remote-image validator, generate temporary adversarial Article fixtures and require rejection of:

- unquoted remote attributes such as `<img src=https://tracker.example/pixel.webp>`;
- entity-encoded schemes such as `src="https&#58;//tracker.example/pixel.webp"`;
- every Markdown image form that the configured renderer turns into a remote `<img>`, including shortcut reference syntax (`![Label]` plus `[Label]: https://…`);
- a compliant remote figure containing a second local `<img>`—the policy requires exactly one `<img>`, not merely one remote `<img>`;
- `<picture>`, `<source>`, or any `srcset` descendant, regardless of whether one candidate is local;
- a canonical source URL present only as visible text, a prefix/suffix, or a query-parameter substring of another destination.

Prefer parsing the renderer's resulting HTML with an HTML5 parser and inspecting actual elements and attributes. If a regex pre-scan remains, treat it only as defense in depth: HTML quoting, entities, and Markdown reference resolution make regex-only remote-element discovery bypassable. Extract source-section link destinations and require exact normalized URL membership rather than substring checks. Add each demonstrated bypass to the permanent regression suite.

When raw HTML contains visible caption text, report both the validator's count and a count with the complete figure removed. This proves that the Article remains within its editorial word range regardless of whether the counting policy includes rendered caption text.

## Rendered-output checks

Build Jekyll to a temporary destination outside the repository and inspect generated HTML, not only source Markdown. Keep Bundler metadata outside the checkout as well: copy `Gemfile` to a task-specific temporary directory, set `BUNDLE_GEMFILE` to that copy, and set `BUNDLE_PATH` there before running `bundle exec jekyll build`. A temporary Jekyll destination alone is insufficient because Bundler may still create `Gemfile.lock` beside the repository `Gemfile`. Record the initial untracked-file set; if a lockfile is accidentally created, remove it only when it was absent initially, then prove the final untracked set matches the initial snapshot.

For local SVG syntheses, inspect both the Article's rendered `<img alt>` and the SVG source's own `<title>`, `<desc>`, and visible `<text>` nodes. A blocker correction can be complete in prose, caption, visible labels, and HTML alt text while stale or overclaimed language remains in the SVG's embedded accessibility metadata. Parse each SVG as XML, reject scripts or unexpected external/embedded-image references, and require all accessible-text layers to preserve the same attribution and evidentiary boundary.

Verify:

- one semantic `<figure>` in the intended location;
- descriptive, non-promotional alt text;
- a source-linked `<figcaption>` and a clear full-resolution destination;
- `loading="lazy"`, intrinsic dimensions, and, when requested, `decoding="async"` and `referrerpolicy="no-referrer"`;
- valid HTML parsing with no structural errors;
- no remote image in card/index metadata.

Serve the temporary build and scroll the image into view before checking `naturalWidth` and `naturalHeight`; a lazy image can correctly report zero dimensions while still outside the loading threshold.

For browser tooling without viewport controls, create same-origin iframes at 320px and 375px widths. Each iframe has its own browsing context and therefore activates real media queries. Compare `scrollWidth` with `clientWidth`, and inspect image, figure, and caption rectangles. Also test desktop and both themes.

Simulate failure by replacing the rendered image URL with a known 404. Confirm that explanatory prose, alt text, caption, provenance link, and full-resolution link remain, and that the reserved intrinsic aspect ratio does not create horizontal overflow.

## Accessibility and privacy interpretation

- Check keyboard focus on the linked image and caption links.
- Measure caption contrast in both themes. Report a pre-existing shared-style failure separately, but do not hide it merely because the revision did not edit CSS.
- Distinguish auto-load privacy from click-through privacy: an image referrer policy governs the image request; an ordinary destination link can still send a referrer unless navigation policy says otherwise.
- A remote image cannot be called privacy-neutral. The correct verdict is that the residual third-party disclosure is inherent and explicitly accepted by the exception.

## Knowledge graph and repository hygiene

Keep the review strictly read-only. Before invoking any repository script, inspect whether it parses or ignores command-line arguments; do not assume `--help` is side-effect-free. Simple generators may ignore unknown arguments and perform a real generation, so even a help probe can mutate tracked state.

Before any potentially mutating check, record the working-tree status and exact hashes or copies of affected generated files. Run generators only in an isolated temporary checkout populated with the proposed files—never in the review target. If an accidental mutation occurs, restore the exact pre-review bytes before continuing, disclose the incident, and verify the restoration independently; do not silently retain a generated “fix,” because a reviewer is not authorized to edit the submission.

If source hashing updates graph state:

1. Compare every stored state hash with its edited source's SHA-256 before generation; report a mismatch as a publication blocker rather than repairing it in place.
2. Run the graph generator twice in an isolated temporary checkout populated with the proposed files.
3. Require zero changed sources on the second run and byte-identical public graph output when only prose/raw HTML changed.
4. Remove any lockfile or generated artifact created during validation, then re-run `git status`, `git diff --check`, and the untracked-file check. Require the final working-tree snapshot to match the pre-review snapshot byte-for-byte except for changes that already existed when review began.

## Verdict format

Return a concise fail-closed report with:

- `passed`;
- `blocking_issues`;
- `nonblocking_notes`;
- concrete `verification_evidence`;
- `files_modified_by_reviewer`.

A remote-image review passes only when origin, dimensions, provenance, rendered behavior, failure behavior, responsive layout, privacy implications, graph state, and repository hygiene have all been checked. Never commit or push as part of the local checkpoint review.