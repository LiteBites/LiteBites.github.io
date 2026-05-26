---
layout: post
title: "Adding Conditional Control to Text-to-Image Diffusion Models"
short_title: "ControlNet"
date: 2025-05-21
type: "Paper brief"
read_time: "7 min read"
venue: "ICCV 2023"
tags:
  - Generative Models
  - Diffusion Models
summary: "ControlNet adds spatial conditioning to pretrained text-to-image diffusion models while protecting the original model's generation quality through zero-initialized control branches."
paper_url: "https://openaccess.thecvf.com/content/ICCV2023/html/Zhang_Adding_Conditional_Control_to_Text-to-Image_Diffusion_Models_ICCV_2023_paper.html"
code_url: "https://github.com/lllyasviel/ControlNet"
---

## Why this paper matters

Text-to-image diffusion models are good at turning prompts into images, but text alone is a weak interface for precise spatial control. If a user wants the generated image to follow an edge map, a depth map, a segmentation mask, or a human pose, the model needs conditioning information that describes structure directly.

ControlNet addresses this gap without throwing away the value of a strong pretrained diffusion model. The practical question is simple: can we add task-specific control to Stable Diffusion while keeping the base model stable and useful?

## The bite

The key idea is to attach a trainable control branch to a locked pretrained diffusion model. The locked branch preserves the image generation capability that was already learned. The trainable branch learns how to inject external conditions, such as edges or poses, into the generation process.

The important stabilizing trick is zero convolution. ControlNet connects the conditional branch to the main model through convolution layers initialized to zero. At the beginning of training, this means the new branch does not immediately disturb the pretrained model. The control signal is allowed to enter gradually as the zero-initialized parameters learn useful values.

## How it works

ControlNet starts from a pretrained text-to-image diffusion model and makes a trainable copy of relevant encoder blocks. The original model is locked, while the copied branch receives both image features and conditional features. Its outputs are added back into the main model through skip-style connections.

<figure>
  <img src="{{ '/assets/images/papers/controlnet/method-03.png' | relative_url }}" alt="ControlNet architecture showing a locked Stable Diffusion U-Net and a trainable conditional copy connected through zero convolutions." />
  <figcaption>Paper figure: ControlNet works by attaching a trainable conditional path to a locked diffusion backbone, using zero-initialized connections so control can be learned without destabilizing the base model.</figcaption>
</figure>

Zero convolution is what makes this setup safer than directly fine-tuning or randomly attaching a new branch. Since the connecting layers initially output zero, the first behavior remains close to the original pretrained model. After the first updates, the control branch begins to participate in training without injecting arbitrary random noise into the generation path.

This framing also explains why ControlNet can support many kinds of conditions. The external map changes, but the pattern is the same: preserve the pretrained diffusion model, learn a condition-aware branch, and use controlled feature injection to guide the final image.

## What to look at in the results

The most useful results are the examples where the same text prompt is constrained by different structural inputs. These show whether the method really follows the conditioning map rather than merely producing a plausible image.

<figure>
  <img src="{{ '/assets/images/papers/controlnet/results-01.png' | relative_url }}" alt="Qualitative ControlNet examples showing image generation guided by conditions such as Canny edges and human pose." />
  <figcaption>Paper figure: these examples matter because they show the practical payoff of ControlNet—different condition maps can steer composition directly instead of relying on prompt wording alone.</figcaption>
</figure>

Also look for the balance between controllability and image quality. A method that follows an edge map but damages the base model's generation ability would be less useful. ControlNet's design is valuable because it tries to gain control without sacrificing the pretrained model's strengths.

## Practical takeaways

- Text prompts are not enough when spatial layout matters.
- A locked pretrained model can be extended instead of fully fine-tuned.
- Zero-initialized connections help new conditioning branches start safely.
- ControlNet is best understood as controlled feature injection around a reusable diffusion backbone.
- When reading the paper, focus on how different condition maps change the generated image while preserving quality.

## Links

- [Paper page at CVF Open Access](https://openaccess.thecvf.com/content/ICCV2023/html/Zhang_Adding_Conditional_Control_to_Text-to-Image_Diffusion_Models_ICCV_2023_paper.html)
- [Official code on GitHub](https://github.com/lllyasviel/ControlNet)
