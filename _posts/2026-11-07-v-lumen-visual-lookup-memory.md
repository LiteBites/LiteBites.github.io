---
layout: post
title: "V-LUMEN: Visual Lookup Memory for Embedding Scaling in Vision-Language Models"
short_title: "Can Visual Memory Replace Adapter Capacity?"
date: 2026-11-07
type: "Paper brief"
read_time: "7 min read"
venue: "NeurIPS 2026 poster; arXiv v2"
tags:
  - Vision-Language Models
  - Efficient Tuning
  - Memory Management
summary: "Sparse visual lookup memory roughly preserves matched-adapter accuracy, but more memory rows have not yet improved it."
card_image: "/assets/images/papers/v-lumen-visual-lookup-memory/visual-lookup-boundary.svg"
card_image_alt: "Original four-stage diagram: visual patches and a text question form codes through frozen components, then spatial/query-dependent hash keys; selected rows from a learned memory table are gated into a frozen VLM at decoder layers 2 and 8. The measured table stays on the GPU; CPU or SSD serving is only proposed."
paper_url: "https://arxiv.org/abs/2610.37019v2"
---

A vision-language model sees a chart, a map, or a document as continuous visual features. Those features do not arrive with the neat, reusable token IDs that make language-model lookup tables easy to index. **V-LUMEN** asks whether a small number of learned vectors, selected by *visual* addresses, can provide another way to store model capacity. Its answer is interesting but narrower than “more memory makes the model smarter”: in the reported tests, shifting some adapter capacity into a sparse visual memory largely **preserves** average accuracy at a matched budget. Simply adding more memory rows does not yet raise it.

Miso Choi, Daekeun Kim, Eunji Kim, and Jungbeom Lee's paper is [listed as a NeurIPS 2026 poster](https://neurips.cc/virtual/2026/poster/154969). This reading follows [arXiv v2](https://arxiv.org/html/2610.37019v2), dated November 5.

## Why give visual features addresses?

Language-side lookup memories can use token or n-gram identities to retrieve a small set of trained embeddings. A patch feature from an image, by contrast, is a continuous vector; tiny changes can make an exact-vector address useless. V-LUMEN first maps each visual hidden state, using a **frozen random projection and frozen pretrained LaVIT codebook**, to a discrete visual code. It then modifies that code's integer address with row and column summaries, a coarse position, and a rank-bucketed signal derived from the text question. The *same* patch may therefore read different memory rows under different questions. [Paper, §§2.2–2.4](https://arxiv.org/html/2610.37019v2#S2.SS2).

