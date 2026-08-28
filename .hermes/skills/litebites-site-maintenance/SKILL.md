---
name: litebites-site-maintenance
description: Maintain and evolve the LiteBites GitHub Pages/Jekyll site outside paper authoring. Use for shared layouts, navigation, CSS, responsive behavior, accessibility, local Jekyll validation, preview/review checkpoints, and explicitly authorized publication.
version: 1.7.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [litebites, jekyll, github-pages, css, accessibility, publishing]
---

# LiteBites Site Maintenance

Use this skill for reusable site-level changes in the LiteBites repository: layouts, indexes, navigation, shared CSS, theme behavior, and GitHub Pages publication. Resolve the target checkout from the user's supplied path or the current Git root containing `_config.yml`, `POLICY_POST.md`, and the LiteBites layouts; never depend on a machine-specific absolute path. If the task starts outside the repository and no checkout can be discovered safely, ask for its location. For researching or writing individual Paper Bites, use `litebites-paper-research` and `litebites-paper-writing` instead.

## Core workflow

1. **Inspect before proposing.** Read the affected layout, shared CSS, Jekyll configuration, collection/index logic, and representative generated pages. Check `git status --short --branch` before planning.
2. **Present choices when requested.** Explain behavior and tradeoffs in reader terms, recommend one option, and stop before editing when the user asks for a plan first.
3. **Keep the implementation shared and small.** Prefer a layout/include plus existing shared CSS over editing individual Markdown posts. Reuse existing design tokens and avoid new dependencies or JavaScript unless required.
4. **Respect review checkpoints.** If the user says “let me know before push,” implement and validate locally, show the exact changed files and previews, then wait. Do not commit or push until explicit approval.
5. **Build and inspect generated output.** Run the repository-compatible Jekyll build into a temporary destination, then inspect actual rendered HTML and browser output—not only Liquid source.
6. **Test boundaries and responsive states.** Check representative middle and endpoint pages, 320/375px mobile widths, desktop width, light/dark themes, long titles, keyboard focus, and horizontal overflow.
7. **Clean generated artifacts.** Remove only artifacts created during the task, such as an untracked `Gemfile.lock`, `_site`, `.bundle`, or `vendor`. Preserve pre-existing files. A plan saved under `.hermes/plans/` should not be included in the site diff unless the repository intentionally tracks plans.
8. **Publish safely after approval.** Fetch, verify `HEAD == origin/main` (or reconcile deliberately), stage only intended paths, review the staged diff, commit, dry-run/push, verify local/tracking/remote SHAs, and poll the deployed page until the new markup is live.

## LiteBites design conventions

- The current visual system is grid-led and editorial: off-white/black surfaces, thin rules, square modules, oversized uppercase display type, IBM Plex Sans for reading text, IBM Plex Mono for metadata, and one signal-green accent.
- Keep expressive typography and catalog density on discovery surfaces (Home, Paper Bites, Data Bites), but preserve a quiet reading measure and restrained section hierarchy inside Paper Bite and Data Bite detail pages.
- Reuse semantic CSS variables such as `--bg`, `--surface`, `--ink`, `--muted`, `--faint`, `--line`, `--line-strong`, `--signal`, `--grid-bg`, and `--image-bg`. Extend the token system rather than scattering literal colors.
- Use supplied paper figures and dataset images as catalog imagery. Add explicit front-matter fields such as `card_image` and `card_image_alt` when a template needs a stable featured image; provide a typographic fallback for entries without one.
- Keep interactive targets at least 44px high.
- Use semantic landmarks and descriptive `aria-label` values.
- Keep keyboard focus visible; do not rely on hover alone.
- Let long paper titles wrap with `minmax(0, 1fr)` and `overflow-wrap: anywhere`; do not truncate meaningful destinations merely to preserve card height. Truncate only low-value utility breadcrumbs where a long page title would enlarge the global chrome.
- Avoid redundant navigation. If the global header already provides the same index destination, do not repeat an “All …” link in a local previous/next footer unless the user explicitly wants it.
- For mobile, stack controls and keep DOM/tab order logical.
- Respect `prefers-reduced-motion`, retain light/dark/system theme behavior, and verify that the signal accent remains legible in both themes.

### Reference-inspired redesign workflow

When the user supplies another site as a visual reference, inspect it visually and extract transferable principles (grid, hierarchy, type posture, density, image treatment, interaction shape). Do not copy branded assets, proprietary code, or the reference page one-for-one.

When fidelity or taste is the main decision, create a standalone prototype outside the repository first, populate it with real LiteBites content and imagery, validate desktop/mobile, and show it for approval. After approval, translate the composition into Jekyll's shared layouts and data-driven loops rather than pasting the prototype wholesale. Preserve a local review checkpoint before commit/push.

See `references/grid-led-redesign.md` for the proven prototype-to-Jekyll mapping and validation matrix.

