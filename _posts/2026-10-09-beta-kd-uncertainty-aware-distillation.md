---
layout: post
title: "Uncertainty-Aware Knowledge Distillation for Multimodal Large Language Models"
short_title: "Beta-KD"
date: 2026-10-09
type: "Paper brief"
read_time: "7 min read"
venue: "CVPR 2026"
tags:
  - Knowledge Distillation
  - Multimodal Models
  - Vision-Language Models
  - Bayesian Learning
summary: "Beta-KD learns how strongly a multimodal student should follow its teacher, but its gains depend on the loss and comparison being examined."
card_image: "/assets/images/papers/beta-kd-uncertainty-aware-distillation/method-01.png"
card_image_alt: "Beta-KD diagram comparing fixed data-and-teacher supervision with input-dependent weights on teacher-student alignment losses."
paper_url: "https://openaccess.thecvf.com/content/CVPR2026/papers/Sun_Uncertainty-Aware_Knowledge_Distillation_for_Multimodal_Large_Language_Models_CVPR_2026_paper.pdf"
code_url: "https://github.com/Jingchensun/beta-kd"
---

## When the teacher should not have a fixed vote

A small vision-language model can learn from two sources at once: answers in its training data and a larger teacher model's predictions or internal features. The usual recipe adds a distillation loss to the student's answer-prediction loss and assigns it a fixed weight. But not every example deserves the same amount of teacher guidance. A teacher can be uncertain, a label can be noisy, and different distillation losses can have incompatible scales.

**Beta-KD** asks whether that weight can be learned rather than searched manually. Its interesting contribution is not a new teacher or a new vision encoder. It is a way to balance *data supervision* against one or more teacher–student alignment objectives while training a smaller multimodal model. The paper tests task-wide weights and weights predicted separately for each input.

## A precision-like weight, not a correctness oracle

The authors treat a mismatch between student and teacher activations as an energy: better agreement has lower energy. In their Bayesian construction, the teacher supplies a prior over student activations. A positive weight called **beta** controls how concentrated that prior is. Large beta makes the student match the teacher more strongly; small beta relaxes that pressure. The student's ordinary cross-entropy loss still trains it on the target answers.

Taking the negative log of this prior gives a weighted distillation loss *and* a normalization term. The paper approximates the latter locally, yielding a training objective that can be read as **answer loss + beta × teacher–student discrepancy − a log-beta term**. That last term changes how a learned beta is optimized; it is not an additional accuracy measurement. The derivation assumes a suitable local energy minimum and curvature, so this is an approximation under a model of teacher guidance, not proof that a model can measure a teacher's true error probability.

