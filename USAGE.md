# Using LiteBites

This guide covers two ways to maintain LiteBites:

1. **Automated usage** with an agentic AI system such as Hermes Agent.
2. **Manual usage** for graph generation and local Jekyll previews.

Run commands from the repository root unless a section says otherwise. Public content is ordered **Article Bites → Paper Bites → Data Bites** across the site.

## Repository map

| Content | Source location | Public URL | Editorial authority |
|---|---|---|---|
| Article Bite | `_articles/<slug>.md` | `/articles/<slug>/` | `POLICY_ARTICLE.md` |
| Paper Bite | `_posts/YYYY-MM-DD-<slug>.md` | `/posts/<slug>/` | `POLICY_POST.md` and `.paper-archive.toml` |
| Data Bite | `_datasets/<slug>.md` | `/data/<slug>/` | Existing `_datasets/*.md` entries and the dataset layout |
| Knowledge graph | Generated JSON and curated relations | `/graph/` | `scripts/KNOWLEDGE_GRAPH.md` |

Repository-managed images belong under:

```text
assets/images/articles/<slug>/
assets/images/papers/<slug>/
assets/images/datasets/
```

## Automated usage with an agentic AI system

### Start the agent in the repository

An agent should work from this Git checkout so it can read the current policies, examples, scripts, and Git state:

```bash
cd /path/to/LiteBites.github.io
hermes
```

Before editing, ask the agent to inspect `git status`, the relevant policy, recent examples of the same Bite type, and the canonical source. Drafting and local validation do **not** imply permission to commit or push. Request a local review checkpoint unless publication is explicitly authorized.

### Example prompt: Article Bite

```text
Write a new LiteBites Article Bite about:
<canonical technical article or announcement URL>

Use the canonical source and independent corroboration where available. Follow
POLICY_ARTICLE.md, distinguish reported claims from verified evidence, keep the
body between 400 and 800 words, use the required six sections, and choose only
truthful tags. Store any approved local images below assets/images/articles/.
Refresh the knowledge graph twice, build and inspect the Article page, archive,
homepage, and graph, then show me a local preview checkpoint. Do not commit or
push until I approve it.
```

Article Bites should explain what happened, why it matters, the minimum technical context, remaining uncertainty, practical takeaways, and sources. A company announcement is an attributable claim, not independent validation.

### Example prompt: Paper Bite

```text
Research and write a new LiteBites Paper Bite for:
<canonical paper URL, DOI, arXiv ID, or PDF>

First build an evidence ledger from the full canonical paper, including exact
metadata, method, decisive results, benchmark protocol, limitations, and useful
figures. Follow POLICY_POST.md and .paper-archive.toml. Write 900 to 1,800 body
words using the six standard Paper Bite sections. Extract complete, attributable
paper figures into assets/images/papers/<slug>/ when they improve understanding.
Refresh the knowledge graph twice, build and inspect the post, Paper Bites index,
homepage, and graph, and obtain an independent source-fidelity review. Stop at a
local preview checkpoint; do not commit or push until I approve it.
```

Paper Bite claims and numerical comparisons should retain the dataset, split, metric, model scale, and evaluation protocol that make them meaningful.

### Example prompt: Data Bite

```text
Create a new LiteBites Data Bite for:
<canonical dataset page or repository URL>

Verify the dataset owner, intended task, scale, license, access conditions,
annotation type, known limitations, and whether it is suitable for commercial or
clinical use. Inspect the existing _datasets/*.md entries and _layouts/dataset.html,
then create _datasets/<slug>.md with accurate metadata and concise prose. Store an
approved local image under assets/images/datasets/ with descriptive alt text.
Refresh the knowledge graph twice, build and inspect the Data Bite, Data Bites
index, homepage, and graph, then show me a local preview checkpoint. Do not commit
or push until I approve it.
```

There is currently no separate Data Bite policy or dedicated Data Bite writing skill. Until one is added, the existing dataset entries and `_layouts/dataset.html` define the mechanical schema; primary dataset documentation and licensing terms remain the evidence source.

### Skills used for LiteBites

The following Hermes skills encode the established workflows:

| Skill | Role |
|---|---|
| `litebites-article-writing` | Research, draft, validate, preview, and safely publish Article Bites |
| `litebites-paper-research` | Build a source-grounded paper research brief and select figures |
| `litebites-paper-writing` | Convert the verified brief into a policy-compliant Paper Bite |
| `paper-summary-archiver` | Portable Markdown archiving, assets, derived hooks, and review boundaries |
| `litebites-site-maintenance` | Jekyll layouts, CSS, navigation, accessibility, previews, and deployment |
| `arxiv` | Locate and verify arXiv papers and versions |
| `ocr-and-documents` | Extract text and figures when PDFs or scans require local processing |
| `humanizer` | Final prose pass after factual and structural validation |

The first five LiteBites-specific skills are backed up in this repository under `.hermes/skills/`, including their references and templates. The complete backup is approximately 200 KiB. Supporting general-purpose skills such as `arxiv`, `ocr-and-documents`, and `humanizer` remain profile-installed dependencies rather than duplicated repository content.

Inspect installed skills with:

```bash
hermes skills list
```

