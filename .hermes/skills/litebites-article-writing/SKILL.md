---
name: litebites-article-writing
description: "Use when researching, drafting, revising, or publishing a LiteBites Article Bite from recent technical news, release notes, standards, repositories, or engineering posts. Verify primary and corroborating sources, separate facts from interpretation, enforce the 400–800-word Article Bite contract, refresh the knowledge graph, build locally, and stop for review unless publication is explicitly authorized."
version: 1.0.9
author: Hermes Agent
license: MIT
platforms: [macos, linux, windows]
metadata:
  hermes:
    tags: [litebites, technical-news, analysis, jekyll, publishing]
    related_skills: [litebites-site-maintenance, litebites-paper-writing, humanizer]
---

# LiteBites Article Writing

## Overview

Create evidence-backed Article Bites for LiteBites. Article Bites are 400–800-word analyses of recent technical developments. They identify what happened, explain why it matters, supply the minimum technical context, disclose uncertainty, and end with practical takeaways and sources.

This skill owns the complete Article Bite production path: source verification, evidence ledger, drafting, metadata, mechanical validation, knowledge-graph refresh, Jekyll build, visual review, and the publication boundary. The repository source and `POLICY_ARTICLE.md` remain authoritative if this skill drifts.

## When to use

Use this skill when the user asks to:

- turn a technical announcement, release note, standard, repository change, engineering post, or recent technology article into a LiteBites entry;
- revise an existing file under `_articles/`;
- add source attribution, caveats, or corrections to an Article Bite;
- validate or publish an Article Bite;
- update Article Bite presentation or graph metadata as part of a specific article.

Do not use this skill for:

- academic paper summaries — use `litebites-paper-research` and `litebites-paper-writing`;
- dataset overviews — follow the Data Bite conventions;
- site-wide layouts, navigation, or graph architecture without an article — use `litebites-site-maintenance`;
- rumors or unsupported social posts that lack a stable canonical source.

## Repository discovery

Resolve the target checkout from a path supplied by the user or from a Git root containing all of:

```text
POLICY_ARTICLE.md
_config.yml
articles.html
scripts/validate_article_bites.rb
scripts/generate_knowledge_graph.rb
```

Never hardcode a user home directory. Before editing, run:

```bash
git status --short --branch
git log -1 --oneline --decorate
```

Record unrelated existing changes and preserve them. Completion criterion: the repository, branch, tracking relationship, and pre-existing diff are known.

## Content contract

Article Bite files live at:

```text
_articles/<stable-slug>.md
```

Dates belong in front matter, not filenames. Generated URLs are:

```text
/articles/<stable-slug>/
```

Required front matter:

```yaml
---
layout: article
title: "Exact descriptive article title"
short_title: "Compact index title"
date: YYYY-MM-DD
type: "Article Bite"
read_time: "N min read"
source_name: "Canonical publisher or author"
source_url: "https://canonical.example/source"
source_published: YYYY-MM-DD
last_reviewed: YYYY-MM-DD
tags:
  - Precise Topic
summary: "One accurate sentence explaining the development and its significance."
---
```

Optional fields:

```yaml
card_image: "/assets/images/articles/<slug>/card.png"
card_image_alt: "Descriptive alt text"
additional_sources:
  - name: "Independent corroborating source"
    url: "https://example.com/corroboration"
```

If `card_image` exists, `card_image_alt` is mandatory. Keep all card images and repository-managed article assets under `assets/images/articles/<slug>/`. Prefer local media. A publisher-hosted inline image is allowed only when `POLICY_ARTICLE.md` permits it and the site owner explicitly requests that exception for a specific Article Bite; it must remain remote rather than becoming a card image.

Required headings, exactly once and in order:

```markdown
## What happened
## Why it matters
## Technical context
## What remains uncertain
## Practical takeaways
## Sources
```

## Workflow

### 1. Read policy and examples

Read `POLICY_ARTICLE.md`, `_config.yml`, the Article layout/index, and up to two recent `_articles/*.md` files. If no real Article Bite exists, use `templates/article-bite.md` from this skill and the repository policy rather than inventing conventions.

Completion criterion: required metadata, section order, URL, asset path, word limit, graph hook, and publication boundary are explicit.

### 2. Verify the source set

Start from the canonical source rather than a search result or secondary summary. Confirm publisher/author, title, exact publication date, stable HTTPS URL, and current availability. Read linked release notes, documentation, repository changes, standards text, benchmarks, or filings that determine the technical claim.

Corroborate consequential claims with an independent source when available. Search snippets and generated summaries may discover sources but never count as evidence. Social posts may support attributed statements but cannot alone establish a consequential technical fact.

Use `references/source-review.md` to create the evidence ledger. For vendor-reported benchmark records, perfect scores, or “frontier” claims, also apply `references/vendor-benchmark-claims.md`: classify the evidence level, pin the result to its exact public/private evaluation scope, distinguish model from harness, identify metric blind spots, and inventory scorecards, traces, configuration, and reproduction materials. Resolve material contradictions before drafting. Completion criterion: every consequential claim is classified as reported fact, attributable claim, independent evidence, LiteBites interpretation, or uncertainty and has a source.

