---
layout: article
title: "NVIDIA AVO's Perfect ARC-AGI-3 Public-Set Score Tests the Agent, Not Just the Model"
short_title: "NVIDIA AVO on ARC-AGI-3"
date: 2026-08-23
type: "Article Bite"
read_time: "3 min read"
source_name: "NVIDIA Technical Blog"
source_url: "https://developer.nvidia.com/blog/nvidia-avo-reaches-100-on-arc-agi-3-demonstrating-a-frontier-level-general-purpose-architecture-for-long-horizon-autonomous-agents/"
source_published: 2026-08-21
last_reviewed: 2026-08-31
tags:
  - Agentic AI
  - Language Models
  - Reasoning Systems
summary: "NVIDIA reports a perfect ARC-AGI-3 public-set score for AVO, but the result measures a complete agent harness and leaves private-set generalization, compute cost, and component-level attribution unresolved."
additional_sources:
  - name: "ARC-AGI-3 benchmark overview"
    url: "https://arcprize.org/arc-agi/3"
  - name: "ARC-AGI-3 scoring methodology"
    url: "https://docs.arcprize.org/methodology"
  - name: "ARC-AGI-3 scorecard documentation"
    url: "https://docs.arcprize.org/scorecards"
  - name: "ARC Prize Claude Opus 5 verified results"
    url: "https://arcprize.org/results/anthropic-claude-opus-5"
  - name: "AVO research paper"
    url: "https://arxiv.org/abs/2603.24517"
  - name: "VISTA project page"
    url: "https://vista-research.github.io/"
---

## What happened

On August 21, 2026, NVIDIA reported that its **Agentic Variation Operators (AVO)** system achieved a 100.00 Relative Human Action Efficiency score on the 25-environment ARC-AGI-3 public set. Running Claude Opus 5, AVO completed all 183 levels in 6,624 environment actions. NVIDIA also compared that total with the 7,542 actions reported by MIT's VISTA harness, while cautioning that the systems differ too much for a controlled comparison.

The scope matters. This was a result on the openly available public environments, not the semi-private or private competition sets. NVIDIA's post includes an editor's note clarifying that distinction.

## Why it matters

The result is evidence for a practical point about agent evaluation: the model and the harness are not interchangeable. ARC Prize's verified model-level evaluation reports 30.16% for Claude Opus 5 at High reasoning effort. NVIDIA used a different reasoning setting, observation format, memory system, and execution loop, so the difference cannot be assigned to AVO alone. Still, the gap shows why a model score does not predict the behavior of a complete agent system.

AVO is also notable for moving between two unlike domains. Its earlier research used autonomous evolutionary search to optimize GPU kernels. The ARC experiment applies the same broad inspect, act, evaluate, remember, and recover loop to unfamiliar interactive environments. That transfer is more informative than the headline score by itself.

## Technical context

ARC-AGI-3 presents game-like environments without instructions, stated rules, or stated goals. An agent must infer how actions change the world and carry useful knowledge into later levels. The benchmark's RHAE metric combines completion with action efficiency relative to first-time-human baselines. Only actions that alter the environment count; internal reasoning, read-only tool calls, and retries are not part of the action total.

For ARC-AGI-3, NVIDIA says AVO received each observation as an exact 64-by-64 text grid rather than an image. Persistent memory carries forward observations, hypotheses, and results, while a supervisor watches for stagnation and can redirect the search. NVIDIA's [architecture diagram](https://developer.nvidia.com/blog/nvidia-avo-reaches-100-on-arc-agi-3-demonstrating-a-frontier-level-general-purpose-architecture-for-long-horizon-autonomous-agents/) shows this main-agent loop, memory, tools, and conditional supervisor intervention.

<figure class="article-figure">
  <a href="{{ '/assets/images/articles/nvidia-avo-arc-agi-3/avo-loop.svg' | relative_url }}">
    <img src="{{ '/assets/images/articles/nvidia-avo-arc-agi-3/avo-loop.svg' | relative_url }}" width="1600" height="900" loading="lazy" decoding="async" alt="Diagram showing 64-by-64 text-grid observations entering an AVO loop of inspect, plan, act, and evaluate, supported by persistent memory, read-only tools, and a supervisor that redirects stalled search before state-changing environment actions are counted.">
  </a>
  <figcaption>LiteBites synthesis of AVO's ARC-AGI-3 execution loop from the <a href="https://developer.nvidia.com/blog/nvidia-avo-reaches-100-on-arc-agi-3-demonstrating-a-frontier-level-general-purpose-architecture-for-long-horizon-autonomous-agents/">NVIDIA Technical Blog</a>; it is an original explanatory diagram, not NVIDIA's figure. <a href="{{ '/assets/images/articles/nvidia-avo-arc-agi-3/avo-loop.svg' | relative_url }}">Open full resolution ↗</a></figcaption>
</figure>

## What remains uncertain

The 100.00 result is currently an NVIDIA-reported system evaluation. ARC Prize documentation says scorecards are not public, and NVIDIA's post does not link a public AVO scorecard or complete replay set. The available AVO paper documents the earlier GPU-kernel work, not the ARC-AGI-3 experiment.

The experiment also does not isolate which component produced the gain. Memory, supervision, text-grid observations, context management, prompting, and reasoning settings all changed relative to the model baseline and VISTA. RHAE ignores internal token usage, tool calls, wall-clock time, and compute, so fewer environment actions do not necessarily mean lower total cost. Finally, perfect performance on public environments does not establish performance on hidden competition sets or unrelated real-world tasks.

## Practical takeaways

- Evaluate the model and agent harness as separate layers with separate baselines.
- Record prompts, observation encoding, memory policy, tool permissions, action budget, token use, wall-clock time, and recovery behavior.
- Do not translate a public-set result into a private-set or general-intelligence claim.
- Require shared replays or independently inspectable evaluation records before treating a vendor-reported run as independently reproducible.
- Use ARC-AGI-3's action metric alongside compute and latency measurements, not as a substitute for them.

## Sources

- [NVIDIA Technical Blog — NVIDIA AVO Reaches 100% on ARC-AGI-3](https://developer.nvidia.com/blog/nvidia-avo-reaches-100-on-arc-agi-3-demonstrating-a-frontier-level-general-purpose-architecture-for-long-horizon-autonomous-agents/)
- [ARC Prize — ARC-AGI-3 benchmark overview](https://arcprize.org/arc-agi/3)
- [ARC Prize — ARC-AGI-3 scoring methodology](https://docs.arcprize.org/methodology)
- [ARC Prize — ARC-AGI-3 scorecard documentation](https://docs.arcprize.org/scorecards)
- [ARC Prize — Claude Opus 5 verified results](https://arcprize.org/results/anthropic-claude-opus-5)
- [Chen et al. — AVO: Agentic Variation Operators for Autonomous Evolutionary Search](https://arxiv.org/abs/2603.24517)
- [MIT — VISTA: A Visual Harness for Reasoning in an Interactive World](https://vista-research.github.io/)
