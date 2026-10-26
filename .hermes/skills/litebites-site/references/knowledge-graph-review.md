# Knowledge Graph Review

How the generator works, how to curate relations, and how to disable the feature are documented in `scripts/KNOWLEDGE_GRAPH.md`. `scripts/litebites graph` regenerates twice and asserts idempotence; `scripts/litebites graph --check` fails when committed graph files are stale. This reference covers the editorial review that code cannot do. Use it after any Bite is added or retagged, and when changing the generator.

## Principles

- Tags are editorial metadata first. Never change tags, summaries, or prose to create or suppress an edge. A truthful isolated node is better than a misleading relationship.
- Metadata similarity means topical proximity only. Directional relations (`builds-on`, `evaluates`, `validates`, `contradicts`, `announces`) exist only as reviewed `provenance: curated` entries in `_data/knowledge-graph-relations.yml`. LLM or embedding suggestions are candidates, never accepted facts.
- Article node topics come only from front-matter `tags`; incidental words in a summary ("benchmark", "dataset") must not add topics. If they do, fix the generator with a regression test; do not reword accurate prose.
- Never hand-edit `_data/knowledge-graph-state.json` or `assets/data/knowledge-graph.json`.

## Per-Bite review

After `scripts/litebites graph`:

1. Exactly one node `<type>:<slug>` exists for the Bite, with matching title, summary, date, topics, and URL.
2. Every new edge shares a defensible topic. No Article-to-Data edge appears just because the article mentions benchmarks or data.
3. Every edge endpoint resolves; public JSON contains no `sourcePath`, `sourceHash`, or `topicWeights`.
4. Compare against the committed graph (`git diff --stat` on the two graph files, or parse both and diff node/edge IDs). Record:

```text
Graph before: N nodes / E edges
Graph after:  N nodes / E edges
Added/removed nodes: ...
Added/removed edges: ...
```

### Removed edges

The generator keeps each node's top-N neighbors, and the public graph is the undirected union of those selections, so a node can have more than N incident edges and a new stronger edge can displace a weaker inferred one elsewhere. Classify every removed edge as expected neighbor-cap displacement, a generator regression, or an editorially important relation that should be curated. Accept displacement only for low-ranked inferred edges, and report it at the checkpoint even when non-blocking.

## Slug and URL consistency

Punctuation in a source name (version dots, slashes) can make Jekyll's permalink differ from a raw-basename graph URL, so the graph's Open Bite link 404s while the page itself builds. After building, compare rather than infer: filename basename, rendered archive href, built page path, graph node id and url, and the inspector's Open Bite href must all agree and return 200. For an already-published Bite, a slug change is a URL migration: preserve or redirect the old URL.

## Browser checks on `/graph/`

- Search finds the node; selecting it shows correct details, neighbors, and relationship labels; Open Bite works.
- Type filters, keyboard selection (Enter/Space on a focused node), and the no-JavaScript directory fallback work.
- Category order is Article, Paper, Data on every surface (filters, legend, directory, fallback). Use an explicit type rank, never alphabetical sorting.
- In automation, click the visible node shape (`[data-node-id="<id>"] .graph-node-shape`), not the `<g>` box: labels use `pointer-events: none`, so a center click can land on the stage. Assert the selected class, inspector title, and exact href.

## When changing the generator or graph UI

- Bump the generator version when cache semantics change so cached nodes rebuild.
- Prove determinism against a clean checkout or the committed baseline, not only by running twice in an already-mutated tree.
- Read-only reviews run the generator only in an isolated temporary copy.
- SVG pitfall: `element.hidden = true` on an SVG `<g>`/`<line>` may not set a real attribute. Use `setAttribute('hidden', '')` / `removeAttribute('hidden')` plus a CSS rule `.graph-node[hidden], .graph-edge[hidden] { display: none; }`, and verify with rendered-element checks.
- Keep layout deterministic and finite (no perpetual motion); respect `prefers-reduced-motion`.
- Keep the feature removable: graph-only files plus small conditional hooks in `_layouts/default.html`, behind `knowledge_graph.enabled`. Build once with the flag off and confirm graph navigation disappears.
