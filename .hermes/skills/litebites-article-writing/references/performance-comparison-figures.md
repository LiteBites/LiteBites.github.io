# Performance Comparison Figures for Article Bites

Use this reference when an Article Bite would benefit from a benchmark, performance, evaluation, or comparison graph.

## Disambiguate “graph” first

In LiteBites, “graph” can mean either:

- the site-wide knowledge graph; or
- a performance-comparison chart/graph image inside an Article.

Do not infer which one the user means from the word alone. If the surrounding request mentions figures, benchmark results, model comparisons, or a latest post, explicitly confirm that the requested artifact is a performance graph before proposing knowledge-graph work.

## Prefer a focused figure over a dense source collage

Source announcements often publish large multi-panel benchmark collages that become unreadable inside a 700px article column. Before choosing an asset:

1. Record the source image dimensions, file size, panels, legend, and protocol notes.
2. Match the figure scope to benchmarks actually discussed in the Article.
3. Reject panels that are unrelated to the Article merely because they are available.
4. Test text and legend readability at desktop, 390px, 375px, and 320px.
5. Preserve access to the complete source chart through a clearly labeled source link.

## Original source versus an explicitly requested replot

Do not prototype a local crop or replot automatically. Under the normal Article Bite image workflow, use the admissible canonical publisher-hosted original or omit the figure. Prototype crop/replot variants only when the user explicitly requests an original performance visualization as a separate editorial deliverable and the fidelity/legibility tradeoff matters.

### Original LiteBites replot

Use this only after that explicit separate request, particularly when the source figure is dense, logo-dependent, or illegible on mobile.

- Transcribe only visible, verified values.
- Obtain a second review of model labels, benchmark labels, bar ordering, and values before plotting.
- Use text model names; color or logos must not be the only identifiers.
- Keep benchmark-specific scales explicit.
- Mark the graphic prominently as vendor-reported when the source is a vendor announcement.
- Cite the source chart and describe the figure as “replotted by LiteBites.”
- Do not normalize, average, rank, or compare scores across different benchmarks unless the source and methodology justify it.

### Source-faithful crop

Use only when provenance/reuse is acceptable and the crop remains interpretable.

- Preserve benchmark titles, axes, values, and the original legend.
- Never crop away footnotes or context required to identify models and protocols.
- Disclose cropping, annotation, or recomposition in the caption.
- Link to the complete source image.
- If reuse rights are unclear, omit the figure from the Article and retain a normal link to the complete official chart. Do not fall back to a crop or local replot unless the user separately requests an original visualization.

## Protocol caveats

A performance graph must not visually overrule the prose caveats. Verify and disclose where relevant:

- harness and agent scaffold;
- pass@k, avg@k, or repeat count;
- timeout and tool permissions;
- judge model or grading method;
- public versus in-house benchmarks;
- contamination risk;
- whether the comparison is independently reproduced or vendor-reported.

Do not call a figure an independent leaderboard when its values come from the announcing vendor.

## Responsive delivery

- Use a horizontal multi-panel version only when labels remain readable at article width.
- If a canonical publisher-hosted original becomes unreadable on mobile, keep a visible full-resolution source link or omit the inline figure; do not add `<picture>`, `srcset`, or a local mobile copy.
- Use SVG only for a user-explicit original LiteBites visualization; provide descriptive alt text and a factual caption because SVG text inside an `<img>` is not an accessibility substitute.
- Store chart assets under `assets/images/articles/<slug>/` only for that user-explicit original-visualization deliverable. The default Article workflow must not download or recreate a local production figure.
- Link the displayed figure to the full-resolution source or local full-size asset when useful.

## Prototype and approval boundary

When the user asks for a plan or says not to add the graph directly:

1. Inspect source candidates read-only.
2. Save the implementation plan under `.hermes/plans/`.
3. Create any requested prototypes only under `/tmp`.
4. Show source-crop and replot variants side by side when the user asks to compare both.
5. Do not modify the Article, commit, or push until the user selects a prototype and approves integration.

## Verification checklist

- [ ] “Graph” meaning explicitly confirmed
- [ ] Any crop/replot/local asset is backed by an explicit user request for an original visualization as a separate editorial deliverable
- [ ] If no admissible original-source image exists, the Article omits the figure
- [ ] Plotted benchmarks match Article scope
- [ ] Every value and model label checked against source pixels
- [ ] Vendor-reporting label visible
- [ ] Protocol caveat remains adjacent to figure
- [ ] Complete official chart remains reachable
- [ ] Desktop and mobile layouts readable
- [ ] Alt text and caption are non-duplicative and sufficient
- [ ] No knowledge-graph topics or relationships changed because of the figure
- [ ] Local preview approved before publication
