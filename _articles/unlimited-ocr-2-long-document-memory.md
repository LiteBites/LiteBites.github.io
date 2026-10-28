---
layout: article
title: "Unlimited-OCR-2 Makes Hundred-Page Parsing a Memory-Management Problem"
short_title: "Unlimited-OCR-2 and Long Documents"
date: 2026-10-28
type: "Article Bite"
read_time: "4 min read"
source_name: "Baidu on Hugging Face"
source_url: "https://huggingface.co/baidu/Unlimited-OCR-2"
source_published: 2026-10-27
last_reviewed: 2026-10-28
tags:
  - Optical Character Recognition
  - Document Parsing
  - Efficient Inference
summary: "Baidu's Unlimited-OCR-2 combines sparse visual attention with page-window cache reuse to parse hundred-page documents, but its benchmark lead measures an author-run pipeline."
additional_sources:
  - name: "Baidu — Unlimited OCR Works 2 technical report"
    url: "https://huggingface.co/baidu/Unlimited-OCR-2/blob/main/Unlimited-OCR-2.pdf"
  - name: "Baidu — MarathonDocBench dataset and evaluation protocol"
    url: "https://huggingface.co/datasets/baidu/MarathonDocBench"
  - name: "MPDocBench — organizer repository"
    url: "https://github.com/Tongyi-Zhiwen/Qwen-Doc/tree/main/MPDocBench"
---

Baidu's [October 27 release](https://huggingface.co/baidu/Unlimited-OCR-2) puts an oddly literal question behind its name: how does one OCR request cover a hundred-page document without retaining every page's visual key–value (KV) cache on the GPU at once? Its answer is not an infinite context window. It is a model that selects a small visual working set, paired with a serving system that processes overlapping groups of pages and discards old page caches.

## The attention budget and the page window

