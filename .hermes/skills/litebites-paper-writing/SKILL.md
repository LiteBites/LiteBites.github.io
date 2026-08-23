---
name: litebites-paper-writing
description: "Use when drafting or revising an evidence-backed AI-paper summary for the LiteBites Jekyll blog. Apply POLICY_POST.md editorial rules and .paper-archive.toml mechanics, validate metadata and figures, refresh the independent knowledge graph, build locally, and leave review-ready files without publishing unless requested."
version: 1.5.0
author: Hermes Agent
license: MIT
platforms: [macos, linux, windows]
metadata:
  hermes:
    tags: [litebites, jekyll, paper-summary, technical-writing, publishing]
    related_skills: [paper-summary-archiver, litebites-paper-research, arxiv, content-site-ui-design]
---

# LiteBites Paper Writing

## Overview

Create a publishable Paper Bite in the LiteBites repository from a verified research brief. This is the LiteBites-specific adapter over the class-level `paper-summary-archiver` workflow; keep site voice, schema, graph commands, and deployment rules here while reusable archiving behavior lives in the umbrella skill.

Resolve the target repository from the user's supplied path or the current Git root containing `POLICY_POST.md`, `.paper-archive.toml`, and `_config.yml`. Do not depend on a machine-specific absolute checkout path; if the task starts outside the repository and no checkout can be discovered safely, ask for its location. For cross-machine backup, category-preserving installation, and package verification, follow `references/portable-skill-distribution.md`.

The repository's `POLICY_POST.md` is the local source of truth. Read it and one or two recent representative posts before drafting because repository conventions may evolve after this skill is written.

A complete task produces real Markdown and local assets, refreshes the independent knowledge graph, validates the rendered post and graph, and reports the resulting files. Do not commit or push unless the user explicitly requests it.

## When to Use

Use this skill when:

- Writing a new LiteBites AI-paper summary.
- Revising a Paper Bite for accuracy, clarity, structure, or tone.
- Converting research notes into repository-ready Jekyll Markdown.
- Adding paper figures and checking their references.

Do not begin from unverified snippets. If no evidence-backed research brief exists, run the LiteBites paper research workflow first.

## Required Repository Conventions

### File and front matter

Create:

`_posts/YYYY-MM-DD-short-slug.md`

Use lowercase kebab-case for the slug. Store figures under:

`assets/images/papers/<short-slug>/`

Required front matter:

```yaml
---
layout: post
title: "Exact canonical paper title"
short_title: "Compact display title"
date: YYYY-MM-DD
type: "Paper brief"
read_time: "N min read"
venue: "Verified venue or status"
tags:
  - Topic
summary: "One accurate sentence."
paper_url: "https://..."
project_url: "https://..."
code_url: "https://..."
---
```

Omit optional URL fields when unavailable rather than inserting empty or invented destinations. Preserve their semantics: `paper_url` is the canonical paper, `project_url` is an actual project/landing page, and `code_url` is an implementation repository. A proceedings or venue record belongs in `Links`, not in `project_url` merely to fill the field. YAML-quote titles, summaries, venue names, and other strings that may contain punctuation. `title` must exactly match an official canonical source; use `short_title` for abbreviations.

Tags are also inputs to the independent LiteBites knowledge graph. Choose a compact set of precise, reusable research topics that accurately describe the paper and align with established repository terminology. Avoid broad filler such as `AI`, unnecessary synonyms, and tags selected merely to force a graph connection. Editorial truth takes priority over graph density.

### Section order

Use this order unless the user requests another format:

1. `## Why this paper matters`
2. `## The bite`
3. `## How it works`
4. `## What to look at in the results`
5. `## Practical takeaways`
6. `## Links`

Aim for a 5–8 minute read. Keep the summary compact without making it shallow.

## Writing Workflow

### 1. Re-read local policy, profile, and examples

Read `POLICY_POST.md`, `.paper-archive.toml` when present, `_config.yml`, the post layout, and at least one recent high-quality post. Treat `POLICY_POST.md` as the editorial authority and `.paper-archive.toml` as the machine-readable source for paths, metadata mappings, ordered sections, derived-state hooks, validation commands, and publication mode. Check `git status` before writing so pre-existing user changes are not overwritten or accidentally included.

Do not duplicate generic fields when the profile maps them to LiteBites names. In particular, honor `[metadata.field_map] source_url = "paper_url"` instead of adding `source_url` to post front matter. See `references/paper-archive-profile.md` for precedence, graph-hook, and validation guidance.

