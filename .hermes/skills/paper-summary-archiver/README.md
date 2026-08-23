# Paper Summary Archiver

A portable Hermes skill for turning academic papers into evidence-backed Markdown summaries and archiving them in static sites, Obsidian vaults, or plain Markdown repositories.

## Why this exists

This package extracts the reusable workflow from a site-specific paper-writing process. It intentionally does **not** assume:

- A particular repository path
- Jekyll or GitHub Pages
- A fixed front-matter schema
- A fixed section template
- One image-link syntax
- A knowledge graph
- Automatic publication

Project-specific behavior belongs in `.paper-archive.toml` profiles and adapters.

## Package structure

```text
paper-summary-archiver/
├── SKILL.md
├── README.md
├── LICENSE
├── references/
│   └── adapter-contract.md
├── templates/
│   ├── paper-archive.toml
│   └── paper-summary.md
└── scripts/
    └── validate_profile.py
```

## Install locally

From the `Hermes-Skills` repository root, preserve the research category when copying the package:

```bash
mkdir -p ~/.hermes/skills/research
cp -R research/paper-summary-archiver ~/.hermes/skills/research/
```

To install every skill currently published in this repository's research category:

```bash
mkdir -p ~/.hermes/skills/research
cp -R research/* ~/.hermes/skills/research/
```

Start a new Hermes session or run `/reload-skills` so the skill registry reloads.

## Configure a repository

Copy the template to the root of a Markdown archive:

```bash
cp templates/paper-archive.toml /path/to/archive/.paper-archive.toml
python3 scripts/validate_profile.py /path/to/archive/.paper-archive.toml
```

The profile controls paths, filename templates, metadata, headings, figures, validation, and optional post-write hooks.

For example, a repository can add a deterministic knowledge-graph hook without changing the core skill:

```toml
[[hooks.after_write]]
name = "knowledge-graph"
enabled = true
command = "ruby scripts/generate_knowledge_graph.rb"
working_directory = "."
deterministic = true
idempotence_check = true
mutates_editorial_markdown = false
expected_outputs = [
  "_data/knowledge-graph-state.json",
  "assets/data/knowledge-graph.json",
]
```

## Community extensions

Prefer contributions in this order:

1. A `.paper-archive.toml` example for a project.
2. A platform adapter following `references/adapter-contract.md`.
3. A new summary template.
4. A dependency-light validator or safe generator.

Do not fork the core workflow merely to change paths or headings. Keep evidence, accessibility, review, and publication safeguards common across adapters.

## Relationship to specialized workflows

A specialized site skill may wrap this workflow with stricter editorial policies, branded voice, layout-specific figures, or deployment rules. The specialized skill remains the authoritative adapter for that site; this package supplies the reusable core for other archives.

## License

MIT
