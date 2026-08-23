# Portable LiteBites Skill Distribution

Use this reference when backing up, publishing, or installing the complete LiteBites skill suite on another machine.

## Separate the three portability layers

```text
LiteBites Git repository
  POLICY_POST.md, POLICY_ARTICLE.md, .paper-archive.toml, posts, articles,
  assets, graph/build scripts

Hermes skill repository
  research/paper-summary-archiver/
  research/litebites-article-writing/
  research/litebites-paper-research/
  research/litebites-paper-writing/
  software-development/litebites-site-maintenance/

Hermes runtime profile
  $HERMES_HOME/skills/research/<skill>/
```

Committing `.paper-archive.toml` makes repository mechanics portable, but it does not install a Hermes skill. Likewise, installing the skill does not clone the LiteBites repository or transfer Hermes memory, credentials, or profile configuration.

## Category-preserving package layout

Use this source layout for a private or community skill repository:

```text
research/
├── paper-summary-archiver/
├── litebites-article-writing/
├── litebites-paper-research/
└── litebites-paper-writing/

software-development/
└── litebites-site-maintenance/
```

The `research` directory comes from the package path, not from `metadata.hermes.tags`. Preserve the whole skill directory, including `references/`, `templates/`, `scripts/`, and assets; copying only `SKILL.md` silently drops required guidance and validators.

## Install on another machine

For the default profile:

```bash
mkdir -p ~/.hermes/skills/research
mkdir -p ~/.hermes/skills/software-development
cp -R research/paper-summary-archiver ~/.hermes/skills/research/
cp -R research/litebites-article-writing ~/.hermes/skills/research/
cp -R research/litebites-paper-research ~/.hermes/skills/research/
cp -R research/litebites-paper-writing ~/.hermes/skills/research/
cp -R software-development/litebites-site-maintenance ~/.hermes/skills/software-development/
```

For a named profile, preserve both category directories under:

```text
~/.hermes/profiles/<profile>/skills/
```

If `HERMES_HOME` is set, use `$HERMES_HOME/skills/` as the destination root instead of assuming `~/.hermes/skills/`. Reload skills or start a new session, then verify discovery with `hermes skills list`.

## Repository discovery

The writing skill must locate LiteBites from the user-supplied path or a Git root containing `POLICY_POST.md`, `.paper-archive.toml`, and `_config.yml`. Never encode one machine's absolute checkout path in a portable skill.

## Backup and release gate

Before committing a skill export:

1. Compare the export with the active skill package byte-for-byte, except intentional distribution documentation.
2. Parse each `SKILL.md` front matter and verify name/version/description limits.
3. Confirm every referenced support file exists.
4. Ensure no machine-specific absolute paths, credentials, profile memory, or generated caches entered the package.
5. Validate templates and scripts with their dependency-light validators.
6. Keep commit/push separate from export unless explicitly authorized.