There are two ways to choose beta. **Task-level Beta-KD** learns positive weights shared across examples for each supervision channel. **Instance-level Beta-KD** uses a small network to predict the weights from each input. Student and weighting network are optimized together, replacing a manual search over fixed combinations. Different teacher signals, such as output distributions and intermediate features, can receive separate weights. See the [method and equations](https://arxiv.org/html/2603.21426v1#S3.SS2).

<figure>
  <img src="{{ '/assets/images/papers/beta-kd-uncertainty-aware-distillation/method-01.png' | relative_url }}" alt="On the left, data and a larger teacher supervise a small language model through separate losses. On the right, an input-dependent weighting network assigns positive beta weights to two teacher–student alignment channels while answer cross-entropy trains the student." width="1498" height="744" loading="lazy" decoding="async" />
  <figcaption>Figure 1 by Jingchen Sun and coauthors, <a href="https://arxiv.org/html/2603.21426v1#S1.F1"><em>Uncertainty-Aware Knowledge Distillation for Multimodal Large Language Models</em>, arXiv v1</a>. Reproduced unchanged under <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>. The right panel is the instance-level variant; the paper also evaluates shared task-level weights. <a href="{{ '/assets/images/papers/beta-kd-uncertainty-aware-distillation/method-01.png' | relative_url }}">Open the full-resolution figure.</a></figcaption>
</figure>

## What actually changes in training

For the main MobileVLM V2 experiments, the paper uses a 7B-parameter teacher and a 1.7B-parameter student. It freezes the vision encoder and tokenizer during distillation and fine-tunes the language backbone. This matters for attribution: Beta-KD changes the weighting of supervision while the rest of this training setup is held by the authors' chosen comparisons; it does not shrink an already trained teacher at inference time. The early loss-design and weighting experiments use ScienceQA, while the broader evaluation uses mixed image–text transfer data and six benchmarks ([experiment setup](https://arxiv.org/html/2603.21426v1#S4.SS1)).

The loss itself also matters. Matching teacher and student output probabilities by cosine distance is one tested choice; other rows use KL variants or feature-level alignment. Beta-KD is a weighting framework around those objectives, not one fixed loss that can be credited with every improvement. When an author row replaces the underlying loss *and* adds Beta-KD, those are two changes; compare it against the matching loss baseline before assigning the gain to weighting.

## Read the comparisons in pairs

The cleanest broad comparison in [Table 4](https://arxiv.org/html/2603.21426v1#S4.T4) holds each loss family fixed. The authors' reproduced **Align-KD** row reports a six-benchmark average of **63.4**; adding instance-level Beta-KD reports **64.6**. The separate **Cosine KD** row also reports **63.4**; adding instance-level Beta-KD reports **65.5**. These are reported averages across the paper's six benchmark metrics, with the MME score divided by 20 before averaging. They are not gains from changing Align-KD directly into the final Cosine-plus-Beta configuration.

<div class="paper-results-scroll" role="region" aria-labelledby="beta-kd-results-caption" tabindex="0">
  <table class="paper-results-table">
    <caption id="beta-kd-results-caption">Selected matched-loss pairs from paper Table 4: reported six-benchmark average (higher is better)</caption>
    <thead><tr><th scope="col">Loss-family setting</th><th scope="col">Fixed/no Beta-KD</th><th scope="col">Instance Beta-KD</th></tr></thead>
    <tbody>
      <tr><th scope="row">Align-KD</th><td>63.4</td><td>64.6</td></tr>
      <tr><th scope="row">Cosine KD</th><td>63.4</td><td>65.5</td></tr>
    </tbody>
  </table>
</div>
<p class="paper-results-note">Author-reported rows for the MobileLLaMA 1.4B-backbone setting; the two loss families are separate comparisons. The MME component is normalized to the other metrics' scale. Scroll horizontally on a narrow screen.</p>

The within-family pattern supports the value of adaptive weighting *in this setup*. It does not mean every distillation objective improves. In the [three-loss ScienceQA ablation, Table 3](https://arxiv.org/html/2603.21426v1#S4.T3), **CE + total-variation distance + feature distillation** scores **51.8** overall VQA accuracy with manual weights and **49.0** with instance-level Beta-KD; image-question accuracy likewise falls from **59.7** to **56.8**. The MSE-on-probabilities combination also declines against its manual baseline. Those counterexamples qualify the paper's broad “consistently outperforms” language. They are a useful check against treating a precision-like weight as universally reliable.

A separate [Table 5](https://arxiv.org/html/2603.21426v1#S4.T5) tests LLaVA-style Qwen students under a Qwen2.5-3B teacher: for the 0.5B student, TextVQA rises from **52.0%** with LLaVA-KD to **54.9%** with instance-level Beta-KD; ScienceQA rises from **60.6%** to **64.4%**. This is evidence beyond one student architecture, not an apples-to-apples comparison with MobileVLM's Table 4 averages. The paper's [training-efficiency table](https://arxiv.org/html/2603.21426v1#S4.T6) reports **1.82 iterations/s** and **47.5 GB** GPU memory for Align-KD versus **1.85 iterations/s** and **47.6 GB** for its instance-weighted variant. That narrow comparison suggests modest *weighting-module* overhead, not a measured reduction in teacher computation or end-to-end deployment cost.

## Where the uncertainty claim stops

The learned beta is a training weight inferred through the chosen objective, not a separately validated probability that a teacher prediction is correct. The paper's plotted entropy and weight trajectories illustrate its proposed interpretation, but do not establish calibration on known teacher mistakes. The local approximation behind the log-beta term is also conditional on the selected energy and curvature assumptions. Neither result licenses a blanket claim that the method detects all noisy labels or teacher hallucinations.

The six-benchmark averages are author-reported, with no independent replication here. A sensible follow-up would hold the same teacher, student, transfer data, and distillation objective fixed; then compare tuned fixed weights, task-level weights, and instance-level weights across multiple runs. Report accuracy per benchmark, uncertainty variation, and compute for the *whole* training run. That is a proposed test, not one performed in this post.

## Checks to carry into another distillation run

- Compare adaptive weights against a tuned **fixed-weight baseline for the same loss**, not a different divergence or a larger model.
- Keep label supervision in the accounting: a reduced teacher weight does not remove the cross-entropy training signal.
- Inspect losses that regress, not only the best cosine-distance row; Table 3 shows where instance-level weighting can hurt.
- Measure whether learned weights track *actual teacher errors* before calling them calibrated uncertainty.
- Separate a small weighting-network overhead from the cost of repeatedly running the teacher during distillation.

## Links

- [Official CVPR 2026 proceedings entry](https://openaccess.thecvf.com/content/CVPR2026/html/Sun_Uncertainty-Aware_Knowledge_Distillation_for_Multimodal_Large_Language_Models_CVPR_2026_paper.html) and [paper PDF](https://openaccess.thecvf.com/content/CVPR2026/papers/Sun_Uncertainty-Aware_Knowledge_Distillation_for_Multimodal_Large_Language_Models_CVPR_2026_paper.pdf)
- [Versioned arXiv HTML and Figure 1 (v1)](https://arxiv.org/html/2603.21426v1)
- [Author-linked Beta-KD repository](https://github.com/Jingchensun/beta-kd) (no paper-evaluated commit or tagged release verified; its current README's summary numbers differ from Table 4)
- [Figure reuse license: CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)
