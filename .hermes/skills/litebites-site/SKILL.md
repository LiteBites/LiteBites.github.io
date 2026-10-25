---
name: litebites-site
description: "Use when maintaining the LiteBites Jekyll/GitHub Pages site itself rather than writing a single Bite: layouts, includes, CSS, navigation, accessibility, the knowledge graph, validators and scripts, local preview, scheduled upkeep, Data Bite housekeeping, and explicitly authorized commits and publication of any Bite."
version: 2.0.0
author: Hermes Agent
license: MIT
platforms: [macos, linux, windows]
metadata:
  hermes:
    tags: [litebites, jekyll, github-pages, css, accessibility, publishing]
    related_skills: [litebites-article, litebites-paper]
---

# LiteBites Site

Procedure for site-level changes in the LiteBites repository, plus the shared publish procedure that the Article and Paper skills hand off to. Repository maps and folder rules come from the auto-loaded `AGENTS.md` files (root, `scripts/`, `_includes/`, `assets/images/`, and each content folder); do not restate them.

| Topic | Authority |
|---|---|
| Content rules | `POLICY_ARTICLE.md`, `POLICY_POST.md`, `POLICY_DATA.md`, `POLICY_REMOTE_IMAGES.md` |
| Mechanical schema | `_data/bite_schema.yml` + `scripts/validate_bites.rb` |
| Repo commands | `scripts/litebites` (see `scripts/AGENTS.md`) |
| Knowledge graph internals | `scripts/KNOWLEDGE_GRAPH.md` |
| Interactive components and their data shapes | `_includes/AGENTS.md` |

Data Bites have no separate skill: authoring guidance lives in `_datasets/AGENTS.md` and `POLICY_DATA.md`. For a single Article or Paper Bite, use `litebites-article` or `litebites-paper`.

## Workflow boundary

Implementing and validating never imply permission to commit, push, or deploy. Stop at the local preview checkpoint (step 6) unless the user explicitly authorized publication in this conversation. If the user asks for a plan or options first, stop before editing. Leave unrelated working-tree changes (the owner often has uncommitted work) untouched, and never stage them.

## Repo commands

| Command | Use |
|---|---|
| `scripts/litebites validate [paths...]` | schema validation of Bites |
| `scripts/litebites graph` / `graph --check` | regenerate graph twice (idempotence) / fail if stale |
| `scripts/litebites test` | all script test suites |
| `scripts/litebites build` | Jekyll build into a temp dir |
| `scripts/litebites check` | validate + test + graph --check + build + `git diff --check`; run before every checkpoint |
| `scripts/litebites preview [port]` | loopback preview at http://127.0.0.1:4179/ |

The CLI keeps Bundler and build output outside the repository. If you ever run Bundler directly, keep `BUNDLE_GEMFILE`/`BUNDLE_PATH` and `--destination` under `${TMPDIR:-/tmp}` so no `Gemfile.lock`, `_site/`, `.bundle/`, or `vendor/` appears in the repo; never change gem versions to fit a global Ruby.

## Procedure

### 1. Inspect before proposing
`git status --short --branch`. Read the affected layout/include, `assets/css/styles.css` region, `_config.yml`, and representative generated pages. Explain options in reader terms and recommend one.

### 2. Keep the change shared and small
Prefer a layout or `_includes/` component plus existing CSS tokens over editing individual Bites. New interactivity should be data-driven (front matter or `_data/` YAML rendered by an include) rather than new per-page JavaScript. No new dependencies without a reason the user accepts. If the feature must stay removable, put it in feature-specific files behind a `_config.yml` flag and test a build with the flag off.

### 3. Validators, schema, generator, scripts
Change code and tests together; run `scripts/litebites test`. For schema/validator or new-content-family work, use `references/validator-and-review-hardening.md`. For generator or graph-UI work, use `references/knowledge-graph-review.md`.

### 4. Run the checks
```bash
scripts/litebites check
```
Fix every failure. A passing build does not prove generated output is right: inspect the rendered HTML for the changed surfaces.

### 5. Browser verification
For any visual or interactive change follow `references/browser-verification.md` (route matrix, 320/375/desktop, light/dark, overflow, focus, 44px targets, no-JS fallback, design conventions).

### 6. Local preview checkpoint
```bash
scripts/litebites preview
```
Report: exact modified files; user-visible behaviour; check, responsive, theme, keyboard, and graph results; desktop/mobile previews for visual changes; confirmation that no build artifacts remain in the repo; and an explicit statement that nothing was committed or pushed. Stop the preview after review unless asked to keep it. Previews bind to loopback only; never expose a LAN, `0.0.0.0`, or tunnel address without a fresh explicit request. To clear a stale listener: `lsof -nP -iTCP:4179 -sTCP:LISTEN`, then `kill <that PID>` (never `killall ruby` or broad `pkill`).

**Stop here** unless publication is explicitly authorized.

### 7. Publish (only with explicit approval; shared by all Bite types)
1. `git fetch`; require local `HEAD` to equal the tracking branch, or reconcile deliberately. Never force-push.
2. Re-run `scripts/litebites check`.
3. Stage an explicit allowlist of intended paths (Bite, its assets, generated graph files, intended site files). Never stage the owner's unrelated changes, `.hermes/plans/`, `.DS_Store`, `Gemfile.lock` you created, screenshots, fixtures, or build output.
4. `git diff --cached --check`; review `git diff --cached --stat` and the full staged diff; confirm previously untracked production files are included.
5. Commit with a focused conventional message (`content: …`, `feat: …`, `fix: …`), push the approved branch, and verify that local `HEAD`, the tracking ref, and `git ls-remote` share one SHA.
6. A Pages build is not a deployment. Confirm the deploy for that SHA, then poll cache-busted live URLs until the new content appears (an early 404 or stale page is normal during propagation). Open the live page and graph, check the console, and report commit SHA, live URLs, and deployment evidence.

## Scheduled upkeep (Hermes cron)

Cron jobs only report; they never edit, commit, or push. Each run is a fresh session, so prompts must be self-contained; output `[SILENT]` when there is nothing to report. Typical jobs: weekly link and remote-image liveness (every `remote-publisher-image` URL still returns a decodable image), monthly stale-review audit (Article Bites with old `last_reviewed`). Record the exact `hermes cron create … --workdir <repo> --skill litebites-site` command for each job in `scripts/AGENTS.md` (or README) so jobs can be recreated; check there before creating a duplicate.

## Pitfalls

- Do not treat a successful Liquid edit as done without building and checking generated output.
- Do not leave plans, generated lockfiles, or screenshots as accidental repo changes.
- Do not add a duplicate index link when the global header already provides it.
- Do not hand-edit generated graph JSON; regenerate.
- Do not hard-code one machine's paths or Ruby prefix in committed scripts.
- Browser checks right after deployment may hit caches; use cache-busted URLs and the live DOM.
