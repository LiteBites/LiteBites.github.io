---
layout: article
title: "Claude Opus 5.5: Lower Token Costs, Higher Agentic Ambition"
short_title: "Claude Opus 5.5"
date: 2026-09-23
type: "Article Bite"
read_time: "4 min read"
source_name: "Anthropic"
source_url: "https://www.anthropic.com/claude-opus-5-5"
source_published: 2026-09-22
last_reviewed: 2026-09-23
tags:
  - AI Models
  - AI Agents
  - Developer Tools
summary: "Anthropic’s Claude Opus 5.5 targets long-running coding and knowledge work with lower token prices, a 1M-token context window, and benchmark gains that still need careful protocol reading."
card_image: "/assets/images/articles/claude-opus-5-5/benchmark-reading.svg"
card_image_alt: "LiteBites diagram showing selected Claude Opus 5.5 benchmark results alongside the evaluation conditions readers should check"
additional_sources:
  - name: "Claude Opus 5.5 System Card"
    url: "https://anthropic.com/claude-opus-5-5-system-card"
  - name: "Claude Platform release notes"
    url: "https://platform.claude.com/docs/en/release-notes/overview"
  - name: "Models overview"
    url: "https://platform.claude.com/docs/en/models/overview"
---

## The Opus tier is shifting toward long-running work

Anthropic’s Claude Opus 5.5 is not framed as a small quality bump. It is the first release in a new Claude 5.5 family, aimed at long-running agentic coding and knowledge work. Anthropic says it reaches roughly the level of Claude Fable 5.1 on most work while costing 40% less to run than Opus 5 on typical workloads.

The platform details support that positioning: a 1-million-token context window, up to 128,000 output tokens, always-on adaptive thinking, and a model ID of `claude-opus-5-5`. API pricing is $4 per million input tokens and $20 per million output tokens, down from $5 and $25 for Opus 5. Cache reads fall from $0.50 to $0.20 per million tokens.

That is a meaningful change for agents whose cost comes from repeated context transfer rather than a single prompt. It also changes the practical question. The issue is no longer simply whether Opus 5.5 is more capable; it is whether the extra capability arrives with fewer steps, fewer retries, or less human cleanup.

## The headline benchmarks need their footnotes

Anthropic reports Opus 5.5 leading its comparison table on agentic coding, computer use, and knowledge work. Its reported scores include 66.4% on Terminal-Bench 4.0, 54.4% on FrontierCode, 57.8% on CursorBench, 1846 on GDPval-AA, and 81.8% partial on OSWorld 2.0.

Those numbers are not one uniform evaluation. Anthropic says most results use adaptive thinking at maximum effort, while Terminal-Bench uses xhigh effort. Some competitor figures are reported by their vendors. AutomationBench results come from Zapier’s early-access evaluation, and Anthropic notes that safeguard interventions counted as failures there.

The release also reports meaningful uncertainty. Terminal-Bench’s standard errors are large enough that small margins should not be read as decisive. Anthropic says benchmark gaps at this capability level are a less reliable guide to real-world differences, and that the practical gap between Opus 5.5 and Fable 5.1 is narrower than the table suggests.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="LiteBites synthesis of Claude Opus 5.5 benchmark results and evaluation conditions">
    <a href="{{ '/assets/images/articles/claude-opus-5-5/benchmark-reading.svg' | relative_url }}"><img src="{{ '/assets/images/articles/claude-opus-5-5/benchmark-reading.svg' | relative_url }}" width="1600" height="900" loading="lazy" decoding="async" alt="LiteBites diagram showing selected Claude Opus 5.5 benchmark results alongside the evaluation conditions readers should check"></a>
  </div>
  <figcaption>
    LiteBites synthesis from <a href="https://www.anthropic.com/claude-opus-5-5">Anthropic’s Opus 5.5 announcement</a> and its benchmark footnotes. The metrics use different scales and conditions; the figure does not create a cross-benchmark ranking.
    <a href="{{ '/assets/images/articles/claude-opus-5-5/benchmark-reading.svg' | relative_url }}">Open full resolution ↗</a>
  </figcaption>
</figure>

## Efficiency is the actual product story

The strongest case for Opus 5.5 may be economic rather than leaderboard-based. Anthropic says the model generates output more than 30% faster than Opus 5, uses fewer tokens per task, and costs about 40% less for typical token-billed work. It also offers a fast mode with up to 2.5× speed at twice the standard token price.

Anthropic’s examples are promising but remain company-reported: a large code migration completed in less than a day, a 200,000-line audit finished in under three hours, and a HAProxy C-to-Rust rewrite that finished faster and cost less than a Fable 5.1 run. These are useful workload clues, not independently reproduced benchmarks.

## What to test before switching

For a real evaluation, measure completed task quality alongside total tokens, tool calls, wall-clock time, retries, intervention rate, and recovery behavior. Test the same harness and effort settings across models. Check whether safeguards, fallback models, or human corrections changed the apparent cost.

Opus 5.5 looks designed for agents that stay busy for hours, not just chat turns that finish in seconds. Whether it is a better default depends less on the headline score than on how reliably its lower token use survives contact with your own workflow.

## Sources

- [Introducing Claude Opus 5.5 — Anthropic](https://www.anthropic.com/claude-opus-5-5)
- [Claude Opus 5.5 System Card — Anthropic](https://anthropic.com/claude-opus-5-5-system-card)
- [Claude Platform release notes](https://platform.claude.com/docs/en/release-notes/overview)
- [Models overview — Claude Platform Docs](https://platform.claude.com/docs/en/models/overview)
