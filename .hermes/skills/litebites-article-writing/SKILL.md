---
name: litebites-article-writing
description: "Use when researching, drafting, revising, or publishing a LiteBites Article Bite from recent technical news, release notes, standards, repositories, or engineering posts. Verify primary and corroborating sources, separate facts from interpretation, enforce the 400–800-word Article Bite contract, refresh the knowledge graph, build locally, and stop for review unless publication is explicitly authorized."
version: 1.4.2
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

Never hardcode a user home directory. Shell examples in this skill use POSIX syntax; on Windows, run them in Git Bash or WSL, or translate environment assignments and paths to PowerShell before execution. Before editing, run:

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

Use only lowercase ASCII letters, digits, and hyphens in `<stable-slug>` (`^[a-z0-9]+(?:-[a-z0-9]+)*$`). Translate punctuation inside product and model names into hyphens—for example, `GLM-5.3-Flash` becomes `glm-5-3-flash.md`. Do not leave extra periods before `.md`: Jekyll may normalize them in the rendered permalink while a metadata generator preserves the raw basename, creating a broken graph URL.

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

If `card_image` exists, `card_image_alt` is mandatory. Keep all card images and repository-managed article assets under `assets/images/articles/<slug>/`. For informative inline Article visuals, prefer the original canonical publisher-hosted HTTPS asset rather than downloading a repository copy. Remote images are optional and must follow `POLICY_ARTICLE.md` plus `references/remote-publisher-images.md`; they must never become card images or discovery-surface dependencies.

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

Use `references/source-review.md` to create the evidence ledger. For vendor-reported benchmark records, perfect scores, or “frontier” claims, also apply `references/vendor-benchmark-claims.md`: classify the evidence level, pin the result to its exact public/private evaluation scope, distinguish model from harness, identify metric blind spots, and inventory scorecards, traces, configuration, and reproduction materials. For workplace agents, coding agents, computer-use agents, and other products that combine models with tools and connectors, apply `references/agent-product-announcements.md`: separate model, orchestration, action, extension, connector, artifact, governance, and economics layers; distinguish launch availability from current documentation and future roadmap; and audit permission and data-flow boundaries. For desktops, workstations, accelerators, chips, servers, and edge systems discussed through an AI-workload lens, apply `references/hardware-system-ai-releases.md`: build a tier-by-tier configuration matrix, keep base price separate from maximum capability, analyze memory/compute/runtime/system constraints, and preserve pre-shipping, privacy, ecosystem, and clustering limits. Resolve material contradictions before drafting. Completion criterion: every consequential claim is classified as reported fact, attributable claim, independent evidence, LiteBites interpretation, or uncertainty and has a source.

### 3. Design a source-adaptive editorial spine

Keep the six required level-two headings as the stable publication contract, but do **not** treat their paragraph prompts as a rigid article template. Before drafting, classify the source by its dominant evidence shape and identify the characteristic that should organize the story:

```text
Model release       → release delta → architecture/serving mechanism → access → evidence limits
Agent product       → action surface → orchestration/connectors → permissions/economics → reliability limits
Benchmark claim     → protocol → headline result → comparability/reproduction → metric blind spots
API or standard     → normative change → compatibility/migration → implementation status → residual risk
Security event      → timeline → root cause → blast radius → mitigation → remaining exposure
Hardware/system     → architecture → measurement protocol → cost/deployment → availability
Tool/repository     → changed behavior → integration path → maintenance/security → ecosystem fit
```

Use the closest shape or combine two when the source genuinely spans categories. Allocate words according to the evidence rather than evenly across sections. A model release may spend most of `## Technical context` on the mechanism that changes serving economics; a benchmark story may expand protocol and uncertainty; an agent launch may emphasize permissions and failure boundaries. Optional source-specific `###` subheadings are allowed when they improve navigation, but they must not replace, rename, reorder, or add to the six required `##` headings.

Write a one-line editorial spine before prose:

```text
Because <verified mechanism or change>, <practical consequence>; however, <main evidence limit>.
```

Reject generic spines that could describe any release. Use `references/source-adaptive-structure.md` for archetype-specific questions, word-budget guidance, subsection rules, and anti-template checks.

### 4. Draft from the ledger and spine

Write the six required sections around the chosen spine. Target 400–800 body words and approximately 2–4 minutes. Use exact dates instead of relative phrases that will become ambiguous. Prefer direct verbs and concrete nouns over promotional language.

