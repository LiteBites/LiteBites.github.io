# Adding a First-Class Bite Collection

Use this pattern when LiteBites adds a new editorial content family alongside existing Paper Bites and Data Bites.

## Architecture

Create a dedicated Jekyll collection instead of placing unlike content in `_posts/`. This preserves `site.posts` as Paper Bites and prevents Paper previous/next navigation from crossing content types.

Example shape:

```text
_posts/       -> Paper Bites
_datasets/    -> Data Bites
_articles/    -> Article Bites
```

Give the collection its own layout, archive page, policy, validator, and stable permalink. Keep category ordering explicit in every shared discovery surface; for Article Bites the approved order is Article, Paper, Data.

Do not fabricate a launch entry merely to exercise templates. An intentional empty state is preferable to invented editorial content.

## Test-first vertical slices

1. Add a failing source-level test for collection registration, layout/index existence, and global category order.
2. Implement the smallest collection/index/navigation slice and make it pass.
3. Add validator behavior tests with temporary Markdown fixtures. Cover a valid entry, word-count boundary, non-empty tags, strict ISO dates, exact level-two heading sequence, and the canonical URL appearing inside `## Sources` rather than elsewhere in the body.
4. Add a failing graph integration test in a temporary repository copy, then add the new node type to source discovery, URL/type metadata, statistics, and browser controls.
5. Run the full suite after every slice.

The validator should use YAML safe loading, require HTTPS URLs with hosts, reject unresolved TODO/TBD markers, enforce the editorial word range, and report all failures with a nonzero exit status.

## Validate an empty collection with a real fixture

A production collection may intentionally contain no entries, which means an ordinary Jekyll build cannot exercise its detail layout or graph node. Validate without polluting the working tree:

1. Copy the repository to a unique temporary directory, excluding `.git`, `.hermes`, lockfiles, and generated output.
2. Add a clearly labeled 400–800-word validation fixture only in that copy.
3. Run the content validator there.
4. Run the graph generator twice; require the second run to report zero changed sources.
5. Build Jekyll from the temporary copy to a separate temporary destination.
6. Inspect the populated homepage, collection archive, detail page, and graph node at 320px, 375/390px, and desktop in light/dark themes.
7. Exercise keyboard graph selection, content-type filtering, source links, and the no-JavaScript fallback.
8. Delete only the temporary copy, screenshots, preview servers, and browser packages installed by this validation run.

This validates real rendering without creating a fake production post.

## Knowledge-graph extension

Treat every content family as a distinct node type with a namespaced ID and stable URL, for example `article:<slug>`. Add the new source directory to incremental hashing and bump the generator version when cache semantics change. Include per-type statistics even when the count is zero.

Use a shape distinction that does not depend on color alone. Keep automatic relationships conservative: truthful metadata can produce `shared-topic`; directional claims such as `validates`, `contradicts`, or `builds-on` require reviewed curated provenance.

Run the production generator twice after implementation and verify that the second run is idempotent. Public JSON must omit private source paths, hashes, and internal topic weights.

## Independent final-review gate

Review the complete uncommitted surface, not merely `git diff`: inventory staged,
unstaged, and untracked paths, then read every relevant untracked file directly.
Untracked layouts, validators, tests, policies, and index pages are often the core of
a new collection and are invisible to ordinary diffs.

For a final collection review, independently verify:

- collection registration, defaults, permalink, empty state, and detail layout;
- strict validator behavior, including metadata types, impossible dates, malformed
  HTTPS URLs, heading order, source placement, word limits, and image traversal;
- graph generation in a temporary copy, two-run idempotence, public/private field
  separation, and preservation of all pre-existing Paper/Data nodes and edges;
- frontend type labels, shape distinction, explicit Article/Paper/Data ordering,
  filters, keyboard selection, directory links, and no-JavaScript fallback;
- global navigation/footer order and `aria-current` behavior in generated HTML;
- successful Jekyll rendering of Article, Paper, and Data pages with no new
  horizontal-overflow, focus, landmark, or heading regressions.

Do not let source-string assertions stand in for browser behavior: execute at least
one rendered-DOM or browser interaction check for ordering, filtering, and keyboard
selection. Perform builds and generator probes in an isolated temporary copy when
reviewing a worktree that must remain untouched.

When the user requires a machine-readable verdict, emit exactly the requested JSON
schema with no prose or Markdown fences. Fail closed: any security concern or logic
error makes `passed` false; reserve `suggestions` for genuinely non-blocking items.

## Preview approval and direct publication

When the user asks to preview before publishing, build to a temporary destination and
serve that directory with a tracked background process. Verify the archive, homepage,
and graph endpoints return successfully, then give the user direct localhost links.
Keep the server running through review, but stop it and remove its temporary build after
the approved update is confirmed live.

After explicit approval to push directly to the current publication branch:

1. Fetch the remote and require local `HEAD` to equal the tracking branch before
   committing; reconcile upstream movement instead of overwriting it.
2. Stage an explicit allowlist of intended site paths. Never stage `.hermes/plans/`,
   temporary fixtures, screenshots, dependency directories, or generated Jekyll output.
   A checkout-local `.git/info/exclude` entry may hide `.hermes/` without altering the
   published repository.
3. Run `git diff --cached --check`, inspect the staged name/status and summary, and
   confirm all previously untracked production files are now included.
4. Commit with a focused conventional message, push the approved branch, then verify
   local `HEAD`, the tracking ref, and `git ls-remote` all resolve to the same full SHA.
5. Poll cache-busted live URLs until the collection archive, homepage ordering, graph
   controls, frontend JavaScript, and public graph JSON all contain the new deployment.
   A first 404 or stale response during GitHub Pages propagation is normal; success must
   come from a later positive check rather than from assuming the push deployed.
6. Open the deployed archive and graph in a browser, confirm expected accessibility-tree
   controls and zero console errors, then stop the local preview and clean only artifacts
   created by the task.
7. Report the commit link and full SHA, live URLs, deployment evidence, clean branch
   status, and any separate repository or portable-skill changes that were deliberately
   not pushed.

## Review boundary

Builds commonly create an untracked `Gemfile.lock`; remove it only if the current run created it and it was absent before. Keep `_site`, `.bundle`, `vendor`, temporary fixtures, screenshots, browser packages, and `.hermes/plans/` outside publication scope.

Report the empty production state separately from the populated temporary-fixture validation. Do not imply that a real entry exists until one has been researched and approved.