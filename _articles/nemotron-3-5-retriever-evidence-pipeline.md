---
layout: article
title: "Nemotron 3.5 Retriever: Five Models, Three Evidence Jobs"
short_title: "Nemotron 3.5 Retriever Models"
date: 2026-10-22
type: "Article Bite"
long_form: true
read_time: "7 min read"
source_name: "NVIDIA on Hugging Face"
source_url: "https://huggingface.co/blog/nvidia/nemotron-retriever-world-class-agentic-retrieval"
source_published: 2026-10-21
last_reviewed: 2026-10-23
tags:
  - Document Retrieval
  - Document Parsing
  - AI Agents
summary: "A model-by-model guide to Nemotron 3.5's multimodal embedders, reranker, and parser, with separate benchmark comparisons and deployment limits."
additional_sources:
  - name: "ViDoRe v3.1 dense-retrieval leaderboard"
    url: "https://mteb-leaderboard.hf.space/benchmark/ViDoRe(v3.1)"
  - name: "ViDoRe v3.1 reranking leaderboard"
    url: "https://leaderboard.mteb.org/benchmark/ViDoRe(v3.1%2C%20reranking)"
  - name: "ParseBench dataset and leaderboard"
    url: "https://huggingface.co/datasets/llamaindex/ParseBench?leaderboard_max_params=1B"
---
A question about a scanned report can fail three ways: the page is read incorrectly, the right page never enters search results, or a useful candidate ranks too low. [NVIDIA's Nemotron 3.5 Retriever release](https://huggingface.co/blog/nvidia/nemotron-retriever-world-class-agentic-retrieval) addresses those jobs with **five checkpoints**, not one do-everything model.

**The quick take:** Parse structures pages; three Embed checkpoints make text and page images searchable; Rerank refines candidate order. The retrieval models take **text queries** against text, RGB page-image, or combined documents. Their benchmark scores do not measure an agent's final answer.

## How the pieces meet

For “Which chart shows sales by region?”, Embed can search page images directly. Parse is useful when you also need extracted text, reading order, tables, or coordinates. Rerank reorders Embed's candidates before an agent reads them. **Parse is optional; Rerank cannot rescue a page that Embed missed.** This LiteBites flow is explanatory, not a mandatory NVIDIA pipeline or measured end-to-end system.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable flow of optional Parse, Embed, Rerank, and downstream agent evidence">
    <a href="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/retrieval-flow.svg' | relative_url }}"><img src="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/retrieval-flow.svg' | relative_url }}" width="1200" height="900" loading="lazy" decoding="async" alt="Documents can pass through optional Parse or directly into Embed; a text query drives retrieval, Rerank scores candidates, and an agent receives selected evidence."></a>
  </div>
  <figcaption>Original LiteBites synthesis of the <a href="https://huggingface.co/blog/nvidia/nemotron-retriever-world-class-agentic-retrieval">published model roles</a>; not the publisher's original figure. The dashed route bypasses optional Parse. Swipe on narrow screens. <a href="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/retrieval-flow.svg' | relative_url }}">Open full resolution ↗</a></figcaption>
</figure>

## Embed: choose the first-stage retrieval index

An Embed model is a *bi-encoder*: it encodes documents ahead of time, stores vectors beside their source pages, and encodes a text query at search time. Nearby vectors become candidates. NVIDIA mean-pools token representations and L2-normalizes the result, so dot product gives cosine similarity—not the probability that a page answers the question. All three accept text, image, or combined documents, but **only text queries** in their documented interfaces. Apply the cards' `query:` and `passage:` templates consistently when encoding both sides.

### Embed 8B BF16: the larger visual retriever

