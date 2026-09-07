---
layout: post
title: "DoRA: Weight-Decomposed Low-Rank Adaptation"
short_title: "DoRA"
date: 2026-09-07
type: "Paper brief"
read_time: "6 min read"
venue: "ICML 2024 (Oral)"
tags:
  - Parameter-Efficient Fine-Tuning
  - LoRA
  - Large Language Models
  - Vision-Language Models
summary: "DoRA keeps LoRA's low-inference-cost design but separates magnitude from direction, giving the adapter more room to change how a pretrained weight is scaled without updating the whole matrix."
card_image: "/assets/images/papers/dora-weight-decomposed-low-rank-adaptation/magnitude-direction-differences.png"
card_image_alt: "DoRA Figure 3 comparing magnitude and direction differences for LoRA and DoRA against pretrained query matrices across layers"
paper_url: "https://arxiv.org/abs/2402.09353v6"
project_url: "https://nbasyl.github.io/DoRA-project-page/"
code_url: "https://github.com/NVlabs/DoRA"
---

## Why LoRA's cheapness comes with a catch

LoRA is popular for a practical reason: it can adapt a large pretrained model by training small low-rank matrices, then merge the update into the base weights before inference. That means the deployed model does not need an extra adapter path just to serve the result. The trade-off is that the low-rank update has to express the useful change through a constrained route, and the authors of DoRA argue that this can leave an accuracy gap compared with full fine-tuning.

DoRA—Weight-Decomposed Low-Rank Adaptation—starts with a simple question: what does full fine-tuning change in a weight matrix that LoRA is not changing as effectively? The paper's analysis compares updates in two parts of a weight: its **magnitude**, or scale, and its **direction**, or orientation. The authors report that full fine-tuning and LoRA do not move through those parts in the same way. Their proposed fix is to make both parts tunable while keeping the large directional update low-rank.

That makes DoRA less like a new model architecture than a different parameterization for fine-tuning. The base model stays in place; the adapter gets a more deliberate division of labor.

## The magnitude-direction split

For a pretrained weight matrix, DoRA writes the weight as a magnitude term multiplied by a normalized directional term. At initialization, the two components reproduce the original weight. During fine-tuning, the magnitude becomes a trainable vector, while the direction is updated through LoRA's two low-rank matrices. In the paper's notation, the pretrained weight plus the low-rank update is normalized before the learned magnitude rescales it.

This split is useful because LoRA normally asks its low-rank update to account for changes in both scale and orientation at once. DoRA gives scale its own small trainable component and lets the low-rank path concentrate on direction. In the paper's formulation, the low-rank update is added to the pretrained weight before that combined direction is normalized; it is not an independent normalized direction added afterward. The extra parameter cost is tiny in the paper's language-model experiments: the full-rank DoRA configuration uses 0.84% trainable parameters on LLaMA-7B versus 0.83% for LoRA. The adjusted version halves the LoRA rank and uses 0.43%.

There is also an optimization argument. The normalization step projects the directional gradient away from the current weight and rescales it by the learned magnitude. The authors connect that behavior to more stable optimization, and their weight-update analysis reports a negative correlation between magnitude and directional changes for full fine-tuning (-0.62) and DoRA (-0.31), compared with a positive correlation for LoRA (0.83) in their VL-BART case study. Those correlations are evidence for the paper's explanation, not a universal law about every adapter or model.

<figure>
  <img src="{{ '/assets/images/papers/dora-weight-decomposed-low-rank-adaptation/magnitude-direction-differences.png' | relative_url }}" alt="Two-panel source figure comparing magnitude and direction differences for LoRA and DoRA against pretrained query matrices across model layers." />
  <figcaption>Figure 3 from <cite>DoRA: Weight-Decomposed Low-Rank Adaptation</cite> by Shih-Yang Liu, Chien-Yi Wang, Hongxu Yin, Pavlo Molchanov, Yu-Chiang Frank Wang, Kwang-Ting Cheng, and Min-Hung Chen: magnitude and direction differences between LoRA/DoRA fine-tuned query matrices and the pretrained weights across layers. The figure helps make the paper's central decomposition concrete. Source: <a href="https://arxiv.org/pdf/2402.09353v6">DoRA, Figure 3</a>, used under the paper's <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/">CC BY-NC-SA 4.0</a> terms.</figcaption>
  <p><a href="{{ '/assets/images/papers/dora-weight-decomposed-low-rank-adaptation/magnitude-direction-differences.png' | relative_url }}">Open the full-resolution Figure 3</a> for readable labels.</p>