Completion criterion: current editorial rules, profile mechanics, front matter, section, asset, hook, validation, and tone conventions are known; any policy/profile conflict is surfaced; and unrelated working-tree changes are accounted for.

### 2. Map evidence to sections

Create a private outline before prose:

- Motivation and practical problem → `Why this paper matters`
- One central concept → `The bite`
- Inputs, components, training, and outputs → `How it works`
- Central experiments, ablations, and caveats → `What to look at in the results`
- Three to five reusable lessons → `Practical takeaways`
- Canonical destinations → `Links`

Every factual claim must map to the research brief or original paper. Remove claims that cannot be verified. Do not copy the abstract or lightly rearrange source prose.

Completion criterion: every section has a distinct job and an evidence source.

#### Position, survey, and perspective papers

Do not force an experimental-paper narrative onto a paper that introduces no new benchmark or controlled evaluation. Keep the standard heading `What to look at in the results`, but use it to explain the paper's evidence type: literature synthesis, formal argument, case analysis, expert estimate, theorem, correspondence, or proposed workflow. State early that the work is non-experimental, distinguish cited prior results from evidence produced by the paper itself, and label illustrative percentages or case judgments as estimates rather than measured outcomes. See `references/position-papers.md` for the compact adaptation recipe.

### 3. Draft in LiteBites voice

Write in English with short, concrete, scan-friendly sentences. Prefer plain technical vocabulary and define uncommon acronyms on first use.

Useful phrasings include:

- “The key idea is…”
- “This matters because…”
- “A useful way to read the result is…”
- “The limitation is…”

Avoid hype, absolute superiority claims, invented novelty, and dense acronym chains. Use scoped language such as “on the evaluated datasets” and “the authors report.” Mark interpretation as interpretation. For retrieval-based systems, do not call retrieved passages “evidence” unless the source or evaluation establishes support; prefer “retrieved documents,” “passages,” or “context,” and reserve “evidence” for verified support or the paper's explicitly defined variable.

Write the central idea before module names or benchmark detail. Explain information flow rather than listing components. In results, teach the reader which comparisons matter instead of transcribing every number.

Completion criterion: a technically literate reader can restate the problem, method, evidence, and caveat after one reading.

### 4. Estimate reading time

Count body words, excluding YAML and raw HTML where practical. Use a consistent estimate near 200–230 words per minute and round to a sensible whole minute. Keep the final `read_time` aligned with the actual post rather than copying a template value.

Completion criterion: front matter and actual length agree, normally within the 5–8 minute policy range.

### 5. Add figures deliberately

Usually add one method figure and one results figure, but treat this as a usefulness target rather than a quota. Download from an official paper PDF, supplementary source, or project page; never hotlink external images. If a position, survey, perspective, or theory paper has no meaningful results figure, use one strong explanatory figure or no figure and record the reason in the research brief. Never manufacture a chart, crop prose as a pseudo-result, or add an unrelated image merely to preserve a two-figure pattern.

Use:

```html
<figure>
  <img src="{{ '/assets/images/papers/<slug>/<file>.png' | relative_url }}" alt="Descriptive visual content" />
  <figcaption>Paper figure: what this shows and why it matters.</figcaption>
</figure>
```

Keep blank lines around raw HTML. Use stable names such as `method-01.png` and `results-01.png`. Prefer complete figures over tight crops that remove legends or labels. Check both intrinsic and rendered dimensions: when a complete figure is too wide for readable labels on mobile, retain the uncropped figure and add a descriptive same-origin link to the full-resolution asset rather than silently cropping away context. Confirm the reuse context or license where relevant.

Completion criterion: every Markdown asset path exists, each selected image is legible, alt text describes the visual, and the caption explains its role; the number of figures matches the source's actual explanatory value rather than a template quota.

### 6. Validate content mechanically

Check:

- YAML parses and required keys are present.
- The filename date and front-matter date match.
- The slug and asset directory match.
- Headings appear once and in the required order.
- Local image paths resolve.
- Canonical external links return successfully or redirect to the intended source.
- No placeholders such as `TODO`, `TBD`, or empty template values remain.
- No unverified number or superlative remains.

Completion criterion: all checks pass or each unavoidable exception is disclosed.

### 7. Refresh and review the knowledge graph

After the post content, front matter, slug, and assets are final, inspect the enabled `knowledge-graph` hook in `.paper-archive.toml` and run its configured command from its configured working directory. The current repository command is:

