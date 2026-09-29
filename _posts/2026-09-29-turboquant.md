---
layout: post
title: "TurboQuant: Online Vector Quantization with Near-optimal Distortion Rate"
short_title: "TurboQuant"
date: 2026-09-29
type: "Paper brief"
read_time: "6 min read"
venue: "arXiv preprint (2025)"
tags:
  - Vector Quantization
  - KV Cache
  - Nearest Neighbor Search
summary: "TurboQuant rotates vectors before scalar quantization and adds a residual sketch when unbiased inner products matter; its theory and two application tests need different readings."
card_image: "/assets/images/papers/turboquant/recall-1536.png"
card_image_alt: "Figure 5(b): nearest-neighbor recall versus candidate count for TurboQuant, product quantization, and RabitQ on 1536-dimensional embeddings."
paper_url: "https://arxiv.org/abs/2504.19874v1"
---

## Why a smaller vector is not enough

A vector database stores many embeddings and compares them with query vectors. A language model similarly keeps keys and values from earlier tokens in its KV cache. Fewer bits per vector could reduce the data that must be stored or moved. But the compressed vector still needs to preserve the geometry used by the application: reconstruction accuracy for one job, inner products for another.

[TurboQuant](https://arxiv.org/abs/2504.19874v1), a 2025 arXiv preprint, tackles both jobs with a data-oblivious quantizer. Here *online* means it can encode a new vector without fitting a codebook to the particular dataset first. It does **not** mean rotation, encoding, decoding, and application-level serving cost nothing.

## Rotate first, then quantize each coordinate

The first variant, **TurboQuant-mse**, starts with a shared random rotation of a unit-length vector. The rotated vector's coordinates have a known marginal distribution—a scaled Beta distribution that resembles a Gaussian in high dimensions. Instead of learning a separate codebook from the vectors to be compressed, the method precomputes scalar quantization centroids for the chosen dimension and bit width. It replaces each rotated coordinate with the index of its nearest centroid. Decoding retrieves those centroids and reverses the rotation.

That is the useful simplification: a vector-level geometric problem becomes a set of scalar decisions after the rotation. The rotation and codebooks still require setup; *data-oblivious* means the codebooks do not have to be trained on the eventual dataset. The paper's reconstruction guarantee concerns **expected squared error** over the quantizer's randomness for unit vectors, not a deterministic error bound for each encoded vector.

A low reconstruction error does not automatically make an **unbiased** inner-product estimate. At low bit widths, the MSE-optimized variant can systematically shift the estimated similarity between a stored vector and a query. Figure 1 and Section 4.1 show this distinction empirically; at higher bit widths the MSE variant's bias shrinks, so the product variant is not the best choice for every metric and budget.

## Spend one bit on the residual

For inner products, **TurboQuant-prod** uses two stages. It spends *b − 1* bits per coordinate on the MSE reconstruction, computes the residual—the part of the original vector that reconstruction missed—and spends one more bit per coordinate on a Quantized Johnson–Lindenstrauss (QJL) sign sketch of that residual. Reconstruction combines the first estimate with the residual correction. The algorithm also stores the residual's norm.

The paper proves an *expected* unbiased inner-product estimator under its stated model and gives a squared-error bound that decreases with bit width. That claim is about the estimator, not a promise that every approximate neighbor search or generated answer matches full precision. In practice, a nominal *b* bits per channel also leaves out the residual norm and shared rotation, projection, and codebook storage when accounting for an entire system.

## What “near-optimal” does—and does not—establish

The paper derives an information-theoretic lower bound and compares it with its quantizer's upper bound. Its stated MSE upper-bound constant is approximately **2.7 times** the asserted lower-bound constant, with both scaling as **4⁻ᵇ** for *b* bits per coordinate. This is a claim about **expected reconstruction distortion**, not a 2.7× speedup, memory reduction, or generation-quality result. The lower-bound theorem says that a difficult input *exists* for a quantizer; it does not say all inputs have that much error.

There is also a reason to treat the paper's **all-dimensions** wording cautiously. As written, its positive lower bound at dimension *d = 1* and *b = 1* cannot hold: a one-dimensional unit sphere has just two points, which one bit can encode exactly. This edge case does not negate the higher-dimensional experiments or the construction, but it means the stated universal lower-bound proof should not be presented as independently settled without further mathematical review.

## Two applications, different evidence

For **KV-cache quantization**, Figure 4 tests needle-in-a-haystack retrieval with Llama-3.1-8B-Instruct across contexts from **4k to 104k tokens**. Under the reported setting where compressed methods use **25% of the full cache memory**, TurboQuant and the full-precision model both score **0.997**. That is equality on this particular retrieval test—not a finding of identical generation quality everywhere.

The LongBench table gives a more qualified picture. On **Llama-3.1-8B-Instruct**, the average is **50.06** for the 16-bit full cache, **49.44** for TurboQuant at 2.5 nominal bits per channel, and **50.06** at 3.5 bits. KIVI at 5 bits scores **50.16** in the same table. On **Ministral-7B-Instruct**, the reported full-cache and 2.5-bit TurboQuant averages are **49.89** and **49.62**; a 3.5-bit Ministral row is not shown. These rounded averages do not come with uncertainty intervals, so they do not prove statistical equivalence or uniform superiority. Section 4.3 describes a length-balanced LongBench-E selection, while Table 1's caption says LongBench-V1; keep that naming discrepancy in mind when reproducing the comparison.

The 2.5-bit figure is a mixed-precision allocation: **32 of 128 channels** use 3 bits and **96** use 2. It describes encoded channel precision, not a measured reduction of total GPU memory including model weights and other state.

For **nearest-neighbor search**, the paper tests whether the true highest-inner-product item appears within the approximate top-*k* results. Its Figure 5 compares TurboQuant with product quantization (PQ) and RabitQ at 2 and 4 bits on GloVe and two DBpedia/OpenAI3 embedding sizes. The excerpt below shows the **1,536-dimensional** case: TurboQuant's curves lead their same-bit comparison curves at the small candidate counts where recall has room to differ; the curves converge near one as *k* grows. One panel is not evidence that every corpus, scale, or implementation behaves the same way.

<figure>
  <img src="{{ '/assets/images/papers/turboquant/recall-1536.png' | relative_url }}" width="1440" height="1296" loading="lazy" decoding="async" alt="Recall@1@k against Top-k candidate count on 1536-dimensional DBpedia/OpenAI3 embeddings. Six curves compare TurboQuant, PQ, and RabitQ at two and four bits. TurboQuant leads its same-bit baselines at the smallest k; all curves approach one by larger k." />
  <figcaption>Zandieh, Daliri, Hadian, and Mirrokni, <a href="https://arxiv.org/abs/2504.19874v1">TurboQuant</a>, Figure 5(b) only: the OpenAI3, 1,536-dimensional panel. Rasterized at 2× from <code>experiments/nearest_neighbor/recall-1536.pdf</code> in the versioned arXiv source, without changing its plotted content; <a href="https://creativecommons.org/licenses/by/4.0/">CC BY 4.0</a>. Recall@1@k asks whether the exact top neighbor appears among the approximate top <em>k</em>. <a href="{{ '/assets/images/papers/turboquant/recall-1536.png' | relative_url }}">Open the full-resolution panel.</a></figcaption>
</figure>

The paper also gives striking 4-bit **quantization-time** rows. It does not fully specify comparable one-time setup and timing scope for each method, however. Those rows should not be turned into an end-to-end indexing, search-latency, or production-throughput speedup.

## Before choosing a compressor

- **Name the objective.** Low reconstruction MSE and unbiased inner products call for different TurboQuant variants; test the metric your application uses.
- **Count the whole representation.** Include stored norms, shared transforms, codebooks, and any outlier treatment—not only nominal bits per channel.
- **Match the evaluation.** Needle retrieval, LongBench generation, and nearest-neighbor recall test different behavior. Check per-task results rather than substituting one headline score.
- **Benchmark the actual pipeline.** Measure encoding, decoding, indexing, memory, and query latency under your own dimensions and hardware before claiming a systems win.

## Links

- [TurboQuant: versioned arXiv record](https://arxiv.org/abs/2504.19874v1)
- [TurboQuant: full paper, algorithms, theorems, and figures](https://arxiv.org/pdf/2504.19874v1)
- [Versioned source archive containing Figure 5(b)](https://export.arxiv.org/src/2504.19874v1)
- No author-maintained implementation revision matching this paper was verified; no code link is asserted.