Keep these voices distinct:

```text
Reported fact: “The release notes state…”
Attribution: “The company says…”
Independent evidence: “A separate benchmark found…”
LiteBites interpretation: “A useful way to read this is…”
Uncertainty: “It is not yet clear whether…”
```

Vary internal flow deliberately: lead each section with the fact or tension most important for this source, use transitions that carry the same editorial spine forward, and omit background that does not change the reader’s judgment. Do not force every release through identical paragraph counts, repeated stock phrases, or a feature-list chronology.

Do not turn an announcement into measured evidence, add tags to manufacture graph connections, or hide uncertainty to make the narrative cleaner. Completion criterion: prose follows the ledger and editorial spine, all six sections exist, the internal structure fits the source’s characteristics, and every source in the final list materially supports the article.

### Performance graphs and figure requests

The word “graph” is ambiguous on LiteBites: it may mean the site-wide knowledge graph or a performance-comparison chart inside an Article. When a request mentions figures, benchmarks, model comparisons, or “the latest post,” confirm the intended meaning before proposing graph architecture work.

For benchmark visuals, prefer a focused, readable figure covering only results discussed in the Article. Dense vendor collages should be evaluated at real article and mobile widths rather than embedded automatically. Prototype a source-faithful crop or original LiteBites replot only when the user separately and explicitly requests an original performance visualization as an editorial deliverable; a general request to add Article figures is not sufficient. Every value and model label must be checked against the source pixels; vendor-reported results and protocol differences must remain visually explicit. See `references/performance-comparison-figures.md` for the complete source-versus-replot, provenance, responsive-layout, and approval workflow.

During source review, identify whether a canonical publisher image would materially improve the explanation. If so, propose it as an optional inline figure and render it from the verified original HTTPS asset URL rather than downloading a copy. Confirm that the canonical page itself uses the exact asset and that the publisher controls the media infrastructure. Use the required `remote-publisher-image` figure markup with `data-source-url`, descriptive alt text, decoded intrinsic dimensions, lazy loading, asynchronous decoding, `no-referrer`, a source-linked caption, and a visible full-resolution link. Add the canonical page to `## Sources`; never use remote Markdown image syntax, `srcset`, or a remote `card_image`. The prose must remain understandable if the asset fails. Explain the unavoidable third-party request and publisher-controlled durability at the local checkpoint. Use `references/remote-publisher-images.md` for the complete admission, markup, privacy, responsive/failure testing, and deployment workflow. When the exact asset is served from an official publisher repository, also apply `references/repository-backed-publisher-assets.md`: verify organization identity, exact-use evidence, the license of the repository that actually contains the image, per-file exceptions, mutable-branch risk, and mobile readability for dense charts. Link the exact governing license in the caption or Sources and preserve any required copyright attribution; do not assume a project/model license covers documentation artwork without checking the asset-containing repository. A visible download link or press gallery is not permission by itself. When auditing several existing Articles, keep a temporary admit/reject ledger and accept that only one—or none—may qualify. If a small portrait asset is admitted, test its rendered size rather than inheriting the site's full-width image rule blindly; cap and center it with a reusable class when full-width rendering causes excessive upscaling.

If a post has no admissible canonical publisher-hosted image, skip the inline figure. Do not force presentation coverage by capturing screenshots, downloading third-party images into the repository, or creating a replacement local figure. A first-party LiteBites chart or diagram is outside the default Article Bite image workflow and should be produced only when the user explicitly requests an original visualization as a separate editorial deliverable; in that exceptional case, apply `references/first-party-explanatory-figures.md`.

When migrating several published Articles to this rule, process them sequentially: inventory the current figure and asset for one Article, choose admissible original-source embed or no figure, remove stale markup and repository assets, and run that Article's validator before moving to the next. After every Article is handled, run the batch tests, regenerate the knowledge graph twice, build the site, and assert the expected per-Article figure counts. This prevents a bulk edit from hiding stale references or accidental replacements.

### 5. Validate mechanically

Run:

```bash
ruby scripts/validate_article_bites.rb _articles/<slug>.md
```