```bash
ruby scripts/generate_knowledge_graph.rb
```

If the profile and repository script disagree, stop and surface the mismatch rather than silently following stale instructions. The generator is incremental: it hashes Paper Bite and Data Bite sources, reuses unchanged nodes and accepted edges, and processes only new, changed, renamed, or removed content. It reads posts but must never rewrite them. Run it twice when `idempotence_check = true`; the second run should report `0 changed sources`, proving that the generated output is deterministic and current.

Validate that:

- The new or revised post appears as exactly one `paper:<slug>` node.
- Its title, summary, URL, date, venue, reading time, and topics match the final front matter.
- Every inferred relationship has a defensible shared topic.
- Existing unrelated nodes and accepted relationships remain intact.
- All edge endpoints resolve to existing nodes.
- Public `assets/data/knowledge-graph.json` contains no source paths, hashes, or internal topic weights.

Do not edit prose or add inaccurate tags merely to create edges. A truthful isolated node is preferable to a misleading relationship. If the paper has a meaningful directional relationship that metadata cannot express, propose a reviewed entry in `_data/knowledge-graph-relations.yml`; add it only when supported by the source and record `provenance: curated`. LLM or embedding suggestions are editorial candidates, never automatically accepted graph facts.

Completion criterion: graph generation succeeds, a second run skips unchanged sources, the post node is accurate, every new edge is defensible, and both `_data/knowledge-graph-state.json` and `assets/data/knowledge-graph.json` reflect the final post. See `references/knowledge-graph-publishing.md` for the detailed tag, curation, browser-validation, and diff-scope guidance.

### 8. Build and inspect the site

Install dependencies if needed with Bundler in an environment compatible with the repository’s GitHub Pages dependency set. Do not alter the project’s dependency versions merely to accommodate a globally installed Ruby. Prefer a compatible Ruby manager or isolated environment when necessary.

Inspect `.paper-archive.toml` `[validation]` commands when present and run the configured Jekyll build in a repository-compatible environment. The current repository command is:

```bash
bundle check || bundle install
bundle exec jekyll build
```

The profile's `publishing.mode = "review-only"` does not authorize commit or deployment; it requires the local review checkpoint after validation.

Keep Bundler's install directory **outside the Jekyll source tree** when possible. Jekyll 3 may scan a local `vendor/bundle` as site content and parse gem template files as posts. If an existing local bundle must remain inside the repository, exclude both `vendor` and `.bundle` in the effective Jekyll configuration before building. Prefer a temporary overlay config for verification rather than changing the repository's permanent `_config.yml` solely for the local environment:

```yaml
# /tmp/litebites-build-exclude.yml
exclude:
  - Gemfile
  - Gemfile.lock
  - README.md
  - POLICY_POST.md
  - vendor
  - .bundle
```

```bash
bundle exec jekyll build --config _config.yml,/tmp/litebites-build-exclude.yml
```

Inspect the generated post HTML and confirm the expected permalink, title, six headings, links, and figure paths. Verify that each rendered image target exists under `_site/`; a successful build alone does not prove asset references are correct. Also confirm that the paper index contains the new post and that `/graph/` loads the new node from `/assets/data/knowledge-graph.json`. Select the node and verify its details, neighbors, relationship labels, and Open Bite destination. Check graph search and the Paper/Data filters. For a normal post-only addition, inspect the graph at desktop and a narrow mobile width; if graph code or styling changed, run the full site-maintenance validation matrix. If visual changes are involved, run the local server and inspect desktop and mobile layouts. Bind temporary previews to loopback by default. Do not expose a preview through a LAN, all-interface bind, Tailscale, or another remote interface without a fresh explicit request. If remote preview is cancelled or fails, stop every preview process associated with this repository and verify its listener ports are closed; do not leave a fallback server running. Stop loopback previews after validation unless the user explicitly asks to keep one available. For shared previous/next controls or other post-navigation changes, follow `references/jekyll-post-navigation.md` to verify chronology, boundary posts, generated targets, responsive overflow, theme contrast, and keyboard focus with concise element screenshots.

After verification, remove build-only artifacts created inside the repository (`_site`, `.bundle`, `vendor`, and an unrequested generated lockfile) only after confirming they were not pre-existing user files and are not tracked. Never delete a pre-existing dependency cache or lockfile merely to clean the diff.

