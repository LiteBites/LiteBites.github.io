# First-party explanatory figures

Use this reference only when the user explicitly requests an original LiteBites visualization as a separate editorial deliverable. It is not a fallback for the normal Article Bite image workflow. When a publisher image cannot satisfy the remote-image admission contract, the default outcome is prose plus a normal canonical source link and no inline figure.

## Decision order

1. Prefer an informative publisher-hosted image only when exact origin, exact-use evidence, and compatible display permission are verified.
2. If permission is absent, restrictive, or ambiguous, do not hotlink, download, trace, crop, or closely redraw the publisher artwork; omit the Article figure.
3. Create a **first-party LiteBites synthesis** from cited facts or structured values only after the user separately and explicitly requests an original visualization.
4. If the explicit visualization would not add explanatory value, recommend prose rather than decorative art.

A general request to add figures across Articles does not activate this workflow. Confirm the separate original-visualization request before designing or storing a local asset.

## Suitable first-party visuals

- A workflow diagram synthesized from documented components and relationships.
- A capacity/bandwidth chart built from cited technical specifications.
- A system-boundary diagram separating models, orchestration, connectors, artifacts, and governance.
- An architecture summary built from model-card fields such as total/active parameters, expert routing, layer pattern, and context limits.

Do not reproduce the source's visual composition, icons, branding, typography, color system, or distinctive layout. Facts and functional relationships may be synthesized; artwork and expressive arrangement may not be copied without permission. Design from a written fact ledger rather than tracing or keeping the publisher figure open as a visual template.

Before publication, require an independent originality review whenever an official figure exists on the same topic. The reviewer should compare the LiteBites asset with the provider artwork and return a per-figure verdict covering copied expression, distinctive arrangement, branding, and factual fidelity. Shared boxes, arrows, or relationships that are functionally necessary are not by themselves a pass: the overall composition must still be independently designed. Use **“LiteBites synthesis”**, not “redraw,” unless the source license explicitly permits a derivative and the Article satisfies its attribution/share-alike terms.

## Asset and markup contract

Store the asset at:

```text
assets/images/articles/<slug>/<descriptive-name>.svg
```

Prefer a self-contained SVG with:

- a fixed `viewBox` and intrinsic `width`/`height`;
- a solid background that remains readable in light and dark site themes;
- system fonts only, with no external requests;
- `<title>` and `<desc>` inside the SVG;
- strong contrast, generous spacing, and legible labels at Article width;
- no scripts, foreign objects, embedded raster copies, third-party logos, or tracking.

Embed it with a normal local figure, not `remote-publisher-image`:

```html
<figure class="article-figure">
  <a href="{{ '/assets/images/articles/<slug>/<file>.svg' | relative_url }}">
    <img
      src="{{ '/assets/images/articles/<slug>/<file>.svg' | relative_url }}"
      width="1600"
      height="900"
      loading="lazy"
      decoding="async"
      alt="Describe the information and relationships, not the visual style.">
  </a>
  <figcaption>
    LiteBites synthesis from <a href="SOURCE-1">source one</a> and
    <a href="SOURCE-2">source two</a>; explain any compressed scale or interpretive boundary.
    <a href="{{ '/assets/images/articles/<slug>/<file>.svg' | relative_url }}">Open full resolution ↗</a>
  </figcaption>
</figure>
```

The caption must identify the graphic as a LiteBites synthesis. If the source has an original figure on the same topic, say explicitly that the LiteBites asset is an explanatory synthesis or redraw and not the publisher's original figure.

## Accuracy checks

- Trace every number and relationship to a linked source already under `## Sources`.
- Keep measured values, configuration ceilings, vendor claims, and interpretation visually distinct.
- Never use proportional bar heights without a truthful scale. If heights are compressed or schematic, disclose that inside the figure and caption; exact labels carry authority.
- Do not imply that active parameters equal checkpoint memory, maximum configuration equals base specification, or workflow boxes reveal undocumented internal architecture.
- Keep the Article understandable if the figure is removed.
- Re-run the 400–800-word validator after caption insertion.

## Verification

1. Parse every SVG as XML and ensure the Jekyll build copies it to the expected route.
2. Inspect the figure in the Article, not just as a standalone asset.
3. Check desktop, 320px, light, and dark rendering; require no horizontal overflow.
4. At mobile width, keep a visible full-resolution link when labels become small.
5. Replace the image source temporarily with a missing local path and verify intrinsic sizing, alt text, caption, and surrounding prose preserve a usable failure state.
6. Include new untracked asset paths explicitly in `git status`, independent-review scope, staging, and publication reporting.
7. Refresh graph source state after Article content changes even when public graph nodes and edges remain byte-identical.

## Checkpoint reporting

Report remote and first-party figures separately:

- Remote assets require publisher-request privacy and mutability disclosure.
- Local first-party assets require source provenance, synthesis disclosure, file hashes or paths, and confirmation that no third-party artwork was copied.
- Explain any Articles deliberately left without figures because neither route was useful or defensible.
