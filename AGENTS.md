# LiteBites: agent guide

LiteBites is a Jekyll blog on GitHub Pages (branch `main`, root folder,
deployed by GitHub's own Pages build). It publishes three kinds of "Bites"
about AI and computer science. Folders with their own rules have an
`AGENTS.md`; read it when you work there.

## Map

| Bite | Source | URL | Editorial policy | Skill |
|---|---|---|---|---|
| Article Bite (news, releases, engineering posts) | `_articles/<slug>.md` | `/articles/<slug>/` | `POLICY_ARTICLE.md` | `litebites-article` |
| Paper Bite (one paper) | `_posts/YYYY-MM-DD-<slug>.md` | `/posts/<slug>/` | `POLICY_POST.md` | `litebites-paper` |
| Data Bite (one public dataset) | `_datasets/<slug>.md` | `/data/<slug>/` | `POLICY_DATA.md` | none (`_datasets/AGENTS.md`) |

Also:
- Remote images for every type: `POLICY_REMOTE_IMAGES.md`.
- Rules a script checks: `_data/bite_schema.yml`, `_data/tags.yml`, `_data/glossary.yml`.
- Site work (layouts, CSS, scripts, graph, publishing): skill `litebites-site`.
- Why things are this way: `docs/decisions/`. Named exceptions: `docs/exceptions.md`.

## Commands (run from the repo root)

| When | Command |
|---|---|
| Start a new Bite | `scripts/litebites new article\|paper\|data <slug>` |
| After editing a Bite | `scripts/litebites validate <path>` |
| After a Bite is final | `scripts/litebites graph` |
| Before any review checkpoint | `scripts/litebites check` |
| To look at the site | `scripts/litebites preview` → http://127.0.0.1:4179/ |
| Collect an article source | `python3 scripts/litebites_pipeline.py collect <url>` |

`check` runs the validator, the graph freshness check, all tests, a Jekyll
build with the site check, and `git diff --check`. CI runs the same command on
every push and pull request (`.github/workflows/check.yml`).

## Lifecycle of a Bite

1. Collect and read the canonical source. Build an evidence ledger; claims come from sources, never from memory.
2. `scripts/litebites new …`, then write under the matching policy.
3. `scripts/litebites validate <path>`. Fix what it reports instead of working around it.
4. `scripts/litebites graph` (it runs twice and confirms the second run changes nothing).
5. `scripts/litebites check`, then `scripts/litebites preview`, and inspect the page, its index, the homepage, and `/graph/` in light and dark themes.
6. **Stop at a local review checkpoint.** Report the changed files and what to look at.
7. Commit and push only after the owner explicitly approves, following `litebites-site`, step 7.

## Main rules

- **Source fidelity first.** Keep reported claims, independent evidence, interpretation, and uncertainty distinct. Never invent numbers, quotes, or links.
- **No commit, push, or deploy without explicit approval** in the current conversation.
- **Leave unrelated working-tree changes alone.** The owner often has uncommitted edits; never stage, revert, or reformat them.
- **Never hand-edit generated files:** `_data/knowledge-graph-state.json` and `assets/data/knowledge-graph.json`. Regenerate them.
- **Tags come from `_data/tags.yml`.** Reuse a tag when one fits. Never add or change tags just to create graph links.
- **Mechanical rules live in the schema.** To change one, edit `_data/bite_schema.yml` and its tests, not the prose. If a policy and the schema disagree, report it.
- **Interactive features are data**, rendered by `_includes/` components (`_includes/AGENTS.md`). Never put `<script>` in a Bite.
- **Keep build output out of the repo.** No `_site/`, `Gemfile.lock`, `.bundle/`, `vendor/`, or screenshots. The CLI builds in a temp folder.
- Repository documents (`AGENTS.md`, `POLICY_*.md`, `docs/`) are excluded in `_config.yml`. When adding a new one, exclude it too; the site check fails if one gets published.
