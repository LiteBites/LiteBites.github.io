# LiteBites

LiteBites is a minimal English research blog for bite-sized AI and computer science paper notes.

See [USAGE.md](USAGE.md) for agent-assisted Bite authoring, knowledge-graph updates, and the local preview workflow.

## Stack

- GitHub Pages
- Jekyll
- Markdown collections for Article, Paper, and Data Bites
- IBM Plex Sans

## Site structure

- `index.html` — Home
- `articles.html` — Article Bites index at `/articles/`
- `papers.html` — Paper Bites index at `/papers/`
- `data.html` — Data Bites index at `/data/`
- `graph.html` — Knowledge graph at `/graph/`
- `_articles/<slug>.md` — Individual Article Bites
- `_posts/YYYY-MM-DD-slug.md` — Individual paper posts
- `_datasets/<slug>.md` — Individual Data Bites
- `assets/css/styles.css` — Site styles

## Local development

Start the local preview:

```bash
./scripts/preview.sh
```

Open:

```text
http://127.0.0.1:4179/
```

Press `Ctrl+C` in the same terminal to stop the server. See [USAGE.md](USAGE.md) for custom ports, graph generation, agent-assisted authoring, validation, and project-local skills.

## Writing posts

Create a new Markdown file under `_posts/`:

```text
_posts/YYYY-MM-DD-short-slug.md
```

Use this front matter:

```yaml
---
layout: post
title: "Post title"
short_title: "Short title"
date: YYYY-MM-DD
type: "Paper brief"
read_time: "6 min read"
venue: "Conference or source"
tags:
  - Topic
  - Topic
summary: "One-sentence summary."
paper_url: ""
code_url: ""
source_note_url: ""
---
```

Use `POLICY_POST.md` for the post writing format.

## GitHub Pages

For a `*.github.io` repository, GitHub Pages can build Jekyll automatically.

Recommended settings:

- Source: `Deploy from a branch`
- Branch: `main`
- Folder: `/root`

Do not add `.nojekyll`; this site intentionally uses Jekyll.
