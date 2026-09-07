# LiteBites Post Policy

This document defines the default writing policy for LiteBites posts. Use it as the standing reference when turning papers, demos, or technical notes into public posts for the site.

## Core principles

1. **English-first**
   - All public-facing posts should be written in English.
   - Keep sentences short, concrete, and easy to scan.
   - Prefer plain technical English over promotional or exaggerated language.

2. **Writing-focused minimalism**
   - The post should help the reader understand the paper, not admire the page design.
   - Use headings, spacing, short paragraphs, and carefully chosen figures as the main structure.
   - Avoid decorative claims, invented metrics, or unnecessary visual noise.

3. **Bite-sized but not shallow**
   - Each post should be readable in roughly 5–8 minutes.
   - Explain the core idea before details, modules, or benchmark tables.
   - Include enough technical substance that the reader can continue studying the original paper.

4. **Respect the source**
   - Link to the paper, project page, and code when available.
   - Do not overstate the contribution beyond what the source supports.
   - Distinguish paper claims, personal interpretation, and practical reading advice.

## Default Paper Bite structure

Use the current LiteBites Paper Bite structure unless the user explicitly asks for another format.

1. `## Why this paper matters`
2. `## The bite`
3. `## How it works`
4. `## What to look at in the results`
5. `## Practical takeaways`
6. `## Links`

Keep each section concise. Prefer a small number of clear paragraphs over exhaustive reproduction of the source note.

### 1. Header

Include:

- Post type, such as `Paper brief`, `Demo note`, or `Reading guide`
- Title
  - For paper posts, `title` must be the exact paper title from an official or canonical source such as the official paper page, arXiv, OpenReview, CVF, or ACL Anthology.
  - Do not paraphrase, simplify, translate, or add informal aliases in `title`.
  - Use `short_title` for compact display names such as `ControlNet`, `LoRA`, or `Chain-of-Zoom`.
- One-paragraph summary
- Metadata such as reading time, topic tags, venue, and source links
- For a Paper Bite with a captured figure, `card_image` must point to the local figure used for the homepage thumbnail, and `card_image_alt` must describe that visual for the card.

### 2. Why this paper matters

This is the motivation section. Answer:

- What problem does this paper address?
- Why should a reader care?
- What practical situation does this paper help with?

### 3. The bite

This is the central idea in 1–3 paragraphs.

It should be understandable before the reader sees equations, internal module names, or long benchmark discussion.

### 4. How it works

Explain the method using a small number of named parts.

For model architecture papers, focus on:

- The baseline problem
- The new module or interaction
- How information flows through the system
- What is trained, reused, or adapted

For systems or demo papers, focus on:

- Inputs and outputs
- Main pipeline
- Key design decision
- Failure modes or constraints

### 5. What to look at in the results

Summarize how to read the evidence.

Do not list every number. Instead, explain:

- What comparisons matter
- Which tasks or datasets are most relevant
- What result would change a reader's mind
- Any caveats or limitations

### 6. Practical takeaways

End with 3–5 concise bullets.

Good takeaways are reusable ideas, reading guidance, or practical lessons. They should not be generic praise.

### 7. Links

Include source links at the end when available:

- Paper
- Project page
- Code
- Related notes, if any

## Figure policy for paper posts

Figures are not the main point of LiteBites posts, but they should be included when they materially improve understanding. In current practice, paper posts are usually stronger with carefully selected figures.

### Asset convention

- Store paper figures under `assets/images/papers/<slug>/`.
- The `<slug>` should match the post slug used in `_posts/YYYY-MM-DD-<slug>.md`.
- Keep filenames simple and stable, for example `method-01.png` or `results-01.png`.

### Selection convention

Use figures selectively rather than filling the post with screenshots.

- Usually include **one figure in `## How it works`** to explain the method, architecture, or workflow.
- Usually include **one figure in `## What to look at in the results`** to help the reader interpret the evidence.
- If a figure does not improve understanding, it is better to omit it.

### Figure quality

- Prefer complete, uncropped figures when readability or context would otherwise be lost.
- Avoid overly tight crops that remove labels, legends, arrows, or comparison context.
- Use the original paper figure when possible instead of recreating a low-quality approximation.

### Figure markup

Use local figure blocks with HTML so captions and layout stay consistent.

```html
<figure>
  <img src="{{ '/assets/images/papers/<slug>/<file>.png' | relative_url }}" alt="Descriptive alt text" />
  <figcaption>Paper figure: brief explanation of what the figure shows and why it matters.</figcaption>
</figure>
```

Rules:

- Use local asset paths, not external hotlinks.
- Write meaningful `alt` text that describes the visual content.
- Use `figcaption` to explain why the figure matters in the post.
- Leave blank lines around raw HTML blocks so Markdown parsers do not merge them into surrounding text incorrectly.

### Layout expectations

- Figures must fit inside the post layout without overflowing the article width.
- Figures must remain readable on mobile.
- Post content should assume the site CSS is responsible for responsive rendering, but the post author should still avoid unusually large or awkward figure usage.

## Maintenance and verification

When a post includes figures, verify the references before considering the work done.

- Make sure every referenced figure file actually exists.
- If assets are renamed, moved, or manually replaced, update the post references to match.
- Confirm that the figure and its caption still correspond to each other after any asset change.
- Prefer fixing broken references in the Markdown rather than silently removing figure usage.

## Tone guide

Use:

- “The key idea is…”
- “This matters because…”
- “A useful way to read the result is…”
- “The limitation is…”

Avoid:

- “This revolutionary paper…”
- “Clearly outperforms everything…”
- “It is obvious that…”
- Dense acronym chains without explanation

## Suggested Jekyll mapping

The site uses Jekyll, so every public post should live as a Markdown file under `_posts/`.

- File naming: `_posts/YYYY-MM-DD-short-slug.md`
- Layout: `layout: post`
- Required front matter: `title`, `short_title`, `date`, `type`, `read_time`, `venue`, `tags`, `summary`
- Recommended source fields: `paper_url`, `code_url`, `source_note_url`, `project_url`
- `index.html` and `papers.html` should render paper post lists from `site.posts` rather than hard-coded cards.
- `data.html` should keep Data Bites as concise curated dataset cards until a dedicated dataset collection is introduced.
