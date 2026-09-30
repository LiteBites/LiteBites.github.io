---
layout: article
title: "GPT-6.1 Sol vs Astra: Better Value Is Not the Same as Better Everywhere"
short_title: "GPT-6.1 Sol vs Astra"
date: 2026-09-30
type: "Article Bite"
read_time: "3 min read"
source_name: "OpenAI"
source_url: "https://openai.com/index/introducing-gpt-6-1-sol/"
source_published: 2026-09-29
last_reviewed: 2026-09-30
tags:
  - AI Models
  - Developer Tools
  - Computer Use
summary: "GPT-6.1 Sol approaches Astra on OpenAI's coding and computer-use evaluations at a fraction of the API price, but benchmark scope and early user reports complicate the idea of an outright win."
additional_sources:
  - name: "GPT-6.1 Sol API model documentation"
    url: "https://developers.openai.com/api/docs/models/gpt-6.1-sol"
  - name: "GPT-6 Astra API model documentation"
    url: "https://developers.openai.com/api/docs/models/gpt-6-astra"
  - name: "Tibo's launch post on X"
    url: "https://x.com/thsottiaux/status/2104986027953930613"
---

A cheaper model can match a flagship on a coding test and still lose on your hardest job. That is the interesting tension in OpenAI's [September 29 announcement](https://openai.com/index/introducing-gpt-6-1-sol/) of **GPT-6.1 Sol**: it moves close to GPT-6 Astra on several company-reported evaluations, while the standard API input and output token prices are one-fifth as high. Does that make Sol *better*? It depends on what you are trying to finish.

## Where Sol closes the gap

OpenAI says Sol **matches Astra on DeepSWE v1.1**, a benchmark of long-running software-engineering tasks, at roughly one-fifth the cost per task. This is a vendor-reported agent benchmark, not an independent verdict on all coding work. On the **OSWorld 2.0 v2026.08.08 offline set**, Sol at maximum reasoning effort comes within 2.1 percentage points of Astra at roughly one-seventh the cost per task. That OSWorld result uses a *partial reward* metric, not a production success rate.

There is also a clear boundary to the headline. On **Terminal-Bench Science 0.1**, OpenAI says Astra has the highest score among the tested models, at 68.1%. Sol costs less per task in that comparison, but OpenAI still recommends Astra for the hardest scientific research tasks. "Better" here can mean more successful, cheaper, or a better balance of the two; those are different claims.

## The bill is more than the sticker price

The [Sol](https://developers.openai.com/api/docs/models/gpt-6.1-sol) and [Astra](https://developers.openai.com/api/docs/models/gpt-6-astra) API pages list standard rates of **$2/$10 versus $10/$50 per million input/output tokens**. Cached input is $0.10 for Sol versus $1 for Astra. These are token rates, not guarantees of one-fifth the bill for a finished task: reasoning effort, retries, tool calls, and output length matter. Both model pages also say that prompts above **272,000 input tokens** trigger higher rates for the *full request*, not just the excess tokens.

OpenAI lists Sol for ChatGPT Work, Codex, and the API, but says it is **not yet in Chat**. The company describes an upcoming Sol **Ultrafast** option with up to eight-times-faster token generation in Codex; that is a rollout promise, not a measured speed advantage for standard Sol. The endpoint and mode matter when comparing someone's experience with an API price chart.

## The launch post meets the user reports

In his [X post](https://x.com/thsottiaux/status/2104986027953930613), Tibo calls Sol an "absolute workhorse" with near-Astra intelligence at one-fifth of Astra's price. He says Ultrafast is already available for Astra and coming soon for Sol. It is a useful statement of the product pitch, not an independent test.

Early [Reddit usage reports](https://www.reddit.com/r/codex/comments/1wu5jv2/interesting_usage_observation/) describe much lighter subscription-quota use on apparently similar work; [another Plus user](https://www.reddit.com/r/codex/comments/1wu34dn/new_sol_is_great/) says planning and review no longer exhaust their allowance as quickly. But a [separate thread](https://www.reddit.com/r/codex/comments/1wu0hdb/its_so_frustrating_right_now/) reports slow actions and lengthy compactions. These are self-reports with different settings and tasks, not a controlled head-to-head. A low API token price cannot settle the subscription-quota or wall-clock question.

## Choose by accepted work, not the model name

- Try Sol first on representative coding and computer-use tasks where cost or quota is the constraint; keep Astra as a fallback when the result does not pass review.
- Compare the same tasks, tools, context, and reasoning settings. Record accepted changes, retries, manual corrections, elapsed time, and total API spend or subscription usage.
- Treat DeepSWE and the OSWorld offline partial reward as scoped, vendor-reported evidence; test your own failures before generalizing them.
- Check availability and speed mode separately. A future Ultrafast option does not make standard Sol fast today.

## Sources

- [OpenAI — Introducing GPT-6.1 Sol](https://openai.com/index/introducing-gpt-6-1-sol/)
- [OpenAI Developers — GPT-6.1 Sol model documentation](https://developers.openai.com/api/docs/models/gpt-6.1-sol)
- [OpenAI Developers — GPT-6 Astra model documentation](https://developers.openai.com/api/docs/models/gpt-6-astra)
- [Tibo — GPT-6.1 Sol launch post on X](https://x.com/thsottiaux/status/2104986027953930613)
- [Reddit r/codex — Interesting usage observation](https://www.reddit.com/r/codex/comments/1wu5jv2/interesting_usage_observation/)
- [Reddit r/codex — New sol is great](https://www.reddit.com/r/codex/comments/1wu34dn/new_sol_is_great/)
- [Reddit r/codex — It's so frustrating right now](https://www.reddit.com/r/codex/comments/1wu0hdb/its_so_frustrating_right_now/)
