---
layout: article
title: "Graph Engineering: Why Agent Workflows Should Stop Being Queues"
short_title: "Graph Engineering for Agents"
date: 2026-09-21
type: "Article Bite"
read_time: "4 min read"
source_name: "seeco"
source_url: "https://x.com/i/article/2088183750425280512"
source_published: 2026-08-14
last_reviewed: 2026-09-21
tags:
  - AI Agents
  - Agent Infrastructure
  - Developer Tools
summary: "A graph-engineering playbook argues that agent workflows should expose real dependencies, run independent work in parallel, and verify results at the edges instead of forcing every task through a queue."
card_image: "/assets/images/articles/graph-engineering/chain-vs-graph.svg"
card_image_alt: "Diagram comparing a linear agent queue with a dependency graph that runs independent jobs in parallel"
additional_sources:
  - name: "Claude Code subagents documentation"
    url: "https://code.claude.com/docs/en/sub-agents"
  - name: "Claude Code common workflows"
    url: "https://code.claude.com/docs/en/common-workflows"
  - name: "Claude Code hooks reference"
    url: "https://code.claude.com/docs/en/hooks"
  - name: "Original X post"
    url: "https://x.com/seeconvm/status/2088199384580108339"
---

## The queue hiding inside your agent

Most multi-step agents are written like a queue: do one thing, wait, do the next, and keep going until the context window fills up. The sequence is easy to understand, but it often hides the real structure of the work. Some steps depend on earlier output. Others merely happen to appear later in the script.

That distinction is the starting point for “graph engineering,” a term used in a recent X long-form article by seeco. The proposal is straightforward: model an agent as a dependency graph. Nodes are bounded jobs. Edges describe which outputs another job actually consumes. If two nodes do not share a dependency, making them wait for each other is a design choice—not a technical requirement.

## “And then” is not always an edge

Consider an agent asked to inspect a codebase, check its open issues, and summarize deployment risks. If the issue search does not need the codebase inspection, those jobs can run concurrently. A later synthesis step can wait for both results.

That shape is a diamond: one task fans out into independent work, then fans back in at a deliberate barrier. The barrier matters. Starting everything at once is not graph engineering; it is just uncontrolled concurrency. The downstream node should wait only for the outputs it needs, and each edge should make that data contract explicit.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Comparison of a linear agent queue and a dependency graph">
    <a href="{{ '/assets/images/articles/graph-engineering/chain-vs-graph.svg' | relative_url }}"><img src="{{ '/assets/images/articles/graph-engineering/chain-vs-graph.svg' | relative_url }}" width="1600" height="900" loading="lazy" decoding="async" alt="Diagram comparing a linear agent queue with a dependency graph that runs two independent jobs in parallel before a synthesis step"></a>
  </div>
  <figcaption>
    LiteBites synthesis from the <a href="https://x.com/i/article/2088183750425280512">graph-engineering article</a>; the layout is original and schematic, not a measured performance chart. Swipe or scroll horizontally on narrow screens.
    <a href="{{ '/assets/images/articles/graph-engineering/chain-vs-graph.svg' | relative_url }}">Open full resolution ↗</a>
  </figcaption>
</figure>

The same reasoning exposes accidental serialization. “Summarize this file and then tell me the weather” is a chain in code, but the weather query does not consume the summary. The graph has two independent branches. A linear script has turned them into unnecessary waiting.

## Parallelism needs contracts

The useful part of the playbook is not the instruction to spawn more agents. It is the discipline around each node: define the input, define the output, and decide what happens when the result is incomplete or wrong.

A verifier can sit on an edge before the next node receives the data. A failed branch can retry, stop, or remain isolated instead of poisoning the entire run. A conditional edge can route a difficult request to a stronger model while sending routine work to a cheaper one. Cycles are possible too, but they need a convergence rule; otherwise the graph is an expensive loop with better vocabulary.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Schematic comparison of sequential and parallel agent execution timelines">
    <a href="{{ '/assets/images/articles/graph-engineering/sequential-vs-parallel.svg' | relative_url }}"><img src="{{ '/assets/images/articles/graph-engineering/sequential-vs-parallel.svg' | relative_url }}" width="1600" height="900" loading="lazy" decoding="async" alt="Schematic timeline comparing four sequential agent jobs with two parallel branches followed by a merge job"></a>
  </div>
  <figcaption>
    LiteBites synthesis from the <a href="https://x.com/i/article/2088183750425280512">graph-engineering article</a>; durations are illustrative and do not represent a benchmark. Swipe or scroll horizontally on narrow screens.
    <a href="{{ '/assets/images/articles/graph-engineering/sequential-vs-parallel.svg' | relative_url }}">Open full resolution ↗</a>
  </figcaption>
</figure>

Claude Code’s official documentation confirms the building blocks around this idea. It documents custom subagents, parallel research, background work, dynamic workflows, worktree isolation, and hooks that run around subagent and tool events. Those capabilities make graph-shaped orchestration practical, but they do not prove every performance claim made by community posts.

## Topology is a hypothesis, not a benchmark

The X article argues that graph topology determines cost and latency. That is directionally sensible: independent work can overlap, while every unnecessary dependency adds waiting. But the article does not provide a controlled benchmark showing that a graph is always faster, cheaper, or more reliable than a chain.

Actual results depend on model latency, tool delays, rate limits, context transfer, retries, synchronization barriers, and how much work the final merge step must perform. Parallel branches can also increase peak resource use and make failures harder to reason about. “Coordination costs zero model tokens” may describe a particular orchestration path, but it should not be treated as a universal property of agent systems.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Agent edge contract and verification flow">
    <a href="{{ '/assets/images/articles/graph-engineering/edge-contracts.svg' | relative_url }}"><img src="{{ '/assets/images/articles/graph-engineering/edge-contracts.svg' | relative_url }}" width="1600" height="900" loading="lazy" decoding="async" alt="Diagram showing a source node emitting findings, an edge verifier checking schema and confidence, and pass or fail paths to downstream work"></a>
  </div>
  <figcaption>
    LiteBites synthesis from the <a href="https://x.com/i/article/2088183750425280512">graph-engineering article</a> and <a href="https://code.claude.com/docs/en/hooks">Claude Code hook documentation</a>; it illustrates a design pattern rather than a required implementation. Swipe or scroll horizontally on narrow screens.
    <a href="{{ '/assets/images/articles/graph-engineering/edge-contracts.svg' | relative_url }}">Open full resolution ↗</a>
  </figcaption>
</figure>

## A practical graph-engineering checklist

Before parallelizing an agent, inspect every “and then.” Ask whether the next step reads the previous output. If it does not, consider a fan-out. Give each node a narrow contract, and give each edge a clear payload. Add a verifier where a bad result would contaminate downstream work. Put barriers only where a merge truly needs all branches. Finally, measure wall-clock time, model calls, tool calls, retries, peak concurrency, and failure recovery separately.

The important shift is conceptual: an agent is not necessarily a queue of prompts. It is a program whose dependency graph can be made explicit, tested, and redesigned. Parallelism is one consequence. Better failure boundaries and clearer reasoning about cost may matter just as much.

## Sources

- [Graph Engineering: Stop Chaining Your Agents — seeco](https://x.com/i/article/2088183750425280512)
- [Original X post](https://x.com/seeconvm/status/2088199384580108339)
- [Create custom subagents — Claude Code Docs](https://code.claude.com/docs/en/sub-agents)
- [Common workflows — Claude Code Docs](https://code.claude.com/docs/en/common-workflows)
- [Hooks reference — Claude Code Docs](https://code.claude.com/docs/en/hooks)