### 3. Draft from the ledger

Write the six required sections. Target 400–800 body words and approximately 2–4 minutes. Use exact dates instead of relative phrases that will become ambiguous. Prefer direct verbs and concrete nouns over promotional language.

Keep these voices distinct:

```text
Reported fact: “The release notes state…”
Attribution: “The company says…”
Independent evidence: “A separate benchmark found…”
LiteBites interpretation: “A useful way to read this is…”
Uncertainty: “It is not yet clear whether…”
```

Do not turn an announcement into measured evidence, add tags to manufacture graph connections, or hide uncertainty to make the narrative cleaner. Completion criterion: prose follows the ledger, all six sections exist, and every source in the final list materially supports the article.

### Performance graphs and figure requests

The word “graph” is ambiguous on LiteBites: it may mean the site-wide knowledge graph or a performance-comparison chart inside an Article. When a request mentions figures, benchmarks, model comparisons, or “the latest post,” confirm the intended meaning before proposing graph architecture work.

For benchmark visuals, prefer a focused, readable figure covering only results discussed in the Article. Dense vendor collages should be evaluated at real article and mobile widths rather than embedded automatically. Prototype a source-faithful crop and an original LiteBites replot side by side when the user wants to compare both. Every value and model label must be checked against the source pixels; vendor-reported results and protocol differences must remain visually explicit. See `references/performance-comparison-figures.md` for the complete crop-versus-replot, provenance, responsive-layout, and approval workflow.

When the user requests a figure without storing it in the repository, reconcile that request with `POLICY_ARTICLE.md`; do not silently weaken policy. Prefer a verified descriptive link to the original figure. If the site owner explicitly requests an embedded publisher-hosted original and repository policy allows that narrow exception, verify that the asset uses HTTPS and the canonical publisher's media infrastructure, then include descriptive alt text, a source-linked caption, intrinsic width and height, lazy loading, asynchronous decoding, a privacy-preserving referrer policy, and a full-resolution link. The article must remain understandable if the remote asset later fails, and the remote image must never become `card_image`. Explain this dependency at the local checkpoint. Use `references/remote-publisher-images.md` for the markup pattern, privacy and durability disclosure, responsive/failure testing, and deployment verification.

### 4. Validate mechanically

Run:

```bash
ruby scripts/validate_article_bites.rb _articles/<slug>.md
```

Fix metadata, headings, URL, image, placeholder, and word-count failures. Re-run until it reports `PASS` and a count between 400 and 800 words. Dates must use exact `YYYY-MM-DD` values; required text and tags must be non-empty strings; the six required `##` headings must be the complete level-two heading sequence with no extras; the canonical `source_url` must appear inside `## Sources`, not merely elsewhere in the body; and normalized card-image paths must remain under `/assets/images/articles/`.

When the validator or schema changes, use the adversarial cases in `references/article-validation-hardening.md`; a single valid fixture is not sufficient.

Then inspect the diff for copied promotional language, unsupported causality, stale relative dates, missing attribution, and source links that do not support the adjacent claim. Mechanical success is necessary but not sufficient.

### 5. Refresh and review the graph

After the article, metadata, slug, and tags are editorially final, run:

```bash
ruby scripts/generate_knowledge_graph.rb
ruby scripts/generate_knowledge_graph.rb
```

The second run must report `0 changed sources`. Validate:

- exactly one `article:<slug>` node exists;
- its URL is `/articles/<slug>/`;
- direct topics derive from truthful Article tags;
- Article nodes do not gain extra topics from summary or keyword inference (for example, the word `benchmark` must not silently add `Datasets`); add or update a generator regression instead of rewriting accurate prose to suppress a false edge;
- every edge endpoint exists;
- automatically inferred edges use `shared-topic` with metadata provenance;
- directional relations such as `validates`, `contradicts`, `announces`, or `builds-on` appear only when reviewed and curated;
- public JSON omits internal source paths, hashes, and topic weights.

An isolated truthful node is better than a misleading connection. Use `references/knowledge-graph-topic-hygiene.md` for the adversarial regression pattern, generator-version rule, and before/after edge audit.

### 6. Build and inspect together

Activate a Ruby version compatible with the repository's GitHub Pages dependencies. Keep Bundler and Jekyll output outside the repository:

```bash
export LITEBITES_TMP="${TMPDIR:-/tmp}/litebites-article-validation"
export BUNDLE_PATH="$LITEBITES_TMP/ruby-bundle"
bundle check || bundle install
bundle exec jekyll build --destination "$LITEBITES_TMP/site"
```

Inspect:

```text
/articles/
/articles/<slug>/
/
/graph/
/papers/
/data/
```