In an interactive Hermes session, a skill may be loaded explicitly with:

```text
/skill litebites-paper-writing
```

The agent should still read repository policy and current examples because local conventions can change after a skill was written.

### Repository-local skills

LiteBites carries its five core repository-owned skills at:

```text
.hermes/skills/litebites-article-writing/
.hermes/skills/litebites-paper-research/
.hermes/skills/litebites-paper-writing/
.hermes/skills/paper-summary-archiver/
.hermes/skills/litebites-site-maintenance/
```

Hermes recognizes repository-owned skills under either location:

```text
.hermes/skills/<skill-name>/SKILL.md
.agents/skills/<skill-name>/SKILL.md
```

Use `.hermes/skills/` for Hermes-specific skills and `.agents/skills/` when the same skill should be shared with compatible agent CLIs. Project skills have higher precedence than profile-installed skills for sessions started inside this Git repository.

After adding or cloning project skills, review their contents and trust the repository from its root:

```bash
hermes skills trust
```

Then start a new session or run `/reload-skills`. If the installed Hermes version does not provide `hermes skills trust`, update Hermes and consult the current [Hermes Skills System documentation](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills#project-local-skills).

Project skills are normal version-controlled files. They can be edited directly under `.hermes/skills/`; when synchronizing a newer profile copy, copy the complete skill directory so its `references/`, `templates/`, `scripts/`, and `assets/` remain intact. Review the resulting Git diff, validate front matter and instructions, and commit the update deliberately. Do not place credentials, private source ledgers, machine-specific secrets, or unpublished research material inside a skill. Hermes treats project skills as repository-owned; global skill curation does not maintain them automatically.

## Manual usage

### Update the knowledge graph

After finalizing an Article, Paper, or Data Bite, run:

```bash
ruby scripts/generate_knowledge_graph.rb
ruby scripts/generate_knowledge_graph.rb
```

The second run should report `0 changed sources`. Review the generated files:

```bash
git diff -- _data/knowledge-graph-state.json \
  assets/data/knowledge-graph.json
```

The generator reads Bite metadata without rewriting editorial Markdown. It updates:

```text
_data/knowledge-graph-state.json
assets/data/knowledge-graph.json
```

The first file contains incremental authoring state. The second is browser-safe public data. Article graph topics come only from reviewed front-matter tags; do not change tags merely to manufacture relationships.

For a directional relationship that cannot be represented by shared topics, add a reviewed entry to `_data/knowledge-graph-relations.yml` using valid IDs such as `article:<slug>`, `paper:<slug>`, or `dataset:<slug>`. See `scripts/KNOWLEDGE_GRAPH.md` before curating an edge.

### Visualize the knowledge graph

Start the local site:

```bash
./scripts/preview.sh
```

Open:

```text
http://127.0.0.1:4179/graph/
```

Check that the expected node appears once, its metadata and topics are accurate, its edges are defensible, and **Open Bite** leads to the correct page. Also test graph search and the Article, Paper, and Data filters.

### Run the prototype web page on localhost

The preview launcher works from any current directory because it resolves the repository root from its own location:

```bash
/path/to/LiteBites.github.io/scripts/preview.sh
```

From the repository root, the shorter command is:

```bash
./scripts/preview.sh
```

The default URL is:

```text
http://127.0.0.1:4179/
```

Choose another port by passing it as the first argument:

```bash
./scripts/preview.sh 4180
```

The script:

- prefers the installed Homebrew Ruby 3.1 formula when available;
- keeps its temporary Gemfile, lockfile, Bundler dependencies, and Jekyll output under the operating system's temporary directory;
- separates each repository's temporary cache and uses a port-specific Jekyll destination;
- binds only to `127.0.0.1`, so the preview is not exposed to the LAN or internet;
- watches source files and rebuilds while it runs;
- never creates or removes `Gemfile.lock` in the repository.

### Stop the localhost frontend

Keep the preview in the foreground. To terminate it, press:

```text
Ctrl+C
```

in the same terminal. Confirm that the listener closed with:

```bash
lsof -nP -iTCP:4179 -sTCP:LISTEN
```

No output means nothing is listening on that port. If a stale listener remains, use the PID printed by `lsof` and terminate only that process:

```bash
kill <PID>
```

Do not use broad commands such as `killall ruby` or `pkill -f jekyll`, because they can stop unrelated work.

## Validation before publication

Before committing content or site changes, run the checks relevant to the change:

```bash
ruby scripts/test_article_bites.rb
ruby scripts/validate_article_bites.rb
ruby scripts/generate_knowledge_graph.rb
ruby scripts/generate_knowledge_graph.rb
bash -n scripts/preview.sh
git diff --check
git status --short --branch
```

For a full local build, `./scripts/preview.sh` performs the dependency check and Jekyll build before starting the server. Inspect the affected Bite page plus its archive, the homepage, and `/graph/` in both light and dark themes.

Do not commit generated or local-only artifacts:

```text
Gemfile.lock
.bundle/
vendor/
_site/
```

Commit and push only after the local checkpoint is approved. GitHub Pages deployment is separate from the localhost preview: `127.0.0.1` is private to the current machine, while pushing `main` triggers the public site workflow.
