# Original LiteBites Visualizations

`POLICY_ARTICLE.md` and `POLICY_REMOTE_IMAGES.md` decide when an original LiteBites diagram or replot is appropriate. This reference covers how to make one that is accurate, original, and accessible. It also covers benchmark/performance charts.

## Disambiguate "graph" first

On LiteBites, "graph" can mean the site-wide knowledge graph or a performance chart inside a Bite. If a request mentions figures, benchmarks, model comparisons, or "the latest post", confirm which one is meant before proposing any work.

## Originality

- Design from a written fact ledger of cited values and relationships, not by tracing or keeping the publisher figure open as a template.
- Do not reproduce the source's composition, icons, branding, typography, colour system, or distinctive layout. Functionally necessary boxes and arrows are fine; the overall composition must be independent.
- Label it "LiteBites synthesis" (or "replotted by LiteBites" for a chart). Use "redraw" only if the source license explicitly permits derivatives and its terms are met.
- When an official figure exists on the same topic, get an independent originality review comparing the two (copied expression, distinctive arrangement, branding, factual fidelity).

Good candidates: workflow diagrams from documented components; capacity/bandwidth charts from cited specs; system-boundary diagrams separating model, orchestration, connectors, artifacts, governance; architecture summaries from model-card fields.

## Replotting benchmark results

- Plot only benchmarks the prose discusses; reject unrelated panels.
- Transcribe only visible, verified values; get a second check of labels, ordering, and values before plotting.
- Use text model names; colour or logos must not be the only identifier. Keep benchmark-specific scales.
- Mark vendor-reported values prominently. Never call it an independent leaderboard.
- Do not normalize, average, rank, or compare across different benchmarks unless the methodology justifies it.
- Keep protocol caveats (harness, pass@k, timeouts, tools, judge, public vs in-house set, contamination, reproduction status) adjacent to the figure.
- Link the complete official chart.

## Asset contract

Store under `assets/images/articles/<slug>/` (or `assets/images/papers/<slug>/`). Prefer a self-contained SVG with a fixed `viewBox`, intrinsic `width`/`height`, a solid background readable in both themes, system fonts only, `<title>` and `<desc>`, strong contrast, and no scripts, foreign objects, embedded rasters, logos, or external requests. Embed as a normal local `<figure>` (not `remote-publisher-image`) with descriptive alt text, a caption that says "LiteBites synthesis from <source links>" and discloses any compressed or schematic scale, and a full-resolution link.

## Accuracy checks

- Every number and relationship traces to a source already under `## Sources`.
- Keep measured values, configuration ceilings, vendor claims, and interpretation visually distinct.
- No proportional bar heights without a truthful scale; if schematic, say so in the figure and caption.
- Do not imply active parameters equal checkpoint memory, maximum configuration equals base spec, or that boxes reveal undocumented internals.
- The Bite must remain understandable without the figure. Re-run the validator after adding the caption (word count).

## Verification

1. Parse the SVG as XML; reject scripts and external/embedded image references. Check that `<title>`, `<desc>`, visible `<text>`, HTML alt, and caption all carry the same attribution and evidence boundary.
2. Inspect it inside the rendered Bite at desktop and 320px, light and dark; no horizontal overflow.
3. Swap the src for a missing path and confirm alt, caption, and prose still work.
4. Name new untracked asset paths explicitly in the checkpoint report.

When the user asks for a plan first or to compare variants, put prototypes under `/tmp` and do not touch the Bite until a variant is approved.
