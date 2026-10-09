---
layout: article
title: "LightOnOCR-3 Adds Page Grounding to OCR—But the Pipeline Moved Upstream"
short_title: "LightOnOCR-3: OCR + Grounding"
date: 2026-10-09
type: "Article Bite"
read_time: "4 min read"
source_name: "LightOn AI on Hugging Face"
source_url: "https://huggingface.co/blog/lightonai/lightonocr-3"
source_published: 2026-10-08
last_reviewed: 2026-10-09
tags:
  - Optical Character Recognition
  - Document Parsing
  - Vision-Language Models
summary: "LightOnOCR-3 puts transcription, layout boxes, image descriptions, and chart tables into one model, though benchmark formatting and upstream annotation still matter."
additional_sources:
  - name: "LightOnOCR-3-4B model card"
    url: "https://huggingface.co/lightonai/LightOnOCR-3-4B"
  - name: "LightOnOCR benchmark reproduction repository, October 5 snapshot"
    url: "https://github.com/lightonai/LightOnOCR/tree/36755d461be079737860a5f03ae0c803501269e9/benchmarks"
---

A document parser often needs separate OCR, layout detection, and chart interpretation stages. [LightOn's October 8 release](https://huggingface.co/blog/lightonai/lightonocr-3) puts those outputs behind one model call. LightOnOCR-3 comes in three named variants—0.8B, 1B, and 4B—and adds **grounding** to ordinary page transcription. That could simplify an inference pipeline. It does not mean the system was built without a complicated pipeline of its own.

## One page, two output modes

Send a page image with an empty text prompt and the model produces the familiar transcription. Send the exact prompt `grounding` and it also marks content blocks with labels and boxes: `![title](x1,y1,x2,y2)`, for example, uses page coordinates normalized to **0–1000**. The same stream can carry image descriptions and chart values as HTML tables. The [4B model card](https://huggingface.co/lightonai/LightOnOCR-3-4B) says other instructions are outside the training distribution; this is not a general-purpose document question-answering interface.

That compact inline format matters when the output feeds search or chunking. It gives a downstream system text *and* a place on the original page, without wrapping every block in verbose JSON. But a chart table is generated content: an unreadable point or an estimated value is not a verified measurement. A consumer still has to decide which regions to trust and how to preserve their source coordinates.

<figure class="remote-publisher-image" data-source-url="https://huggingface.co/blog/lightonai/lightonocr-3">
  <a href="https://cdn-uploads.huggingface.co/production/uploads/6421a255eaad1bcb28afdd0e/StHrYJS2gE35QlwNdTQOg.png">
    <img src="https://cdn-uploads.huggingface.co/production/uploads/6421a255eaad1bcb28afdd0e/StHrYJS2gE35QlwNdTQOg.png" width="2000" height="1260" loading="lazy" decoding="async" referrerpolicy="no-referrer" alt="A fictional company report page has colored boxes around its title, text, image, chart, and table; matching output blocks show labels, normalized coordinates, an image description, and HTML tables.">
  </a>
  <figcaption>LightOn's <a href="https://huggingface.co/blog/lightonai/lightonocr-3">publisher-hosted grounding illustration</a> pairs a fictional page with the intended structured format. It is <strong>not an actual model prediction</strong> or a measured accuracy example. <a href="https://cdn-uploads.huggingface.co/production/uploads/6421a255eaad1bcb28afdd0e/StHrYJS2gE35QlwNdTQOg.png">Open the original full-resolution diagram ↗</a></figcaption>
</figure>

## The benchmark depends on its wrapper

LightOn reports these **overall scores** across three separate document benchmarks. This is a selection from its release tables, **not** a complete leaderboard or an independent LiteBites evaluation. The model-name links identify publisher-hosted checkpoints; the **numbers come from LightOn’s [release](https://huggingface.co/blog/lightonai/lightonocr-3)**, not those model cards.

<div class="paper-results-scroll" role="region" aria-label="LightOnOCR-3 selected benchmark scores" tabindex="0">
  <table class="paper-results-table">
    <caption>LightOn-reported overall scores (higher is better <em>within</em> each column; different benchmarks have different tasks).</caption>
    <thead>
      <tr><th scope="col">Model ↗</th><th scope="col">olmOCR-Bench</th><th scope="col">ParseBench (5 cats)</th><th scope="col">fr-bench-pdf2md</th></tr>
    </thead>
    <tbody>
      <tr><th scope="row"><a href="https://huggingface.co/lightonai/LightOnOCR-3-4B">LightOnOCR-3-4B ↗</a></th><td>86.3</td><td>75.1</td><td>74.1</td></tr>
      <tr><th scope="row"><a href="https://huggingface.co/lightonai/LightOnOCR-3-0.8B">LightOnOCR-3-0.8B ↗</a></th><td>85.5</td><td>74.6</td><td>70.5</td></tr>
      <tr><th scope="row"><a href="https://huggingface.co/lightonai/LightOnOCR-3-1B">LightOnOCR-3-1B ↗</a></th><td>84.5</td><td>71.4</td><td>69.6</td></tr>
      <tr><th scope="row"><a href="https://huggingface.co/infly/Infinity-Parser2-Pro">Infinity Parser Pro ↗</a></th><td>87.6</td><td>74.3</td><td>63.2</td></tr>
      <tr><th scope="row"><a href="https://huggingface.co/datalab-to/chandra-ocr-2">Chandra 2 ↗</a></th><td>85.8</td><td>70.1</td><td>69.0</td></tr>
    </tbody>
  </table>
</div>
<p class="paper-results-note">Selected rows in the <a href="https://huggingface.co/blog/lightonai/lightonocr-3">October 8 release tables</a>. The blog calls the linked Infinity-Parser2-Pro checkpoint “Infinity Parser Pro.” Scores and processing setups should not be treated as controlled model-only comparisons; scroll the table horizontally on small screens. The older LightOnOCR-2 row is excluded because its olmOCR overall omits one category.</p>

The release itself warns that edit-distance scoring is sensitive to formatting and applies normalization before evaluation. There is also a visible snapshot difference: the author's [October 5 benchmark repository](https://github.com/lightonai/LightOnOCR/tree/36755d461be079737860a5f03ae0c803501269e9/benchmarks) lists **86.1** for the 4B model under a named postprocessing pipeline, rather than the blog's **86.3**. Its comparison rows differ too. The repository pins scripts and revisions, which helps reproduction, but these two sets of numbers should not be combined into one leaderboard without reconciling their pipelines.

Speed has a similar boundary. LightOn reports tests on the same **512 pages**, with one H100 per model and vLLM 0.30.0. Its 0.8B and 4B models achieve their best reported olmOCR scores at a **400-DPI, 5-megapixel cap**; a smaller 1,540-pixel rendering raises peak throughput but changes the input. Faster serving at lower resolution is a quality–throughput choice, not a free acceleration at identical page detail.

## The pipeline moved into the training data

LightOn describes using its older OCR model plus PaddleOCR, Docling, document-layout detectors, and text-to-box alignment to construct grounding annotations. It audited ambiguous or duplicated regions rather than accepting every detected box. A much larger Qwen vision-language model supplied candidate image descriptions and chart tables; format and plausibility checks rejected some of those candidates. Unprinted chart values could be estimated from axes during annotation, not simply transcribed from the page.

That is the useful distinction: **one-model inference is not one-model supervision**. The release and [Apache-2.0 model cards](https://huggingface.co/lightonai/LightOnOCR-3-4B) make the resulting checkpoints available, but they do not establish error rates for every document type or guarantee that chart cells match their source pixels. The 4B product name is also not an exact parameter audit: Hugging Face's card currently displays about **5B parameters** for that checkpoint.

## Before replacing a parser

- Test plain transcription and `grounding` separately on your own scans, forms, tables, and multi-column pages.
- Inspect boxes and chart cells against the page image; do not treat a plausible HTML table as verified data.
- Compare benchmark rows only with the same categories, formatting rules, render resolution, and postprocessing.
- Budget for image resolution, output tokens, and the **whole** document workflow—not only model decoding.

## Sources

- [LightOnOCR-3 release article — LightOn AI, October 8, 2026](https://huggingface.co/blog/lightonai/lightonocr-3)
- [LightOnOCR-3-4B model card, mode guidance, and license](https://huggingface.co/lightonai/LightOnOCR-3-4B)
- [Author's benchmark scripts and recorded results (October 5 repository snapshot)](https://github.com/lightonai/LightOnOCR/tree/36755d461be079737860a5f03ae0c803501269e9/benchmarks)
