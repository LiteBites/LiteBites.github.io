# LiteBites

LiteBites is a minimal English research blog with bite-sized notes on AI and computer science: **Article Bites** (news and engineering posts), **Paper Bites** (one paper each), and **Data Bites** (public datasets).

The site is maintained mostly by an agent (Hermes Agent). Agents start from [`AGENTS.md`](AGENTS.md); this README is the human overview.

## Stack

- GitHub Pages branch build (`main`, root folder) with Jekyll and the `github-pages` gem. Do not add `.nojekyll`.
- Markdown collections: `_articles/`, `_posts/`, `_datasets/`.
- IBM Plex Sans / Mono, no front-end framework. Interactive features are small includes plus `assets/js/site.js`.

## Everyday commands

```bash
scripts/litebites new article <slug>      # or: paper <slug> --date YYYY-MM-DD, data <slug>
scripts/litebites validate [paths...]     # schema checks for Bites
scripts/litebites graph                   # regenerate the knowledge graph (runs twice)
scripts/litebites check                   # everything CI runs
scripts/litebites preview [port]          # http://127.0.0.1:4179/
```

`preview` binds to `127.0.0.1` only and keeps Bundler files and build output in your temp folder, so it never creates `Gemfile.lock` or `_site/` in the repo. Press `Ctrl+C` to stop it. If a listener stays behind, find it with `lsof -nP -iTCP:4179 -sTCP:LISTEN` and `kill <PID>`. Avoid `killall ruby`.

Requirements: Ruby with Bundler (Ruby 3.1 is preferred for the Jekyll build; Homebrew `ruby@3.1` is picked up automatically) and Python 3 for the article source pipeline.

## Where things live

| What | Where |
|---|---|
| Editorial policies | `POLICY_ARTICLE.md`, `POLICY_POST.md`, `POLICY_DATA.md`, `POLICY_REMOTE_IMAGES.md` |
| Mechanical rules (fields, word ranges, sections) | `_data/bite_schema.yml`, enforced by `scripts/validate_bites.rb` |
| Tag vocabulary / glossary | `_data/tags.yml` / `_data/glossary.yml` |
| Agent instructions | `AGENTS.md` and per-folder `AGENTS.md` files |
| Agent skills | `.hermes/skills/litebites-article`, `litebites-paper`, `litebites-site` |
| Decisions and exceptions | `docs/decisions/`, `docs/exceptions.md` |
| Knowledge graph | `scripts/generate_knowledge_graph.rb`, `scripts/KNOWLEDGE_GRAPH.md`, `/graph/` |
| Interactive components | `_includes/` (documented in `_includes/AGENTS.md`), `assets/css/components.css`, `assets/js/site.js` |

Pages: `/` home, `/archive/` (articles and papers, filterable by topic), `/articles/`, `/papers/`, `/data/`, `/graph/`. Press `/` or `Cmd/Ctrl+K` anywhere to search.

## Working with Hermes

Start Hermes from the repository root so it loads `AGENTS.md` and the project skills:

```bash
cd /path/to/LiteBites.github.io
hermes            # after adding or changing project skills: hermes skills trust, then /reload-skills
```

Example requests:

```text
Write a new LiteBites Article Bite about <canonical URL>. Stop at a local preview checkpoint.
(Add "use long_form: true" only when you want a deep, multi-topic piece of up to 1,600 words.)

Research and write a Paper Bite for <arXiv ID or URL>. Use benchmarks: for the main
results table if it helps. Stop at a local preview checkpoint.

Create a Data Bite for <dataset page>. Verify license and access terms first.
```

Drafting and validation never imply permission to commit or push. Agents stop at a local review checkpoint, and publishing follows `litebites-site`, step 7, after you approve.

The general-purpose skills `arxiv`, `ocr-and-documents`, and `humanizer` stay profile-installed and are not copied into this repo.

## Continuous integration

`.github/workflows/check.yml` runs `scripts/litebites check` on every push and pull request. It only checks; deployment remains GitHub Pages' branch build.
