# LiteBites Knowledge Graph

The graph is an independent, static feature. It reads Paper Bite and Data Bite
source files but does not modify them.

## Update the graph

Run from the repository root:

```bash
ruby scripts/generate_knowledge_graph.rb
```

The generator:

1. hashes every Paper Bite and Data Bite source;
2. reuses cached nodes and accepted edges for unchanged sources;
3. processes only new, changed, or removed sources;
4. retrieves candidate neighbors through a topic index rather than comparing
   every pair;
5. writes the browser-safe graph to
   `assets/data/knowledge-graph.json`.

Incremental state is stored in `_data/knowledge-graph-state.json`. The public
JSON omits source paths, content hashes, and internal topic weights.

## Curate a relationship

Add reviewed relationships to `_data/knowledge-graph-relations.yml`:

```yaml
relations:
  - source: paper:source-slug
    target: dataset:target-slug
    relation: evaluates
    label: Evaluates with
    provenance: curated
    topics:
      - Anomaly Detection
```

Node IDs use `paper:slug` or `dataset:slug`. The generator stops with an error
if a curated relationship references a missing node.

Metadata-derived relationships use `shared-topic` and retain the shared topic
names as provenance. Future LLM suggestions should be reviewed before they are
added to the curated relationship file.

## Disable or remove

Set this in `_config.yml` to hide graph navigation:

```yaml
knowledge_graph:
  enabled: false
```

Complete removal requires deleting:

- `graph.html`
- `assets/css/knowledge-graph.css`
- `assets/js/knowledge-graph.js`
- `assets/data/knowledge-graph.json`
- `_data/knowledge-graph-relations.yml`
- `_data/knowledge-graph-state.json`
- `scripts/generate_knowledge_graph.rb`
- this file

Then remove the graph-only conditionals from `_layouts/default.html` and the
`knowledge_graph` configuration block. No Paper Bite or Data Bite needs to be
edited.