Fix metadata, headings, URL, image, placeholder, and word-count failures. Re-run until it reports `PASS` and a count between 400 and 800 words. Dates must use exact `YYYY-MM-DD` values; required text and tags must be non-empty strings; the six required `##` headings must be the complete level-two heading sequence with no extras; the canonical `source_url` must appear inside `## Sources`, not merely elsewhere in the body; and normalized card-image paths must remain under `/assets/images/articles/`. Remote images must pass the fail-closed figure contract: rendered HTML rather than Markdown image syntax, exactly one `<img>` per `remote-publisher-image` figure, HTTPS image URL, canonical `data-source-url`, intrinsic dimensions, alt text, lazy loading, asynchronous decoding, image-request `no-referrer`, no `<picture>`, `<source>`, or `srcset`, caption links to source and full resolution, and the source URL present as an exact link destination under `## Sources`.

When the validator or schema changes, use the adversarial cases in `references/article-validation-hardening.md`; a single valid fixture is not sufficient.

Then inspect the diff for copied promotional language, unsupported causality, stale relative dates, missing attribution, and source links that do not support the adjacent claim. Mechanical success is necessary but not sufficient.

### 6. Refresh and review the graph

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

An isolated truthful node is better than a misleading connection. Use `references/knowledge-graph-topic-hygiene.md` for the adversarial regression pattern, generator-version rule, and before/after edge audit. When a subject name contains punctuation or version dots, use `references/slug-url-consistency.md` to verify that the filename, rendered permalink, graph id/URL, and inspector link all resolve to one canonical slug.

### 7. Build and inspect together

Activate a Ruby version compatible with the repository's GitHub Pages dependencies. Keep Bundler metadata, installed gems, and Jekyll output outside the repository:

```bash
export LITEBITES_TMP="${TMPDIR:-/tmp}/litebites-article-validation"
mkdir -p "$LITEBITES_TMP"
cp Gemfile "$LITEBITES_TMP/Gemfile"
export BUNDLE_GEMFILE="$LITEBITES_TMP/Gemfile"
export BUNDLE_PATH="$LITEBITES_TMP/ruby-bundle"
bundle check || bundle install
bundle exec jekyll build --destination "$LITEBITES_TMP/site"
```

A temporary Jekyll destination alone does not prevent Bundler from creating `Gemfile.lock` beside the active Gemfile. Record the initial untracked-file set before building and require the final set to match it; remove an accidentally created lockfile only when it was absent initially.

Inspect:

```text
/articles/
/articles/<slug>/
/
/graph/
/papers/
/data/
```

Verify the preferred Bite order is Article, Paper, Data wherever content categories are presented, including navigation, graph filters, legends, accessible directories, and no-JavaScript fallback content. Use an explicit type rank rather than alphabetical sorting. Confirm the Article index is newest-first, source metadata wraps, the homepage lists the article, and Paper Bite pagination remains paper-only. Resolve the rendered archive href and graph node URL independently; require both to equal `/articles/<slug>/`, return HTTP 200 in the built site, and match the graph inspector’s Open Bite href.

For automated graph interaction checks, target the visible SVG node shape (for example, `[data-node-id="article:<slug>"] .graph-node-shape`) rather than the enclosing `<g>` bounding box: label text may use `pointer-events: none`, causing center-point automation clicks to land on the SVG stage. After clicking, assert the node’s selected class, inspector title, and exact `/articles/<slug>/` link; do not treat mere node presence as an interaction pass.

At 320px, 375/390px, and desktop, check horizontal overflow, long titles, navigation, 44px targets, visible focus, light/dark themes, and no-JavaScript graph fallback. Completion criterion: build and browser checks pass with no console errors or missing local assets.

### 8. Prepare the local review checkpoint

Run:

```bash
git diff --check
git status --short --branch
git diff --stat
git diff
```

Exclude `_site`, `Gemfile.lock`, `.bundle`, `vendor`, caches, temporary screenshots, and planning artifacts from publication scope. Before presenting the checkpoint, obtain an independent review of the current production diff and explicitly named untracked implementation files. Treat asynchronous review results as snapshots: if any reviewed file changes afterward, re-run verification and dispatch a fresh review. Use `references/article-validation-hardening.md` for review freshness and adversarial checks.

