---
layout: article
title: "Muse Wonder Is a Model Family, Not the Muse Agent"
short_title: "Muse Wonder: Model vs. Agent"
date: 2026-10-13
type: "Article Bite"
read_time: "4 min read"
source_name: "Meta Newsroom"
source_url: "https://about.fb.com/news/2026/10/introducing-muse-wonder-models/"
source_published: 2026-10-12
last_reviewed: 2026-10-13
tags:
  - AI Agents
  - Large Language Models
  - Developer Tools
summary: "Meta's Muse Wonder models launch for developers before reaching the Muse personal agent; access, memory claims, and benchmark provenance matter more than the shared name."
additional_sources:
  - name: "Meta research post and evaluation charts"
    url: "https://research.meta.ai/blog/muse-wonder"
  - name: "Muse Wonder model card"
    url: "https://research.meta.ai/static/muse-wonder-model-card"
  - name: "Meta Model API model and pricing page"
    url: "https://dev.meta.ai/models/muse-wonder/"
---

The shared name hides a useful distinction. [Muse](https://about.fb.com/news/2026/09/introducing-muse-personal-ai-agent/) is Meta's personal agent: an app and a secure computer that can work across other services with permission. [Muse Wonder and Wonder Full](https://about.fb.com/news/2026/10/introducing-muse-wonder-models/) are **new models**, announced October 12, 2026. Wonder can be used by developers now; Meta says it will power Muse *later*, first for subscribers. A new model launch does not mean every Muse user has already been switched to it.

## Three names, two layers

The table is a **source-grounded guide to access**, not a benchmark or a promise that the agent and model share every feature.

<div class="paper-results-scroll" role="region" aria-label="Muse product and Wonder model access compared" tabindex="0">
  <table class="paper-results-table">
    <caption>What you can use as of Meta's October 12 announcement; swipe horizontally on small screens.</caption>
    <thead><tr><th scope="col">Name</th><th scope="col">What it is</th><th scope="col">Access now</th></tr></thead>
    <tbody>
      <tr><th scope="row"><a href="https://about.fb.com/news/2026/09/introducing-muse-personal-ai-agent/">Muse ↗</a></th><td>Personal agent product: app, tools, connected services, and approvals</td><td>Existing product; Wonder integration announced for later</td></tr>
      <tr><th scope="row"><a href="https://dev.meta.ai/models/muse-wonder/">Muse Wonder ↗</a></th><td>Frontier model for coding and agentic tasks</td><td>Meta Model API and Muse Code</td></tr>
      <tr><th scope="row"><a href="https://dev.meta.ai/models/muse-wonder/">Muse Wonder Full ↗</a></th><td>Higher-capability model in the same family</td><td>Muse Code Power / Maximum subscriptions; no direct API listing</td></tr>
    </tbody>
  </table>
</div>

This also separates **a model's behavior** from **the agent's safeguards**. Meta describes Active Memory as retaining useful context and Active Focus as continuing through blockers, recovering, and asking for help. But the Muse product supplies its own secure VM, connectors, action approvals, and audit trail. Neither a benchmark score nor a model name establishes how those pieces behave together in your account.

## What the charts actually test

Meta's [research post](https://research.meta.ai/blog/muse-wonder) shows strong results on agent, coding, and memory tests. Its [original MemoryBench chart](https://research.meta.ai/articles/introducing-muse-wonder/images/memorybench-light-v2.webp) is an **internal model evaluation** of recall across long, complicated conversations—not a field study of Muse users. It makes Meta's memory claim concrete while leaving the product question open.

The [model card](https://research.meta.ai/static/muse-wonder-model-card) is unusually useful here: the headline scorecard combines Meta-run evaluations, third-party results, and other providers' reported scores. Its **Personal Superintelligence Index**, MemoryBench, and FocusBench are internal. The SWE-Marathon row even mixes different agent harnesses, so it is **not** one controlled model-only race. The card generally describes comparisons at **max reasoning effort**, but Wonder Full's SWE-Marathon result is specifically reported at **xhigh**; cost and latency depend on the setting. The card also flags imperfect multi-step reasoning and weak precise 3D/spatial tasks, and recommends additional guardrails around agents that take real-world actions.

Independent experience is too thin for an overall verdict. In one public [PokéBench run](https://pokebench.tv/), Wonder (not Full) remained in Pokémon Red's forest at the 1,000-turn limit, with a reported $96.06 run cost. That is a real, narrow game-control result with a particular harness—not a reproducible coding comparison or a test of the Muse agent. It gives no basis for judging Wonder Full.

This **source-grounded guide to three different measures** is not a combined ranking or an independently reproduced benchmark:

<div class="paper-results-scroll" role="region" aria-label="Wonder evaluation measures and their limits" tabindex="0">
  <table class="paper-results-table">
    <caption>What each reported measure tests—and what it leaves open. Swipe horizontally on small screens.</caption>
    <thead><tr><th scope="col">Test</th><th scope="col">Measure / setup</th><th scope="col">Cannot establish</th></tr></thead>
    <tbody>
      <tr><th scope="row"><a href="https://research.meta.ai/static/muse-wonder-model-card">MemoryBench ↗</a></th><td>Meta's internal, rubric-judged recall across long conversations</td><td>Reliable memory in the live Muse agent</td></tr>
      <tr><th scope="row"><a href="https://research.meta.ai/static/muse-wonder-model-card">SWE-Marathon ↗</a></th><td>Pass@1 on long coding tasks; the displayed model rows use different agent harnesses</td><td>A controlled model-only coding comparison</td></tr>
      <tr><th scope="row"><a href="https://pokebench.tv/">PokéBench ↗</a></th><td>One Wonder run: furthest Pokémon Red milestone in a 1,000-turn budget; cost reported separately</td><td>Wonder Full or general coding performance</td></tr>
    </tbody>
  </table>
</div>

## A safe first test

On [Meta's model page](https://dev.meta.ai/models/muse-wonder/), `muse-wonder-1.0` has a listed **1M-token context** and API rates of **$4 input / $20 output per million tokens**; `muse-wonder-full-1.0` is listed for Muse Code subscriptions, not direct API use. The [general API quickstart](https://dev.meta.ai/docs/quickstart) still demonstrates a Spark model, so select Wonder's exact model ID rather than copying that example unchanged. An actual Wonder API call was **not** made for this Article.

- Try a small, non-sensitive coding or document task first, with an answer you can check yourself.
- If it takes actions through an agent, confirm which tool permissions and human approvals are active; do not infer them from the model name.
- Compare models in the *same* harness, reasoning setting, and task, and record token cost alongside task success.
- For memory, test whether it remembers a corrected fact after a long conversation without exposing private material.

## Sources

- [Muse Wonder and Wonder Full launch — Meta, October 12, 2026](https://about.fb.com/news/2026/10/introducing-muse-wonder-models/)
- [Muse Wonder research post and original figures](https://research.meta.ai/blog/muse-wonder)
- [Muse Wonder model card and evaluation methodology](https://research.meta.ai/static/muse-wonder-model-card)
- [Muse product launch — Meta, September 8, 2026](https://about.fb.com/news/2026/09/introducing-muse-personal-ai-agent/)
- [Wonder model IDs, availability, and pricing](https://dev.meta.ai/models/muse-wonder/)
- [Meta Model API quickstart](https://dev.meta.ai/docs/quickstart)
- [PokéBench's public Wonder game-control run and logs](https://pokebench.tv/)
