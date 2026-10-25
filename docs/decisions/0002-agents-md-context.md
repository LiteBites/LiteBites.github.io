# 0002: Agent context lives in AGENTS.md files

**Date:** 2026-10-26 · **Status:** accepted

## Context
Hermes Agent maintains this repository. It loads `AGENTS.md` from the repo root
down to the working folder, and loads a folder's `AGENTS.md` the first time it
touches a file there. Before this change, every session re-read a 300-line
`USAGE.md` and all of the policies.

## Decision
- The root `AGENTS.md` holds the map, the lifecycle, and the main rules.
- Each content or code folder has a short `AGENTS.md` with only its own rules.
- Skills stay in `.hermes/skills/`. No `CLAUDE.md` and no `.claude/` folder.
- `AGENTS.md` and `docs/` are excluded from the Jekyll build.
  `scripts/check_site.rb` fails if a repository document gets published.

## Consequences
Keep `AGENTS.md` files short and directive. Hermes blocks a context file that
looks like prompt injection, so never paste untrusted source text into one.
