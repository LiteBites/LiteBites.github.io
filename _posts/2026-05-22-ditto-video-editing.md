---
layout: post
title: "Scaling Instruction-Based Video Editing with a High-Quality Synthetic Dataset"
short_title: "Ditto"
date: 2026-05-22
type: "Paper brief"
read_time: "7 min read"
venue: "arXiv 2025"
tags:
  - Video Editing
  - Generative Models
  - Datasets
summary: "Ditto turns instruction-based video editing into a data problem first: it builds a million-sample synthetic dataset, then trains Editto with curriculum learning to follow text edits more reliably."
paper_url: "https://arxiv.org/abs/2510.15742"
project_url: "https://ezioby.github.io/Ditto_page"
code_url: "https://github.com/EzioBy/Ditto"
---

## Why this paper matters

Instruction-based image editing has improved quickly, but instruction-based video editing is still much less reliable. The hard part is not only changing content, but changing it consistently across time while keeping motion, structure, and identity stable.

This paper argues that the bottleneck is data more than architecture alone. If high-quality paired video-editing examples are scarce, end-to-end video editors stay weak. Ditto is the authors' answer: build a scalable pipeline for synthetic video editing data, then use that dataset to train a stronger editor.

## The bite

The key idea is to let image editing do what it is already good at, then use that result to guide video generation. Ditto first edits a key frame with an instruction-based image editor, then uses that edited frame together with depth-based motion structure and the text instruction to generate the full edited video.

That design matters because it avoids a common trade-off in earlier work. Many scalable pipelines could propagate an edit through a video, but often with weak temporal consistency or limited edit quality. Ditto tries to keep both: richer edits from modern image editors, and more coherent videos from an in-context video generator.

## How it works

The pipeline has three main stages. First, the authors curate source videos from Pexels and filter them for duplicates and weak motion. That step is easy to overlook, but it matters because the final dataset quality depends heavily on whether the source videos are visually useful for editing in the first place.

<figure>
  <img src="{{ '/assets/images/papers/ditto/pipeline-04.png' | relative_url }}" alt="The Ditto synthetic data pipeline, from source video filtering through instruction generation, edited key frames, in-context video generation, and post-processing." />
  <figcaption>Paper figure: the Ditto pipeline builds edited video triplets by combining instruction generation, key-frame image editing, depth-guided video generation, and post-generation filtering.</figcaption>
</figure>

Second, a vision-language model generates grounded edit instructions from each source video. A key frame is edited with Qwen-Image, depth is predicted from the source video, and an in-context video generator combines the edited key frame, the depth video, and the text instruction to synthesize the target edited video. A useful way to read this is as a division of labor: the edited frame defines appearance, the depth video preserves structure and motion, and the text keeps the edit semantically aligned.

Third, the generated triplets go through filtering and enhancement. A VLM checks instruction fidelity, source fidelity, visual quality, and safety. The paper then uses a denoising enhancement stage to clean artifacts while trying to preserve the intended edit. With this pipeline, the authors report spending more than 12,000 GPU-days to build Ditto-1M, a dataset of roughly one million edited videos.

The training side has one more important idea: modality curriculum learning. Because the synthetic pipeline provides an edited reference frame during generation, the model is first trained with that visual scaffold still available. Over time, the scaffold is gradually removed, forcing the model to rely on text instructions alone at inference time.

## What to look at in the results

The most useful evidence is not just whether the method edits a video, but whether it does so while preserving temporal coherence. The paper reports gains over prior methods on automatic metrics and on human evaluation, especially for instruction following and overall quality. In the table, their method improves both edit accuracy and temporal consistency rather than trading one for the other.

<figure>
  <img src="{{ '/assets/images/papers/ditto/results-07.png' | relative_url }}" alt="Qualitative comparison figure showing Ditto against earlier instruction-based video editing methods across stylization and local edit examples." />
  <figcaption>Paper figure: qualitative comparisons matter here because they show whether the edited object changes clearly while identity, background, and motion remain stable across frames.</figcaption>
</figure>

The qualitative examples are also worth reading carefully. Look at stylization cases such as pixel-art or LEGO-like rendering, and local edits such as changing clothing attributes. The important question is whether the edited object changes while the rest of the video still feels like the same scene. The paper's claim is strongest when the edit is obvious but identity, motion, and background remain stable.

One caveat is that this is still a synthetic-data story. The paper shows encouraging transfer beyond the raw generator and some synthetic-to-real behavior, but a careful reader should still ask how well the model generalizes to messier real-world prompts and videos.

## Practical takeaways

- A strong video editor may depend more on data construction quality than on adding one more editing module.
- Editing a single key frame first is a practical way to import the strengths of image editing into video editing.
- Depth or other structural signals help because video editing is a temporal consistency problem, not just a framewise appearance problem.
- Curriculum learning is doing real work here: the model starts with visual guidance, then learns to stand on text alone.
- When reading the paper, focus on where the pipeline reduces trade-offs between fidelity, diversity, cost, and temporal coherence.

## Links

- [Paper on arXiv](https://arxiv.org/abs/2510.15742)
- [Project page](https://ezioby.github.io/Ditto_page)
- [Official code on GitHub](https://github.com/EzioBy/Ditto)
