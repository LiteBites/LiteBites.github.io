---
name: litebites-article
description: "Use when researching, drafting, revising, or correcting a LiteBites Article Bite (_articles/) from recent technical news, release notes, standards, repositories, or engineering posts. Collect and verify sources, build an evidence ledger, draft a source-adaptive analysis under POLICY_ARTICLE.md, run the repo validator and checks, and stop at a local preview checkpoint unless publication is explicitly authorized."
version: 2.0.0
author: Hermes Agent
license: MIT
platforms: [macos, linux, windows]
metadata:
  hermes:
    tags: [litebites, technical-news, analysis, jekyll]
    related_skills: [litebites-paper, litebites-site, humanizer]
---

# LiteBites Article

Procedure for one Article Bite: a short, evidence-backed analysis of a recent technical development. This skill is the *how*. The rules live in the repo and win over anything here:

| Topic | Authority |
|---|---|
| Editorial standard, voice, structure jobs, sources, corrections | `POLICY_ARTICLE.md` |
| Publisher-hosted images | `POLICY_REMOTE_IMAGES.md` |
| Required front matter, word range, sections, tags, figure markup | `_data/bite_schema.yml`, enforced by `scripts/litebites validate` |
| Folder conventions | `_articles/AGENTS.md`, `assets/images/AGENTS.md` |
| Interactive components (`claim.html`, glossary terms) | `_includes/AGENTS.md` |

Do not copy rules from those files into your notes or prompts. Read them, then run the validator and fix what it reports.

Not for: academic papers (use `litebites-paper`), Data Bites (`_datasets/AGENTS.md`, `POLICY_DATA.md`), site-wide layout/graph work (use `litebites-site`), or rumors without a stable canonical source.

## Workflow boundary

Drafting, validating, and previewing never imply permission to commit, push, or deploy. Stop at the local preview checkpoint (step 8) unless the user has explicitly authorized publication in this conversation. Leave unrelated working-tree changes untouched.

## Procedure

### 1. Orient
- `git status --short --branch`; note pre-existing changes so you never stage or revert them.
- Read `POLICY_ARTICLE.md` and one or two recent `_articles/*.md` that resemble the source type.

### 2. Collect the source
```bash
python3 scripts/litebites_pipeline.py collect <canonical-url>
```
Use the cached `review-input.md` as the starting packet (see `scripts/LITEBITES_PIPELINE.md`). Then open the canonical source itself and whatever determines the technical claim: release notes, docs, repository diff, spec text, benchmark page, filing.

### 3. Build the evidence ledger
Copy `templates/evidence-ledger.md` to `/tmp` and fill it. Classify every consequential claim as reported fact, attributable claim, independent evidence, LiteBites interpretation, or uncertainty, each with a recoverable source location. Corroborate performance, safety, cost, compatibility, and adoption claims independently where possible; otherwise attribute and name the gap. Load the reference that matches the source:

- vendor benchmark records, perfect scores, "frontier" claims → `references/vendor-benchmark-claims.md`
- agents, coding/computer-use/workplace products → `references/agent-product-announcements.md`
- chips, workstations, servers, edge systems → `references/hardware-system-ai-releases.md`

Keep four dates distinct: source publication (`source_published`), review date (`last_reviewed`), launch capability, and current documented capability or roadmap. Never back-project current docs into the launch.

Done when every planned sentence maps to a ledger row and contradictions are resolved or stated.

### 4. Choose the structure
Classify the source archetype and write the one-line editorial spine. Pick source-specific `##` headings per `POLICY_ARTICLE.md`. Use `references/source-adaptive-structure.md` for archetype priorities, word allocation, and anti-template checks.

### 5. Scaffold and draft
```bash
scripts/litebites new article <slug> [--date YYYY-MM-DD]
```
The slug is lowercase ASCII words joined by hyphens; turn punctuation and version dots into hyphens (`GLM-5.3-Flash` → `glm-5-3-flash`). Fill the scaffolded front matter from the ledger, then draft from the ledger and spine. Keep fact, attribution, interpretation, and uncertainty in distinct voices; use exact dates. Choose tags that truthfully describe the story, never to manufacture graph edges.

Optional: mark key sentences with `{% include claim.html kind="..." text="..." %}` or glossary terms when they genuinely help (see `_includes/AGENTS.md`).

### 6. Figures (optional)
Decide during source review whether a visual would materially improve understanding.
- Publisher-hosted original → admit only under `POLICY_REMOTE_IMAGES.md`; verify with `references/remote-image-review.md`.
- LiteBites diagram or benchmark replot → `references/original-visualizations.md`.
- Otherwise no figure. Never a screenshot or downloaded publisher copy.

### 7. Validate, then refresh derived state
```bash
scripts/litebites validate _articles/<slug>.md   # fix every reported error, re-run until clean
scripts/litebites graph                          # after tags/slug/summary are final
scripts/litebites check                          # validate + tests + graph --check + build + diff --check
```
Mechanical success is necessary, not sufficient. Re-read the diff for copied promotional language, unsupported causality, stale relative dates, missing attribution, and links that do not support the adjacent claim. Review the new `article:<slug>` node and its edges with `litebites-site` → `references/knowledge-graph-review.md`. A truthful isolated node beats a misleading edge.

### 8. Local preview checkpoint
```bash
scripts/litebites preview      # http://127.0.0.1:4179/
```
Inspect `/articles/<slug>/`, `/articles/`, `/`, and `/graph/` (click the node; Open Bite must land on `/articles/<slug>/`) at desktop and ~375px, light and dark. Stop the preview when done unless asked to keep it.

For a claim-level fidelity review, use a read-only reviewer with a fresh view of the current tree, and name untracked files explicitly (plain `git diff` omits them). If any file changes after the review, the verdict is stale: re-check and re-review.

Report to the user:
- canonical and corroborating sources; body word count; `last_reviewed`;
- exact changed files (editorial vs generated graph files);
- `scripts/litebites check` result; graph node/edge changes;
- any remote image with its privacy/durability trade-off;
- claims that remain caveated;
- an explicit statement that nothing was committed or pushed.

**Stop here** unless publication is explicitly authorized.

### 9. Publish (only with explicit approval)
Follow the publish procedure in `litebites-site`. Suggested message: `content: publish <short topic> Article Bite`.

## Revisions and corrections

When a consequential claim changes, add a visible update/correction note and refresh `last_reviewed` (see `POLICY_ARTICLE.md`). Re-run steps 7–8 for every revision.

## Pitfalls

- **Secondary-source drift:** news summaries change claims and dates. Return to the canonical source.
- **Announcement as evidence:** "the company says" is attribution, not validation.
- **Product/model collapse:** a model benchmark does not establish product reliability, and a feature list does not establish model capability.
- **Paper contamination:** Article Bites never go in `_posts/`.
- **Graph gaming:** never alter tags or prose to create edges.
- **"Graph" ambiguity:** confirm whether the user means the knowledge graph or a performance chart.
- **Approval collapse:** a green `check` is not permission to commit.
