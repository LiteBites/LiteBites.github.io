---
layout: post
title: "Efficient Memory Management for Large Language Model Serving with PagedAttention"
short_title: "PagedAttention"
date: 2026-08-14
type: "Paper brief"
read_time: "6 min read"
venue: "SOSP 2023"
tags:
  - LLM Serving
  - Systems
  - Memory Management
  - Inference
summary: "PagedAttention treats the key-value cache like virtual memory, letting vLLM allocate and share fixed-size blocks on demand so more requests fit into each serving batch."
card_image: "/assets/images/papers/pagedattention/method-01.png"
card_image_alt: "PagedAttention method diagram"
paper_url: "https://dl.acm.org/doi/10.1145/3600006.3613165"
project_url: "https://vllm.ai/"
code_url: "https://github.com/vllm-project/vllm"
---

## Why this paper matters

Large language model serving is expensive partly because autoregressive generation leaves GPUs underused. Each request produces one token at a time, so serving systems need to batch many requests together to use the hardware efficiently. The batch size, however, is often limited by memory rather than compute.

The main pressure comes from the key-value cache, or KV cache. It stores attention keys and values for every token already seen by the model, grows as generation continues, and has an unknown final size. Earlier systems reserved contiguous memory for a request's possible maximum length. The paper's profiling shows that only 20.4% to 38.2% of this reserved KV-cache memory held actual token states in the evaluated baselines; the rest was lost to reservation and fragmentation.

This paper matters because it reframes that allocation problem using a mature systems idea. Instead of forcing every sequence into one contiguous region, it makes the KV cache behave more like virtual memory.

## The bite

The key idea is **PagedAttention**: split each sequence's KV cache into fixed-size logical blocks and map them to physical GPU blocks that do not need to be contiguous. A block table performs the translation, much like a page table maps virtual pages to physical memory.

That change removes the need to reserve space for a sequence's maximum possible length. Physical blocks are allocated only when new tokens need them, so waste is limited mainly to unused positions in the final block. Because all physical blocks have the same size, the allocator also avoids the external fragmentation created by differently sized contiguous chunks.

The same indirection lets multiple sequences point to shared blocks. With reference counts and copy-on-write, parallel samples or beam-search branches can reuse a common prompt cache until their token histories diverge. Sharing therefore applies not only within one decoding request but also across requests with a common prefix.

## How it works

vLLM combines PagedAttention with a scheduler and KV-cache manager. For each request, the manager tracks logical blocks in token order and maps them to physical blocks on the GPU. Before a decoding iteration, the scheduler chooses requests for the batch and allocates any newly required blocks. A custom attention kernel then gathers keys and values through the block tables and writes the new token states into their assigned locations.

<figure>
  <img src="{{ '/assets/images/papers/pagedattention/method-01.png' | relative_url }}" alt="PagedAttention diagram showing one query vector attending to key and value vectors stored in three non-contiguous memory blocks." />
  <figcaption>Paper figure: PagedAttention keeps a sequence logically continuous while its key and value vectors live in non-contiguous physical blocks.</figcaption>
</figure>

The memory manager also handles pressure when GPU blocks run out. vLLM preempts all sequences belonging to a request together, because resuming computation requires their complete token state to be present. It can either swap the evicted KV blocks to CPU memory or discard and recompute them later. Recompute is cheaper than replaying generation token by token: the existing prompt and generated tokens can be processed together in one prompt-phase pass. The paper finds that recomputation is preferable for small blocks, while swapping becomes more competitive for larger transfers.

A block's size creates another trade-off. Small blocks reduce internal fragmentation and make fine-grained sharing easier, but they expose less parallelism and create many small transfers. Large blocks improve hardware utilization while wasting more space on short sequences. The ablation selects 16 tokens as the default because it performs well on both the longer ShareGPT trace and the shorter Alpaca trace.

This is not a free abstraction. Block-table lookups and non-contiguous access make the PagedAttention kernel 20–26% slower than the paper's highly optimized FasterTransformer attention kernel in a microbenchmark. The end-to-end gain comes from fitting more requests into a batch, not from making an individual attention operation faster.

## What to look at in the results

The central result is the point where latency suddenly rises as incoming request rate exceeds a system's serving capacity. Across OPT-13B, OPT-66B, and OPT-175B on synthetic traces derived from ShareGPT and Alpaca lengths, vLLM moves that saturation point to the right. The paper reports 2–4× higher throughput at a similar latency than FasterTransformer and Orca overall.

<figure>
  <img src="{{ '/assets/images/papers/pagedattention/results-01.png' | relative_url }}" alt="Six line charts comparing normalized latency against request rate for vLLM, FasterTransformer, and three Orca memory-allocation variants across OPT models and ShareGPT or Alpaca traces." />
  <figcaption>Paper figure: vLLM sustains higher request rates before normalized latency rises sharply, especially for longer ShareGPT sequences and memory-constrained configurations.</figcaption>
</figure>

Figure 12 is useful because it also shows where the advantage narrows. For OPT-175B on the shorter Alpaca workload, Orca's stronger variants can already batch many requests, making the system more compute-bound and reducing the benefit of better memory management. PagedAttention helps most when memory is the real bottleneck.

The baseline design matters when reading these curves. FasterTransformer is paired with a custom dynamic-batching scheduler. Orca is represented by three allocator variants: one reserves the maximum sequence length, one rounds output capacity to a power of two, and an infeasible oracle knows each final output length in advance. vLLM sustaining higher rates than the oracle variant is useful evidence that paging does more than estimate lengths more accurately: it removes external fragmentation and enables sharing.

The complex-decoding results strengthen the systems argument. On the Alpaca trace, KV-block sharing saves 6.1%–9.8% of memory for parallel sampling and 37.6%–55.2% for beam search. On ShareGPT, the reported ranges rise to 16.2%–30.5% and 44.3%–66.3%, respectively. The paper also reports that sharing a common translation prefix gives vLLM 1.67× higher throughput than an oracle Orca baseline for a one-example prefix and 3.58× for a five-example prefix.

The evaluation has boundaries worth keeping in view. The authors implement Orca themselves because its source was unavailable, request arrivals are synthesized from ShareGPT and Alpaca sequence lengths, and the experiments use 2023-era OPT and LLaMA models on NVIDIA A100 GPUs. The broader lesson is therefore about dynamic KV-cache allocation, not a permanent throughput number for every modern model and accelerator.

## Practical takeaways

- In autoregressive serving, improving memory utilization can raise throughput more than optimizing a single kernel because it enables larger batches.
- KV-cache capacity should be allocated on demand when output lengths are unknown; reserving for the worst case wastes scarce GPU memory.
- Indirection is valuable when it enables both compact allocation and sharing, especially for beam search, parallel sampling, and shared prefixes.
- Systems optimizations must be read end to end: PagedAttention adds kernel overhead but wins by changing the batch-level operating point.
- The benefit depends on the workload. When serving is compute-bound rather than memory-bound, better KV-cache management has less room to help.

## Links

- [Paper in the ACM Digital Library](https://dl.acm.org/doi/10.1145/3600006.3613165)
- [Paper on arXiv](https://arxiv.org/abs/2309.06180v1)
- [vLLM project](https://vllm.ai/)
- [Official code on GitHub](https://github.com/vllm-project/vllm)
