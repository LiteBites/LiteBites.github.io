# _posts/: Paper Bites

One file per paper: `_posts/YYYY-MM-DD-<slug>.md` → `/posts/<slug>/`. The filename date must equal front-matter `date`.

- **Editorial rules:** `POLICY_POST.md`. **Mechanics for paper tooling:** `.paper-archive.toml` (kept in sync with the schema by a test).
- **Field rules:** `_data/bite_schema.yml` → `types.paper`. Create with `scripts/litebites new paper <slug> --date YYYY-MM-DD`; check with `scripts/litebites validate <path>`.
- **Procedure:** skill `litebites-paper` (research first, then write).

Contract summary (the validator is authoritative):
- `title` is the exact canonical paper title; `short_title` is the display name.
- Required: `venue`, `read_time`, `tags`, `summary`, `paper_url`, plus `layout: post` and `type: Paper brief`.
- 900–1,800 body words for Bites dated 2026-07-06 or later (older ones are listed in `docs/exceptions.md`).
- At least four narrative `##` sections, then a final `## Links` that links `paper_url` exactly.
- Figures go in `assets/images/papers/<slug>/` (see `assets/images/AGENTS.md`). `card_image` must be one of those local files.
- Results tables: prefer front-matter `benchmarks:` with `{% include benchmarks.html index=0 %}`. Keep every number exactly as printed in the paper, quoted as strings, and give each row a caveat when its protocol differs. See `_includes/AGENTS.md`.
- `check_yourself:` (1–5 questions) is optional; answers must come from the post itself.

Example of every component: `_posts/2026-10-06-novalad-document-extraction.md`.
