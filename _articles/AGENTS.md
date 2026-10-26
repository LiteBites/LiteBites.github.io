# _articles/: Article Bites

One file per Article Bite: `_articles/<slug>.md` → `/articles/<slug>/`. The slug is lowercase kebab-case and never changes after publication.

- **Editorial rules:** `POLICY_ARTICLE.md` (sources, attribution voices, 400–800 words, adaptive sections, practical ending).
- **Field rules:** `_data/bite_schema.yml` → `types.article`. Create the file with `scripts/litebites new article <slug>`, then run `scripts/litebites validate _articles/<slug>.md`.
- **Procedure:** skill `litebites-article`.

Contract summary (the validator is authoritative):
- Required front matter: `title`, `short_title`, `date`, `source_name`, `source_url`, `source_published`, `last_reviewed`, `tags`, `summary`, plus `layout: article` and `type: Article Bite`.
- 400–800 body words. `long_form: true` (unquoted boolean) allows up to 1,600, and only when the owner explicitly asked for a deep, multi-topic piece.
- At least three narrative `##` sections, then exactly one final `## Sources` that links `source_url` exactly.
- `additional_sources` entries need `name` and an HTTPS `url`.
- `card_image` (optional) lives under `/assets/images/articles/<slug>/` and needs `card_image_alt`. Remote images are never card images.
- Remote publisher images use the `figure.remote-publisher-image` contract in `POLICY_REMOTE_IMAGES.md`. LiteBites diagrams use `figure.article-figure` with a `LiteBites synthesis` caption. The validator checks both.

Tags and the graph: article graph topics come only from `tags`. Choose tags that describe the story, from `_data/tags.yml`. A thin graph is fine; a forced link is not.

This file is excluded from the site build (`_config.yml`).
