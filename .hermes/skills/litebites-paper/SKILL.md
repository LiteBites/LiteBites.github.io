---
name: litebites-paper
description: "Use when researching, drafting, or revising a LiteBites Paper Bite (_posts/) from an AI or computer-science paper given as a title, URL, arXiv ID, DOI, or PDF. Verify canonical metadata, build an evidence-backed research brief, select and extract figures, write under POLICY_POST.md and .paper-archive.toml, run the repo validator and checks, and stop at a local preview checkpoint unless publication is explicitly authorized."
version: 2.0.0
author: Hermes Agent
license: MIT
platforms: [macos, linux, windows]
metadata:
  hermes:
    tags: [litebites, academic-research, ai-papers, jekyll]
    related_skills: [litebites-article, litebites-site, arxiv]
---

# LiteBites Paper

Procedure for one Paper Bite: research the paper first, then write. This skill is the *how*. The rules live in the repo and win over anything here:

| Topic | Authority |
|---|---|
| Editorial standard, section jobs, figure selection, tone | `POLICY_POST.md` |
| Paths, field mapping, hooks, publication mode | `.paper-archive.toml` |
| Required front matter, word range, sections, tags, figure markup | `_data/bite_schema.yml`, enforced by `scripts/litebites validate` |
| Folder conventions | `_posts/AGENTS.md`, `assets/images/AGENTS.md` |
| `benchmarks:`, `check_yourself:`, glossary, `claim.html` | `_includes/AGENTS.md` |
| Publisher-hosted images | `POLICY_REMOTE_IMAGES.md` |

`POLICY_POST.md` decides editorial questions; `.paper-archive.toml` decides mechanics. If they disagree, or either disagrees with the schema, stop and tell the user rather than silently picking one. Honor the profile's field map: the canonical link is `paper_url`; never add a generic `source_url` to a post.

Not for: news or release analysis (use `litebites-article`), Data Bites (`_datasets/AGENTS.md`, `POLICY_DATA.md`), or site-wide changes (use `litebites-site`).

## Workflow boundary

Researching, drafting, validating, and previewing never imply permission to commit, push, or deploy. `.paper-archive.toml` sets `publishing.mode = "review-only"`: stop at the local preview checkpoint (step 9) unless the user explicitly authorized publication in this conversation. Leave unrelated working-tree changes untouched.

## Part A: research (no prose yet)

### 1. Orient
`git status --short --branch`; read `POLICY_POST.md`, `.paper-archive.toml`, and one or two recent `_posts/*.md` of similar type.

### 2. Resolve the canonical paper
Prefer: official venue page and PDF → versioned arXiv abstract and PDF → official project page and author repo → official supplement. Indexes, blogs, and README claims are for discovery only; search snippets are never evidence. Check for revised, withdrawn, or superseded versions and record the exact version read. Verify exact title, authors, venue/status, and date; write "arXiv preprint; venue not verified" rather than guessing.

### 3. Read in layers and fill the brief
Copy `templates/research-brief.md` to `/tmp`. Read abstract/intro → method → experiments (datasets, metrics, baselines, ablations) → limitations/appendix. Search the extracted text for `limitation`, `ablation`, `baseline`, `metric`, and component names; if extraction is incomplete, switch to another canonical HTML/PDF source.

Fill the evidence ledger for every consequential claim. Keep three voices separate: paper claim ("The authors report…"), observed evidence ("Table 3 shows…"), interpretation ("A useful way to read this is…"). Never compare numbers across different splits, protocols, or scales without saying so.

For position, survey, perspective, or theory papers, classify the evidence type with `references/position-papers.md` instead of forcing an experimental narrative.

Done when you can say what goes in, what happens, what comes out, what is trained, how it is evaluated, and every planned number has a location.

### 4. Select figures
Usually one method figure for the mechanism section and one results figure for the evidence section; this is a usefulness target, not a quota. Never manufacture a results chart or crop prose to fill a slot. For arXiv papers, pull original assets from the versioned e-print archive: `references/arxiv-source-figure-extraction.md` (opaque white background for dark mode, caption mapping, verification). Check reuse context and keep attribution ("Paper figure: …").

## Part B: write

### 5. Scaffold
```bash
scripts/litebites new paper <slug> [--date YYYY-MM-DD]
```
Fill the front matter from the brief. `title` is the exact canonical title; abbreviations go in `short_title`. Omit `project_url`/`code_url` when they do not exist; a proceedings record belongs in the links section, not in `project_url`. Put figures under `assets/images/papers/<slug>/` with stable names (`method-01.png`, `results-01.png`).

### 6. Draft
Map evidence to the section jobs in `POLICY_POST.md` before writing prose; every section has a distinct job and a source. Write the central idea before module names, explain information flow rather than listing components, and teach which comparisons matter instead of transcribing tables. Use scoped language ("on the evaluated datasets", "the authors report"). Define acronyms on first use. For retrieval systems, do not call retrieved passages "evidence" unless the paper establishes support. Do not paraphrase the abstract.

Tags: compact, precise research topics already used in the archive; never broad filler or tags chosen to force graph edges.

### 7. Interactive components (optional)
Consider `benchmarks:` (sortable table with per-row dataset/split/metric/protocol caveats) and `check_yourself:` (reveal cards) when they improve understanding; see `_includes/AGENTS.md` for the data shapes. A benchmark row is still a claim: it needs a ledger entry and must not compare incompatible protocols.

### 8. Validate, then refresh derived state
```bash
scripts/litebites validate _posts/<file>.md   # fix every reported error, re-run until clean
scripts/litebites graph                       # after tags/slug/summary are final
scripts/litebites check                       # validate + tests + graph --check + build + diff --check
```
Then check by hand what code cannot: every number and superlative traces to the brief; read time reflects the final text; external links resolve to the intended source; figure, caption, and section still refer to the same experiment. Review the new `paper:<slug>` node with `skill_view("litebites-site", "references/knowledge-graph-review.md")`. If the paper supports a typed relation metadata cannot express (e.g. `evaluates` a Data Bite), propose a `provenance: curated` entry in `_data/knowledge-graph-relations.yml`; add it only after evidence review.

### 9. Local preview checkpoint
```bash
scripts/litebites preview      # http://127.0.0.1:4179/
```
Inspect the post, `/papers/`, `/`, and `/graph/` (search, select the node, Open Bite) at desktop and ~375px, light and dark. Confirm figures load, are legible, and do not overflow. Stop the preview when done unless asked to keep it.

Report to the user: canonical metadata and version read; exact changed files classified as editorial post, local assets, curated graph data, or generated graph state; `scripts/litebites check` result; new node and edges; figure choices and any omitted figure with its reason; caveats that remain; and an explicit statement that nothing was committed or pushed.

**Stop here** unless publication is explicitly authorized.

### 10. Publish (only with explicit approval)
Follow the publish procedure in `litebites-site`. Suggested message: `content: publish <short title> Paper Bite`.

## Pitfalls

- **Writing before research:** a fluent post can still be wrong. Finish the ledger first.
- **Abstract-only reading:** abstracts omit protocol and caveats.
- **Metadata drift:** indexes show stale titles and guessed venues.
- **Metric laundering:** a gain means nothing without dataset, split, baseline, and metric direction.
- **Overclaiming causality:** ablations support scoped interpretation, not universal proof.
- **Figure mismatch:** caption, crop, and prose must describe the same experiment.
- **Template residue:** empty URLs, stale read time, placeholder tags.
- **Graph gaming:** isolated truthful nodes are fine.
- **Approval collapse:** a green `check` is not permission to commit.
