---
layout: article
title: "A Field Guide to MinerU's Papers, Code, and Model Checkpoints"
short_title: "MinerU: Papers to Checkpoints"
date: 2026-10-11
type: "Article Bite"
read_time: "4 min read"
source_name: "OpenDataLab / MinerU"
source_url: "https://github.com/opendatalab/MinerU/releases/tag/mineru-4.0.12-released"
source_published: 2026-10-11
last_reviewed: 2026-10-11
tags:
  - Optical Character Recognition
  - Document Parsing
  - Vision-Language Models
summary: "Four MinerU research papers trace a PDF extraction pipeline, a coarse-to-fine model, data-centric training, and diffusion OCR; here are the matching code and official model links."
additional_sources:
  - name: "MinerU code and research links"
    url: "https://github.com/opendatalab/MinerU"
  - name: "MinerU2.5 at ACL 2026"
    url: "https://aclanthology.org/2026.acl-industry.3/"
  - name: "MinerU-Diffusion at ECCV 2026"
    url: "https://link.springer.com/chapter/10.1007/978-3-032-37577-3_24"
---

"MinerU" names a project and several different parsers, not one interchangeable model. Its [October 11, 2026 release](https://github.com/opendatalab/MinerU/releases/tag/mineru-4.0.12-released) adds self-hosted parsing API endpoints; that current code is **not** necessarily the snapshot evaluated in older papers.

## Four papers, not one benchmark row

<div class="paper-results-scroll" role="region" aria-label="MinerU research papers, publication status, and official Hugging Face artifacts" tabindex="0">
  <table class="paper-results-table">
    <caption>Paper, venue, and official artifact; links do not reproduce reported results.</caption>
    <thead>
      <tr><th scope="col">Paper ↗</th><th scope="col">Research focus</th><th scope="col">Publication</th><th scope="col">Hugging Face ↗</th></tr>
    </thead>
    <tbody>
      <tr><th scope="row"><a href="https://arxiv.org/abs/2409.18839">MinerU (2024) ↗</a></th><td>PDF extraction pipeline and postprocessing</td><td>arXiv technical report</td><td><a href="https://huggingface.co/opendatalab/PDF-Extract-Kit">PDF-Extract-Kit components ↗</a></td></tr>
      <tr><th scope="row"><a href="https://aclanthology.org/2026.acl-industry.3/">MinerU2.5 ↗</a></th><td>Coarse-to-fine, 1.2B vision-language parser</td><td>ACL 2026 Industry Track; <a href="https://arxiv.org/abs/2509.22186">arXiv version</a></td><td><a href="https://huggingface.co/opendatalab/MinerU2.5-2509-1.2B">2509 checkpoint ↗</a></td></tr>
      <tr><th scope="row"><a href="https://arxiv.org/abs/2604.04771">MinerU2.5-Pro ↗</a></th><td>Data engine and training with 2.5 architecture retained</td><td>arXiv technical report</td><td><a href="https://huggingface.co/opendatalab/MinerU2.5-Pro-2604-1.2B">2604 checkpoint ↗</a></td></tr>
      <tr><th scope="row"><a href="https://link.springer.com/chapter/10.1007/978-3-032-37577-3_24">MinerU-Diffusion ↗</a></th><td>2.5B block-wise diffusion decoding</td><td>ECCV 2026; <a href="https://arxiv.org/abs/2603.22458">arXiv version</a></td><td><a href="https://huggingface.co/opendatalab/MinerU-Diffusion-V1-0320-2.5B">V1 0320 checkpoint ↗</a></td></tr>
    </tbody>
  </table>
</div>
<p class="paper-results-note">PDF-Extract-Kit contains <em>component weights</em>, not one MinerU model. Swipe horizontally on small screens.</p>

The [original report](https://arxiv.org/abs/2409.18839) combined PDF-Extract-Kit models with preprocessing and postprocessing rules to extract text, formulas, tables, and layout. [MinerU2.5](https://aclanthology.org/2026.acl-industry.3/) changed the center of gravity: first analyze a reduced-resolution page for layout, then read targeted crops at native resolution. Its paper is **in ACL's 2026 Industry Track proceedings** even though the project README still offers an arXiv-preprint BibTeX entry.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable diagram of four MinerU research directions">
    <a href="{{ '/assets/images/articles/mineru-papers-code-and-models/research-lineage.svg' | relative_url }}"><img src="{{ '/assets/images/articles/mineru-papers-code-and-models/research-lineage.svg' | relative_url }}" width="1600" height="900" loading="lazy" decoding="async" alt="The original component-based MinerU pipeline leads to MinerU2.5's coarse-to-fine parser; Pro retains its architecture and changes training, while Diffusion branches into a separate parallel decoder."></a>
  </div>
  <figcaption>LiteBites synthesis of the <a href="https://arxiv.org/abs/2409.18839">original report</a>, <a href="https://aclanthology.org/2026.acl-industry.3/">MinerU2.5 paper</a>, <a href="https://arxiv.org/abs/2604.04771">Pro report</a>, and <a href="https://arxiv.org/abs/2603.22458">Diffusion paper</a>. Arrows show research relationships, not interchangeable checkpoints; swipe on narrow screens or <a href="{{ '/assets/images/articles/mineru-papers-code-and-models/research-lineage.svg' | relative_url }}">open the full-resolution diagram ↗</a>.</figcaption>
</figure>

## Results belong to their protocols

The papers report useful numbers, but not on one common test. The original work measures **components**; the later papers evaluate end-to-end models under different OmniDocBench versions and layout settings. Selected author-reported rows are **not a combined leaderboard**. Only the paired **v1.6 Full** rows share one paper and protocol. Their **Overall** measure is a composite, not NID, TEDS, or F1 alone: `[(1 − Text Edit) × 100 + Table TEDS + Formula CDM] / 3` ([formula](https://arxiv.org/html/2604.04771)).

<div class="paper-results-scroll" role="region" aria-label="Selected MinerU model results with separate benchmark protocols" tabindex="0">
  <table class="paper-results-table">
    <caption>Selected paper-reported results. Higher is better within the named metric; do not rank across different tasks or benchmark versions.</caption>
    <thead>
      <tr><th scope="col">System / model</th><th scope="col">Exact evaluation scope</th><th scope="col">Reported result</th></tr>
    </thead>
    <tbody>
      <tr><th scope="row"><a href="https://arxiv.org/abs/2409.18839">MinerU-era layout component ↗</a></th><td>Academic-paper validation; detector mAP (2024 report, Table 3)</td><td>77.6 mAP</td></tr>
      <tr><th scope="row"><a href="https://arxiv.org/abs/2509.22186">MinerU2.5 ↗</a></th><td>OmniDocBench v1.5; no supplied layout (2.5 paper, Table 5)</td><td>90.67 overall</td></tr>
      <tr><th scope="row"><a href="https://arxiv.org/abs/2604.04771">MinerU2.5 baseline ↗</a></th><td>OmniDocBench v1.6 Full (Pro paper, Table 3)</td><td>92.98 overall</td></tr>
      <tr><th scope="row"><a href="https://arxiv.org/abs/2604.04771">MinerU2.5-Pro ↗</a></th><td>OmniDocBench v1.6 Full (Pro paper, Table 3)</td><td>95.69 overall</td></tr>
      <tr><th scope="row"><a href="https://arxiv.org/abs/2603.22458">MinerU-Diffusion ↗</a></th><td>OmniDocBench v1.5; no ground-truth layout (Diffusion paper, Table 1)</td><td>88.94 overall</td></tr>
    </tbody>
  </table>
</div>
<p class="paper-results-note">The first row measures a <strong>layout detector</strong>, not complete MinerU. “No supplied layout” requires the model to predict it. Do not compare v1.5 with v1.6 as one leaderboard.</p>

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable full-scale chart of MinerU2.5 and Pro on OmniDocBench v1.6 Full">
    <a href="{{ '/assets/images/articles/mineru-papers-code-and-models/v16-same-protocol.svg' | relative_url }}"><img src="{{ '/assets/images/articles/mineru-papers-code-and-models/v16-same-protocol.svg' | relative_url }}" width="1600" height="700" loading="lazy" decoding="async" alt="Full-scale zero-to-one-hundred bars show author-reported 92.98 overall for the MinerU2.5 baseline and 95.69 for Pro on the same OmniDocBench v1.6 Full evaluation: a 2.71-point difference."></a>
  </div>
  <figcaption>LiteBites synthesis and replot of <a href="https://arxiv.org/abs/2604.04771">the Pro technical report, Table 3</a>. The full 0–100 scale avoids exaggerating the 2.71-point difference. These are author-reported v1.6 Full results, not independently reproduced or a comparison with v1.5; swipe on narrow screens or <a href="{{ '/assets/images/articles/mineru-papers-code-and-models/v16-same-protocol.svg' | relative_url }}">open the full-resolution chart ↗</a>.</figcaption>
</figure>

## Pro changes the data; Diffusion changes the decoder

[MinerU2.5-Pro](https://arxiv.org/abs/2604.04771) keeps the 1.2B architecture and focuses on sample selection, annotation checks, and staged training. The authors also revised OmniDocBench to **v1.6**, adding a hard subset and changing matching rules. The chart above uses their same-protocol comparison, not the older v1.5 row. The linked **2604** checkpoint is the paper-era artifact; a newer **2605** model under the same account should not silently replace it in a paper comparison.

[MinerU-Diffusion](https://link.springer.com/chapter/10.1007/978-3-032-37577-3_24) goes another way: instead of generating the document representation left-to-right, it uses block-wise diffusion to decode multiple tokens in parallel. It has a [separate code repository](https://github.com/opendatalab/MinerU-Diffusion) and an **ECCV 2026** proceedings record. Its reported decoding speedup is not a measured end-to-end speedup for the main MinerU application, and its checkpoint is not a drop-in renaming of 2.5-Pro.

## Where the code and demos fit

Use the maintained [MinerU repo](https://github.com/opendatalab/MinerU) for installation; its README links an [official Hugging Face demo](https://huggingface.co/spaces/opendatalab/MinerU). Diffusion has [separate code](https://github.com/opendatalab/MinerU-Diffusion) and a [model card](https://huggingface.co/opendatalab/MinerU-Diffusion-V1-0320-2.5B). Current `main`, demos, and model cards can change independently of paper versions. Check each model card’s license and runtime requirements before local inference.

## If you are choosing a starting point

- Use the original report to understand why layout, OCR components, and postprocessing were combined; its component bundle is not a one-command end-to-end model.
- Start from the 2.5 paper and **2509** checkpoint for the coarse-to-fine VLM; use the ACL record for a formal citation.
- Read Pro's v1.6 evaluation rules before comparing scores; keep its **2604** checkpoint distinct from later weights.
- Treat Diffusion as a separate decoding research line. Test full-page quality and latency in your own workflow rather than transplanting a decoder-only speed claim.

## Sources

- [MinerU 4.0.12 release — OpenDataLab, October 11, 2026](https://github.com/opendatalab/MinerU/releases/tag/mineru-4.0.12-released)
- [Maintained MinerU repository and official demo link](https://github.com/opendatalab/MinerU)
- [Original MinerU technical report](https://arxiv.org/abs/2409.18839)
- [MinerU2.5 — ACL 2026 Industry Track](https://aclanthology.org/2026.acl-industry.3/)
- [MinerU2.5 arXiv version](https://arxiv.org/abs/2509.22186)
- [MinerU2.5-Pro technical report](https://arxiv.org/abs/2604.04771)
- [MinerU-Diffusion — ECCV 2026](https://link.springer.com/chapter/10.1007/978-3-032-37577-3_24)
- [MinerU-Diffusion arXiv version](https://arxiv.org/abs/2603.22458)
- [MinerU-Diffusion implementation](https://github.com/opendatalab/MinerU-Diffusion)
- [Official OpenDataLab Hugging Face models and demo](https://huggingface.co/opendatalab)
