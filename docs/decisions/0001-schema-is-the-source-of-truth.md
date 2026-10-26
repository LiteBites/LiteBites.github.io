# 0001: The schema is the source of truth for mechanical rules

**Date:** 2026-10-26 · **Status:** accepted

## Context
The same rules were written three times: in `POLICY_*.md`, in the Hermes
skills, and in `scripts/validate_article_bites.rb`. When one copy changed, the
others fell behind. Only Article Bites were validated.

## Decision
- `_data/bite_schema.yml` defines each Bite type's fields, word range, section
  rule, image folder, and extra checks. `_data/tags.yml` is the tag vocabulary.
- `scripts/validate_bites.rb` enforces them for every type. Its error messages
  say how to fix the problem.
- Policies keep editorial judgment only. Skills describe procedures and point to
  the policies and the CLI.

## Consequences
- To change a mechanical rule, edit the schema and its tests, not a policy.
- `.paper-archive.toml` duplicates the paper fields for paper tooling.
  `scripts/test_validate_bites.rb` fails when the two drift apart.
- Older Bites that predate a rule are recorded in `docs/exceptions.md`, not
  silently allowed.
