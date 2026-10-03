---
layout: article
title: "Perplexity's Decisions API Looks Like Jev—Where the Similarity Ends"
short_title: "Perplexity Decisions vs Jev"
date: 2026-10-03
type: "Article Bite"
read_time: "3 min read"
source_name: "TypeSafe AI"
source_url: "https://typesafe.ai/blog/introducing-system-one-models-and-jev"
source_published: 2026-09-15
last_reviewed: 2026-10-03
tags:
  - AI Models
  - Agent Infrastructure
  - Developer Tools
summary: "Perplexity's Decisions API shares Jev's typed-question pattern, but a similar request shape is not proof of equivalent judgments or a drop-in replacement for agent workflows."
additional_sources:
  - name: "Perplexity — Decisions API guide"
    url: "https://docs.perplexity.ai/docs/decisions/quickstart"
  - name: "TypeSafe — Jev introduction"
    url: "https://docs.typesafe.ai/introduction"
  - name: "TypeSafe — Jev models and pricing"
    url: "https://docs.typesafe.ai/models"
  - name: "Perplexity — Decisions API reference"
    url: "https://docs.perplexity.ai/api-reference/decisions-post"
---

A support ticket arrives. Before anyone writes a reply, the system needs three smaller judgments: Does it need a human? Which team should see it? How serious is it? [Perplexity's Decisions API](https://docs.perplexity.ai/docs/decisions/quickstart) answers those questions as probabilities instead of paragraphs. If that sounds like [TypeSafe's Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev), introduced on September 15, it should. Perplexity's guide does not disclose its original publication date; its October 1 metadata is a *revision* date, not a verified launch date. The interesting question is whether you can trust a replacement in the same workflow.

## The shared shape: state, questions, numbers

Both services take a *state*—say, a ticket with a subject and body—and named questions about it. A **noul** returns a yes/no probability; a **choice** distributes probability across options; a **score** rates an ordered rubric. You can ask all three in one request and let code apply thresholds or request human review. Neither API needs to generate a customer-facing explanation to make that preliminary decision. [Perplexity's schema](https://docs.perplexity.ai/api-reference/decisions-post) and [TypeSafe's interface](https://docs.typesafe.ai/api) document that common pattern.

The model behind each endpoint is different: Perplexity specifies **`pplx-decider-v1-27b`** at `POST /v1/decisions`, while TypeSafe lists **`jev-latest`** at `POST /v1/systemone`. The similar vocabulary does not establish shared model weights, equal probability calibration, or compatible error handling. An application needs an adapter and tests, not just a changed base URL.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable comparison of the two decision API interfaces">
    <a href="{{ '/assets/images/articles/perplexity-decisions-vs-jev/decision-interface.svg' | relative_url }}">
      <img src="{{ '/assets/images/articles/perplexity-decisions-vs-jev/decision-interface.svg' | relative_url }}" width="1200" height="800" style="min-width: 640px; max-width: none;" loading="lazy" decoding="async" alt="The same ticket and three question types can go to either TypeSafe Jev or Perplexity Decisions at separate endpoints; each returns typed probabilities for application-owned thresholds and review.">
    </a>
  </div>
  <figcaption>LiteBites synthesis from <a href="https://docs.perplexity.ai/docs/decisions/quickstart">Perplexity's Decisions API guide</a> and <a href="https://docs.typesafe.ai/api">TypeSafe's API reference</a>. This is a schematic interface comparison, not a measured speed or accuracy result. Swipe or scroll horizontally on narrow screens. <a href="{{ '/assets/images/articles/perplexity-decisions-vs-jev/decision-interface.svg' | relative_url }}">Open full resolution ↗</a></figcaption>
</figure>

## Where the two contracts diverge

Perplexity lists **$0.04 per million input tokens**, with free output tokens and no request fee. [TypeSafe lists](https://docs.typesafe.ai/models) **$0.042 per million input tokens** for Jev, also with free output. That tiny published rate difference says little about total workflow cost: retries, reviews, and wrong automatic actions matter more. These are provider prices, not a measured head-to-head cost per correct decision.

The input envelopes differ more. Perplexity accepts text, JSON, and base64-encoded images, with an input limit below **262,144 tokens** and up to **128 questions** per call. Jev's documented model takes text/structured text, not images, with a **64k-token total budget** and an additional **32k limit for state plus the longest question**. Perplexity documents **10 requests per second** per organization; TypeSafe lists **80**, while warning that its limits can change. Neither limit predicts latency or accuracy on your data.

## A decision service is not a search agent

The Perplexity name can mislead here. Its [Agent API](https://docs.perplexity.ai/docs/agent-api/quickstart) does web-grounded, tool-using generation; the Decisions API returns bounded judgments about the state *you supply*. Perplexity's [ticket-triage example](https://docs.perplexity.ai/docs/cookbook/examples/decisions-api-ticket-triage/README) sends only escalated tickets to the Agent API for an investigation plan. That is a vendor example of a two-stage design, not independent evidence that its decision model outperforms Jev.

Likewise, [TypeSafe's API](https://docs.typesafe.ai/api) supplies typed decisions, not an agent's full routing or screening policy. Perplexity also supplies a decision primitive, not a ready-made replacement for application policy. The application still owns the consequences of a false negative or a confident-looking wrong choice.

## What to test before switching

- Replay labeled tickets or routing cases through both endpoints with identical question criteria. Compare the *actions your code takes*, not just the top label.
- Check calibration near your review threshold and route uncertain or high-stakes cases to a person or a stronger model.
- Test image inputs separately: they are a Perplexity feature, not evidence of better text-only decisions.
- Measure end-to-end latency, retries, rate limits, and cost on your workload. No public comparison cited here establishes a winner.

## Sources

- [TypeSafe AI — Introducing System One Models & Jev (September 15, 2026)](https://typesafe.ai/blog/introducing-system-one-models-and-jev)
- [Perplexity — Decisions API guide](https://docs.perplexity.ai/docs/decisions/quickstart)
- [Perplexity — Decisions API request and response reference](https://docs.perplexity.ai/api-reference/decisions-post)
- [Perplexity — Ticket-triage example](https://docs.perplexity.ai/docs/cookbook/examples/decisions-api-ticket-triage/README)
- [Perplexity — Agent API guide](https://docs.perplexity.ai/docs/agent-api/quickstart)
- [TypeSafe — Jev introduction](https://docs.typesafe.ai/introduction)
- [TypeSafe — Jev model specifications and pricing](https://docs.typesafe.ai/models)
- [TypeSafe — System One API reference](https://docs.typesafe.ai/api)
