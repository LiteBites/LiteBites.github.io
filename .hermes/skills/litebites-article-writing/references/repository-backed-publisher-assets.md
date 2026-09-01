# Repository-Backed Publisher Assets

Use this checklist when a publisher's canonical article or model card references an image hosted from the publisher's official source-code repository. This is a reusable evidence path for remote Article figures; it is not automatic permission for arbitrary repository images.

## Admission test

Admit the asset only when every item passes:

1. **Official identity:** establish that the documentation/model-card namespace and the source repository are controlled by the same publisher or authoring organization.
2. **Exact-use evidence:** the canonical publisher page contains the exact remote image URL proposed for the Article. Similar filenames, mirrors, search results, and manually constructed URLs do not count.
3. **Asset-level permission:** the repository has a compatible license covering the image file, with no per-file notice or third-party attribution that overrides it. A model-weights license does not automatically license documentation artwork; inspect the repository that actually contains the asset. Link the exact governing license from the Article and preserve any copyright/notice language required by that license. If the publisher's general website terms conflict with a specific repository license, document why the repository license governs that exact asset rather than silently choosing the more convenient terms.
4. **Source contract:** use the canonical publisher page as `data-source-url`, and include that exact destination under `## Sources`.
5. **Publisher-hosted request:** the `img src` must remain on infrastructure controlled by the publisher or its official repository account. Do not substitute an image proxy, search CDN, or copied local file.
6. **Editorial value:** the figure must explain a mechanism, result, interface, or caveat. Reject logos, hero art, and promotional product photography unless they materially support the analysis.

A visible “download” button or press gallery is not reuse permission by itself. If site terms prohibit public display or permission remains ambiguous, fail closed and keep prose plus a normal source link.

## Mutable branch URLs

Canonical pages often reference `raw` URLs on a mutable default branch. Preserve the exact referenced URL rather than silently replacing it with a commit-pinned URL, because changing it breaks exact-use provenance. Record that the publisher may replace or remove the asset, retain the Article's full meaning in prose, and include a visible full-resolution link.

Use a commit-pinned asset only when the canonical publisher page itself references that pinned URL or another authoritative record ties that exact revision to the published figure.

## Dense benchmark figures

A dense benchmark chart can be worthwhile when it makes a methodological caveat concrete—for example, showing mixed ordering across several vendor-run evaluations. Apply all of these safeguards:

- place it next to the prose that explains protocol differences and uncertainty;
- do not imply that heterogeneous benchmarks form one controlled ranking;
- write alt text that summarizes the chart's structure and main pattern rather than transcribing every number;
- provide a full-resolution link for labels that become small on narrow screens;
- verify desktop light/dark rendering and at least a 320 px viewport;
- confirm that width/height preserve layout when loading fails and that the caption still explains why the figure matters.

## Portrait and low-resolution assets

The site-wide Article image rule may expand every image to the full content width. For a small portrait source, this can turn a technically valid embed into a blurry, visually dominant block.

- Compare intrinsic dimensions with actual desktop and mobile display dimensions.
- If the asset is materially upscaled, add a reusable semantic modifier such as `remote-publisher-image--portrait` and cap its figure width in site CSS; center the figure and retain `max-width: 100%` behavior on narrow screens.
- Rebuild after CSS changes, then inspect desktop light/dark, approximately 320 px, caption wrapping, and broken-image layout.
- Do not download or enlarge the publisher image to solve presentation; preserve the canonical remote asset.

## Audit record

When updating several existing Articles, keep a temporary admission ledger with one decision per candidate: admit or reject, exact source page, exact asset URL, publisher-control evidence, permission evidence, editorial purpose, dimensions, privacy host, mutability, and rejection reason. It is valid—and often correct—for only one of many Articles to receive a figure.