**Embed 8B produces 4,096-dimensional vectors so text queries can find matching text or page images.** Its [card](https://huggingface.co/nvidia/Nemotron-3.5-Embed-8B-BF16) reports **8.38B parameters**, a vision encoder and a language tower. NVIDIA froze the Nemotron-3-Embed-8B text component while training the visual parts; it therefore claims *identical text embeddings* to that **same-size predecessor**. This may simplify adding images to a compatible text index, but does not make 8B and 1B vectors interchangeable.

The default image **longest edge is 1,120 pixels**, configurable up to 1,540; the **32,768-token** context includes both image and text tokens. Test whether fine chart labels survive preprocessing on your pages.

### Embed 1B BF16: the smaller index option

**Embed 1B does the same text-to-document retrieval with distilled weights and 2,048-dimensional vectors.** “1B” is a checkpoint label: its [card](https://huggingface.co/nvidia/Nemotron-3.5-Embed-1B-BF16) reports **1.55B parameters**. NVIDIA distilled it from 8B using cosine-distance and mean-squared-error losses over multilingual text/image retrieval data. Its frozen text tower shares an embedding space with the **1B** Nemotron 3 predecessor—not with 8B. Smaller vectors can save index storage; measure retrieval quality and latency on your workload.

### Embed 1B NVFP4: a serving variant, not a new task

**Embed 1B NVFP4 quantizes eligible weights and activations of the 1B BF16 model while retaining 2,048-dimensional output.** Its [card](https://huggingface.co/nvidia/Nemotron-3.5-Embed-1B-NVFP4) describes quantization-aware distillation, particularly for long inputs. NVIDIA says BF16/NVFP4 vectors generally share a space, but advises checking quality before swapping checkpoints. The documented serving path is **vLLM on NVFP4-capable Blackwell**; the BF16 checkpoint supports the cards' Transformers and Sentence Transformers examples.

NVIDIA [reports](https://huggingface.co/blog/nvidia/nemotron-retriever-world-class-agentic-retrieval) **101.3 documents/s with BF16 versus 128.8 with NVFP4 on one GB200**. That figure pairs throughput with **ViDoRe v3** accuracy under a vLLM nightly—not v3.1 scores below—and says nothing about other GPUs or end-to-end indexing.

<div class="paper-results-scroll" role="region" aria-label="Three Embed checkpoints and their deployment differences" tabindex="0">
  <table class="paper-results-table">
    <caption>Embed checkpoint guide from the NVIDIA model cards; specifications, not a measured latency comparison. Swipe horizontally on narrow screens.</caption>
    <thead><tr><th scope="col">Checkpoint</th><th scope="col">Parameters / vector</th><th scope="col">Document input</th><th scope="col">Documented serving path</th></tr></thead>
    <tbody>
      <tr><th scope="row">8B BF16</th><td>8.38B / 4,096-D</td><td>Text, page image, or both</td><td>Transformers, Sentence Transformers, vLLM</td></tr>
      <tr><th scope="row">1B BF16</th><td>1.55B / 2,048-D</td><td>Text, page image, or both</td><td>Transformers, Sentence Transformers, vLLM</td></tr>
      <tr><th scope="row">1B NVFP4</th><td>1.55B / 2,048-D</td><td>Text, page image, or both</td><td>vLLM + NVFP4-capable Blackwell</td></tr>
    </tbody>
  </table>
</div>

The [ViDoRe v3.1 dense leaderboard](https://mteb-leaderboard.hf.space/benchmark/ViDoRe(v3.1)) records **61.17 mean nDCG@10** for Embed 8B, **58.38** for 1B BF16, and **56.60** for multimodal Qwen3-VL-Embedding-8B across **10 tasks**. nDCG@10 rewards relevant results near the top ten; the 0–100 display is **not** agent-task success. Embed 8B led *dense* retrieval when checked, but two late-interaction systems ranked higher overall. NVFP4 has no separate matched v3.1 row here.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable ViDoRe v3.1 dense retrieval chart for Embed models">
    <a href="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/embed-vidore-v3-1.svg' | relative_url }}"><img src="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/embed-vidore-v3-1.svg' | relative_url }}" width="1200" height="480" loading="lazy" decoding="async" alt="ViDoRe v3.1 dense mean nDCG@10: Nemotron Embed 8B 61.17, Embed 1B BF16 58.38, and Qwen3-VL-Embedding-8B 56.60. NVFP4 is not plotted."></a>
  </div>
  <figcaption>LiteBites synthesis (original replot) from the <a href="https://mteb-leaderboard.hf.space/benchmark/ViDoRe(v3.1)">organizer's ViDoRe v3.1 dense leaderboard</a> (<a href="https://mteb-leaderboard-backend.hf.space/v1/benchmarks/ViDoRe%28v3.1%29/scores">organizer results JSON</a>), checked October 23, 2026. Ten-task mean nDCG@10; different from ViDoRe v3 and from reranking. The chart does not include late-interaction models. Swipe on narrow screens. <a href="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/embed-vidore-v3-1.svg' | relative_url }}">Open full resolution ↗</a></figcaption>
</figure>

## Rerank 8B BF16: inspect the shortlist

**Rerank 8B reads a text query with one candidate and returns a relevance logit to reorder the shortlist.** Its [card](https://huggingface.co/nvidia/Nemotron-3.5-Rerank-8B-BF16) reports **8.38B parameters**, a Pixtral-based visual encoder, and a bidirectional Ministral3 tower. It accepts text, page-image, or combined documents. Unlike reusable Embed vectors, *each query–document pair* is scored together; use it on candidates rather than an entire corpus.

A **raw logit** is a relative ranking signal, not a calibrated probability; even a negative value can outrank another candidate. For multimodal serving, its card uses vLLM `/classify` rather than the generic `/score` route, which can mishandle image placeholders. Rerank cannot recover a relevant page absent from first-stage retrieval. NVIDIA trained a text reranker before adding image and image–text data, which does not guarantee performance on every language or layout.

[ViDoRe v3.1 Reranking](https://leaderboard.mteb.org/benchmark/ViDoRe(v3.1%2C%20reranking)) records **60.49 mean nDCG@10** versus **59.17** for Qwen3-VL-Reranker-8B. Its **40 candidate-list tasks** draw top-50 pages from four retrievers, including BM25 and Nemotron Embed 8B—not a fixed Embed 1B pipeline. Do not compare this mean with the Embed chart as if they measured one task.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable ViDoRe v3.1 reranking chart">
    <a href="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/rerank-vidore-v3-1.svg' | relative_url }}"><img src="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/rerank-vidore-v3-1.svg' | relative_url }}" width="1200" height="382" loading="lazy" decoding="async" alt="ViDoRe v3.1 reranking mean nDCG@10 across 40 candidate-list tasks: Nemotron Rerank 8B 60.49 versus Qwen3-VL-Reranker-8B 59.17."></a>
  </div>
  <figcaption>LiteBites synthesis (original replot) from the <a href="https://leaderboard.mteb.org/benchmark/ViDoRe(v3.1%2C%20reranking)">organizer's ViDoRe v3.1 reranking leaderboard</a> (<a href="https://mteb-leaderboard-backend.hf.space/v1/benchmarks/ViDoRe%28v3.1%2C%20reranking%29/scores">organizer results JSON</a>), checked October 23, 2026. Candidate lists come from four first-stage retrievers, not one fixed pipeline. Swipe on narrow screens. <a href="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/rerank-vidore-v3-1.svg' | relative_url }}">Open full resolution ↗</a></figcaption>
</figure>

## Parse 631M: make page structure usable

**Parse turns an RGB page into ordered text, semantic classes, and normalized boxes for downstream document work.** The [card](https://huggingface.co/nvidia/Nemotron-3.5-Parse) reports **630.8M parameters**: a C-RADIOv4-SO400M visual encoder, adapter, and ten-layer mBART decoder. A task-control prompt guides output. Postprocessing can render Markdown with HTML tables and supported table/chart material as LaTeX, HTML, JSON, or CSV. Use it when you need cells or provenance boxes rather than just a relevant page image. To recover pixel boxes, scale normalized x and y by the evaluated image dimensions; check extracted structure against the original.

**Model pass and pipeline result differ.** NVIDIA describes one full-page pass; a double pass refines selected table/chart crops; a triple pass adds detection and refines the region union. On **2,078 prepared pages**, its [card](https://huggingface.co/nvidia/Nemotron-3.5-Parse) reports **72.74, 74.92, and 75.20** overall ParseBench points respectively. The winning 75.20 is not a single forward pass.

The [under-1B ParseBench display](https://huggingface.co/datasets/llamaindex/ParseBench?leaderboard_max_params=1B) shows NVIDIA's **75.20 triple-pass submission** and **74.60** for LightOnOCR-3-0.8B. Its overall score combines **tables, charts, content faithfulness, semantic formatting, and visual grounding**—not retrieval nDCG@10. These are vendor submissions, not a matched independent rerun. NVIDIA separately measures **10.62 prepared pages/s for triple pass on one H100** (about 10.5 in its blog). This excludes initial page preparation and final writes; its reported serving speed also depends on the described vLLM plugin. It neither measures complete PDF processing nor proves a fair speed ratio against LightOn. See our [LightOnOCR-3 Article]({{ '/articles/lightonocr-3-grounded-document-parsing/' | relative_url }}) for its separate workflow.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable ParseBench under-one-billion comparison chart">
    <a href="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/parse-parsebench-under-1b.svg' | relative_url }}"><img src="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/parse-parsebench-under-1b.svg' | relative_url }}" width="1200" height="390" loading="lazy" decoding="async" alt="ParseBench under-1B five-category overall score: Nemotron Parse triple-pass 75.20, LightOnOCR-3-0.8B 74.60. Both are vendor submissions."></a>
  </div>
  <figcaption>LiteBites synthesis (original replot) from <a href="https://huggingface.co/datasets/llamaindex/ParseBench?leaderboard_max_params=1B">ParseBench's under-1B leaderboard</a> and the <a href="https://huggingface.co/nvidia/Nemotron-3.5-Parse/blob/main/.eval_results/parsebench.yaml">NVIDIA</a> and <a href="https://huggingface.co/lightonai/LightOnOCR-3-0.8B/blob/main/.eval_results/parsebench.yaml">LightOn</a> submissions. This is a five-category overall score, not a throughput comparison or matched independent rerun. Swipe on narrow screens. <a href="{{ '/assets/images/articles/nemotron-3-5-retriever-evidence-pipeline/parse-parsebench-under-1b.svg' | relative_url }}">Open full resolution ↗</a></figcaption>
</figure>

## What the numbers cannot promise

The three charts are intentionally adjacent to their models: **dense retrieval**, **reranking given candidates**, and **document parsing** answer different questions. Do not read their bar lengths as one combined model ranking. In particular, NVIDIA's [agent-cost Figure 1](https://huggingface.co/blog/nvidia/nemotron-retriever-world-class-agentic-retrieval) has a caption about *task success and inference tokens*, while its axes show **retrieval nDCG@10** and **dollar-denominated agent token cost per query**. Its roughly **14% lower-cost** claim for adding Rerank to Embed 8B is not independently checkable there from raw per-task totals and pricing assumptions. The plotted axes do **not** establish higher end-to-end task success.

## Before putting this into a retrieval system

- Assemble representative pages with scans, small charts, tables, and the languages your users ask about. Check Parse's reading order, regions, and cell structure against the originals; skip Parse where image retrieval suffices.
- Measure whether relevant pages survive Embed's first-stage top-k. Compare 8B, 1B BF16, and—on supported Blackwell/vLLM—NVFP4 on **the same queries and corpus**. Never mix 4,096- and 2,048-dimensional vectors in one index.
- Hold those candidates fixed and test what Rerank changes in top-k relevance, query latency, and GPU cost. A leaderboard win is not a production cost estimate.
- Finally, check citations and **answer correctness** from the whole agent. A good retrieval score cannot reveal an unsupported final answer.

The released model cards use [OpenMDW 1.1](https://openmdw.ai/license/1-1/); separately installed components can have their own terms. We reviewed published cards and organizer records but **did not download weights or run inference**. A sensible adoption decision depends on your documents, hardware, and failure budget—not the largest number among unrelated charts.

## Sources

- [NVIDIA Nemotron 3.5 Retriever release — October 21, 2026](https://huggingface.co/blog/nvidia/nemotron-retriever-world-class-agentic-retrieval)
- [Embed 8B BF16 model card](https://huggingface.co/nvidia/Nemotron-3.5-Embed-8B-BF16)
- [Embed 1B BF16 model card](https://huggingface.co/nvidia/Nemotron-3.5-Embed-1B-BF16)
- [Embed 1B NVFP4 model card](https://huggingface.co/nvidia/Nemotron-3.5-Embed-1B-NVFP4)
- [Rerank 8B BF16 model card](https://huggingface.co/nvidia/Nemotron-3.5-Rerank-8B-BF16)
- [Parse 631M model card, pass configurations, and throughput protocol](https://huggingface.co/nvidia/Nemotron-3.5-Parse)
- [MTEB ViDoRe v3.1 dense leaderboard and methodology](https://mteb-leaderboard.hf.space/benchmark/ViDoRe(v3.1))
- [MTEB ViDoRe v3.1 dense results JSON](https://mteb-leaderboard-backend.hf.space/v1/benchmarks/ViDoRe%28v3.1%29/scores)
- [MTEB ViDoRe v3.1 reranking leaderboard and methodology](https://leaderboard.mteb.org/benchmark/ViDoRe(v3.1%2C%20reranking))
- [MTEB ViDoRe v3.1 reranking results JSON](https://mteb-leaderboard-backend.hf.space/v1/benchmarks/ViDoRe%28v3.1%2C%20reranking%29/scores)
- [ParseBench under-1B leaderboard and dataset card](https://huggingface.co/datasets/llamaindex/ParseBench?leaderboard_max_params=1B)
- [NVIDIA ParseBench triple-pass submission](https://huggingface.co/nvidia/Nemotron-3.5-Parse/blob/main/.eval_results/parsebench.yaml)
- [LightOnOCR-3-0.8B ParseBench submission](https://huggingface.co/lightonai/LightOnOCR-3-0.8B/blob/main/.eval_results/parsebench.yaml)
- [OpenMDW 1.1 model license](https://openmdw.ai/license/1-1/)
