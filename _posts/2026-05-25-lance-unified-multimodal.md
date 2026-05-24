---
layout: post
title: "Lance: Unified Multimodal Modeling by Multi-Task Synergy"
short_title: "Lance"
date: 2026-05-25
type: "Paper brief"
read_time: "7 min read"
venue: "arXiv 2026"
tags:
  - Multimodal Models
  - Image Generation
  - Video Generation
summary: "Lance argues that a unified image-video model works better when tasks share context but not every representation or parameter path, combining multi-task training with separate understanding and generation routes."
paper_url: "https://arxiv.org/abs/2605.18678"
project_url: "https://lance-project.github.io"
code_url: "https://github.com/bytedance/Lance"
---

## Why this paper matters

Many multimodal systems still split into two worlds. One model family is good at understanding images and videos, answering questions, and following instructions. Another family is good at generating or editing visuals. Unifying these abilities in a single native model is attractive, but it is hard because semantic reasoning and visual synthesis do not want exactly the same representations or training objectives.

Lance matters because it treats this as a design and training problem rather than a pure scaling problem. The paper asks a practical question: can one relatively lightweight model handle image and video understanding, generation, and editing together, without collapsing into a weak compromise on all of them?

## The bite

The key idea is to keep the context unified while decoupling the capability pathways. Lance lets different tasks share one interleaved multimodal sequence, so understanding and generation can still see the same inputs and benefit from multi-task transfer. But it does not force every task to use the same visual representation or exactly the same parameter path.

That split is the important move. Lance uses semantic visual tokens for understanding, VAE latent tokens for generation, autoregressive next-token prediction for text-side tasks, and flow matching for visual generation. In other words, it tries to keep the parts that should be shared shared, and the parts that naturally conflict separate.

## How it works

Architecturally, Lance is built around two principles named directly in the paper: unified context learning and decoupled capability pathways. Inputs from text, images, and videos are converted into a shared interleaved sequence. Within that sequence, Lance mixes text tokens, understanding-oriented visual tokens from a ViT encoder, and generation-oriented latent tokens from a VAE encoder.

<figure>
  <img src="{{ '/assets/images/papers/lance/overview-09.png' | relative_url }}" alt="Overview of Lance showing a shared multimodal context sequence with separate understanding and generation pathways, plus modality-aware rotary positional encoding." />
  <figcaption>Paper figure: Lance keeps one shared multimodal context, but separates understanding and generation into different expert pathways and objectives.</figcaption>
</figure>

The backbone then uses a dual-stream mixture-of-experts setup. One expert mainly serves understanding and text generation, while the other serves visual generation and editing. This is paired with two different objectives: autoregressive language modeling for understanding tasks, and flow-based prediction in latent space for generation tasks. A useful way to read the model is as a compromise between full sharing and full separation.

The paper adds two more technical pieces on top of that. First, it introduces modality-aware rotary positional encoding, or MaPE, to separate heterogeneous visual token groups inside the same sequence. Second, it uses staged multi-task training: pre-training for basic paired tasks, continual training for broader task coverage, supervised fine-tuning for higher-quality control, and reinforcement learning to improve image generation details such as text rendering.

## What to look at in the results

The most important result is not that Lance wins every single benchmark. It is that a 3B-activated-parameter model stays competitive across several different capability families at once: image generation, video generation, multimodal editing, and video understanding. That is the core evidence for the paper's multi-task-synergy claim.

The results are especially interesting when the paper compares Lance with other unified models rather than with highly specialized closed models. On image and video generation benchmarks, Lance is usually near the top of the unified-model group. On MVBench, it also stays strong enough to show that generation-oriented training did not erase understanding ability.

<figure>
  <img src="{{ '/assets/images/papers/lance/results-21.png' | relative_url }}" alt="Qualitative multimodal editing comparison figure showing Lance against baseline models on image and video editing tasks." />
  <figcaption>Paper figure: the qualitative editing examples are a good stress test because they show whether a unified model can make precise changes while preserving structure, texture, and temporal consistency.</figcaption>
</figure>

The editing examples are also a good place to focus. If unified modeling is real rather than superficial, the model should not only caption or generate, but also modify images and videos in a controlled way. The paper's qualitative figures suggest that Lance is strongest when precise edits still need realistic appearance and stable motion.

One caveat is that the paper still relies on a fairly engineered recipe: dual experts, distinct token types, staged training, data scheduling, and a specialized positional encoding trick. So the lesson is probably not that unification is simple. The lesson is that unification becomes more plausible when the system respects the differences between tasks instead of pretending they are identical.

## Practical takeaways

- Unified multimodal modeling works better when sharing happens at the context level, not necessarily at every representation level.
- Understanding and generation often want different visual tokens and different objectives, so partial decoupling is a feature, not a failure.
- Multi-task training can help core generation quality, not just add extra downstream skills.
- Video support matters because it is a stronger test of whether a unified model really handles temporal structure instead of only static images.
- When reading the paper, focus on the design trade-off: how much should a unified model share, and where should it specialize?

## Links

- [Paper on arXiv](https://arxiv.org/abs/2605.18678)
- [Project page](https://lance-project.github.io)
- [Official code on GitHub](https://github.com/bytedance/Lance)