The [new technical report](https://huggingface.co/baidu/Unlimited-OCR-2/blob/main/Unlimited-OCR-2.pdf) calls the model's attention scheme **Sparse Reference Sliding Window Attention**, or SR-SWA. A local window keeps nearby text in view. A *Page Gate* narrows candidate image blocks to the page being parsed; a *Token Sieve* selects a fixed number of relevant blocks. The previous Unlimited OCR bounded its text history but could still attend to an expanding set of earlier visual tokens. Version 2 bounds the selected visual references as well. That is a claim about **per-step attention**, not a promise that the entire document is remembered exactly.

A second change handles the memory that image pages occupy *before* decoding. The serving pipeline divides a long document into overlapping page windows, reuses the shared boundary page's key–value cache, and releases inactive page caches. Baidu's example [SGLang configuration](https://huggingface.co/baidu/Unlimited-OCR-2#sglang) uses ten-page windows and a customized wheel. To a client, it can be one request; internally, it is sequential work with limited retained context. That distinction matters for a table continuing across a window boundary—and for headings that depend on much earlier pages.

<figure class="article-figure article-figure--ocr2">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable diagram of Unlimited-OCR-2 attention selection and page-window cache reuse">
    <a href="{{ '/assets/images/articles/unlimited-ocr-2-long-document-memory/working-set-and-page-windows.svg' | relative_url }}">
      <img src="{{ '/assets/images/articles/unlimited-ocr-2-long-document-memory/working-set-and-page-windows.svg' | relative_url }}" width="600" height="700" loading="lazy" decoding="async" alt="Document pages are processed in overlapping windows. Within an active window, the model attends to nearby text and selected visual blocks. The shared boundary page's cache is retained for the next window; older page caches are released. This depicts the reported design, not a memory measurement.">
    </a>
  </div>
  <figcaption>LiteBites synthesis of the <a href="https://huggingface.co/baidu/Unlimited-OCR-2/blob/main/Unlimited-OCR-2.pdf">technical report's attention and cache-reuse descriptions</a> and the <a href="https://huggingface.co/baidu/Unlimited-OCR-2#sglang">serving instructions</a>. Schematic, not to scale; the visible working set is not a claim of complete document recall. On narrow screens, swipe horizontally or <a href="{{ '/assets/images/articles/unlimited-ocr-2-long-document-memory/working-set-and-page-windows.svg' | relative_url }}">open full resolution ↗</a>.</figcaption>
</figure>

## A long-document result with a long protocol

The report provides a useful contrast, but its scores are **Baidu-reported system results**, not independently reproduced model-only measurements. The three tests below have different document lengths and scoring rules; their numbers should be read **within each row**, never as one combined ranking.

<div class="paper-results-scroll" tabindex="0" role="region" aria-label="Scrollable Baidu-reported document-parsing scores across separate benchmarks">
<table class="paper-results-table">
  <caption>Baidu's reported Overall scores; higher is better within a benchmark. Comparators differ by row and evaluation pipelines may differ.</caption>
  <thead><tr><th scope="col">Test</th><th scope="col">Unlimited-OCR-2</th><th scope="col">Selected reported comparisons</th></tr></thead>
  <tbody>
    <tr><th scope="row">MPDocBench, up to 30 pages</th><td>84.59</td><td>Unlimited OCR: 61.89</td></tr>
    <tr><th scope="row">MarathonDocBench, 103–300 pages</th><td>77.06</td><td>Kimi-K3: 33.74</td></tr>
    <tr><th scope="row">OmniDocBench v1.6, single pages</th><td>94.02</td><td>Unlimited OCR: 93.92; TeleOCR: 96.91</td></tr>
  </tbody>
</table>
</div>
<p class="paper-results-note">Source: Baidu's <a href="https://huggingface.co/baidu/Unlimited-OCR-2/blob/main/Unlimited-OCR-2.pdf">technical report, Tables 1–3</a>. MarathonDocBench is Baidu's own released benchmark. The table is a selection, not an independent leaderboard; swipe or scroll to see all columns.</p>

MarathonDocBench [releases images and annotations](https://huggingface.co/datasets/baidu/MarathonDocBench) for 100 documents, but its evaluation needs a patched MPDocBench toolkit and explicit matching and table-scoring timeouts. The dataset's instructions say some general-model requests exceed provider image or output limits: images may be downscaled, documents skipped, and failed predictions scored as empty. Baidu also [post-processes its block output](https://github.com/baidu/Unlimited-OCR/blob/main/utils/README.md) into evaluation Markdown. So the large Marathon lead is evidence about this **whole benchmark setup**, not an isolated gain from SR-SWA or a fair promise for every deployment. The report's **7.0× and 5.6×** comparisons concern *per-step decoding latency* against full attention and the older attention scheme at hundred-page scale—not end-to-end PDF processing speed.

## What to test before handing it a book

Baidu's [own limitations section](https://huggingface.co/baidu/Unlimited-OCR-2/blob/main/Unlimited-OCR-2.pdf) says the sparse scheme does not preserve global document information well, particularly heading hierarchy. A smaller page window also reduces memory at the possible expense of cross-page merging. The public [MIT-tagged checkpoint](https://huggingface.co/baidu/Unlimited-OCR-2) and benchmark data make testing possible, but the recommended long-document path uses custom serving code; the hosted report for version 2 is **not** the June arXiv paper linked in the card's citation, which describes version 1.

For a real archive, try short pages, very long pages, and tables crossing both page *and window* boundaries. Check whether every page completes, whether headings and table continuations survive, and how often provider caps, retries, output limits, or post-processing change the result. “Unlimited” is a useful engineering direction; the present evidence demonstrates an author-reported hundred-page regime, not unlimited accuracy or cost-free memory.

## Sources

- [Baidu — Unlimited-OCR-2 model card and October 27 release](https://huggingface.co/baidu/Unlimited-OCR-2)
- [Baidu — Unlimited OCR Works 2 technical report, hosted PDF](https://huggingface.co/baidu/Unlimited-OCR-2/blob/main/Unlimited-OCR-2.pdf)
- [Baidu — MarathonDocBench dataset, protocol, and leaderboard notes](https://huggingface.co/datasets/baidu/MarathonDocBench)
- [Baidu — Unlimited OCR evaluation post-processing](https://github.com/baidu/Unlimited-OCR/blob/main/utils/README.md)
- [MPDocBench — organizer's benchmark repository](https://github.com/Tongyi-Zhiwen/Qwen-Doc/tree/main/MPDocBench)