For a claim-level source-fidelity review, keep the reviewer read-only and require a structured verdict with `passed`, `blocking_issues`, `nonblocking_notes`, `claim_checks`, and `files_modified_by_reviewer`. Each blocking issue must cite exact article line numbers, explain the evidence mismatch or policy failure, and give replacement-ready wording or a concrete fix. Check semantic scope, not just matching numbers: distinguish products from product families, model weights from CUDA-dependent runtimes or workflows, peak-compute ratios from measured workload speedups, and maximum configurations from base-price configurations. Verify linked source availability live, but treat HTTP success as availability evidence only—not support for a claim. When an internal link targets another untracked Bite, either include that companion in the named publication scope and verify both built URLs, or flag the dependency. Audit prose policy mechanically as well as editorially, including the required three-to-five Practical Takeaways even if the validator currently accepts more.

Report:

- canonical and corroborating sources;
- body word count and last-reviewed date;
- exact changed files;
- validator and Jekyll results;
- graph node/edge changes and idempotence;
- responsive and interaction checks;
- any claims that remain caveated.

Stop here unless the user explicitly authorizes commit and push.

### 9. Publish only with explicit approval

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
3. **Timeline collapse:** A source read today may have been published earlier, and current documentation may postdate the launch. Keep Article date, review date, source publication date, launch capability, current capability, and roadmap separate; never back-project current docs into the announcement.
4. **Product/model collapse:** A model benchmark does not establish the reliability of an agent product, and a product feature list does not establish model capability. Audit the complete orchestration, tool, connector, extension, permission, artifact, governance, and cost stack.
5. **Premature certainty:** Preserve missing benchmarks, compatibility limits, deployment constraints, and unknowns.
6. **Paper contamination:** Never save Article Bites in `_posts/`; it would mix pagination and policy.
7. **Graph gaming:** Never alter tags or prose solely to create edges.
8. **Remote-image drift:** Do not embed arbitrary web images, hotlink decorative marketing art, or use remote Markdown image syntax. Use only an informative original that the canonical publisher page references, then enforce HTTPS, provenance, intrinsic sizing, alt text, lazy loading, `no-referrer`, source/full-resolution caption links, responsive behavior, graceful failure, and the privacy/durability checkpoint.
9. **Build artifacts:** Keep dependency and generated site output outside the repository.
10. **Slug normalization split:** Punctuation in a source name can produce different Jekyll and graph slugs. Normalize the filename to lowercase letters, digits, and hyphens before generation, then compare the rendered archive href, built path, graph URL, and Open Bite href.
11. **Approval collapse:** A successful local build is not permission to commit or publish.

## Verification checklist

- [ ] Repository and pre-existing changes identified
- [ ] Canonical source read and verified
- [ ] Consequential claims corroborated where possible
- [ ] Evidence ledger complete
- [ ] Required metadata present and accurate
- [ ] Article date, last-reviewed date, source publication date, launch capability, current documented capability, and roadmap are not conflated
- [ ] For agent products, model, orchestration, actions, extensions, connectors, artifacts, governance, and economics were reviewed as separate layers
- [ ] Six sections appear exactly once and in order
- [ ] Body contains 400–800 words
- [ ] Source facts, interpretation, and uncertainty are distinct
- [ ] Every remote image is informative, publisher-origin verified, covered by an exact asset-level permission basis, linked to the governing license/required notice, validator-compliant, responsive/theme checked, failure-tested, and disclosed for privacy and durability
- [ ] If no admissible canonical publisher-hosted image exists, the Article omits the figure; no screenshot, downloaded third-party copy, or locally created presentation fallback was added
- [ ] Any first-party visualization exists only because the user explicitly requested an original visualization as a separate editorial deliverable, and it passed source-grounding, originality, responsive/theme, and failure review
- [ ] Validator reports PASS
- [ ] Graph generator run twice; second run reports zero changed sources
- [ ] Article node, URL, topics, and relationships reviewed
- [ ] Stable slug uses only lowercase letters, digits, and hyphens; archive href, built path, graph URL, and Open Bite href match and return HTTP 200
- [ ] Article page, index, homepage, graph, Paper Bites, and Data Bites built
- [ ] Mobile, desktop, themes, keyboard, and no-JavaScript fallback checked
- [ ] Adversarial validator cases checked when schema or validation changes
- [ ] Independent review covers the current tree and named untracked implementation files
- [ ] Diff contains no unrelated or generated artifacts
- [ ] Local review checkpoint presented
- [ ] Commit/push performed only after explicit approval
- [ ] Pages deployment—not merely the build—completed for the pushed SHA
- [ ] Cache-busted live surfaces and any remote image request verified