## Jekyll pagination/navigation guidance

- Current Paper Bites use `_layouts/post.html`; datasets use a separate collection/layout.
- For chronological Paper Bite navigation, `page.previous` and `page.next` are sufficient while `site.posts` contains only Paper Bites.
- Verify generated chronology instead of assuming semantics: in the current site, `page.previous` resolves to the older post and `page.next` to the newer post.
- Render only available neighbors at the oldest/newest boundaries. Never create empty or invisible interactive placeholders.
- Use `rel="prev"` and `rel="next"` on destination links.
- If non-paper content is later added to `site.posts`, replace direct neighbors with type-filtered navigation.

See `references/paper-bite-pagination.md` for the proven title-card implementation and verification matrix.

## First-class Bite collection guidance

When adding a new editorial content family, give it a dedicated Jekyll collection, policy, layout, index, validator, and graph node type rather than mixing it into `_posts/`. Preserve explicit category ordering across navigation, footer, homepage, archives, graph controls, and no-JavaScript fallbacks. If the production collection is empty, keep an honest empty state and build a realistic entry only in a temporary repository copy to exercise the detail layout and graph integration.

Use test-first vertical slices and validate strict metadata, exact heading contracts, responsive rendering, keyboard interaction, idempotent graph generation, and generated-artifact cleanup. For the reusable implementation, temporary-fixture procedure, and fail-closed independent final-review checklist (including staged, unstaged, and untracked files), see `references/first-class-bite-collection.md`.

## Modular optional-feature guidance

When the user asks for a feature to remain independent or easily removable, treat removability as an acceptance criterion rather than a documentation promise:

- Keep page, CSS, JavaScript, public data, generator state, scripts, and documentation in feature-specific files.
- Limit shared-layout changes to small conditional asset/navigation hooks.
- Add a configuration flag and test a real build with the flag disabled.
- Prefer deriving feature data from existing posts and collections read-only; do not revise individual Markdown files unless editorial metadata is intrinsically part of the content.
- Separate private authoring/cache state from sanitized browser data.
- Make generated output deterministic and run the generator twice to prove unchanged sources are skipped.
- Validate the removal boundary by listing every file and shared hook that would be deleted.

For static interactive graphs specifically, including incremental topic-index generation, reviewed-edge provenance, dependency-free SVG interaction, the SVG `hidden` attribute pitfall, and no-JavaScript validation, see `references/static-knowledge-graph.md`.

### Publisher-hosted remote-image review

When an Article Bite embeds an optional publisher-hosted original under `POLICY_ARTICLE.md`, independently verify the exact asset against the canonical publisher page, validator-enforced figure markup, decoded dimensions, rendered HTML attributes, responsive/theme behavior, keyboard access, third-party privacy tradeoffs, and graceful failure. Test lazy loading only after scrolling the image into view; use same-origin narrow iframes when browser tooling lacks viewport controls. Validate source-hash state and graph idempotence in an isolated temporary checkout so the review does not mutate the working tree. Use the fail-closed procedure and verdict schema in `references/remote-image-embedding-review.md`.

### Reusable local preview launchers

When the user wants to run the site without the agent, package the verified multi-command setup as a foreground shell launcher rather than asking them to maintain a fragile pasted command block. Resolve the repository root relative to the script, keep Bundler and Jekyll destinations under `${TMPDIR:-/tmp}`, bind to loopback, reject extra arguments and malformed ports before dependency setup, and print the URL and `Ctrl+C` shutdown instruction.

Prefer copying the repository `Gemfile` into a repository-keyed temporary cache and exporting `BUNDLE_GEMFILE` to that copy. Bundler then creates its lockfile beside the temporary Gemfile and never creates, edits, or deletes the repository's `Gemfile.lock`; this eliminates the concurrent-lockfile ownership race rather than merely mitigating it. Use a port-specific Jekyll destination so simultaneous previews do not share rendered output. Test a real start from outside the checkout, HTTP fetch, PTY `Ctrl+C` shutdown, listener closure, executable mode, leading-zero/overflow/non-numeric ports, extra arguments, repository lockfile noninterference while the server is running, and repository-artifact cleanup before handoff. Keep the script uncommitted until separately approved.

See `references/local-preview-lifecycle.md` for the portable launcher pattern, targeted stale-listener fallback, and validation matrix.

### Repository operator and usage guides

When the user asks for a durable operator guide, create one class-level document (normally `USAGE.md`) that joins the agent-assisted and manual workflows rather than scattering commands across chat history. It should:

