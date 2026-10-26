# scripts/: maintenance tooling

Entry point: `scripts/litebites <command>`. Run `scripts/litebites help` for usage.

| File | Role |
|---|---|
| `litebites` | CLI: `new`, `validate`, `graph [--check]`, `test`, `build`, `check`, `preview` |
| `validate_bites.rb` + `lib/bite_checks.rb` | Schema-driven validator for all Bite types (reads `_data/bite_schema.yml`, `tags.yml`, `glossary.yml`) |
| `validate_article_bites.rb` | Compatibility wrapper: Article Bites only |
| `generate_knowledge_graph.rb` | Writes the two graph files; `--check` reports staleness without writing. Details: `KNOWLEDGE_GRAPH.md` |
| `build.sh`, `preview.sh`, `lib/jekyll_env.sh` | Jekyll build and preview with Bundler and output kept in `$TMPDIR` |
| `check_site.rb` | Checks a built site: no published repository documents, unique Bite titles, working internal links |
| `litebites_pipeline.py` | Collects an article source into a local evidence cache (`LITEBITES_PIPELINE.md`) |
| `test_*.rb`, `test_*.py` | Test suites; `scripts/litebites test` runs all of them |

Rules:
- Change a script and its tests together, then run `scripts/litebites test`.
- Tests build temporary repositories with `Dir.mktmpdir`; never write fixtures into the real content folders.
- Ruby scripts set `Encoding.default_external = Encoding::UTF_8`. Keep that line; some shells have no UTF-8 locale.
- Keep every script runnable on the system Ruby (validator, tests) and Ruby 3.1 with the `github-pages` gem (Jekyll build). CI uses Ruby 3.1.

Scheduled jobs: none are configured (Hermes cron upkeep was deferred). If one is added, record its exact `hermes cron create … --workdir <repo> --skill litebites-site` command here so it can be recreated.
