# Reviewing Vendor-Reported Benchmark Claims

Use this reference when an Article Bite is built around a company, lab, or project announcing a benchmark record, perfect score, or “frontier” result.

## Evidence ladder

Classify the result before writing:

1. **Vendor-reported:** the canonical announcement states the result.
2. **Organizer-recorded:** the benchmark organizer lists the submission or score.
3. **Independently verified:** an independent evaluator reran or audited it.
4. **Reproducible:** code, exact configuration, inputs, traces, and instructions allow a materially equivalent rerun.

These levels are not interchangeable. A vendor link to an organizer methodology does not independently verify the vendor’s run. If scorecards or traces are private, say so directly. Distinguish artifacts that are private by policy from artifacts that can be shared: when scorecards are explicitly non-public but replays can be shared, do not prescribe “public scorecards.” Ask instead for **shared replays or independently inspectable evaluation records**.

## Scope checklist

Record the exact evaluation boundary:

- public, development, semi-private, private, hidden, or competition set;
- number of tasks, environments, levels, or samples;
- model name/version and reasoning setting;
- agent harness, memory, supervisor, tools, observation encoding, and prompting;
- allowed actions, interaction budget, retries, resets, and stopping conditions;
- metric definition and whether higher/lower is better;
- what the metric counts and explicitly excludes;
- token use, tool calls, wall-clock time, hardware, and monetary cost when available;
- scorecard, replay, trace, code, configuration, and ablation availability.

Do not expand a public-set result into a hidden-set or general-intelligence claim.

## Comparison discipline

A model-only baseline and a full agent-harness result answer different questions. Likewise, two agent systems are not a controlled comparison when they differ in model settings, observations, prompts, memory, tools, budgets, or evaluation date.

Use wording such as:

> The comparison shows that system design matters, but it does not isolate which component produced the difference.

Environment-action efficiency is not total efficiency when internal reasoning, read-only tools, retries, tokens, latency, or compute are excluded from the metric.

## Drafting pattern

- Attribute the headline immediately: “Company X reports…”
- State the evaluated set in the same paragraph as the score.
- Explain the metric before interpreting it.
- Separate model capability from harness behavior.
- Name unavailable verification artifacts under uncertainty.
- Prefer “perfect on the evaluated public set” over “solved the benchmark.”
- Treat terms such as “frontier,” “general-purpose,” and “autonomous” as source language unless independently established.

## Figures without repository copies

If the user requests a source figure but no admissible original-source embed exists, do not use Markdown image syntax, a remote `<img>`, or a repository copy. Add a descriptive HTTPS link to the publisher-hosted original asset or canonical article, verify that it resolves to the intended figure, and explain at the review checkpoint that the figure is linked rather than embedded. Direct CDN asset URLs can be less durable than canonical article URLs, so retain the canonical article in `## Sources` and recheck the figure link immediately before publication. Never download or embed a local copy as an Article presentation fallback. If the user separately requests an original visualization, create a source-grounded original under `first-party-explanatory-figures.md`; do not copy the publisher artwork.

## Verification

Before approval, independently check every headline number against the canonical source and, where possible, the benchmark organizer. Confirm that dates and model settings match. Make the source list include the canonical announcement, metric/methodology documentation, organizer result page where available, and the relevant technical report or project page. Record unresolved discrepancies rather than averaging or choosing the more favorable number.
