---
layout: article
title: "A Small Weight Edit Unstuck a Reasoning Model—But Did It Teach Math?"
short_title: "Weight-Space Programming's Loop Fix"
date: 2026-11-08
type: "Article Bite"
read_time: "3 min read"
source_name: "Rikiya Takehi et al."
source_url: "https://rikiyat.github.io/blog/weight-space-programming/"
source_published: 2026-11-02
last_reviewed: 2026-11-08
tags:
  - Small Language Models
  - LLM Reasoning
  - Optimization
summary: "An MIT CSAIL team's direct edit to a small Qwen model sharply improved its reported math score by stopping reasoning loops, while a non-looping model resisted the same approach."
card_image: "/assets/images/articles/weight-space-programming-loop-fix/diagnose-edit-evaluate.svg"
card_image_alt: "Original diagram: Astra used practice forward passes to diagnose Qwen's looping, targeted 131,072 weight positions without gradients, then the researchers measured higher MATH-500 accuracy and fewer token-limit hits."
additional_sources:
  - name: "Qwen3.5-0.8B model card"
    url: "https://huggingface.co/Qwen/Qwen3.5-0.8B"
  - name: "Experiment logs"
    url: "https://github.com/RikiyaT/lm_understand-logs"
  - name: "Edited Qwen checkpoint"
    url: "https://huggingface.co/RikiyaT/Qwen3.5-0.8B-weight-space-programming"
---

What if an AI could fix another model by changing a few numbers in its weights—not by running a training job? In [a November 2 research post](https://rikiyat.github.io/blog/weight-space-programming/), Rikiya Takehi and colleagues at MIT CSAIL describe asking GPT-6 Astra to do exactly that to Qwen3.5-0.8B. The team's headline math score jumped from **7.9% to 48.1%**. The more interesting question is what the edit actually fixed.

## The model was getting stuck

The authors ran Qwen in thinking mode with a 32,768-token answer limit. Under their specified sampling settings, it often repeated itself instead of finishing: **93.0% of its MATH-500 answers hit the limit**. The [Qwen model card](https://huggingface.co/Qwen/Qwen3.5-0.8B) also warns that this small model can enter thinking loops; that warning is context, not an independent replication of this benchmark.

Astra had a Python session with access to the weights and practice problems from the *training* sets of GSM8K and MATH. It could choose prompts and inspect the model's responses through a budget of 10, 25 or 50 **batched forward passes**; it could not use gradients or see the held-out evaluations. In the 50-pass run, the authors say Astra traced the looping to a direction written by MLPs in layers 15 and 19, then subtracted it from selected output columns: **131,072 targeted weight positions, about 0.016%** of the model. The [released edit manifest](https://github.com/RikiyaT/lm_understand-logs/blob/4d09ba6d6a7e891dd8063974dfe81b3d78e3494f/exp8_math/runs/p50c/edit/manifest.json) counts **130,188 stored values that actually changed** after bfloat16 rounding. This was direct weight editing, but emphatically not a feedback-free guess.

<figure class="article-figure">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable diagram of practice-based diagnosis, targeted weight edit, and held-out evaluation">
    <a href="{{ '/assets/images/articles/weight-space-programming-loop-fix/diagnose-edit-evaluate.svg' | relative_url }}">
      <img src="{{ '/assets/images/articles/weight-space-programming-loop-fix/diagnose-edit-evaluate.svg' | relative_url }}" width="960" height="720" loading="lazy" decoding="async" alt="The authors gave Astra Qwen weights and up to 50 batched practice forward passes, not gradients or held-out test data. It targeted 131,072 weight positions in layers 15 and 19. On the authors' MATH-500 evaluation, accuracy went from 7.9% to 48.1%, while answers hitting the token limit fell from 93.0% to 33.1%. The diagram is schematic, not a causal proof that math ability increased.">
    </a>
  </div>
  <figcaption>LiteBites synthesis of <a href="https://rikiyat.github.io/blog/weight-space-programming/">Experiment 8 and the separate Gemma test</a>. Arrows describe the Qwen research workflow, not a training-gradient path; the scores are author-reported. On narrow screens, swipe horizontally or <a href="{{ '/assets/images/articles/weight-space-programming-loop-fix/diagnose-edit-evaluate.svg' | relative_url }}">open full resolution ↗</a>.</figcaption>
</figure>

## A score jump with a narrower explanation

With the 50-pass edit, the team reports **48.1% on MATH-500**, **67.1% on GSM8K** and **62.3% on IFEval**, versus **7.9%, 13.8% and 21.0%** for its unedited Qwen baseline under the same sampling setup. On MATH-500, token-limit hits fell to **33.1%**. Earlier 10- and 25-pass edits barely reduced that limit-hit rate and delivered much smaller math gains. The correspondence makes the loop fix a compelling explanation, but the reported scores alone do not isolate every causal contribution.

Crucially, freeing a model to *finish* its reasoning is not the same as teaching it new reasoning. The authors also tried Gemma 3 270M, which rarely hit its own token limit. After up to 50 practice passes, their MATH-500 scores remained between **6.8% and 7.7%** across the baseline and edited variants; the 50-pass result was **7.0%**. That is a different model with different sampling settings, not a matched head-to-head benchmark. It is a useful failed extension of the weight-editing idea: no similarly obvious loop defect, no comparable improvement.

## What would make this a method?

The team published [experiment logs](https://github.com/RikiyaT/lm_understand-logs) and an [edited Qwen checkpoint](https://huggingface.co/RikiyaT/Qwen3.5-0.8B-weight-space-programming), making the reported procedure more inspectable than a score-only claim. It is still an early research demonstration, not a reliable recipe for upgrading arbitrary models. A convincing next test would repeat the intervention across seeds, model families and sampling configurations, compare it with simpler loop mitigations, and check whether the changed weights help without harming other tasks.

For now, the result is best read as **targeted repair of a conspicuous failure mode**, with a large benchmark consequence—not evidence that a tiny hand-written edit generally manufactures math ability. If you evaluate the checkpoint yourself, inspect both answer accuracy *and* the rate of responses that exhaust the token budget.

## Sources

- [Takehi, Teoh, Zhang and Khattab — *Sparks of Weight-Space Programming*, November 2, 2026](https://rikiyat.github.io/blog/weight-space-programming/)
- [Qwen3.5-0.8B model card — thinking-loop warning and model context](https://huggingface.co/Qwen/Qwen3.5-0.8B)
- [Authors' experiment logs](https://github.com/RikiyaT/lm_understand-logs)
- [Pinned edit manifest — targeted columns and changed bfloat16 entries](https://github.com/RikiyaT/lm_understand-logs/blob/4d09ba6d6a7e891dd8063974dfe81b3d78e3494f/exp8_math/runs/p50c/edit/manifest.json)
- [Edited Qwen checkpoint](https://huggingface.co/RikiyaT/Qwen3.5-0.8B-weight-space-programming)
