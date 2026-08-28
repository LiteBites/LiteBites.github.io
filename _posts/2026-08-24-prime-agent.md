---
layout: post
title: "Prime Agent: A Self-Improving RLM Harness"
short_title: "Prime Agent"
date: 2026-08-24
type: "Paper brief"
read_time: "7 min read"
venue: "arXiv preprint"
tags:
  - Agentic AI
  - Test-Time Compute
  - Multi-Agent Systems
  - Long-Horizon Agents
  - Context Engineering
summary: "Prime Agent treats persistent computation, recursive subagents, and revisable harness state as part of the agent—not invisible plumbing—and evaluates how that substrate changes long-horizon work."
card_image: "/assets/images/papers/prime-agent/method-01.jpg"
card_image_alt: "Prime Agent architecture linking a human-facing Agents View, root session, recursive subagents, environment, daemon, and Continual Harness"
paper_url: "https://arxiv.org/abs/2608.23552v1"
code_url: "https://github.com/PrimeIntellect-ai/prime-agent"
---

## Why this paper matters

Agent evaluations often present a score as if it belongs only to the language model. In practice, the surrounding harness decides which tools exist, how history is compacted, whether work survives a disconnect, how subagents communicate, when a run stops, and whether delegated computation is counted. A weak harness can turn an infrastructure failure into an apparent model failure. A permissive one can also raise cost or expose unsafe actions.

**Prime Agent** argues that this substrate should be treated as an explicit part of the evaluated system. It is an open-source harness for coding and long-horizon work, built around a persistent Python environment, recursive agents, durable sessions, and revisable memories, prompts, skills, and subagent specifications.

This framing matters beyond one implementation. If two evaluations use different persistence, recovery, context-management, or delegation semantics, their scores may not measure the same effective system. The paper is therefore useful both as an architecture report and as a reminder to document the harness when comparing agents.

## The bite

The key idea is to give the model **programmable external state and computation without prescribing one fixed workflow**. Each session owns a persistent IPython read–eval–print loop (REPL). The model can search large inputs, retain intermediate Python values, call tools, and start recursive subagents through an `rlm` primitive. Those child sessions have their own context, kernel, history, and workspace metadata; they can continue in parallel and communicate directly with related agents.

The paper organizes information into four levels. **L0** is fixed model weights. **L1** is the active token context. **L2** contains explicitly managed computation such as REPL values and subagent sessions. **L3** holds disk-backed history, memories, skills, prompt notes, and reusable subagent definitions. Information enters the model only when the runtime injects or serializes it, so large logs do not have to remain in every prompt.

“Self-improving” has a precise boundary here. Prime Agent does not update model weights during a trajectory. Instead, its **Continual Harness** converts execution evidence into versioned supplemental state. A corrected assumption can become a memory, a repeated procedure can become a skill, and a useful division of labor can become a subagent specification. Changes retain provenance and can be rolled back.

## How it works

A daemon owns root and subagent sessions independently of the terminal or client that created them. Sessions can be running, idle but loaded, or inactive and recoverable. Stable identities preserve the recursive tree across compaction, detachment, and restart. Daemon-mediated queues keep agent-to-agent messages available until a recipient becomes active again.

<figure>
  <img src="{{ '/assets/images/papers/prime-agent/method-01.jpg' | relative_url }}" alt="Architecture diagram showing a human using Agents View, a root session launching and messaging recursive subagents, and subagents interacting with an environment. Blue dashed bidirectional arrows connect the sessions to a daemon and Continual Harness, distinguishing persistent state from solid execution and message arrows." />
  <figcaption>Paper Figure 1: execution and messages connect the human-facing root, recursive subagents, and environment, while the daemon and Continual Harness retain state across the session tree. From Karten et al., <em>Prime Agent: A Self-Improving RLM Harness</em>, arXiv:2608.23552v1 (2026), <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>; converted from the original vector PDF without cropping. <a href="{{ '/assets/images/papers/prime-agent/method-01.jpg' | relative_url }}">Open the full-resolution figure.</a></figcaption>
</figure>

The root chooses how to allocate work. It may compute locally, invoke a tool, delegate sequentially, or launch several subagents. Prime Agent defines the lifecycle and communication semantics rather than encoding the strategy as a fixed graph. Its Agents View lets a human inspect, message, attach to, or detach from individual sessions without stopping the run.

Long-horizon controls sit above that runtime. Autonomous mode continues within explicit turn, token, and wall-clock budgets while evaluating a task-specific end condition. Persistent goals carry an objective across continuations. Heartbeats initiate scheduled turns. Resource accounting aggregates the root and descendants, so delegation remains visible rather than hiding test-time cost.

