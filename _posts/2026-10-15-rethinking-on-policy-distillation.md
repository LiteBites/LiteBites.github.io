---
layout: post
title: "Rethinking On-Policy Distillation of Large Language Models: Phenomenology, Mechanism, and Recipe"
short_title: "When a Stronger Teacher Fails to Teach"
date: 2026-10-15
type: "Paper brief"
read_time: "7 min read"
venue: "arXiv preprint, v2 (2026)"
tags:
  - Knowledge Distillation
  - LLM Reasoning
  - Post-Training
summary: "A stronger math-reasoning teacher can fail at on-policy distillation; local token agreement and transferable capabilities help explain why."
card_image: "/assets/images/papers/rethinking-on-policy-distillation/success-vs-failure.png"
card_image_alt: "Six plots compare a successful JustRL-1.5B teacher with a failing R1-Distill-7B teacher for the same student: math accuracy rises only with JustRL, alongside stronger token overlap and a smaller entropy gap."
paper_url: "https://arxiv.org/abs/2604.13016"
code_url: "https://github.com/Thinking-Space/Rethinking-OPD"
---

A teacher can score better on a math test and still fail to improve its student. In a separate reverse-distillation test, the student even loses gains it had already made. Those are the uncomfortable results at the center of **Rethinking On-Policy Distillation of Large Language Models**. Yaxuan Li and coauthors ask a more useful question than “Which teacher is strongest?”: **At the points where the student actually reasons, can it learn from this teacher?**

## Why the strongest teacher can be the wrong one

In ordinary, *off-policy* distillation, the student learns from responses produced in advance by the teacher. In **on-policy distillation (OPD)**, the student generates its own solution first. The teacher then scores the student's next-token choices at each student-generated prefix, and training nudges the student toward the teacher's token distribution there. The teacher is not simply providing a polished answer; it must give useful guidance on the student's sometimes awkward path. [Paper, §2](https://arxiv.org/html/2604.13016v2#S2).

That distinction makes standalone teacher accuracy an incomplete selection rule. Two models can solve similar numbers of problems while assigning very different probabilities to the next steps on *this student's* attempted solutions. The authors propose two conditions for productive OPD: compatible **thinking patterns**—operationalized here partly by agreement among high-probability next tokens—and a teacher with a capability the student can gain. The second condition, “new knowledge,” is an interpretation of controlled model-family comparisons, **not a directly measured quantity**.

## The reversal: bigger is not necessarily more teachable

The clearest experiment fixes a DeepSeek-R1-Distill-Qwen-1.5B student and changes only the teacher. JustRL-1.5B is a post-RL descendant of that student; DeepSeek-R1-Distill-Qwen-7B is larger and scores slightly better as a standalone teacher. Yet in the authors' math experiments, distillation from JustRL improves the student, while distillation from the 7B teacher does not. The successful student closes **more than 80% of its initial accuracy gap to its teacher** in this comparison. This is a gap-recovery measure, not an 80% absolute accuracy score. [§4.1 and Figure 6](https://arxiv.org/html/2604.13016v2#S4.F6).

The plots report **avg@16 accuracy**—mean correctness over 16 sampled solutions per problem; **higher is better**—on AIME 2024, AIME 2025, and AMC 2023. The paper samples at temperature 0.7 and top-p 0.95 for validation. This is *not* pass@16, which would count a problem as solved if *any* sample succeeded. The benchmark panels have different vertical scales, so compare the runs *within* each panel rather than comparing line heights across tasks. The lower plots are training diagnostics, not extra accuracy measures.

<figure>
  <img src="{{ '/assets/images/papers/rethinking-on-policy-distillation/success-vs-failure.png' | relative_url }}" alt="Six line charts for one R1-Distill-1.5B student. Top row: avg@16 accuracy on AIME 2024, AIME 2025, and AMC 2023 climbs with JustRL-1.5B as teacher, but stays nearly flat with R1-Distill-7B. Bottom row: the successful run's shared top-token ratio climbs, its shared-token advantage approaches zero, and its absolute entropy gap narrows; the failing run largely stalls." loading="lazy" />
  <figcaption>Li et al., <a href="https://arxiv.org/html/2604.13016v2#S4.F6">Figure 6, arXiv v2</a>. The same student meets two teachers with different training histories. Original paper figure rasterized from the complete SVG, without cropping; reproduced under <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>. <a href="{{ '/assets/images/papers/rethinking-on-policy-distillation/success-vs-failure.png' | relative_url }}">Open the full-resolution image</a> for readable labels.</figcaption>
</figure>

A second, deliberately backward test strengthens the warning. Starting with the post-RL JustRL-1.5B *as the student*, the authors distill it toward either its own pre-RL 1.5B ancestor or the larger pre-RL 7B model. Both runs regress to roughly the pre-RL level, even though the 7B teacher scores slightly higher than the starting student. Model size and test score did not preserve the student's learned improvement. [§3.3 and Figure 5](https://arxiv.org/html/2604.13016v2#S3.F5).

