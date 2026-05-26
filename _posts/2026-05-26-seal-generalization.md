---
layout: post
title: "Simulated Annealing in Early Layers Leads to Better Generalization"
short_title: "SEAL"
date: 2026-05-26
type: "Paper brief"
read_time: "6 min read"
venue: "CVPR 2023"
tags:
  - Generalization
  - Optimization
  - Transfer Learning
summary: "SEAL improves iterative training by perturbing early layers with short bursts of gradient ascent instead of resetting later layers, leading to better in-distribution accuracy and much stronger transfer behavior than LLF."
paper_url: "https://openaccess.thecvf.com/content/CVPR2023/html/Sarfi_Simulated_Annealing_in_Early_Layers_Leads_to_Better_Generalization_CVPR_2023_paper.html"
code_url: "https://github.com/amiiir-sarfi/SEAL"
---

## Why this paper matters

Many tricks that improve generalization in deep learning are expensive in a quiet way: they often require longer training, multiple generations of optimization, or carefully designed perturbations. Iterative learning methods are interesting because they try to turn that extra training into a regularizer rather than just more compute.

This paper matters because it questions where the useful perturbation should happen. Earlier work such as later-layer-forgetting, or LLF, improves generalization by repeatedly reinitializing later layers. SEAL asks whether the real gain comes from forcing stronger early representations instead, and whether there is a better way to do that.

## The bite

The key idea is simple: do not reset the later layers at all. Instead, briefly push the early layers in the wrong direction with gradient ascent, then let training cool back down with normal gradient descent.

The simulated annealing analogy is the point. A short heating phase perturbs the early representation, and the subsequent descent phase lets the model settle into a better solution. Compared with LLF, this tries to improve generalization without wrecking the features that later turn out to matter for transfer.

## How it works

SEAL follows the same broad iterative-training setup as LLF: training is split into generations, and each generation contains a fixed number of epochs. But the forgetting mechanism changes. LLF reinitializes later layers at the start of each generation, while SEAL performs a short stint of gradient ascent only on the early layers for a few epochs, then returns to standard gradient descent.

<figure>
  <img src="{{ '/assets/images/papers/seal/method-02.png' | relative_url }}" alt="Comparison figure showing LLF resetting later layers and SEAL applying gradient ascent then descent in early layers across generations." />
  <figcaption>Paper figure: SEAL replaces later-layer resets with a short ascent-then-descent cycle in early layers, keeping the later layers stable while still inducing useful forgetting.</figcaption>
</figure>

The paper's underlying claim is that early layers should stay more general and should not become overly specialized too early. By perturbing them intermittently, SEAL encourages the network to relearn difficult examples using simpler and more transferable features. Later layers continue with ordinary descent, so the network keeps useful information from previous generations instead of throwing it away.

The implementation detail that matters most is restraint. The ascent phase is short, the ascent learning rate is heavily reduced, and it is applied only to the early layers. This keeps the method from diverging while still giving the model a real perturbation rather than a purely symbolic one.

## What to look at in the results

The strongest part of the paper is not only the Tiny-ImageNet win. It is the contrast between in-distribution performance and transfer performance. LLF does improve the source task, but its learned features transfer poorly across the downstream datasets the authors test. SEAL improves both.

That matters because it supports the paper's central interpretation: later-layer resetting may help the target task partly by pushing high-level information downward, but it can also damage the more reusable structure that transfer learning depends on. SEAL seems to preserve that structure better.

<figure>
  <img src="{{ '/assets/images/papers/seal/results-05.png' | relative_url }}" alt="Results tables comparing SEAL, LLF, and normal training on few-shot transfer and Hessian-related analysis." />
  <figcaption>Paper figure: the transfer and few-shot results are the key evidence here, because they show SEAL outperforming LLF not just on the source task but also under harder distribution shifts.</figcaption>
</figure>

The paper also uses prediction depth and Hessian statistics to explain the behavior. SEAL achieves stronger prediction depth than both normal training and LLF, and it lands in flatter minima with no negative Hessian eigenvalues in their analysis. Even if you do not take those diagnostics as the whole story, they make the optimization picture more coherent.

## Practical takeaways

- If an iterative method improves the source task but hurts transfer, it may be making representations more brittle rather than more general.
- Where you apply forgetting matters just as much as whether you apply forgetting at all.
- Early-layer perturbation can act like a useful regularizer when it is brief and controlled.
- Generalization should be checked with transfer and few-shot evaluations, not only the original benchmark.
- When reading the paper, focus on the comparison with LLF: the real contribution is better transfer behavior, not just slightly better top-line accuracy.

## Links

- [Paper page at CVF Open Access](https://openaccess.thecvf.com/content/CVPR2023/html/Sarfi_Simulated_Annealing_in_Early_Layers_Leads_to_Better_Generalization_CVPR_2023_paper.html)
- [arXiv version](https://arxiv.org/abs/2304.04858)
- [Official code on GitHub](https://github.com/amiiir-sarfi/SEAL)
