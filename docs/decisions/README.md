# Decision records

Short notes on why LiteBites works the way it does. Read the relevant record
before changing the mechanism it describes. Add a new numbered file when a
decision changes how the site is maintained. Do not rewrite old records;
supersede them.

| # | Decision |
|---|---|
| [0001](0001-schema-is-the-source-of-truth.md) | Mechanical rules live in `_data/bite_schema.yml` and the validator, not in prose |
| [0002](0002-agents-md-context.md) | Agent context lives in `AGENTS.md` files next to the code |
| [0003](0003-committed-graph-files.md) | Generated graph files stay committed; `check` fails when they are stale |
| [0004](0004-data-driven-components.md) | Interactive features are includes driven by data, with no per-post JavaScript |