This is not a nearest-neighbor search over a growing gallery of images. The codes and hash functions construct **addresses**; the memory-table rows at those addresses are **trained parameters**. The routing is non-trainable, while the memory values, gates, and projections that fuse them into the frozen decoder are learned. In the main configuration, lookup-derived updates enter decoder layers **2 and 8**, and each visual token reads a fixed number of cells. The paper calls this an independent capacity axis because the number of *stored* rows can grow without changing the number of rows read per visual token—not because it has shown an accuracy gain from enlarging the table. [§2.5](https://arxiv.org/html/2610.37019v2#S2.SS5), [Appendix D](https://arxiv.org/html/2610.37019v2#A4), [Appendix J](https://arxiv.org/html/2610.37019v2#A10).

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable diagram of V-LUMEN's visual address construction, sparse table read, and gated fusion">
    <a href="{{ '/assets/images/papers/v-lumen-visual-lookup-memory/visual-lookup-boundary.svg' | relative_url }}">
      <img src="{{ '/assets/images/papers/v-lumen-visual-lookup-memory/visual-lookup-boundary.svg' | relative_url }}" width="1200" height="630" alt="Four stages: visual patch features and a text question feed address construction; codes computed through a frozen projection and codebook, spatial context and question-dependent rank bins select rows from learned visual memory; learned gating and projection add a residual at decoder layers 2 and 8. The measured memory resides on the GPU." loading="lazy" decoding="async" />
    </a>
  </div>
  <figcaption>Original LiteBites synthesis of <a href="https://arxiv.org/html/2610.37019v2#S2">V-LUMEN §2</a> and <a href="https://arxiv.org/html/2610.37019v2#A4">Appendix D</a>; no paper artwork is reproduced. The colored cells show sparse selection, not measured importance. On narrow screens, swipe horizontally or <a href="{{ '/assets/images/papers/v-lumen-visual-lookup-memory/visual-lookup-boundary.svg' | relative_url }}">open the full-resolution diagram ↗</a>.</figcaption>
</figure>

One nuance matters: the paper's projected relevance branch uses **separate** frozen random projections for the question and patch vectors. A generic distance-preservation argument for projecting two vectors through the *same* random map does not, on its own, establish that these separate-projection dot products track semantic relevance. The method also includes a direct-similarity branch with a running prior, and its scores are bucketed by rank. Treat “query-conditioned addressing” as the documented mechanism, not proof that every selected bin identifies a relevant region. [§2.4](https://arxiv.org/html/2610.37019v2#S2.SS4), [Appendix D.1–D.2](https://arxiv.org/html/2610.37019v2#A4.SS1).

## The comparison worth reading

The main experiments use a frozen Qwen3-VL-2B-Instruct backbone. For five benchmarks—ChartMuseum, FRIEDA, VisRes, MMMU, and MMMU-Pro—the authors train on **10% of each evaluation dataset**, hold out the other 90%, and evaluate at most 1,000 examples per benchmark. The numbers below are the paper's **mean accuracy across those five tasks**, in percent, averaged across three seeds. The two adapter comparisons hold the relevant budget approximately fixed *within each pair*; they do **not** compare the same LoRA or MoE module before and after a free memory addition. [§3.1 and Table 2](https://arxiv.org/html/2610.37019v2#S3.T2), [Appendix G](https://arxiv.org/html/2610.37019v2#A7).

<div class="paper-results-scroll" role="region" aria-labelledby="v-lumen-results-caption" tabindex="0">
  <table class="paper-results-table">
    <caption id="v-lumen-results-caption">Paper Table 2: five-task mean accuracy for budget-matched adapter pairs (higher is better)</caption>
    <thead><tr><th scope="col">Configuration</th><th scope="col">Mean accuracy</th><th scope="col">Difference within pair</th></tr></thead>
    <tbody>
      <tr><th scope="row">LoRA-only</th><td>22.76%</td><td>—</td></tr>
      <tr><th scope="row">Smaller LoRA + V-LUMEN</th><td>23.33%</td><td>+0.57 percentage points</td></tr>
      <tr><th scope="row">MoE-only</th><td>19.03%</td><td>—</td></tr>
      <tr><th scope="row">Smaller MoE + V-LUMEN</th><td>19.10%</td><td>+0.07 percentage points</td></tr>
    </tbody>
  </table>
</div>
<p class="paper-results-note">LiteBites transcription of <a href="https://arxiv.org/html/2610.37019v2#S3.T2">paper Table 2</a>. LoRA pairs match total trainable parameters; MoE pairs nearly match accessible and per-token activated parameters (<a href="https://arxiv.org/html/2610.37019v2#A7">Appendix G</a>). Small differences lie within the paper's three-seed spread; superiority is not established. Scroll horizontally on narrow screens.</p>

The LoRA-only side uses rank 321; the memory-plus-LoRA side uses rank 107 alongside about **86.1 million V-LUMEN parameters**, yielding nearly equal total trainable counts. The MoE pair matches the accessible parameter count and the number activated per token rather than giving both models identical experts. Some individual benchmarks improve and others fall; the averages do not support a blanket “better than LoRA or MoE” headline. [Tables 2, 7–9](https://arxiv.org/html/2610.37019v2#A7).

V-LUMEN alone also lifts the frozen backbone's five-task mean from **2.18% to 19.97%**. That shows the trained lookup-and-fusion path can supply useful capacity, **not** that it outperforms the adapters: the memory-only run receives **10,000 mid-training and 2,000 supervised fine-tuning (SFT) steps**, versus **2,000 and 1,000** in the LoRA/MoE pairs. The paper explicitly says not to compare those blocks directly. [Tables 2 and 4](https://arxiv.org/html/2610.37019v2#S3.T2), [Appendix E.2](https://arxiv.org/html/2610.37019v2#A5.SS2).

## What transfers—and what does not

On three additional benchmarks outside the training curriculum, the paper reports gains over the frozen backbone without in-domain few-shot samples: TextVQA **11.00% → 37.17%**, OCR-VQA **13.80% → 47.67%**, and VizWiz-VQA **2.00% → 9.97%**. The authors report no shared training images for these tests, with an image-ID audit for TextVQA. This is useful evidence against *evaluation-domain* memorization, but it is a backbone-versus-memory test, **not** a matched-adapter comparison, and it does not show that all distribution shifts are solved. [Table 3](https://arxiv.org/html/2610.37019v2#S3.T3), [Appendix F](https://arxiv.org/html/2610.37019v2#A6).

The most revealing ablation changes **row count** versus **embedding width**. With the default memory width held fixed, increasing rows per table cell from **81,920 to 655,360** raises the V-LUMEN parameter count from about **86.1 million to 673.4 million**, yet the average gain over the frozen backbone stays at **+17.79 percentage points** at both ends; intermediate values fluctuate without a monotonic rise. Widening the retrieved vector, by contrast, changes how much is read per token and brings some improvement, from **+16.44** at width 8 to **+18.70 points** at width 64. That is not evidence of *storage-only* scaling. [Appendix J, Table 18](https://arxiv.org/html/2610.37019v2#A10.T18).

The address components have a separate limitation. Under normal, unperturbed evaluation, even a simple rolling-hash key performs similarly to the elaborate spatial/query hashing. The full design separates more clearly under a deliberately re-drawn projection stress test (one draw, according to the authors), not under the paper's ordinary image-degradation tests. [Appendix I.4, Table 16](https://arxiv.org/html/2610.37019v2#A9.T16).

## The systems boundary

In a **bf16**, one-layer lookup microbenchmark with 64 visual tokens on an RTX 6000 Ada, **total lookup time stays around 11.16–11.23 ms** as the table grows from 0.2× to 8× its default row count. But this measures table-size *insensitivity*, not a fast end-to-end deployment. The authors' end-to-end measurements add **19–25 ms of image prefill**, dominated by key construction currently performed in a Python loop on the CPU. Per-token decode latency hardly changes because the memory is read at visual-token positions during prefill; that does not erase the prefill cost for short answers. [Table 1](https://arxiv.org/html/2610.37019v2#S2.T1), [Appendix H.1, Tables 10–11](https://arxiv.org/html/2610.37019v2#A8.SS1).

Crucially, the tested memory table resides in **GPU memory**, in fp32. The appealing prospect of a much larger table fetched from CPU memory or SSD is explicitly **future work**: no such latency, throughput, or accuracy result is measured here. Offloading would add a different data-movement constraint, including at the first injection layer, where the addresses depend on hidden states. [Appendix H.2](https://arxiv.org/html/2610.37019v2#A8.SS2), [§7](https://arxiv.org/html/2610.37019v2#S7).

## What to take away

- **Compare within matched pairs.** LoRA and MoE budget matching use different parameter definitions; neither small average difference is a demonstrated win. The second-backbone InternVL3.5-2B test is near parity for the budget-matched **MoE** pair, but its **LoRA** pair is *rank-matched*, not total-budget-matched. [Appendix I.3, Table 15](https://arxiv.org/html/2610.37019v2#A9.T15).
- **Ask where extra rows go.** A larger stored table keeps the read count fixed here, but has not improved accuracy. Measure row utilization and the spread of accessed addresses before paying for more capacity.
- **Count the whole serving path.** Report image-prefill latency and GPU footprint alongside decode time; the measured memory still lives on the GPU. Test CPU/SSD offloading before claiming an accelerator-memory benefit.
- **Treat reproducibility as open.** The [paper-linked repository](https://github.com/miso-choi/V-Lumen) currently has no inspectable implementation or reproduction instructions. These numbers are author-reported, not an independent replication.

## Links

- [V-LUMEN, arXiv v2 (version record)](https://arxiv.org/abs/2610.37019v2)
- [Full text and tables](https://arxiv.org/html/2610.37019v2)
- [Official NeurIPS 2026 poster record](https://neurips.cc/virtual/2026/poster/154969)
- [Paper-linked repository (availability may change)](https://github.com/miso-choi/V-Lumen)
