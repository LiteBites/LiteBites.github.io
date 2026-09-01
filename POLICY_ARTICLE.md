# LiteBites Article Bite Policy

This document defines the standing editorial policy for Article Bites: concise analyses of recent technical news, engineering posts, release notes, standards, and industry developments.

## Purpose and scope

Article Bites explain what changed, why it matters technically, and what remains uncertain. They are not press-release rewrites, rumor roundups, or substitutes for original reporting. Public-facing prose is English-first, concrete, and readable in approximately 2–4 minutes.

Each Article Bite should contain **400–800 body words**. Prefer enough context to support an informed judgment over artificial brevity, but remove background that does not change the reader's understanding.

## Source hierarchy

Prefer sources in this order:

1. Original technical blogs, release notes, standards, filings, repositories, documentation, or official announcements.
2. Direct clarification from the responsible author, maintainer, standards body, or organization.
3. Independent reputable reporting, benchmarks, or expert analysis for corroboration and context.
4. Social posts only as attributable statements, never as the sole evidence for consequential technical claims.
5. Search snippets and generated summaries only for discovery, never as evidence.

Record the canonical source name, URL, publication date, and the date on which LiteBites last reviewed the story. Check that every public link resolves to the intended source.

## Fact, attribution, and interpretation rules

Keep these voices distinct:

- **Reported fact:** “The release notes state…”
- **Attribution:** “The company says…”
- **Independent evidence:** “A separate benchmark found…”
- **LiteBites interpretation:** “A useful way to read this is…”
- **Uncertainty:** “It is not yet clear whether…”

Do not present a product announcement as independent validation. Do not convert an estimate, roadmap, marketing claim, or demonstration into a measured result. Avoid copied promotional language, invented consensus, unsupported causality, and certainty beyond the available sources.

Use inline links for consequential claims when practical. The final Sources section must list the canonical source and any additional source that materially supports the analysis.

## Required metadata

Every Article Bite requires:

```yaml
layout: article
title: "Exact descriptive article title"
short_title: "Compact index title"
date: YYYY-MM-DD
type: "Article Bite"
read_time: "N min read"
source_name: "Canonical publisher or author"
source_url: "https://..."
source_published: YYYY-MM-DD
last_reviewed: YYYY-MM-DD
tags:
  - Precise Topic
summary: "One accurate sentence explaining the development and its significance."
```

Optional fields include `additional_sources`, `card_image`, and `card_image_alt`. If `card_image` exists, `card_image_alt` is required. Card images and repository-managed media must live under `assets/images/articles/<slug>/`.

Publisher-hosted inline images are an optional Article Bite feature. Consider one when a diagram, result, interface, or other source image materially improves the explanation; do not add decorative promotional artwork merely to fill space. Render the image directly from its original HTTPS publisher URL rather than downloading a repository copy. The exact asset must appear on the canonical publisher page and use that publisher's media infrastructure. Direct embedding also requires terms, license language, or asset-specific permission compatible with public display. When no admissible original-source image exists—or permission is restrictive or unclear—omit the figure and use descriptive prose plus a normal canonical source link. Do not fill the gap by capturing a screenshot, downloading third-party media into the repository, or creating a local replacement figure merely for presentation.

Every remote image must use the reviewed `<figure class="remote-publisher-image" data-source-url="…">` contract: exactly one `<img>` with descriptive alt text, decoded intrinsic `width` and `height`, `loading="lazy"`, `decoding="async"`, and `referrerpolicy="no-referrer"`; plus exactly one `<figcaption>` linking both the canonical source page and the full-resolution image. `data-source-url` must appear as an exact link destination in `## Sources`. Remote Markdown image syntax, `<picture>`, `<source>`, and `srcset` are not allowed because they bypass the required provenance, privacy, and layout safeguards. The prose must remain understandable if the publisher removes or replaces the asset, and remote images must never be used as `card_image` or another discovery-surface dependency.

At the local review checkpoint, disclose that the automatic image request still exposes the visitor's IP address and request metadata to the publisher even with the image element's `no-referrer`, that ordinary image/caption link clicks may send a navigation referrer unless separately controlled, and that the publisher controls the asset's durability and contents. Verify permission, origin, dimensions, rendering, failure behavior, and live delivery before publication.

## Standard six-section structure

Use these headings exactly once and in this order:

1. `## What happened`
2. `## Why it matters`
3. `## Technical context`
4. `## What remains uncertain`
5. `## Practical takeaways`
6. `## Sources`

### What happened

State the development, responsible organization or author, publication date, and concrete scope. Lead with verified information rather than commentary.

### Why it matters

Explain the technical or operational consequence. Separate immediate impact from possible longer-term implications.

### Technical context

Provide only the background needed to understand the change: architecture, protocol, benchmark, deployment model, standards process, or relationship to prior work.

### What remains uncertain

Identify missing evidence, deployment limits, unavailable benchmarks, unresolved compatibility questions, incentives, or claims that have not been independently verified.

### Practical takeaways

End with three to five concise observations or checks that a practitioner can reuse. Avoid generic praise and predictions presented as facts.

### Sources

List the canonical source first. Add corroborating or contextual sources only when they materially support the analysis. Use descriptive link labels rather than bare URLs.

## Word count and reading time

Count body words while excluding YAML front matter and raw HTML where practical. Keep the result between 400 and 800 words. Estimate reading time at approximately 200–230 words per minute and round to a sensible whole minute.

## Images and external media

Images are optional. Include one only when it explains the technical development, interface, architecture, or evidence. For Article Bites, use a canonical publisher-hosted original only when it satisfies the remote-image contract above. Preserve provenance, use descriptive alt text, and avoid decorative screenshots or promotional artwork that adds no understanding. If no compliant original-source URL is available, publish the Article without an image; do not force visual coverage through screenshots, downloaded copies, or locally created presentation substitutes.

## Corrections and temporal claims

`last_reviewed` records when the analysis was last checked against its sources. If a consequential claim later changes, add a visible update or correction note rather than silently rewriting history. Minor clarity and typo fixes do not require a correction note.

Use exact dates instead of relative phrases such as “today” or “recently” when ambiguity could develop over time.

## Quality gate

Before review, verify:

- The canonical source and date are correct.
- Consequential technical claims are attributed and corroborated where possible.
- Facts, source claims, interpretation, and uncertainty are distinguishable.
- The body contains 400–800 words and all six headings in order.
- Metadata, links, local assets, alt text, and reading time are valid.
- Every remote image satisfies the publisher-hosted figure contract and has verified origin, dimensions, responsive rendering, failure behavior, and privacy/durability disclosure.
- An Article without an admissible original-source image contains no forced screenshot, downloaded copy, or locally created presentation substitute.
- Tags are precise and were not selected merely to force graph relationships.
- The knowledge graph was generated twice; the second run reports zero changed sources.
- The Article page, newest-first index, homepage, and graph were built and inspected.

## Publication boundary

Successful drafting and validation stop at a local review checkpoint. Commit, push, deployment, or publication requires explicit user approval.