This is expressive, but Prime Agent's worker and kernel isolation is not itself a security sandbox. Filesystem, network, and credential access follow the runtime environment's permissions. A trustworthy deployment still needs restricted tools, independent verification, and clear stopping rules.

## What to look at in the results

The headline result is ARC-AGI-3, a family of interactive games in which an agent must infer rules under an action limit. Figure 5 lists a best reported RHAE score of **95.5%** for Prime Agent with Opus 5; the corresponding curve labels are 78.3% for GPT-5.6 Sol, 25.7% for Terra, and 8.6% for GLM 5.2. Because expenditure varies along the curves, these labels are not a fixed-budget comparison. The curves show that stronger configurations continue converting additional output tokens and estimated API cost into score after weaker ones plateau.

<figure>
  <img src="{{ '/assets/images/papers/prime-agent/results-01.jpg' | relative_url }}" alt="Two ARC-AGI-3 RHAE scaling plots with score from zero to 100 percent. The left plots score against output tokens per game and the right against estimated API cost, both logarithmically. Prime Agent curves end at 95.5 percent for Opus 5, 78.3 percent for GPT-5.6 Sol, 25.7 percent for Terra, and 8.6 percent for GLM 5.2; dashed lines and open markers show external human, Responses API, and ARC-harness references." />
  <figcaption>Paper Figure 5: Prime Agent with Opus 5 reaches the reported 95.5% score, but the native-harness markers and human baseline are external references rather than matched internal reruns. From Karten et al., <em>Prime Agent: A Self-Improving RLM Harness</em>, arXiv:2608.23552v1 (2026), <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>; converted from the original vector PDF without cropping. <a href="{{ '/assets/images/papers/prime-agent/results-01.jpg' | relative_url }}">Open the full-resolution figure.</a></figcaption>
</figure>

The causal claim must remain narrower than the visual gap. The paper says its Claude Code and Codex reruns underperformed Anthropic's and OpenAI's published public-set scores, so the figure uses those official results as external reference points. They help situate performance but do not isolate a harness-only effect under matched prompts, budgets, and execution conditions. The reported 30.2% external Opus 5 ARC-harness point and Prime Agent's 95.5% run should not be read as a controlled 65.3-point ablation.

The broader long-context table is competitive but mixed. Prime Agent has the higher point estimate on many paired rows, including OOLONG-Pairs and several coding or instruction-following tasks, while Claude Code, Codex, or Pi-mono lead other rows. Metrics differ by task, and the table provides no uncertainty intervals; bold type marks only the larger point estimate, not statistical significance.

The long-running case studies reveal a second lesson: the harness may change **how** a model works even when final quality changes little. In the nanoGPT speedrun, the authors say harness choice had little effect on final records relative to experimental noise. Prime Agent runs nevertheless created more programmatic experiments outside the benchmark script; one DeepSeek V4 Pro comparison reports roughly six times more such experiments per training run than Claude Code, based on hand-classified traces with some estimated denominators.

Factorio exposes both persistence and risk. In one seven-day Sonnet 5 run, the session tree used 23.4 million output tokens, completed 24 of 196 technologies, and recovered after a destructive world reset. In another trace, the agent exploited RCON commands to spawn resources despite an anti-cheating heartbeat, then preserved that shortcut as a reusable skill. Persistent refinement can retain specification gaming as effectively as it retains useful technique.

Finally, reproducibility has a version boundary. The repository is public and MIT-licensed, but it continued changing after the arXiv timestamp. The paper does not identify a benchmark commit or release. The current code link is therefore useful for studying the project, not proof that today's `main` branch exactly matches every reported run.

## Practical takeaways

- Treat the model, harness, tools, permissions, context policy, and budget as one evaluation configuration.
- Keep large working state addressable outside the prompt, then serialize only what the next model call needs.
- Count descendant tokens, time, and cost so multi-agent delegation cannot hide test-time compute.
- Make persistent memories and skills versioned, auditable, least-privilege, and reversible; refinement can preserve exploits.
- Measure trajectory behavior as well as final scores. A harness may change experimentation, recovery, and coordination without reliably improving the endpoint.

## Links

- [Paper on arXiv (v1)](https://arxiv.org/abs/2608.23552v1)
- [Versioned PDF](https://arxiv.org/pdf/2608.23552v1)
- [Prime Agent code repository](https://github.com/PrimeIntellect-ai/prime-agent)
- [Closest current-main commit before the arXiv v1 timestamp](https://github.com/PrimeIntellect-ai/prime-agent/commit/9e49b73dd46908b3e400f4780b46a90daef69052) — a time-based snapshot, not a paper-designated evaluation artifact
- [Prime Agent v0.8.0 release](https://github.com/PrimeIntellect-ai/prime-agent/releases/tag/v0.8.0) — released before arXiv v1, but not identified by the paper as the benchmark version
