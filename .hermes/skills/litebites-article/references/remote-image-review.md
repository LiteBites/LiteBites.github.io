# Remote Publisher Image Review

`POLICY_REMOTE_IMAGES.md` is the authority for whether a publisher-hosted image may be embedded (admission, permission standard, required markup, privacy disclosure, failure behavior). The validator enforces the markup contract. This reference collects the verification judgment that neither the policy nor the validator can check. It applies to any Bite type that embeds a remote figure, and to independent reviews of one.

## Verify the exact asset

- **Exact-use provenance.** Inspect the canonical page's live DOM, not raw HTML search. Lazy loaders may put the URL in `data-src` or `srcset`; resolve relative references against the page URL before comparing. Record the exact `src`/`currentSrc`. If several candidate URLs appear, hash the payloads to detect aliases before treating them as distinct figures.
- **Payload, not filename.** Fetch the asset; record HTTP status, content type, decoded format, byte size, pixel dimensions, and SHA-256 (plus repository blob SHA when available, so later upstream mutation is detectable). A `.png` URL may serve JPEG bytes. Declared `width`/`height` must equal decoded dimensions.
- **Publisher control.** A plausible hostname is weak evidence. Prefer the canonical page's exact reference plus matching organization namespaces and repository metadata when page and asset live on different services.
- **Caption fidelity.** Compare the publisher's caption/alt with yours; adaptation is fine, changed meaning is not.

## Repository-backed assets (GitHub raw, model-card images)

- Establish that the documentation namespace and the asset repository belong to the same organization.
- Resolve permission at the layer that actually contains the file: a model-weights license or a hosting platform's inferred badge does not automatically govern documentation artwork. Check per-file notices. Link the governing license and preserve required copyright notices when the policy calls for it.
- Canonical pages often reference a mutable default-branch `raw` URL. Keep that exact URL (pinning to a commit breaks exact-use provenance) unless the canonical page itself references a pinned URL. Disclose that the publisher may replace the asset.

## Presentation checks

- Build to a temporary destination and inspect generated HTML, not Markdown.
- In a real browser, scroll the lazy image into view before asserting `complete`, nonzero `naturalWidth`/`naturalHeight`, and the expected `currentSrc`; offscreen lazy images legitimately report zero.
- Check 320px, 375/390px, and desktop in light and dark themes; assert no horizontal overflow or console errors. If browser tooling lacks viewport control, use same-origin iframes at those widths (each iframe activates real media queries).
- Dense charts: keep them next to the prose that explains protocol differences, write alt text that summarizes structure and main pattern rather than transcribing numbers, and rely on the visible full-resolution link for mobile.
- Small portrait assets: compare intrinsic versus displayed size. If the site's full-width rule materially upscales them, use a reusable modifier class (for example `remote-publisher-image--portrait`) that caps and centers the figure; never download or enlarge the publisher file.
- Simulate failure by swapping the URL for a known 404: prose, alt, caption, provenance link, and full-resolution link must still carry the explanation, and the reserved aspect ratio must not overflow.
- Keyboard-focus the image link and caption links; measure caption contrast in both themes.

## Privacy wording

`referrerpolicy="no-referrer"` governs only the automatic image request. That request still exposes visitor IP, user agent, and timing to the publisher/CDN, and the surrounding links are separate navigations that may send a referrer. Never call an embed privacy-neutral; state the residual disclosure at the checkpoint.

## Ledgers and multi-Article migrations

- Keep a temporary admit/reject ledger: canonical page, exact asset URL, payload format and dimensions, provenance evidence, permission evidence or gap, editorial purpose, privacy host, mutability, decision. A useful-but-ineligible candidate is recorded, not forced in. It is normal for only one of several Articles to qualify.
- Migrate existing Articles one at a time: inventory the current figure, decide embed or no figure, remove stale markup and repository assets, search for lingering references, validate that file, then move on. Afterwards run the full `scripts/litebites check` and report a per-route rendered figure count so unexpected images or omissions are visible.

## Reviewer verdict

For an independent review, stay read-only: fingerprint `git status --porcelain=v1 -uall` before and after, and run anything that writes generated state (the graph generator) only in an isolated temporary copy. Inspect a script's argument handling before invoking it; a simple generator may ignore `--help` and regenerate. Return `passed`, `blocking_issues`, `nonblocking_notes`, `verification_evidence`, and `files_modified_by_reviewer`; `passed` is false whenever a blocking issue exists.

## After an approved push

A Pages build is not a deployment. Confirm the deploy for the pushed SHA, fetch the live Article with a cache-busting query, then scroll the live image into view and recheck natural dimensions and request success.
