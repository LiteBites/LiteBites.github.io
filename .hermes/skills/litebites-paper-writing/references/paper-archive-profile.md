# LiteBites Paper Archive Profile

## Purpose

LiteBites may expose repository mechanics through `.paper-archive.toml`. Treat it as a machine-readable adapter for paper-archiving tools, not as an editorial policy replacement.

Responsibility boundary:

```text
POLICY_POST.md       editorial standards, evidence discipline, voice, and judgment
.paper-archive.toml  paths, metadata schema, sections, hooks, validation, publication mode
SKILL.md             end-to-end research, writing, review, and publishing workflow
```

## Precedence

For LiteBites Paper Bites, resolve requirements in this order:

1. The user's explicit request.
2. `POLICY_POST.md` for editorial decisions.
3. `.paper-archive.toml` for mechanical repository conventions.
4. Current repository layouts, configuration, and representative posts.
5. Skill defaults only when the repository is silent.

If the profile conflicts with `POLICY_POST.md`, do not silently choose one. Preserve editorial truth, inspect recent repository conventions, and disclose the mismatch before changing either source.

## Semantic field mapping

Generic archivers normalize the canonical source link as `source_url`; LiteBites stores it as `paper_url`. The profile should declare:

```toml
[metadata.field_map]
source_url = "paper_url"
```

Use mappings instead of adding duplicate generic fields to LiteBites front matter. A profile validator should verify the mapped target field is listed among required fields.

## Knowledge-graph hook

The graph remains derived state and must not mutate Paper Bite Markdown. The profile may configure:

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

Run deterministic hooks twice. The second run must report no changed sources or produce no additional diff. Review new nodes and relationships; do not alter tags or prose merely to create edges.

## Validation

Before presenting a Paper Bite for review:

1. Parse `.paper-archive.toml` with a TOML parser or the generalized archiver validator.
2. Confirm configured directories, scripts, and expected outputs exist.
3. Confirm required front matter and ordered sections match the final post.
4. Run the configured graph hook twice.
5. Build Jekyll with a repository-compatible Ruby and dependency environment.
6. Verify the profile itself is not copied into the generated site.
7. Remove only task-created build artifacts and generated lockfiles.
8. Confirm the final diff contains the intended post/assets plus declared derived outputs.

## Publication boundary

`publishing.mode = "review-only"` means successful generation and validation stop at a local review checkpoint. Commit, push, or deployment still requires explicit user authorization.
