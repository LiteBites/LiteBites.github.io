# Adapter Contract

An adapter maps the target-neutral Paper Summary Archiver workflow onto a specific Markdown system. Adapters change storage and rendering conventions; they do not weaken evidence, accessibility, review, or publication requirements.

## Prefer configuration before code

Use an adapter when a platform has stable conventions shared by many repositories. Use a `.paper-archive.toml` profile when only one project needs different paths, headings, or commands.

A community adapter should be a reference document plus a sample profile. Add a script only when mechanical behavior cannot be expressed declaratively.

## Required adapter fields

Document each field below.

### 1. Detection

Define high-confidence markers and avoid false positives.

Examples:

- Jekyll: `_config.yml`, `_posts/`, and a compatible Markdown layout.
- Hugo: `hugo.toml`/`config.toml`, `content/`, and page bundles or `static/`.
- Obsidian: `.obsidian/` and an established notes/attachments convention.
- Generic: an explicit `.paper-archive.toml`; do not infer a specialized platform from Markdown files alone.

Detection must never override an explicit profile or user instruction.

### 2. Paths

Specify:

- Archive root.
- Content directory.
- Asset directory.
- Filename or page-bundle template.
- Whether paths are vault-relative, repository-relative, or page-relative.
- Collision behavior.

All generated paths must remain inside the target root. Reject path traversal and unexplained absolute destinations.

### 3. Metadata mapping

Map the normalized model to target front matter:

```text
title, date/year, authors, venue, summary, tags/topics,
source_url, doi/arxiv_id, project_url, code_url,
short_title/aliases
```

Document required fields, optional fields, aliases, date formats, and scalar/list types. When the target uses a different field name for a normalized semantic, declare it under `[metadata.field_map]`; for example, `source_url = "paper_url"`. Do not use a target-specific field name without defining its semantic mapping.

### 4. Body structure

Define required headings, optional sections, order, target length, and permitted syntax. Explain adaptations for experimental, survey, theory, and position papers.

### 5. Links and figures

Define:

- Standard Markdown, Liquid, shortcode, or wikilink syntax.
- Local image path behavior.
- Alt-text and caption syntax.
- Figure provenance convention.
- External URL policy.

Adapters must retain accessible alternative text even when the target's embed syntax makes captions optional.

### 6. Derived-state hooks

For each index, search, feed, backlink, citation, or graph hook, document:

- Command.
- Working directory.
- Trigger stage.
- Whether it is deterministic.
- Expected output files.
- Whether it mutates editorial Markdown.
- Validation and rollback/removal procedure.

A hook that mutates a completed post must be opt-in and disclose the exact fields or sections it changes. Knowledge graphs should normally remain independent derived state.

### 7. Native validation

Define exact checks for:

- Front-matter parsing.
- Required metadata and heading order.
- Local links and assets.
- Build/lint/preview command.
- Generated page or note discovery.
- Mobile/theme checks when relevant.
- Cleanup boundaries.

### 8. Publication boundary

Document whether the target uses Git, a sync service, a CMS importer, or no publication step. Adapters may describe publication but must not authorize it. The user must explicitly request commit, push, sync, upload, or deployment.

## Adapter precedence

When multiple adapters match:

1. Explicit user choice.
2. `.paper-archive.toml` `adapter` value.
3. Most specific high-confidence detection.
4. Generic Markdown fallback.

Never combine syntax from two adapters unless the target profile explicitly composes them.

## Extension checklist

A contribution is complete when it includes:

- [ ] Unique lowercase adapter name.
- [ ] Detection markers and ambiguity handling.
- [ ] Sample `.paper-archive.toml` profile.
- [ ] Metadata mapping table.
- [ ] Content and asset path examples.
- [ ] Link and figure syntax examples.
- [ ] Hook commands with expected outputs and idempotence behavior.
- [ ] Native validation matrix.
- [ ] Publication boundary.
- [ ] Removal/disable procedure for optional hooks.
- [ ] At least one experimental-paper example.
- [ ] At least one non-experimental-paper adaptation.

## Example adapter sketches

### Jekyll

```text
markers: _config.yml + _posts/
content: _posts/{date}-{slug}.md
assets: assets/papers/{slug}/
metadata: YAML front matter
links: Markdown or Liquid according to repository examples
validate: bundle exec jekyll build --destination <temporary path>
```

Do not assume every Jekyll site uses the same permalink, layout, tags, or image helper.

### Obsidian

```text
markers: .obsidian/
content: Papers/{citekey}.md
assets: Attachments/Papers/{citekey}/
metadata: YAML front matter plus optional aliases
links: wikilinks or Markdown according to vault settings/examples
validate: links, embeds, aliases, MOC/backlink hook, optional Markdown lint
```

Do not modify `.obsidian/` settings unless the user requests a vault configuration change.

### Generic Markdown

```text
markers: explicit profile or user-selected directory
content: configured path and filename template
assets: configured relative directory
metadata: YAML front matter unless profile says none
links: standard Markdown
validate: profile commands plus local path checks
```

The generic adapter should introduce the fewest assumptions and no publication behavior.