</figure>

A practical implementation detail matters here. The exact normalization creates extra backpropagation memory, so the authors detach the normalization factor from the gradient graph while still updating its value during training. In their ablation, that modification reduces training memory by about 24.4% for LLaMA and 12.4% for VL-BART, with no accuracy change for VL-BART and a reported 0.2-point difference for LLaMA. DoRA can still be merged into the pretrained weights before inference, so the paper claims no additional inference latency over LoRA.

## What the results actually show

The strongest evidence is not one universal benchmark, but repeated comparisons against LoRA across several backbones and tasks. On the paper's eight commonsense-reasoning datasets, same-rank DoRA raises the reported average from LoRA's 74.7 to 78.4 for LLaMA-7B, from 80.5 to 81.5 for LLaMA-13B, from 77.6 to 79.7 for LLaMA2-7B, and from 80.8 to 85.2 for LLaMA3-8B. The rank-halved DoRA configuration also beats LoRA in each of those rows, although it is not identical to the same-rank comparison.

The multimodal results point in the same direction. With VL-BART, DoRA's average is 77.4 versus 76.5 for LoRA on image-text tasks, and 85.4 versus 83.5 on video-text tasks. On LLaVA-1.5-7B visual instruction tuning, the paper reports 67.6 for DoRA, compared with 66.9 for LoRA and 66.5 for full fine-tuning in that table. The authors also combine DoRA's directional update with VeRA. In the paper's MT-Bench table, the combined method improves over VeRA on both evaluated models and exceeds LoRA on LLaMA2-7B; on LLaMA-7B, its displayed 5.0 trails LoRA's 5.1 slightly. That is a compatibility result, not a uniform win over every baseline.

A useful way to read these numbers is that the decomposition appears to help across different tasks and model families under the paper's configurations. It does not prove that DoRA always wins. The experiments use selected datasets, hyperparameters, backbones, and comparison methods; several baseline values are taken from earlier work rather than rerun in one unified pipeline. The LLaVA table, for example, says the LoRA and full-fine-tuning checkpoints come from the earlier LLaVA work, while the DoRA result is evaluated in the paper's setup.

## The evidence stops at the adapter recipe

The paper is strongest as a controlled method comparison within its chosen fine-tuning setups. It is weaker as a guide to deployment cost. The claim of no added inference latency depends on merging the learned update before serving; it does not mean training is free, and it does not remove the memory needed to load the base model. QDoRA extends the idea to quantized fine-tuning, but that is a related configuration rather than proof that every quantized runtime will behave identically.

The official code repository is useful for studying and reproducing parts of the work, but its current README also documents Hugging Face PEFT and diffusion-model support. The repository identifies its code as NVIDIA Source Code License-NC, while the arXiv paper page identifies the manuscript as CC BY-NC-SA 4.0. Those licenses are separate: a permissive-looking software workflow does not automatically grant the same reuse terms for paper figures or text.

There is a broader lesson in the paper's design. Parameter efficiency is not only about reducing the number of trainable parameters. It is also about choosing which degrees of freedom the adapter gets to control. DoRA adds a very small explicit magnitude path so the low-rank direction update does not have to do every job.

## What to try first

- Compare PEFT methods at matched backbone, dataset, rank, learning-rate search, and evaluation protocol; the paper's gains are configuration-specific.
- Treat trainable-parameter percentage and training-memory cost as separate measurements. DoRA can keep parameter counts close to LoRA while still changing backpropagation memory.
- If inference simplicity matters, verify whether the implementation merges the adapter before serving rather than assuming every runtime has identical latency.
- For lower-rank experiments, check the rank-halved DoRA configuration separately; its result is not the same claim as full-rank DoRA versus full-rank LoRA.
- Start with the official PEFT implementation when experimenting, but inspect the exact version, quantization path, and model support instead of assuming every repository example matches the ICML paper.

## Links

- [Paper on arXiv (version 6)](https://arxiv.org/abs/2402.09353v6)
- [Versioned PDF](https://arxiv.org/pdf/2402.09353v6)
- [Official DoRA project page](https://nbasyl.github.io/DoRA-project-page/)
- [Official NVlabs implementation](https://github.com/NVlabs/DoRA)
- [Hugging Face PEFT DoRA documentation](https://huggingface.co/docs/peft/en/developer_guides/lora#weight-decomposed-low-rank-adaptation-dora)
- [CC BY-NC-SA 4.0 license for the paper](https://creativecommons.org/licenses/by-nc-sa/4.0/)