Completion criterion: Jekyll exits successfully, the generated post, paper index, and graph contain the intended content, the new graph node and its Open Bite link work, every rendered local resource resolves, and build-only artifacts do not pollute the final working tree.

### 9. Review the diff

Run `git diff --check`, inspect `git status`, and review the full diff. Ensure only the intended post, assets, and graph state/public-data files changed. A normal new-post diff may include `_data/knowledge-graph-state.json` and `assets/data/knowledge-graph.json`; curated relationships should change only when explicitly reviewed. Do not stage, commit, or push unless asked.

Completion criterion: the final diff is clean, scoped, and ready for user review.

## Editorial Quality Gate

A publishable Paper Bite must satisfy all of these:

- **Exactness:** canonical title and metadata are correct.
- **Fidelity:** claims stay within the source’s evidence.
- **Clarity:** the key idea precedes detail.
- **Substance:** method and evidence are explained, not merely praised.
- **Scope:** performance claims identify relevant benchmarks or conditions.
- **Honesty:** at least one meaningful caveat is included when supported.
- **Usefulness:** practical takeaways are concrete and reusable.
- **Accessibility:** figures have meaningful alt text and captions.
- **Integrity:** prose is original synthesis, not copied source text.

## Common Pitfalls

1. **Writing before research.** A fluent post can still be wrong. Require a verified brief.
2. **Paraphrasing the official title.** Keep `title` exact; shorten only in `short_title`.
3. **Template residue.** Remove empty URLs and update read time, tags, date, and venue.
4. **Result dumping.** Explain decisive comparisons and caveats instead of listing tables.
5. **Overclaiming causality.** Ablations support a scoped interpretation, not universal proof.
6. **Broken figure references.** Validate source paths, rendered paths, and actual files under `_site`; inspect crops for completeness and legibility.
7. **Bundler path inside the source tree.** Jekyll 3 may parse files under `vendor/bundle` as content. Install outside the source or use an overlay config excluding `vendor` and `.bundle`.
8. **Installing around incompatibility.** Do not rewrite Gem dependencies to fit an unsuitable global Ruby.
9. **Clobbering user work.** Check status first and preserve unrelated changes. Before cleaning generated artifacts, distinguish files created during this run from pre-existing user files.
10. **Publishing without consent.** Writing and validation do not imply commit or push permission.
11. **Forgetting or gaming the graph refresh.** Always regenerate graph data after the final post edit, but never distort tags, prose, or scientific framing to manufacture relationships. Preserve editorial truth and accept isolated nodes.
12. **Treating the archive profile as editorial policy.** `.paper-archive.toml` configures mechanics; it does not replace `POLICY_POST.md` or evidence-based judgment. Honor semantic field mappings such as `source_url` → `paper_url`, and surface profile/policy drift instead of inventing duplicate fields.

## Verification Checklist

- [ ] `POLICY_POST.md`, `.paper-archive.toml` when present, and recent posts were inspected.
- [ ] Editorial rules came from policy/source evidence; paths, field mappings, hooks, validation, and publication mode came from the profile.
- [ ] Working-tree state was checked before edits.
- [ ] Exact paper title and metadata are canonical.
- [ ] Required front matter is complete and valid YAML.
- [ ] Six standard sections appear in order.
- [ ] Claims and numbers trace to the research brief or original paper.
- [ ] The summary and takeaways are specific, not promotional.
- [ ] Read time reflects actual length.
- [ ] All local figures exist and include useful alt text and captions.
- [ ] External source links were checked.
- [ ] Tags are precise, canonical research topics and were not selected to force graph edges.
- [ ] `ruby scripts/generate_knowledge_graph.rb` succeeds after the final post edit; a second run reports `0 changed sources` and no further diff.
- [ ] Exactly one accurate graph node represents the post, its URL works, and every new relationship is defensible or explicitly reviewed.
- [ ] Public graph JSON contains no private cache fields and every edge endpoint resolves.
- [ ] `bundle exec jekyll build` succeeds without scanning dependency directories as site content.
- [ ] The generated post, paper index, and knowledge graph were inspected.
- [ ] Any temporary preview was loopback-only unless freshly authorized, then stopped and its listener ports verified closed.
- [ ] Every rendered local image URL maps to an existing file under `_site/`.
- [ ] Temporary build/dependency artifacts created during this run were removed without touching pre-existing user files.
- [ ] `git diff --check` passes and only intended files changed.
- [ ] No commit or push occurred without explicit user instruction.