## What happens on the student's path

To inspect the mechanism, the paper tracks the **overlap ratio**: at a student-generated prefix, what fraction of the student's top-*k* candidate tokens are also in the teacher's top-*k*? The default is *k* = 16. In Figure 6, overlap grows during successful training; in the failing run it largely stalls. The authors also track a shared-token advantage and the difference between the models' next-token entropies. Those measures move toward agreement in the successful run. In its appendix, the paper reports that the shared tokens carry roughly **97–99% of probability mass** for both models in this comparison—not just a coincidental overlap of token names. [§2.3](https://arxiv.org/html/2604.13016v2#S2.SS3), [§4.1](https://arxiv.org/html/2604.13016v2#S4.SS1), [Appendix B.1](https://arxiv.org/html/2604.13016v2#A2.SS1).

An ablation goes beyond correlation. When training updates are restricted to tokens in the *intersection* of the two top-16 sets, they retain nearly the full improvement from updating on all student top-16 tokens. Updating on their non-overlapping tokens is much weaker in the tested configuration. That supports the authors' explanation that usable supervision concentrates where student and teacher already have a shared high-probability vocabulary. It does not prove overlap alone guarantees success: in a separate prompt-content experiment, **accuracy improves while the overlap ratio falls**, because probability mass becomes more concentrated on fewer shared tokens. [§4.2](https://arxiv.org/html/2604.13016v2#S4.SS2), [§5.2](https://arxiv.org/html/2604.13016v2#S5.SS2).

## Two repairs, with different trade-offs

If a student begins too far from its teacher, the first repair is a **cold start**: supervised fine-tune it on teacher-generated math solutions, then run OPD on fresh student rollouts. In the authors' Qwen experiment, the teacher generates 200,000 responses for this initial stage, followed by OPD on approximately 30,000 other prompts; starting from the fine-tuned student beats starting from the base student with the same teacher and OPD prompts. The head start also uses extra data and training, so this is not a claim that OPD alone became more compute-efficient. [§5.1 and Figure 8](https://arxiv.org/html/2604.13016v2#S5.F8).

The second repair changes the **prompts**. Matching a teacher's post-training answer format improves results even when the underlying math questions are held fixed. Matching prompt *content* also helps on the tested sets, but drives the student's entropy lower; the authors caution against relying only on prompts the teacher already saw during its post-training. A mixed prompt set is their suggested direction, not an independently proven best recipe. [§5.2](https://arxiv.org/html/2604.13016v2#S5.SS2).

## Where dense guidance stops helping

Every generated token can receive a teacher signal, but long trajectories are not automatically better. In a response-length comparison, maximum lengths of **3K and 7K tokens** work best; **10K and 15K** plateau or become unstable in that setup. The teacher's advantage when continuing a student-generated solution also shrinks from **+0.37 accuracy at a 1K-token prefix to +0.02 at a 16K prefix**, on the authors' selected long math rollouts. Those figures are accuracy differences under a particular continuation test—not a general-purpose cutoff for all reasoning traces. [§6.1](https://arxiv.org/html/2604.13016v2#S6.SS1).

The experiments are all in mathematical reasoning. The same teacher-selection conditions have **not been established here for coding, open-ended generation, or multi-turn agents**. Nor does the paper directly isolate pre-training data as the source of the teacher's supposedly new capability. Its proposal that some failing runs have cancelling token-level gradients is explicitly a **hypothesis left for future work**, not a demonstrated mechanism. [§6.2](https://arxiv.org/html/2604.13016v2#S6.SS2), [§8](https://arxiv.org/html/2604.13016v2#S8).

## Before choosing a teacher

1. **Test the pair, not just the teacher.** Compare outcomes with the *same student, prompts, and evaluation protocol*; a higher teacher score alone did not predict the OPD result here.
2. **Watch local agreement early.** Measure top-*k* overlap, probability mass on shared tokens, and entropy gap on student rollouts; don't treat one overlap count as a universal success threshold.
3. **Change the starting point if guidance cannot land.** Try a teacher-rollout cold start, but count its added data and supervised-training cost in any comparison.
4. **Check prompt fit and trace length.** Test formats familiar to the teacher and monitor whether long student prefixes make its guidance unreliable; avoid assuming the paper's math-specific length range transfers to another task.

The paper's lasting lesson is not “always pick the smaller teacher.” It is that *teaching depends on what the teacher knows at the student's own next step*—and on whether following that guidance leaves the student with something it did not already have.

## Links

- [Paper and version history](https://arxiv.org/abs/2604.13016)
- [Full paper, arXiv v2](https://arxiv.org/html/2604.13016v2)
- [Authors' code and reproduction notes](https://github.com/Thinking-Space/Rethinking-OPD)
- [Related LiteBites Paper Bite: uncertainty-aware multimodal distillation](https://litebites.github.io/posts/beta-kd-uncertainty-aware-distillation/) — a different distillation question.
