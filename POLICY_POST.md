# LiteBites Post Policy

This document defines the default writing structure for LiteBites posts. Use it as a standing reference when turning papers, demos, or technical notes into blog posts.

## Core principles

1. **English-first**
   - All public-facing posts should be written in English.
   - Keep sentences short and concrete.
   - Prefer plain technical English over promotional language.

2. **Writing-focused minimalism**
   - The post should help the reader understand the paper, not admire the page design.
   - Use headings, spacing, and short paragraphs as the main visual structure.
   - Avoid unnecessary icons, invented metrics, or decorative claims.

3. **Bite-sized but not shallow**
   - Each post should be readable in roughly 5–8 minutes.
   - Explain the core idea before implementation details.
   - Include enough technical substance for a reader to continue studying the paper.

4. **Respect the source**
   - Link to the paper/project/code when available.
   - Do not overstate the contribution beyond what the paper supports.
   - Distinguish paper claims, personal interpretation, and practical reading advice.

## Default post structure

### 1. Header

Include:

- Post type, e.g. `Paper brief`, `Demo note`, `Reading guide`
- Title
  - For paper posts, `title` must be the exact paper title from the official paper page, OpenReview, arXiv, CVF, ACL Anthology, or another canonical source.
  - Do not paraphrase, simplify, or add informal aliases in `title`.
  - Use `short_title` for compact display names such as `ControlNet`, `LoRA`, or `Chain-of-Zoom`.
- One-paragraph summary
- Metadata: reading time, topic tags, source links

### 2. Why this paper matters

A short motivation section. Answer:

- What problem does this paper address?
- Why should a reader care?
- What practical situation does this paper help with?

### 3. The bite

The central idea in 1–3 paragraphs.

This is the most important section. It should be understandable before the reader sees equations or module names.

### 4. How it works

Explain the method using a small number of named parts.

For model architecture papers, use:

- The baseline problem
- The new module or interaction
- How information flows through the system
- What is trained, reused, or adapted

For systems/demo papers, use:

- Inputs and outputs
- Main pipeline
- Key design decision
- Failure modes or constraints

### 5. What to look at in the results

Summarize how to read the experimental evidence.

Do not list every number. Instead, explain:

- What comparisons matter
- Which tasks or datasets are most relevant
- What result would change a reader's mind
- Any caveats

### 6. Practical takeaways

End with 3–5 concise bullets.

Good takeaways are reusable ideas, not generic praise.

### 7. Links

Include source links at the end:

- Paper
- Project page
- Code
- Related notes, if any

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

## Current post style

Use the current LiteBites post style unless the user asks for a different format:

1. `## Why this paper matters`
2. `## The bite`
3. `## How it works`
4. `## What to look at in the results`
5. `## Practical takeaways`
6. `## Links`

Keep each section concise. Prefer a small number of clear paragraphs over exhaustive reproduction of the source note. Preserve the source note's main technical focus, but rewrite it into polished English prose for the public blog.

## Suggested Jekyll mapping

The site uses Jekyll so every public post should live as a Markdown file under `_posts/`.

- File naming: `_posts/YYYY-MM-DD-short-slug.md`
- Layout: `layout: post`
- Required front matter: `title`, `short_title`, `date`, `type`, `read_time`, `venue`, `tags`, `summary`
- Recommended source fields: `paper_url`, `code_url`, `source_note_url`, `project_url`
- `index.html` and `papers.html` should render paper post lists from `site.posts` rather than hard-coded cards.
- `data.html` should keep Data Bites as concise curated dataset cards until a dedicated dataset collection is introduced.