- map each content family to its source path, public URL, editorial authority, and asset location;
- provide copyable example prompts for Article, Paper, and Data Bites, including canonical-source verification, graph refresh, local preview, review, and publication boundaries;
- list the skills actually used and describe their roles without implying that profile-installed skills are committed to the repository;
- explain repository-local skill locations, trust, precedence, and Git review using the current authoritative agent documentation;
- document graph regeneration, the required idempotence run, generated files, curated-edge provenance, and browser inspection;
- make the foreground preview launcher the recommended local-development path, with `Ctrl+C`, exact-port `lsof`, and targeted `kill <PID>` shutdown guidance;
- distinguish localhost preview from GitHub Pages publication and list generated artifacts that must stay out of commits.

Link the guide from `README.md`. If it is an operator document rather than site content, add it to Jekyll's `exclude` list and prove that its generated URL returns 404 while the homepage, graph page, and public graph JSON still load. Validate all documented local paths, balance fenced code blocks, reject placeholders, run each safe command where practical, and test the launcher with a real HTTP fetch plus PTY `Ctrl+C` shutdown.

Project-local skill commands can drift across agent versions. Check both the installed CLI help and the live authoritative documentation. If the live docs describe a newer command than the installed binary, document the upgrade/docs fallback instead of claiming the local command already works. Treat repository skills as reviewed Git content; do not copy credentials, private ledgers, or unpublished material into them, and do not imply that global skill curation maintains repo-owned files.

When the user asks to back up the latest skill versions, do not assume the active profile is newest. Compare the front-matter `version` across the active profile and any maintained portable backup, select the newest source per skill, copy the complete directory (including references/templates/scripts/assets), and verify file equality, total size, portable paths, and absence of secrets before staging. Record versions in the review report so drift is visible.

Make the final integrity check race-aware. Record the selected source version plus a deterministic manifest of relative paths and content hashes, compare the staged backup against that manifest, then re-hash the source immediately before verdict. If the source changed during review, do not mix snapshots or silently declare drift: identify the newer candidate, restart the copy/review boundary, and require one stable source → staged-backup equality result. Review staged, unstaged, and untracked state separately because a staged package produces an empty plain `git diff`.

See `references/repository-usage-guides.md` for the recommended outline and verification checklist.

## Local validation recipe

Activate a Ruby version compatible with the repository's GitHub Pages dependency set using the machine's available version manager (for example `rbenv`, `mise`, `asdf`, or Homebrew). Confirm it before installing dependencies:

```bash
ruby -v
export LITEBITES_TMP="${TMPDIR:-/tmp}/litebites-validation"
mkdir -p "$LITEBITES_TMP"
cp Gemfile "$LITEBITES_TMP/Gemfile"
export BUNDLE_GEMFILE="$LITEBITES_TMP/Gemfile"
export BUNDLE_PATH="$LITEBITES_TMP/ruby-bundle"
bundle check || bundle install
bundle exec jekyll build --destination "$LITEBITES_TMP/site-preview"
```

Using a temporary `BUNDLE_GEMFILE` keeps both dependency metadata and generated output outside the repository, so validation never needs to create or clean up the repository lockfile. If the host does not provide a POSIX-style temporary directory, select an equivalent writable OS-specific path rather than changing repository dependencies to fit the global Ruby.

Then verify:

```bash
git diff --check
git status --short
git diff --stat
```

Serve the temporary destination and use browser or Playwright checks for actual layout. Confirm `document.documentElement.scrollWidth == document.documentElement.clientWidth` at narrow widths.

## Review report before push

Report:

- Exact modified files.
- User-visible behavior, including chronological meaning.
- Boundary, responsive, theme, keyboard, and build results.
- Confirmation that no generated artifacts remain.
- Desktop/mobile previews when visual changes are involved.
- Explicit statement that no commit/push occurred.

After explicit publication approval, report the commit ID, remote SHA verification, clean working tree, deployment status, and live URL.

## Pitfalls

- Do not treat a successful Liquid edit as complete without building Jekyll and checking generated neighbor URLs.
- Do not add an index link by default merely to balance a two-card layout; duplicate controls add noise.
- Do not leave planning documents or generated lockfiles as accidental repository changes.
- Do not use invisible grid placeholders. Explicit grid columns can preserve left/right alignment at boundaries without inaccessible markup.
- Browser extraction can be cached immediately after GitHub Pages deployment. Poll a cache-busted URL and inspect the live DOM before declaring deployment complete.
- Do not hard-code one Mac's Ruby prefix in a committed preview launcher. Detect the available version manager/formula, keep generated output outside the repository, and verify `Ctrl+C` really closes the listener.
- Do not validate a decimal port with bare Bash arithmetic after only a digits regex: values such as `08` and `09` are parsed as invalid octal. Reject leading zeros or use an explicit base-10 conversion, and fail before Bundler or Jekyll runs.
- Avoid exit cleanup based only on “the file was absent at startup, therefore delete it now.” A user or concurrent process may create or edit that path while the server runs. Prefer a temporary `BUNDLE_GEMFILE` so Bundler never touches the repository lockfile; if that is impossible, fingerprint and preserve whenever ownership or content is uncertain.
