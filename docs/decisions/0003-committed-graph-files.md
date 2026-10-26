# 0003: Generated graph files stay committed

**Date:** 2026-10-26 · **Status:** accepted

## Context
`scripts/generate_knowledge_graph.rb` writes `_data/knowledge-graph-state.json`
(incremental state, also read by the Related Bites include) and
`assets/data/knowledge-graph.json` (public data). GitHub Pages' branch build
cannot run custom generators, so the files must exist in the repository.

## Decision
Keep committing both files. `scripts/litebites graph` regenerates them and
confirms that a second run changes nothing. `scripts/litebites graph --check`
(part of `check` and CI) fails, without writing, when they are stale.

## Consequences
- Never hand-edit either file.
- Graph diffs remain large. Moving to an Actions-based Pages deploy would allow
  generating them at build time; revisit if diff noise becomes a problem.
