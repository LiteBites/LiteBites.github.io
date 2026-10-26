# 0004: Interactive features are includes driven by data

**Date:** 2026-10-26 · **Status:** accepted

## Context
The owner wants a more interactive blog. An agent that writes custom
JavaScript inside individual posts would produce code nobody reviews and
features that cannot be checked.

## Decision
- Each interactive feature is one `_includes/` component, CSS in
  `assets/css/components.css`, and behavior in `assets/js/site.js`. The JS only
  adds to a page that already works without it.
- Authors (human or agent) use a feature by writing data: front matter
  (`benchmarks:`, `check_yourself:`), `_data/glossary.yml`, or an include tag.
- `scripts/validate_bites.rb` checks that data. `_includes/AGENTS.md` documents
  every component.
- No raw `<script>` in Bites.

## Consequences
A new interactive feature is a site change (use the `litebites-site` skill):
add the include, the validator rule, a test, and an `_includes/AGENTS.md`
entry.
