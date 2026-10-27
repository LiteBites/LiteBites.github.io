---
layout: article
title: "GPT-6.1 Terra Fits Between Luna and Sol—But the Scores Do Not Form a Ladder"
short_title: "GPT-6.1 Terra in the GPT-6 Family"
date: 2026-10-28
type: "Article Bite"
read_time: "4 min read"
source_name: "OpenAI"
source_url: "https://openai.com/index/introducing-gpt-6-1-terra/"
source_published: 2026-10-26
last_reviewed: 2026-10-28
tags:
  - AI Models
  - Computer Use
  - Developer Tools
summary: "GPT-6.1 Terra sits between Luna and Sol on standard API token prices, but different benchmarks and safety results make a simple family ranking misleading."
additional_sources:
  - name: "OpenAI — GPT-6.1 Terra model documentation"
    url: "https://developers.openai.com/api/docs/models/gpt-6.1-terra"
  - name: "OpenAI — Terra system-card addendum"
    url: "https://deploymentsafety.openai.com/gpt-6-1-terra"
  - name: "Artificial Analysis — GPT-6.1 Terra release"
    url: "https://artificialanalysis.ai/models/releases/gpt-6-1-terra"
---

The [October 26 launch](https://openai.com/index/introducing-gpt-6-1-terra/) of GPT-6.1 Terra creates an awkward question for OpenAI's model menu: if Terra costs less than Sol, how much harder a job should you give it before reaching for Sol or Astra? OpenAI pitches it for image-heavy work, computer use, and writing. That is a useful position in the lineup, not a demonstrated rule for picking the best model.

## A price gap, not an intelligence ladder

The [API model pages](https://developers.openai.com/api/docs/models) put Terra at **$1 input / $5 output per million tokens** under Standard processing. Here is a source-grounded snapshot of the GPT-6 family; **Sol** appears twice because GPT-6 Sol and GPT-6.1 Sol are different model IDs, not interchangeable nicknames.

<div class="paper-results-scroll" tabindex="0" role="region" aria-label="Scrollable GPT-6 family model prices and documented roles">
<table class="paper-results-table">
  <caption>OpenAI Standard API prices per million tokens, October 28, 2026. Input and output are separate rates, not cost per completed task.</caption>
  <thead><tr><th scope="col">Model</th><th scope="col">Documented role</th><th scope="col">Input</th><th scope="col">Output</th></tr></thead>
  <tbody>
    <tr><th scope="row">GPT-6.1 Terra</th><td>Visual and professional work</td><td>$1</td><td>$5</td></tr>
    <tr><th scope="row">GPT-6 Luna</th><td>Focused, high-volume tasks</td><td>$0.10</td><td>$0.50</td></tr>
    <tr><th scope="row">GPT-6 Sol</th><td>Complex coding and agents</td><td>$2</td><td>$10</td></tr>
    <tr><th scope="row">GPT-6.1 Sol</th><td>Coding and professional work</td><td>$2</td><td>$10</td></tr>
    <tr><th scope="row">GPT-6 Astra</th><td>Most demanding tasks</td><td>$10</td><td>$50</td></tr>
  </tbody>
</table>
</div>
<p class="paper-results-note">Role descriptions summarize OpenAI's positioning, not measured task boundaries. Swipe or scroll to see every column on narrow screens. Sources: <a href="https://developers.openai.com/api/docs/models/gpt-6.1-terra">Terra</a>, <a href="https://developers.openai.com/api/docs/models/gpt-6-luna">Luna</a>, <a href="https://developers.openai.com/api/docs/models/gpt-6-sol">Sol</a>, <a href="https://developers.openai.com/api/docs/models/gpt-6.1-sol">6.1 Sol</a>, <a href="https://developers.openai.com/api/docs/models/gpt-6-astra">Astra</a>.</p>

<figure class="article-figure article-figure--compact">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Output token price chart for five GPT-6 family API models; open full resolution for larger labels">
    <a href="{{ '/assets/images/articles/gpt-6-1-terra-family-evidence/output-token-prices.svg' | relative_url }}">
      <img src="{{ '/assets/images/articles/gpt-6-1-terra-family-evidence/output-token-prices.svg' | relative_url }}" width="480" height="540" loading="lazy" decoding="async" alt="Standard API output prices per million tokens: GPT-6 Luna $0.50, GPT-6.1 Terra $5, GPT-6 Sol and GPT-6.1 Sol $10 each, and GPT-6 Astra $50. Bar lengths use a linear $0–$50 scale; these are not costs per completed task.">
    </a>
  </div>
  <figcaption>LiteBites synthesis of OpenAI's <a href="https://developers.openai.com/api/docs/models/gpt-6.1-terra">Terra</a>, <a href="https://developers.openai.com/api/docs/models/gpt-6-luna">Luna</a>, <a href="https://developers.openai.com/api/docs/models/gpt-6-sol">Sol</a>, <a href="https://developers.openai.com/api/docs/models/gpt-6.1-sol">6.1 Sol</a>, and <a href="https://developers.openai.com/api/docs/models/gpt-6-astra">Astra</a> model pages. Output token rates on a linear scale, not measured task cost or quality. <a href="{{ '/assets/images/articles/gpt-6-1-terra-family-evidence/output-token-prices.svg' | relative_url }}">Open full resolution ↗</a>.</figcaption>
</figure>

All five [model pages](https://developers.openai.com/api/docs/models) list a 1,050,000-token context window. That is a capacity specification, not proof of equal quality across long documents. Above **272,000 input tokens**, OpenAI applies higher input, cache, and output rates to the **whole request**. Retries, tools, and reasoning tokens can further change the bill for an accepted answer.

## Three evidence lanes that should not be merged

OpenAI [reports](https://openai.com/index/introducing-gpt-6-1-terra/) **50.3% on Terminal-Bench 4.0 at maximum reasoning effort** for Terra, versus **21.5% published for GPT-5.6 Terra**. That is a predecessor contrast, not a five-model, same-run leaderboard. Its computer-use comparison uses **OSWorld 2.1**, while earlier GPT-6 coverage used **OSWorld 2.0**; joining those scores into one ranking would change the test beneath the reader's feet.

There is independent but different evidence. [Artificial Analysis](https://artificialanalysis.ai/models/releases/gpt-6-1-terra) reports its **Intelligence Index v4.3.2** for maximum-effort variants: Terra **48**, [GPT-6.1 Sol 52](https://artificialanalysis.ai/models/releases/gpt-6-1-sol), [Luna 38](https://artificialanalysis.ai/models/releases/gpt-6-luna), and [Astra 53](https://artificialanalysis.ai/models/releases/gpt-6-astra), as checked October 28. It is a composite of that evaluator's tests, **not an independent reproduction** of Terra's Terminal-Bench or computer-use launch results. Terra was not listed in the [Terminal-Bench organizer's leaderboard](https://www.tbench.ai/) at review time; that absence does not disprove OpenAI's result.

## What the system card changes about the choice

The [Terra system-card addendum](https://deploymentsafety.openai.com/gpt-6-1-terra) classifies the model's cybersecurity capability as **Critical** and biological/chemical capability as **High** under OpenAI's framework. It describes deployment safeguards, but also records statistically significant regressions versus GPT-5.6 Terra in hate and extremism image-input safety tests. A capability gain is not a blanket safety gain. The card cautions that research/API evaluations can differ from production ChatGPT through prompts, tools, and effort settings.

OpenAI says Terra launched in **ChatGPT Work and Codex** for Plus, Pro, Enterprise, and Edu users, as well as the API as `gpt-6.1-terra`; that does not promise identical tools or behavior on every surface. For a real choice, give Terra and the plausible alternative the *same* visual or computer-use tasks at matched effort and permissions. Track accepted results, retries, elapsed time, safety interventions, and **total** spend. Start with Terra if its quality passes that test; keep a stronger model as an escalation path, not as a permanent winner declared by a mixed-protocol chart.

## Sources

- [OpenAI — Introducing GPT-6.1 Terra](https://openai.com/index/introducing-gpt-6-1-terra/)
- OpenAI Developers — model documentation: [GPT-6.1 Terra](https://developers.openai.com/api/docs/models/gpt-6.1-terra), [GPT-6 Luna](https://developers.openai.com/api/docs/models/gpt-6-luna), [GPT-6 Sol](https://developers.openai.com/api/docs/models/gpt-6-sol), [GPT-6.1 Sol](https://developers.openai.com/api/docs/models/gpt-6.1-sol), and [GPT-6 Astra](https://developers.openai.com/api/docs/models/gpt-6-astra)
- [OpenAI — GPT-6.1 Terra system-card addendum](https://deploymentsafety.openai.com/gpt-6-1-terra)
- [Artificial Analysis — GPT-6.1 Terra, GPT-6.1 Sol, GPT-6 Luna, and GPT-6 Astra release pages](https://artificialanalysis.ai/models/releases/gpt-6-1-terra)
- [Artificial Analysis — evaluation methodology](https://artificialanalysis.ai/methodology)
- [Terminal-Bench — organizer leaderboard](https://www.tbench.ai/)
