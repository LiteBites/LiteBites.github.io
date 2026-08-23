# Repository Usage Guide Pattern

Use this reference when turning a repository's accumulated agent and manual workflows into a durable operator guide.

## Recommended outline

1. **Purpose and repository map**
   - Content or feature family
   - Source path
   - Public/rendered destination
   - Policy or schema authority
   - Asset location
2. **Agent-assisted workflow**
   - Start the agent from the repository root
   - Inspect Git state, policy, and representative examples before editing
   - One copyable prompt per major task class
   - Explicit local-review and publication boundary
3. **Skills**
   - Name only skills actually used or intentionally supported
   - Explain each role in one sentence
   - Distinguish profile-installed, external, and project-local skills
   - Link authoritative docs for project trust and precedence
4. **Manual derived-state workflow**
   - Exact generator command
   - Repeat deterministic generators and require unchanged output
   - Name generated/private/public outputs
   - Explain curated metadata and provenance
5. **Local preview lifecycle**
   - One foreground launcher
   - Loopback-only default
   - Default and optional port
   - `Ctrl+C` shutdown
   - Exact-port listener inspection and targeted PID termination
6. **Validation and publication**
   - Syntax/tests/build/graph commands
   - Generated artifacts to exclude
   - Local preview versus remote deployment distinction

## Prompt contract

Each example prompt should name:

- the canonical source identifier;
- the repository policy or examples to inspect;
- evidence and attribution expectations;
- content path and asset path;
- word/section/schema constraints when defined;
- graph regeneration and idempotence;
- rendered surfaces to inspect;
- whether independent review is expected;
- an explicit stop-before-commit instruction unless publication is already authorized.

Avoid prompts that say only “write a post.” They omit the evidence, derived-state, validation, and approval requirements that make the workflow reliable.

## Project-local skills

Use the authoritative agent documentation to verify current locations and trust behavior. For Hermes, current documentation describes:

```text
<project-root>/.hermes/skills/<name>/SKILL.md
<project-root>/.agents/skills/<name>/SKILL.md
```

Project skills are executable procedure documents in practice, so treat trust as a security boundary. Review them like code. Do not assume a command shown in current web documentation exists in an older installed CLI: compare live docs with `<agent> skills --help`, and provide an update/docs fallback when they differ.

Do not claim profile-installed skills are repository-local. Do not vendor a large global skill set merely to make a usage table look self-contained. Add project skills only when repository ownership, portability, and precedence are intentional.

### Backing up the latest skill versions

When a user authorizes a small repository-local backup:

1. Enumerate only the class-level skills that encode the repository's core workflow; keep general-purpose dependencies profile-installed unless portability requires them.
2. Compare each skill's front-matter `version` across the active profile and any maintained portable backup. The active copy is not necessarily newest.
3. Select the newest source independently for each skill, then copy the whole directory—including `references/`, `templates/`, `scripts/`, `assets/`, license, and README files.
4. Build a deterministic source manifest containing the selected version, every relative path, and each content hash. Compare the staged destination against that manifest, parse every copied `SKILL.md`, report versions and total bytes, and scan for secrets and machine-specific absolute paths.
5. Re-hash each selected source immediately before the verdict. If any source changed during review, restart the source-selection, copy, and review boundary rather than accepting a mixed snapshot.
6. Exclude the project-skill directory from generated site output while keeping it tracked by Git. If local `.git/info/exclude` hides all of `.hermes/`, narrow that local rule so `.hermes/skills/**` remains trackable while plans stay ignored.
7. Review staged, unstaged, and untracked state separately before publication; plain `git diff` is empty when the package is already staged. A backup request is not permission to vendor every installed skill.

After changing a source skill during the same session, remember that any already-staged repository backup is stale and must be synchronized and revalidated before commit. Require one stable source-manifest → staged-backup equality result before passing the package.

## Validation checklist

- [ ] Every named repository path exists, or is clearly a placeholder/example.
- [ ] Every documented safe command was syntax-checked or executed.
- [ ] Fenced code blocks are balanced.
- [ ] No `TODO`, `TBD`, secrets, private ledgers, or machine-only credentials remain.
- [ ] The guide is linked from the README or equivalent entry point.
- [ ] Operator-only documentation is excluded from the generated public site when appropriate.
- [ ] The public site still builds after the exclusion change.
- [ ] Homepage, representative content, graph page, and public graph data load.
- [ ] The preview launcher starts, serves an HTTP request, and exits under PTY `Ctrl+C`.
- [ ] The listener closes and temporary lock/build artifacts do not remain in the repository.
- [ ] The graph generator is run twice and the second run is unchanged.
- [ ] The final diff contains only the guide, launcher, discoverability hook, necessary build exclusion, and any explicitly authorized project-skill backup.

## Pitfalls

- **Two competing local-development recipes:** if README and USAGE use different ports or launch methods, make one the recommended path and label the other as a fallback.
- **Publicly shipping operator notes by accident:** Jekyll may copy root documentation unless explicitly excluded.
- **Stale skill-management commands:** cite live docs and test local CLI help instead of silently choosing one source.
- **Overpromising Data workflows:** when no dedicated policy or skill exists, say which examples/layout currently define the schema.
- **Broad process termination:** never recommend `killall` or generic `pkill`; inspect the exact port and terminate only its owning PID.