Verify the preferred Bite order is Article, Paper, Data wherever content categories are presented, including navigation, graph filters, legends, accessible directories, and no-JavaScript fallback content. Use an explicit type rank rather than alphabetical sorting. Confirm the Article index is newest-first, source metadata wraps, the homepage lists the article, Article graph filtering and Open Bite links work, and Paper Bite pagination remains paper-only.

For automated graph interaction checks, target the visible SVG node shape (for example, `[data-node-id="article:<slug>"] .graph-node-shape`) rather than the enclosing `<g>` bounding box: label text may use `pointer-events: none`, causing center-point automation clicks to land on the SVG stage. After clicking, assert the node’s selected class, inspector title, and exact `/articles/<slug>/` link; do not treat mere node presence as an interaction pass.

At 320px, 375/390px, and desktop, check horizontal overflow, long titles, navigation, 44px targets, visible focus, light/dark themes, and no-JavaScript graph fallback. Completion criterion: build and browser checks pass with no console errors or missing local assets.

### 7. Prepare the local review checkpoint

Run:

```bash
git diff --check
git status --short --branch
git diff --stat
git diff
```

Exclude `_site`, `Gemfile.lock`, `.bundle`, `vendor`, caches, temporary screenshots, and planning artifacts from publication scope. Before presenting the checkpoint, obtain an independent review of the current production diff and explicitly named untracked implementation files. Treat asynchronous review results as snapshots: if any reviewed file changes afterward, re-run verification and dispatch a fresh review. Use `references/article-validation-hardening.md` for review freshness and adversarial checks.

Report:

- canonical and corroborating sources;
- body word count and last-reviewed date;
- exact changed files;
- validator and Jekyll results;
- graph node/edge changes and idempotence;
- responsive and interaction checks;
- any claims that remain caveated.

Stop here unless the user explicitly authorizes commit and push.

### 8. Publish only with explicit approval

Fetch and reconcile remote state before staging. Stage explicit approved paths, inspect the full cached diff, and keep unrelated changes out. Use a focused content commit such as:

```text
content: publish <short Article Bite topic>
```

Push only after authorization. Verify local, tracking, and remote SHAs. Then identify the GitHub Pages workflow run for that exact head SHA and distinguish build success from deployment success: a completed build with a queued deploy job is not live publication. If deployment remains externally queued, report the pushed commit accurately and run a bounded background verifier against the workflow status plus a cache-busted, revision-specific marker on the live page. After deployment succeeds, verify cache-busted live Article index, Article page, homepage, and graph URLs; inspect the live browser console and Article node interactions. For remote publisher images, also scroll the live image into view and verify its request, natural dimensions, caption, and full-resolution link. See `references/remote-publisher-images.md`.

## Corrections and revisions

When a consequential source claim changes, add a visible update or correction note and refresh `last_reviewed`; do not silently rewrite history. Minor typo or clarity edits do not require a correction note. Re-run the full validator, graph, build, and review workflow for every revision.

## Common pitfalls

1. **Secondary-source drift:** Drafting from a news summary changes claims and dates. Return to the canonical source.
2. **Announcement as evidence:** “The company says” is attribution, not independent validation.
3. **Premature certainty:** Preserve missing benchmarks, compatibility limits, deployment constraints, and unknowns.
4. **Paper contamination:** Never save Article Bites in `_posts/`; it would mix pagination and policy.
5. **Graph gaming:** Never alter tags or prose solely to create edges.
6. **Remote-image exceptions:** Prefer local assets and never introduce a remote image silently. Use a publisher-hosted inline image only when the site owner explicitly requests it and repository policy permits the narrow exception; verify HTTPS origin, accessibility, provenance, intrinsic sizing, lazy loading, full-resolution access, responsive behavior, and graceful degradation.
7. **Build artifacts:** Keep dependency and generated site output outside the repository.
8. **Approval collapse:** A successful local build is not permission to commit or publish.

## Verification checklist

- [ ] Repository and pre-existing changes identified
- [ ] Canonical source read and verified
- [ ] Consequential claims corroborated where possible
- [ ] Evidence ledger complete
- [ ] Required metadata present and accurate
- [ ] Six sections appear exactly once and in order
- [ ] Body contains 400–800 words
- [ ] Source facts, interpretation, and uncertainty are distinct
- [ ] Validator reports PASS
- [ ] Graph generator run twice; second run reports zero changed sources
- [ ] Article node, URL, topics, and relationships reviewed
- [ ] Article page, index, homepage, graph, Paper Bites, and Data Bites built
- [ ] Mobile, desktop, themes, keyboard, and no-JavaScript fallback checked
- [ ] Adversarial validator cases checked when schema or validation changes
- [ ] Independent review covers the current tree and named untracked implementation files
- [ ] Diff contains no unrelated or generated artifacts
- [ ] Local review checkpoint presented
- [ ] Commit/push performed only after explicit approval
- [ ] Pages deployment—not merely the build—completed for the pushed SHA
- [ ] Cache-busted live surfaces and any remote image request verified
