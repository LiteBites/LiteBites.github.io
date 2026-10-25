---
layout: article
title: "Raon-1 Mini: A Hybrid MoE With Uneven Benchmark Evidence"
short_title: "Raon-1 Mini's Hybrid MoE"
date: 2026-10-25
type: "Article Bite"
read_time: "3 min read"
source_name: "KRAFTON AI model card"
source_url: "https://huggingface.co/KRAFTON/Raon-1-mini-preview"
source_published: 2026-10-21
last_reviewed: 2026-10-25
tags:
  - Language Models
  - Open Models
  - Efficient AI
summary: "KRAFTON's Raon-1 mini preview combines sparse experts with two attention types; its reported scores show strengths and gaps rather than a clean sweep."
additional_sources:
  - name: "KRAFTON AI first model-card commit (October 21, 2026)"
    url: "https://huggingface.co/KRAFTON/Raon-1-mini-preview/commit/2faf87b6545fb0ef6627b7d04d8555f62f9e61c7"
  - name: "KRAFTON AI model configuration"
    url: "https://huggingface.co/KRAFTON/Raon-1-mini-preview/blob/45d2e45c19d8f92b3c0c57b96e975b5fb399bd88/config.json"
  - name: "KRAFTON AI repository and license notice"
    url: "https://github.com/krafton-ai/Raon-1-mini-preview"
---
KRAFTON calls Raon-1 mini a **30B-A4B** model. That shorthand sounds like a size claim, but the [model card](https://huggingface.co/KRAFTON/Raon-1-mini-preview) gives two different numbers: **28.8 billion parameters in the whole model, with 4.3 billion active per token**. The October 21 date comes from the [first model-card commit](https://huggingface.co/KRAFTON/Raon-1-mini-preview/commit/2faf87b6545fb0ef6627b7d04d8555f62f9e61c7), not a verified time for KRAFTON's public announcement. This is a preview, and KRAFTON says its specifications and results may change.

The interesting question is not whether one score makes it the best small model. It is whether Raon can turn its hybrid design into useful quality and serving efficiency without hiding the costs in the rest of the system.

## Twenty-five layers, two kinds of memory

The published [configuration](https://huggingface.co/KRAFTON/Raon-1-mini-preview/blob/45d2e45c19d8f92b3c0c57b96e975b5fb399bd88/config.json) specifies **25 layers**: 18 Raon Delta Attention layers and seven gated multi-head latent attention (MLA) layers. KRAFTON says the former keep a fixed-size state while only the MLA layers retain a growing key–value cache—about **8 KiB per token in BF16**. It also specifies **128 routed experts**; six, plus one shared expert, are used for each token. Fewer active parameters are not the same thing as a 4.3B-parameter download or a guaranteed low-memory deployment.

<figure class="article-figure article-figure--compact">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Raon-1 mini architecture summary; open the full-resolution link for larger text">
    <a href="{{ '/assets/images/articles/raon-1-mini-hybrid-moe-evidence/hybrid-counts.svg' | relative_url }}">
      <img src="{{ '/assets/images/articles/raon-1-mini-hybrid-moe-evidence/hybrid-counts.svg' | relative_url }}" width="480" height="530" loading="lazy" decoding="async" alt="Of 25 layers, 18 use Raon Delta Attention with a fixed-size state and seven use gated MLA with a growing cache. Each token selects six of 128 routed experts plus a shared expert. These are counts, not an ordering diagram.">
    </a>
  </div>
  <figcaption>LiteBites synthesis of <a href="https://huggingface.co/KRAFTON/Raon-1-mini-preview">KRAFTON's model card</a> and <a href="https://huggingface.co/KRAFTON/Raon-1-mini-preview/blob/45d2e45c19d8f92b3c0c57b96e975b5fb399bd88/config.json">configuration</a>; counts, not a layer-order diagram or an independently measured memory saving. <a href="{{ '/assets/images/articles/raon-1-mini-hybrid-moe-evidence/hybrid-counts.svg' | relative_url }}">Open full resolution ↗</a>.</figcaption>
</figure>

KRAFTON advertises a **262,144-token context** and says its Raon Delta Attention and Raon-mHC changes improve long-context behavior and training speed. The configuration supports the stated context setting and layer types; it cannot establish those comparative improvements. We did not find an ablation or a separate public technical report in the linked [project repository](https://github.com/krafton-ai/Raon-1-mini-preview).

## Strong rows, weak rows

KRAFTON's [benchmark table](https://huggingface.co/KRAFTON/Raon-1-mini-preview) compares Raon with two other mixture-of-experts (MoE) models and two dense reference models. Its highlighting marks the best **within the MoE group**, not the overall winner. Raon reports **84.2 on IFBench** versus **66.6** for Qwen3.6-35B-A3B. But on **MMLU Pro**, Raon's **76.5** trails that model's **85.9**; on **Terminal-Bench Lite**, it reports **47.0** versus **63.3**. These are named benchmark scores, not interchangeable percentages of real-world task success.

The **70.8 SWE-Verified** result uses the mini-SWE-agent harness; it cannot isolate the base model from the agent setup. KRAFTON's **92.9 Korean-chat score** comes from an internal benchmark that is not publicly released. No independent rerun of these comparisons is established by the model card.

KRAFTON separately reports **up to 2.18× more output tokens per second** using a DFlash2 draft model. That maximum is for GSM8K at concurrency one on a single NVIDIA B300: **646.3 versus 296.3 output tokens/s** under its specified vLLM and MXFP8 setup. It is not a universal latency result or a measured speedup on a desktop GPU.

## What to try before trusting the label

The weights and model components are described as **Apache-2.0 licensed**, including commercial reuse; the hosted playground and API have separate terms. One practical wrinkle: the [card still says access is granted on request](https://huggingface.co/KRAFTON/Raon-1-mini-preview), while current repository metadata and an unauthenticated weight-link check suggest that a gate is not enforced. Check the access flow at download time rather than treating either statement as permanent.

For an adoption test, use your own Korean and English conversations, long documents, tool calls, and terminal tasks. Record answer quality, tokens, memory use, and end-to-end latency on the hardware and runtime you would actually deploy. KRAFTON has released a detailed model card and weights; its training corpus, full evaluation setup, and independent long-context results remain open questions. That is a reason to test the preview—not a reason to dismiss the architecture or promote its best score as a verdict.

## Sources

- [KRAFTON AI — Raon-1 mini preview model card, architecture, benchmark notes, and license](https://huggingface.co/KRAFTON/Raon-1-mini-preview)
- [First Hugging Face model-card commit — October 21, 2026; artifact-date provenance](https://huggingface.co/KRAFTON/Raon-1-mini-preview/commit/2faf87b6545fb0ef6627b7d04d8555f62f9e61c7)
- [KRAFTON AI — pinned model configuration](https://huggingface.co/KRAFTON/Raon-1-mini-preview/blob/45d2e45c19d8f92b3c0c57b96e975b5fb399bd88/config.json)
- [KRAFTON AI — project repository and license notice](https://github.com/krafton-ai/Raon-1-mini-preview)
