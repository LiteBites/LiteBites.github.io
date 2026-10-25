# Source-Adaptive Article Structure

Use this after the evidence ledger and before drafting. `POLICY_ARTICLE.md` defines the structural invariants (source-specific `##` headings, the editorial jobs every Article must cover, one final `## Sources`, a three-to-five-item practical ending) and the validator enforces the mechanical parts. This reference is about judgment: making the narrative fit the source instead of filling interchangeable containers.

## Editorial spine

Write one sentence before drafting:

```text
Because <verified mechanism or change>, <practical consequence>; however, <main evidence limit>.
```

A strong spine names the mechanism and the limit:

```text
Because the model activates a small fraction of a large MoE and changes long-context attention, "Flash" describes serving economics rather than a small checkpoint; however, vendor benchmark tables do not establish end-to-end deployment cost or reliability.
```

A weak spine could fit anything ("The release is faster and useful, but more testing is needed."). Reject it.

Every section should advance the same spine. Across the chosen headings the Article establishes the change, states the consequence without repeating the announcement, explains the mechanism that causes the consequence, tests that mechanism against the evidence boundary, and turns the judgment into reusable checks. Pick headings that make that argument visible (for example `## How it serves`, `## Where the comparison breaks`, `## Before adopting it`).

## Source archetypes

```text
Model release       → release delta → architecture/serving mechanism → access → evidence limits
Agent product       → action surface → orchestration/connectors → permissions/economics → reliability limits
Benchmark claim     → protocol → headline result → comparability/reproduction → metric blind spots
API or standard     → normative change → compatibility/migration → implementation status → residual risk
Security event      → timeline → root cause → blast radius → mitigation → remaining exposure
Hardware/system     → architecture → measurement protocol → cost/deployment → availability
Tool/repository     → changed behavior → integration path → maintenance/security → ecosystem fit
```

Combine two only when the source genuinely spans categories.

### Model release
Prioritize exact model identity and availability; the architectural or training delta behind the claimed behavior; active versus total parameters, context, modalities, weights, license, API, and supported runtimes; benchmark protocol and whether results are vendor-run or reproduced; the real deployment implication. Do not equate "open weights" with lightweight local use, API price with infrastructure cost, or benchmark quality with agent reliability.

### Agent or workplace product
Prioritize action surface, orchestration loop, connectors, artifacts, permissions, data flow, approval boundaries, pricing, and observed reliability. Keep model identity separate from product behavior. Distinguish launch capability, currently documented capability, and roadmap. See `agent-product-announcements.md`.

### Benchmark or leaderboard claim
Lead with protocol and evaluated scope, not the score. Identify model, harness, tools, budget, retries, judge, public/private set, contamination controls, traces, and reproduction materials. See `vendor-benchmark-claims.md`.

### API, standard, or protocol change
Lead with the normative or behavioral delta. Explain compatibility, migration, fallback behavior, implementation status, versioning, and who bears the operational cost. A published specification is not deployed support.

### Security event
Anchor a chronology in exact dates. Explain root cause, affected versions, blast radius, exploit evidence, mitigations, and residual exposure. Do not infer compromise from a vulnerability alone or repeat an incident-response claim as independent proof.

### Hardware or systems release
Explain architecture together with the measurement protocol. Separate theoretical throughput, microbenchmarks, end-to-end performance, power, memory, interconnect, availability, and price. See `hardware-system-ai-releases.md`.

### Tool or repository release
Explain changed behavior, integration path, compatibility, maintenance status, permissions, supply-chain risk, and ecosystem fit. A repository existing is evidence of availability, not production maturity.

## Flexible word allocation

Shift words toward the evidence center rather than splitting evenly. Rough guide inside the 400–800 budget: establishing the change 60–130, consequence 60–130, mechanism 120–260, uncertainty 90–180, practical ending 50–110. A model-architecture story may use two short `###` subsections for mechanism; a benchmark controversy may spend more on uncertainty; a standard migration may use compact steps at the end.

## Flow checks

1. Could this opening be pasted onto a different release unchanged? Rewrite it.
2. Does the consequence section explain a consequence, or praise the feature list?
3. Does the mechanism section identify causality, or accumulate specifications?
4. Does the uncertainty section challenge the strongest claim with the correct missing evidence?
5. Do the takeaways tell the relevant reader what to verify next?
6. Do transitions carry one argument forward, or does each section restart the article?
7. Are headings and optional `###` subheadings specific enough to justify their space?

## Anti-template patterns

- identical heading names or paragraph counts across Articles;
- "This matters because…" followed by a restated announcement;
- dumping all specifications into one context section without causality;
- a generic "real-world testing is needed" caveat without naming the missing protocol;
- takeaways that could apply to every AI product;
- forcing every archetype to discuss benchmarks, pricing, security, and licensing equally;
- inventing tags or relationships to make the knowledge graph denser.
