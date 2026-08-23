# Article Knowledge-Graph Topic Hygiene

Use this reference when an Article Bite introduces or changes knowledge-graph nodes, topics, or inferred edges.

## Durable contract

Article node topics must come only from reviewed front-matter `tags`. Do not infer extra Article topics from title or summary keywords. Announcement prose naturally contains terms such as “benchmark,” “dataset,” “serving,” and “generation”; broad concept rules can misclassify those incidental words and create misleading relationships.

Paper and Data Bite inference may keep their existing behavior. Apply the stricter rule specifically to Article nodes unless the repository policy changes.

## Regression pattern

Create an isolated Article fixture whose:

- only tag is `Agentic AI`;
- summary deliberately contains a trigger word such as `benchmark`;
- title or tag also exercises any broader alias rule, such as mapping `Agentic AI` to `Language Models`.

Generate the graph and assert the Article node topics are exactly:

```json
["Agentic AI"]
```

The failing pre-fix result may contain inferred topics such as `Datasets` or `Language Models`. Fix the generator rather than weakening accurate Article prose or removing truthful terms.

When generation semantics change, increment the generator version so cached nodes are rebuilt. Run the generator twice; the second run must report zero changed sources.

## Before/after graph audit

Compare the committed public graph with the regenerated graph by stable node and edge IDs. Verify:

1. existing node payloads are unchanged unless intentionally edited;
2. exactly the expected `article:<slug>` node was added or changed;
3. every new edge shares an explicit reviewed Article tag;
4. no Article-to-Data edge appears merely because the article discusses benchmarks or data governance;
5. every removed edge is understood.

A top-N neighbor cap can legitimately displace a weaker pre-existing inferred edge when a stronger Article relationship is added. Treat that as reviewable graph churn, not automatically as corruption: record the removed edge, confirm no curated relation was lost, and ensure the new edge has higher or equally justified metadata weight. In a graph built as the undirected union of every node’s top-N selections, a node may have more than N incident edges because other nodes selected it; the cap governs per-node selection, not final undirected degree.

Verify topology determinism against the committed baseline or a clean checkout, not only by running twice in one already-mutated working tree. A clean regeneration with the same Article should reproduce byte-identical state and public graph files; the second run should still report zero changed sources.

Preserve the committed public graph before regeneration and classify every removed edge as one of:

- expected neighbor-cap displacement;
- a generator regression;
- an editorially important relation that should be curated.

Accept displacement only when the removed edge was inferred, low-ranked, and not editorially important. If a connection should remain stable, curate it or improve the ranking policy; never alter Article prose, tags, or scientific framing to manipulate topology. Report even non-blocking topology side effects at the local review checkpoint.

Record at minimum:

```text
Graph before: N nodes / E edges
Graph after:  N nodes / E edges
Added/removed nodes: ...
Added/removed edges: ...
Second run: 0 changed sources
Public fields and edge endpoints: PASS
```

## Public-output checks

Confirm the browser JSON omits internal fields such as:

```text
sourcePath
sourceHash
topicWeights
```

Confirm every edge endpoint exists, the Article URL is `/articles/<slug>/`, the Article-only filter displays the new node, and the accessible directory lists Article Bites before Paper and Data Bites.
