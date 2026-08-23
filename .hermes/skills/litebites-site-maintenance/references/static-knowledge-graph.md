# Static Knowledge Graph Feature Pattern

Use this pattern for a removable, GitHub Pages-compatible graph or other independently generated discovery surface.

## Architecture

```text
Existing posts and collections (read only)
        ↓
Offline deterministic generator
        ↓
Private incremental state + reviewed relations
        ↓
Sanitized public JSON
        ↓
Local browser-side explorer
```

Keep the feature isolated:

- one Jekyll page (`graph.html`);
- dedicated CSS and JavaScript;
- public generated JSON under `assets/data/`;
- private generator state and curated relations under `_data/`;
- an excluded authoring script directory;
- only small conditional CSS/navigation hooks in the global layout;
- a configuration flag that hides navigation without deleting content.

Do not modify individual posts merely to make them graph nodes. Derive stable IDs from collection type and slug, and reference canonical generated URLs. Post-specific related links can later be rendered from external graph data without changing Markdown sources.

## Incremental generator

A reliable generator should:

1. Hash every source file.
2. Reuse cached nodes for unchanged hashes.
3. Remove stale nodes and edges when a source disappears.
4. Build an inverted topic index and evaluate only candidates sharing indexed topics; avoid global all-pairs comparison.
5. Recompute edges touching changed nodes while preserving accepted edges among unchanged nodes.
6. Validate curated source/target IDs and fail loudly on dangling references.
7. Write deterministic, sorted output without timestamps that create meaningless diffs.
8. Run twice in validation; the second run should report zero changed sources and leave output byte-identical.

Keep source paths, hashes, and internal scoring weights in private state. Strip them from the browser JSON. Store relation labels and provenance (`metadata`, `curated`, or reviewed future sources) in the public edge records.

## Browser implementation

For a small graph, dependency-free SVG is sufficient. Compute a deterministic, finite layout and then stop; do not leave nodes moving continuously. For a large node count, switch to a bounded grid/cluster layout rather than running quadratic repulsion.

Provide:

- search and content-type filters;
- node selection, neighbor highlighting, and a details panel;
- local links to source entries;
- pan, zoom, and reset controls;
- keyboard-selectable SVG nodes;
- an ordinary directory or archive fallback;
- `noscript` links when JavaScript is disabled;
- stable behavior under `prefers-reduced-motion`.

### SVG visibility pitfall

Assigning `element.hidden = true` to an SVG `<g>` or `<line>` may create only a JavaScript property and not a real `hidden` attribute. Filtering can appear to update state while nodes remain rendered. Use:

```js
if (visible) {
  element.removeAttribute('hidden');
} else {
  element.setAttribute('hidden', '');
}
```

and add an explicit stylesheet rule:

```css
.graph-node[hidden],
.graph-edge[hidden] {
  display: none;
}
```

Verify visibility with rendered-element checks, not only state attributes.

## Responsive and accessibility validation

Test 320px, a representative mobile width, and desktop. Oversized single words in display headings can overflow even when their container wraps normally; measure the document width and adjust mobile type size before relying on `overflow-wrap`.

Exercise the actual interaction states:

- select a node and verify title, topics, neighbors, and destination URL;
- search to one result;
- disable each content type and assert SVG and directory entries disappear;
- zoom and reset;
- select a focused SVG node with Enter or Space;
- verify dark theme;
- load with JavaScript disabled;
- validate every public node URL and edge endpoint against generated output;
- ensure the feature script directory is absent from the built site.

Build once with the feature flag disabled and assert graph navigation is absent from representative pages. This verifies the promised disable/removal path rather than merely documenting it.

## Review checkpoint

Before commit or push, report graph counts, exact feature files, confirmation that post/collection sources are unchanged, build and interaction results, and desktop/mobile screenshots. Keep publication behind explicit approval.
