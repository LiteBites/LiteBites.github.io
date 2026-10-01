---
layout: article
title: "Gemini 4 Argon: Strong Scores, Restricted Access"
short_title: "Gemini 4 Argon"
date: 2026-10-01
type: "Article Bite"
read_time: "3 min read"
source_name: "Google"
source_url: "https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-4-argon/"
source_published: 2026-09-30
last_reviewed: 2026-10-01
tags:
  - AI Models
  - Cybersecurity
  - Developer Tools
summary: "Google's Gemini 4 Argon pairs strong benchmark results and an announced million-token output limit with a limited cyber-defender rollout and introductory API pricing."
additional_sources:
  - name: "Google DeepMind — Gemini 4 Argon evaluation methodology"
    url: "https://deepmind.google/models/evals-methodology/gemini-4-argon/"
  - name: "Vals — Vals Index"
    url: "https://www.vals.ai/benchmarks/vals_index"
  - name: "Zapier — AutomationBench"
    url: "https://zapier.com/benchmarks"
  - name: "Collinear — CWE-bench"
    url: "https://cwe-bench.com/"
---

Google announced **Gemini 4 Argon** on September 30 with striking coding, office-work, and security scores. Most developers, though, cannot yet try the model. [Google says](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-4-argon/) it is starting with a *set* of trusted cyber defenders in its Fairwind program, then plans access for developers, enterprises, and consumers, beginning with paid API customers and Google AI Ultra subscribers. It gave no date for that wider release. That gap between performance claims and usable access is the launch story.

## The numbers are not all the same kind of evidence

Google reports **77.9% on DeepSWE v1.1**, a long-horizon coding evaluation, using a mini-swe agent harness. The number comes from [Google's own evaluation](https://deepmind.google/models/evals-methodology/gemini-4-argon/), not an Argon entry on the public benchmark organizer's leaderboard. Google's **91.7% on LVBench** is also self-computed; its video comparisons used different frame caps for competing models because of API limits. Neither chart is a uniform test of everything those models can do.

There is organizer-recorded evidence too. [Vals lists Argon first on its Index](https://www.vals.ai/benchmarks/vals_index) at **68.90% ±0.97**, ahead of Sonnet 5.5 at **67.04% ±0.92**. That Index weights eight finance, coding, legal, and tax evaluations by economic proxies; it does not measure actual GDP impact. [Zapier lists](https://zapier.com/benchmarks) **51.29%** on AutomationBench's High setting, where success requires all end-state checks to pass in a simulated business workflow. On [CWE-bench v1](https://cwe-bench.com/), Argon with the Antigravity agent **ties** GPT-6 Astra and Grok 4.7 at **68% programmatic pass@1** on held-out vulnerability *audit-and-patch* tasks. Organizer listings add evidence, but private test sets and different tools still limit what a cross-benchmark ranking can prove.

## The cyber release has two layers of control

Google says its trusted defenders and internal teams will get Argon **without cyber guardrails**, so they can use its full defensive capabilities. That describes model-level refusals, not open access for anyone. [Fairwind](https://deepmind.google/fairwind-program/) restricts participation and authorized uses, with vetting, authentication, access logs, and organizational controls. Its existing partner count should not be mistaken for a count of Argon users.

Google also describes an early vulnerability find with Wiz and internal engineering gains. These are company-reported examples, not published independent reproductions of Argon's reliability in a production security team. Google says it is strengthening misuse and prompt-injection defenses before broader availability; a benchmark score cannot establish that those protections will hold in deployment.

## The price and output ceiling are launch promises

Google advertises a **1-million-token maximum output**, up from 64,000 tokens. That is an *output* limit, not a claim of a million-token input context. [Vals' evaluated configuration](https://www.vals.ai/models/google_gemini-4-argon) lists a **262,144-token output maximum**; whether and when developers can request Google's announced ceiling remains unclear.

The advertised API prices are also temporary: **$2 per million input tokens and $10 per million output tokens**, with cached input 95% cheaper than the introductory input rate. A [footnote in Google's announcement](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-4-argon/#footnote-1) says those rates become **$4/$20** after the introductory period, without saying when it ends. A token rate is not the cost of a completed agent task, which may need long outputs, tools, and retries.

## What to check before relying on Argon

- Check the actual API model ID, eligibility, and rollout date rather than assuming the announced model is generally callable.
- Test your own coding or security workflow with the same agent, tools, and time budget; record accepted fixes, not just benchmark rank.
- Confirm the output cap available on your endpoint and how long trajectories behave in practice.
- Budget against the post-intro token rates as well as tool calls and retries; do not project a permanent price from the launch offer.

## Sources

- [Google — Gemini 4 Argon announcement and pricing footnote](https://blog.google/innovation-and-ai/models-and-research/gemini-models/gemini-4-argon/)
- [Google DeepMind — Gemini 4 Argon evaluation methodology](https://deepmind.google/models/evals-methodology/gemini-4-argon/)
- [Google DeepMind — Fairwind program](https://deepmind.google/fairwind-program/)
- [Vals — Vals Index leaderboard](https://www.vals.ai/benchmarks/vals_index)
- [Vals — Gemini 4 Argon model configuration](https://www.vals.ai/models/google_gemini-4-argon)
- [Zapier — AutomationBench leaderboard](https://zapier.com/benchmarks)
- [Collinear — CWE-bench leaderboard](https://cwe-bench.com/)
