# LiteBites

LiteBites is a minimal English research blog for bite-sized AI and computer science paper notes.

## Stack

- GitHub Pages
- Jekyll
- Markdown posts in `_posts/`
- IBM Plex Sans

## Site structure

- `index.html` — Home
- `post.html` — Post index at `/post/`
- `gallery.html` — Gallery at `/gallery/`
- `_posts/YYYY-MM-DD-slug.md` — Individual posts
- `assets/css/styles.css` — Site styles

## Local development

Install dependencies:

```bash
bundle install
```

Run the local server:

```bash
bundle exec jekyll serve --livereload
```

Open:

```text
http://localhost:4000
```

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
