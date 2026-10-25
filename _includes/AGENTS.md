# _includes/: interactive components

Each feature is one include, styles in `assets/css/components.css`, and
behavior in `assets/js/site.js`. Pages work without JavaScript. Bites use the
features by writing **data**; never add `<script>` to a Bite. The validator
checks every shape below.

## Automatic (no authoring)

| Include | Where | Source |
|---|---|---|
| `related-bites.html` | Bottom of every Bite | Up to four graph neighbors from `_data/knowledge-graph-state.json`. Run `scripts/litebites graph` after tag changes |
| `search.html` | Every page (header button, `/`, Cmd/Ctrl+K) | `/search.json`, built from front matter |
| `topic-filter.html` | `/archive/`, `/articles/`, `/papers/`, `/data/` | `data-topics` on each `[data-topic-item]` row. Links like `/archive/#topic=Agentic%20AI` work |

## Written in front matter

**`benchmarks:`** is a sortable results table. Place it in the body with `{% include benchmarks.html index=0 %}` (index 1 for the second table, and so on). Every defined table must be placed.
```yaml
benchmarks:
  - title: "Paper Table 5: what the table compares"   # caption
    source: "[Table 5](https://…) of the paper"         # Markdown allowed
    columns: [Method, Accuracy, Latency (ms)]            # first column = row label
    higher_is_better: [true, false]                      # one per metric column; null = no direction
    note: "Protocol caveats for the whole table."        # optional
    rows:
      - cells: [Ours, "91.20", "35.0"]                   # quote numbers to keep printed precision
        caveat: "Author-reported"                        # optional per row; adds a Caveat column
        highlight: true                                  # optional; shades the row
```
Copy numbers exactly from the source. The best value in a column with a direction is bolded automatically, so do not set a direction where the source does not support one.

**`check_yourself:`** adds 1–5 reveal cards after the body (rendered by `check-yourself.html`). Each answer must be supported by the post.
```yaml
check_yourself:
  - q: "Question in one sentence?"
    a: "Answer with *Markdown* allowed."
```

## Written in the body

- `{% include term.html id="teds" %}` or `{% include term.html id="teds" text="TEDS scores" %}` is a glossary term with a hover/focus definition. The `id` must exist in `_data/glossary.yml` (id, term, definition). Use it on the first mention only.
- `{% include claim.html kind="evidence" text="Sentence with **Markdown**." %}` marks a sentence for the reader's "Show evidence layers" toggle. `kind` is one of:
  - `reported`: the source's own claim;
  - `evidence`: independently checked or measured;
  - `interpretation`: LiteBites' reading;
  - `uncertainty`: what is unknown.

  Wrap the existing sentence without changing its words. Do not use straight double quotes inside `text`. Mark a few decisive sentences, not every sentence. The toggle appears only on pages that contain claims.

## Adding a component
A new component is site work (skill `litebites-site`). It needs the include, styles in `components.css`, optional progressive JS in `site.js`, a validator rule and test in `scripts/validate_bites.rb` / `scripts/test_validate_bites.rb`, and an entry here.
