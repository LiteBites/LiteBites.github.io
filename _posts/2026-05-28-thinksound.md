---
layout: post
title: "ThinkSound: Chain-of-Thought Reasoning in Multimodal Large Language Models for Audio Generation and Editing"
short_title: "ThinkSound"
date: 2026-05-28
type: "Paper brief"
read_time: "7 min read"
venue: "NeurIPS 2025"
tags:
  - Audio Generation
  - Multimodal Models
  - Chain-of-Thought
summary: "ThinkSound treats video-to-audio as a reasoning problem rather than a one-shot mapping, using multimodal chain-of-thought to guide a unified model through foley generation, object-focused refinement, and instruction-based editing."
paper_url: "https://arxiv.org/abs/2506.21448"
project_url: "https://thinksound-project.github.io/"
code_url: "https://github.com/FunAudioLLM/ThinkSound"
---

## Why this paper matters

Video-to-audio generation is easy to underestimate. A system does not only need to recognize what appears in a video. It also has to reason about timing, causality, background ambience, overlapping sound events, and which details should be prominent or suppressed.

This paper matters because it argues that better sound generation needs an intermediate reasoning layer. Instead of mapping video directly to waveform in one shot, ThinkSound tries to mimic a more deliberate workflow: analyze the scene, decide what should happen acoustically, then generate or edit the audio step by step.

## The bite

The key idea is to use multimodal chain-of-thought, or CoT, as a control interface for audio generation. A multimodal language model first produces structured reasoning about the scene and the desired sounds, and that reasoning then guides a unified audio foundation model.

That design matters because the model is not limited to one job. ThinkSound uses the same framework for three stages: initial foley generation for a silent video, object-focused refinement when a user points to a region of interest, and instruction-based editing when the user wants to add, remove, or modify sounds in natural language.

## How it works

The pipeline has three layers. First, the authors build **AudioCoT**, a dataset that pairs audio or video with structured reasoning chains about the sounds that should be produced. They then fine-tune a multimodal LLM so it can generate those chains for new inputs. Finally, they train a unified audio model with flow matching so it can synthesize audio from flexible combinations of video, text, audio context, and CoT guidance.

<figure>
  <img src="{{ '/assets/images/papers/thinksound/method-01.png' | relative_url }}" alt="ThinkSound architecture showing a multimodal LLM producing chain-of-thought guidance and a unified multimodal audio transformer using video, text, and audio context for generation and editing." />
  <figcaption>Paper figure: ThinkSound separates reasoning from synthesis, using an MLLM to generate audio-specific chain-of-thought and a unified flow-matching model to turn that reasoning into audio.</figcaption>
</figure>

The three-stage interaction loop is the part to focus on. Stage 1 generates a full soundscape from the whole video. Stage 2 lets the user focus on a specific object or region and refine the audio around it. Stage 3 applies higher-level editing instructions such as adding a new sound event or repairing a masked segment. The same foundation model handles these stages by accepting different combinations of conditions.

Two technical choices are especially important. One is the use of CoT as structured conditioning rather than as a free-form explanation that is ignored later. The other is the unified architecture: instead of training a separate model for each subtask, ThinkSound tries to keep one multimodal audio generator flexible enough to support all three stages.

## What to look at in the results

The paper's main evidence is that CoT guidance improves both quality and alignment. On the VGGSound benchmark, ThinkSound beats prior systems on most objective metrics and on subjective ratings, while the ablation without CoT drops noticeably. That is important because it suggests the reasoning is doing useful work rather than just adding descriptive text.

<figure>
  <img src="{{ '/assets/images/papers/thinksound/results-01.png' | relative_url }}" alt="ThinkSound teaser comparing traditional video-to-audio generation with the ThinkSound pipeline, showing temporal reasoning, object-centric refinement, and instruction-based editing." />
  <figcaption>Paper figure: the teaser is a good summary of the contribution, because it shows that ThinkSound is not only generating sound once, but supporting staged refinement through reasoning, clicks, and editing instructions.</figcaption>
</figure>

The out-of-distribution Movie Gen Audio benchmark also matters. The paper is stronger if the CoT-guided approach is not just overfitting to one benchmark's caption style, and the reported gains there support that broader generalization claim. The object-focused and editing evaluations are also worth attention because they test whether the framework is really interactive rather than just a better silent-video soundtrack model.

One caveat is that the method depends on a fairly engineered stack: a custom CoT dataset, an adapted multimodal LLM, and a unified audio model with several conditioning paths. So the lesson is probably not that audio reasoning is simple. The lesson is that explicit reasoning can be a useful control layer when the generation task is compositionally messy.

## Practical takeaways

- Audio generation from video often fails because the model misses temporal and causal structure, not only because the waveform model is weak.
- Chain-of-thought is most useful here when it becomes a conditioning signal for synthesis, not just an explanatory side output.
- A unified generator becomes more compelling when it can handle generation, local refinement, and editing with the same backbone.
- Interactive multimodal creation benefits from mixing user intent at different granularities: scene-level prompts, object-level focus, and edit-level instructions.
- When reading the paper, focus on what CoT adds over standard caption conditioning: more explicit sound-event structure, timing, and editability.

## Links

- [Paper on arXiv](https://arxiv.org/abs/2506.21448)
- [Project page](https://thinksound-project.github.io/)
- [Official code on GitHub](https://github.com/FunAudioLLM/ThinkSound)
