---
name: litebites-paper-research
description: "Use when researching an AI or computer-science paper for a LiteBites post. Build an evidence-backed research brief from canonical sources, verify metadata and claims, inspect methods and results, select useful figures, and separate paper claims from interpretation before drafting."
version: 1.1.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [litebites, academic-research, ai-papers, evidence, figures]
    related_skills: [arxiv, litebites-paper-writing]
---

# LiteBites Paper Research

## Overview

Turn an AI or computer-science paper into a compact, traceable research brief suitable for a LiteBites post. The brief is an intermediate artifact: collect and verify evidence before writing polished prose.

Optimize for fidelity, not coverage. A completed brief must support the paper's motivation, central idea, mechanism, evidence, limitations, links, and figure choices without relying on invented details.

## When to Use

Use this skill when:

- The user supplies a paper title, URL, PDF, DOI, arXiv ID, or project page.
- A LiteBites Paper Bite needs research before drafting.
- Existing notes need fact-checking against the original source.
- Figures must be chosen from a paper for a future post.

Do not use it as a substitute for reading the full source when the post discusses architecture, quantitative results, ablations, or limitations.

## Source Hierarchy

Prefer sources in this order:

1. Official conference or journal page and paper PDF.
2. Versioned arXiv abstract and PDF.
3. Official project page and author-maintained repository.
4. Official supplementary material or appendix.
5. Reputable indexes only for discovery, never as the sole support for technical claims.

Preserve the exact source version read. If arXiv is used, record the version suffix when available. Verify the exact title, authors, venue, date, and URLs against a canonical source.

Treat README claims, project-page summaries, generated text, and third-party articles as secondary. Do not use search-result snippets as evidence.

## Workflow

### 1. Identify the canonical paper

- Resolve the supplied identifier to an official page and full paper.
- Check for revised, withdrawn, or superseded versions.
- Record exact title, authors, venue/status, publication year, paper URL, PDF URL, project URL, and code URL.
- Note uncertainty explicitly, such as “arXiv preprint; venue not verified.”

Completion criterion: every metadata field used in the post is backed by a canonical page, and no guessed venue or date remains.

### 2. Read in layers

Read the source in this order:

1. Abstract and introduction: problem, motivation, contribution claims.
2. Overview/method: data flow, components, training, inference, and baselines.
3. Experiments: datasets, metrics, comparisons, ablations, and qualitative results.
4. Limitations, conclusion, appendix, and supplementary material when relevant.

Search inside the extracted paper for terms such as `limitation`, `ablation`, `dataset`, `metric`, `baseline`, and major component names. If extraction is incomplete, use an alternate canonical HTML/PDF source or local PDF extraction before proceeding.

Completion criterion: the brief can explain what goes in, what happens, what comes out, what is trained, and how the method is evaluated.

### 3. Build an evidence ledger

For every consequential claim, capture:

- **Claim** — concise factual statement.
- **Evidence location** — section, table, figure, or page.
- **Source wording or values** — enough context to verify it.
- **Interpretation** — why it matters, clearly labeled as interpretation.
- **Confidence** — high, medium, or low.

Consequential claims include dataset sizes, parameter counts, benchmark improvements, “first” claims, superiority claims, training recipes, and stated limitations. Preserve metric names and whether higher or lower is better. Never compare numbers that use different splits, protocols, or model scales without saying so.

Completion criterion: every number and strong comparative statement planned for the post appears in the ledger.

### 4. Synthesize the paper

Answer these questions in plain technical English:

- What problem is addressed, and why does it matter in practice?
- What did prior approaches fail to do?
- What is the key idea in one or two sentences?
- What are the smallest set of components needed to explain the method?
- What evidence most directly tests the central claim?
- Which ablations isolate the contribution?
- What limitations are stated or directly supported?
- What practical lesson can a reader reuse?

Separate three voices:

- **Paper claim:** “The authors report…”
- **Observed evidence:** “Table 3 shows…”
- **Interpretation:** “A useful way to read this is…”

Completion criterion: a reader can understand the paper’s argument without reproducing its abstract or introduction.

### 5. Select figures

Usually shortlist:

- One method, architecture, or pipeline figure for `How it works`.
- One results, ablation, or qualitative figure for `What to look at in the results`.

Treat this as a usefulness target, not a quota. Position, survey, perspective, and theory papers may contain no experimental results figure. In that case, use the single figure that materially improves understanding and explicitly record why a second figure was omitted. Never manufacture a “results” visual, crop prose as if it were a result, or substitute an unrelated project-page image merely to satisfy a two-figure pattern.

For each candidate, record the figure number, page, purpose, important labels, and a proposed descriptive alt text. Prefer complete figures with readable legends and meaningful context. Do not select a figure merely because it looks attractive.

When arXiv provides a versioned e-print source archive, inspect it for the original `\\includegraphics` assets before taking screenshots from the PDF. Original vector PDFs and raster files usually preserve labels and panel context better. If a vector figure must be rasterized for Jekyll, render it at high resolution and use an opaque white background when the source assumes white paper; transparent black-on-white figures can become unreadable in dark mode. Follow [the arXiv source-figure extraction recipe](references/arxiv-source-figure-extraction.md) for safe extraction, caption mapping, rendering, and verification.

Before reusing assets, check the source’s license or usage context. Preserve attribution through a caption such as “Paper figure.” Never remove authorship marks or alter a figure in a misleading way.

Completion criterion: each chosen figure teaches a specific point and can be mapped to a post section; if only one or no figure is appropriate, the brief records the evidence-based reason.

### 6. Produce the research brief

Use this structure:

```markdown
# Research brief: <exact title>

## Canonical metadata
- Exact title:
- Authors:
- Venue/status:
- Version/date:
- Paper:
- PDF:
- Project:
- Code:

## Problem and motivation

## Central idea

## Method map
- Inputs:
- Main components:
- Training:
- Inference/output:

## Evidence ledger
| Claim | Evidence location | Source detail | Interpretation | Confidence |

## Results worth explaining

## Limitations and caveats

## Practical takeaways

## Figure candidates

## Open questions / unresolved facts
```

Do not hide unresolved contradictions. List them under open questions and resolve them before drafting if they affect public claims.

## Common Pitfalls

1. **Abstract-only summaries.** Abstracts omit caveats and experimental protocol. Read the method, experiments, and limitations.
2. **Metadata drift.** Search indexes may show stale titles or venue guesses. Use a canonical page.
3. **Metric laundering.** A reported gain is meaningless without the dataset, split, baseline, and metric direction.
4. **Promotional language.** Replace “revolutionary” and “state of the art everywhere” with scoped evidence.
5. **Unsupported limitations.** Distinguish author-stated limitations from reasonable interpretation.
6. **Figure mismatch.** Ensure the caption, selected crop, labels, and post explanation refer to the same experiment.
7. **Third-party dependence.** Blogs can aid discovery but must not become the technical source of truth.
8. **Premature drafting.** Do not polish the post until the evidence ledger is complete.

## Verification Checklist

- [ ] Exact title and metadata match a canonical source.
- [ ] The full paper, not only the abstract, was inspected.
- [ ] Every number and strong comparison has a traceable location.
- [ ] Dataset, split, metric, model scale, and protocol are preserved.
- [ ] Paper claims and interpretation are clearly separated.
- [ ] At least one meaningful limitation or caveat is captured.
- [ ] Paper, PDF, project, and code links were tested when available.
- [ ] Figure choices have purpose, source location, and proposed alt text.
- [ ] Reused figures are traced to the exact paper version and visually checked in both light and dark presentation contexts.
- [ ] No unresolved fact is silently presented as certain.
