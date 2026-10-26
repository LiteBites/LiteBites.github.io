# _datasets/: Data Bites

One file per public dataset: `_datasets/<slug>.md` → `/data/<slug>/`. There is no separate skill; this file and `POLICY_DATA.md` are the guide.

## Procedure
1. Find the dataset owner's canonical page, license file, and paper. Verify owner, task, scale, license per subset, access terms, and known limits (`POLICY_DATA.md`).
2. `scripts/litebites new data <slug>` and replace every `TODO`.
3. Front matter: `domain`, `task`, `summary`, `use_for`, `scale`, `license`, `caveat`, `dataset_url`, `tags`. Optional: `image` + `image_alt`, `paper_url`, `last_reviewed`. No `layout` field; `_config.yml` sets it.
4. Body: 40–400 words, plain paragraphs with no `##` sections. The layout renders a "Dataset facts" list and links from front matter, so do not repeat them.
5. An optional image goes in `assets/images/datasets/<slug>.<ext>`, only when the license allows it.
6. `scripts/litebites validate _datasets/<slug>.md`, `scripts/litebites graph`, `scripts/litebites check`, preview `/data/` and `/data/<slug>/`, then stop for review.

Graph topics for datasets come from `domain` and `task`, plus generator concept rules, not from `tags`.
