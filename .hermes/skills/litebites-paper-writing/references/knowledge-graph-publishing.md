# Knowledge graph publishing for Paper Bites

Use this stage only when the repository contains the modular LiteBites knowledge graph. The post remains the editorial source; the graph is derived independently after the post is complete.

## Placement in the workflow

Run graph maintenance after the post, metadata, read time, links, and figures are finalized, but before the final Jekyll build and review checkpoint:

```text
finalized Paper Bite
  -> graph generator
  -> relationship review
  -> Jekyll build
  -> post + graph browser validation
  -> user review
  -> explicitly authorized publication
```

Do not let graph connectivity dictate scientific prose or introduce inaccurate metadata.

## Tag quality

Tags serve both archive discovery and graph candidate retrieval. Use a compact set of canonical, technically accurate topics. Prefer stable terms already used in the archive when they describe the same concept. Avoid broad filler such as `AI`, redundant synonyms, and tags added only to manufacture an edge.

Never weaken editorial accuracy to connect a node. A valid isolated node is better than a misleading relationship.

## Generate incrementally

From the repository root, run:

```bash
ruby scripts/generate_knowledge_graph.rb
```

Expected behavior:

- unchanged sources are reused from graph state;
- only new, changed, renamed, or removed Bites are processed;
- candidate neighbors come from the topic index;
- accepted relationships for unchanged nodes remain stable;
- browser-safe data is written separately from private authoring state.

Run the generator a second time. It should report zero changed sources and produce no further diff.

## Review the new node and relationships

Verify all of the following:

1. Exactly one node represents the new post.
2. Its ID, title, type, summary, date, topics, and URL are correct.
3. Its URL resolves in the generated site.
4. Every inferred edge has a defensible shared topic.
5. No existing edge disappeared unexpectedly.
6. Generic vocabulary did not create a noisy cluster.
7. An entry with no defensible neighbor remains isolated rather than receiving a forced edge.

Metadata similarity identifies topical proximity, not claims such as `builds-on`, `evaluates`, or `contrasts-with`.

## Curated relationships

When the paper itself supports a typed relationship that metadata cannot express, propose or add it in `_data/knowledge-graph-relations.yml` only after evidence review. Preserve explicit provenance. Example:

```yaml
relations:
  - source: paper:new-method
    target: dataset:mvtec-ad
    relation: evaluates
    label: Evaluates with
    provenance: curated
    topics:
      - Anomaly Detection
```

Validate both node IDs. LLM or embedding output may propose candidates, but it must not silently become published graph truth.

## Build and browser checks

After generation, build Jekyll and inspect both the new post and `/graph/`. Confirm:

- the Paper Bites index includes the post;
- graph search finds the new node;
- selecting it opens the correct details;
- neighbor highlighting and relationship labels are accurate;
- its Open Bite destination works;
- Paper/Data filters, keyboard selection, and no-JavaScript fallback still work;
- graph and post have no horizontal overflow at narrow widths;
- light and dark themes remain legible;
- every edge source and target exists.

## Diff and publication boundary

A normal new-post diff may include:

```text
_posts/YYYY-MM-DD-slug.md
assets/images/papers/slug/
_data/knowledge-graph-state.json
assets/data/knowledge-graph.json
```

Include `_data/knowledge-graph-relations.yml` only when a reviewed curated relationship changed. The post itself should not receive graph-only fields.

At the review checkpoint, distinguish editorial files from generated graph files and summarize the new node and edges. Do not commit or push until the user explicitly authorizes publication.
