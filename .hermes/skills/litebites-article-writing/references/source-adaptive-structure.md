# Source-Adaptive Article Structure

Use this reference after the evidence ledger and before drafting. The goal is a recognizable LiteBites contract with a source-specific narrative—not six interchangeable containers filled in mechanically.

## Invariants versus adaptive choices

### Invariants

Keep:

- the exact six `##` headings and their order;
- 400–800 body words;
- verified source metadata and clear attribution;
- a practical ending and material source list;
- the local review and publication boundary.

### Adaptive choices

Change according to the source:

- the opening tension;
- paragraph count and relative section length;
- the order of facts inside each required section;
- whether `###` microheadings improve `Technical context` or `What remains uncertain`;
- whether takeaways are operational checks, migration steps, evaluation questions, or risk controls;
- how much space goes to mechanism, evidence, deployment, economics, or uncertainty.

Do not add another `##` heading. Optional `###` headings must be specific to the source and useful at 400–800 words; omit them when they merely restate the parent section.

## Editorial spine

Write one sentence before drafting:

```text
Because <verified mechanism or change>, <practical consequence>; however, <main evidence limit>.
```

A strong spine names the mechanism and limit:

```text
Because the model activates a small fraction of a large MoE and changes long-context attention, “Flash” describes serving economics rather than a small checkpoint; however, vendor benchmark tables do not establish end-to-end deployment cost or reliability.
```

A weak spine could fit anything:

```text
The release is faster and useful, but more testing is needed.
```

Every required section should advance the same spine:

- `What happened` establishes the change and availability.
- `Why it matters` states the consequence without repeating the announcement.
- `Technical context` explains the mechanism that causes the consequence.
- `What remains uncertain` tests the mechanism and evidence boundary.
- `Practical takeaways` turns that judgment into reusable checks.

## Source archetypes

### Model release

Prioritize:

1. exact model identity and availability;
2. the architectural or training delta responsible for the claimed behavior;
3. active versus total parameters, context, modalities, weights, license, API, and supported runtimes;
4. benchmark protocol and whether results are vendor-run or independently reproduced;
5. the real deployment implication.

Avoid equating “open weights” with lightweight local use, API price with infrastructure cost, or benchmark quality with agent reliability.

### Agent or workplace product

Prioritize the action surface, orchestration loop, connectors, artifacts, permissions, data flow, approval boundaries, pricing, and observed reliability. Keep model identity separate from product behavior. Distinguish launch capability, currently documented capability, and roadmap.

### Benchmark or leaderboard claim

Lead with protocol and evaluated scope, not the score alone. Identify model, harness, tools, interaction or token budget, retries, judge, public/private set, contamination controls, traces, and reproduction materials. Allocate extra space to comparability and metric blind spots.

### API, standard, or protocol change

Lead with the normative or behavioral delta. Explain compatibility, migration, fallback behavior, implementation status, versioning, and who bears the operational cost. Separate a published specification from deployed support.

### Security event

Use a chronology anchored in exact dates. Explain root cause, affected versions or systems, blast radius, exploit evidence, mitigations, and residual exposure. Do not infer compromise from vulnerability alone or repeat an incident-response claim as independent proof.

### Hardware or systems release

Explain architecture together with the measurement protocol. Distinguish theoretical throughput, kernel or microbenchmark results, end-to-end performance, power, memory, interconnect, availability, and price. Compare only compatible precision and workload settings.

### Tool or repository release

Explain changed behavior, integration path, compatibility, maintenance status, permissions, supply-chain risk, and ecosystem fit. A repository existing is evidence of availability—not production maturity.

## Flexible word allocation

Treat these as ranges, not quotas:

```text
What happened             60–130
Why it matters            60–130
Technical context        120–260
What remains uncertain    90–180
Practical takeaways       50–110
Sources                    as needed
```

Shift words toward the evidence center. A model architecture story may use two short `###` subsections inside `Technical context`; a benchmark controversy may put more words in uncertainty; a standard migration may use compact steps in practical takeaways.

## Flow checks

Before validation, ask:

1. Could this opening be pasted onto a different release unchanged? If yes, rewrite it.
2. Does `Why it matters` explain a consequence, or merely praise the feature list?
3. Does `Technical context` identify a causal mechanism rather than accumulating specifications?
4. Does uncertainty challenge the strongest claim with the correct missing evidence?
5. Do the takeaways tell the relevant reader what to verify next?
6. Are transitions carrying one argument forward, or does each section restart the article?
7. Are optional subheadings specific enough to justify their space?

## Anti-template patterns

Avoid:

- identical paragraph counts across every Article Bite;
- “This matters because…” followed by a restated announcement;
- dumping all specifications into `Technical context` without explaining causality;
- a generic caveat that “real-world testing is needed” without naming the missing protocol;
- takeaways that could apply to every AI product;
- forcing every archetype to discuss benchmarks, pricing, security, and licensing equally;
- inventing tags or relationships to make the knowledge graph denser.

The final article should feel tailored to its source while remaining unmistakably an Article Bite.