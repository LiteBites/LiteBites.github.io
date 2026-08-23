# Remote image embedding review

Use this checklist when a LiteBites revision exceptionally embeds a publisher-hosted image instead of storing a local asset. The goal is a fail-closed local publication verdict, not merely confirmation that the Markdown looks plausible.

## Scope and policy

1. Review the complete working-tree scope: staged, unstaged, and untracked files.
2. Confirm the policy exception is narrow: explicit owner request, one named Bite, HTTPS, canonical publisher media infrastructure, inline use only, and never `card_image`.
3. Require the prose to explain the useful content without the image. A remote asset is mutable and may disappear.
4. Treat the third-party request as an explicit privacy tradeoff. `referrerpolicy="no-referrer"` removes the page referrer but does not hide the visitor IP address, user agent, or request timing from the publisher/CDN.

## Origin and asset verification

- Inspect the canonical publisher page itself. Confirm that its live DOM references the exact remote media URL; lazy-loading implementations may store it in `data-src` or `srcset` rather than `src`.
- Compare the publisher's figure caption and alt text with the proposed embed. Adaptation is acceptable, but provenance and meaning must remain accurate.
- Fetch the asset directly and verify HTTP success, HTTPS, media content type, decoded file type, byte size, and actual pixel dimensions.
- Confirm the declared HTML `width` and `height` match the decoded dimensions.
- Do not infer publisher ownership from a plausible-looking hostname alone; the canonical page's exact asset reference is stronger evidence.

## Rendered-output checks

Build Jekyll to a temporary destination outside the repository and inspect generated HTML, not only source Markdown. Verify:

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

If source hashing updates graph state:

1. Verify the state hash equals the edited source's SHA-256.
2. Run the graph generator twice in an isolated temporary checkout populated with the proposed files.
3. Require zero changed sources on the second run and byte-identical public graph output when only prose/raw HTML changed.
4. Remove any lockfile or generated artifact created during validation, then re-run `git status`, `git diff --check`, and the untracked-file check.

## Verdict format

Return a concise fail-closed report with:

- `passed`;
- `blocking_issues`;
- `non_blocking_notes`;
- concrete `verification_evidence`;
- `files_modified_by_reviewer`.

A remote-image review passes only when origin, dimensions, provenance, rendered behavior, failure behavior, responsive layout, privacy implications, graph state, and repository hygiene have all been checked. Never commit or push as part of the local checkpoint review.