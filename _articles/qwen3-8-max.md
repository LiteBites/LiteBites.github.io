---
layout: article
title: "Qwen3.8-Max Extends Qwen's Agent Push to a 2.4-Trillion-Parameter Model"
short_title: "Qwen3.8-Max and Long-Horizon Agents"
date: 2026-08-16
type: "Article Bite"
read_time: "3 min read"
source_name: "Qwen Team"
source_url: "https://qwen.ai/blog?id=qwen3.8"
source_published: 2026-08-03
last_reviewed: 2026-08-16
tags:
  - Agentic AI
  - Language Models
  - Multimodal AI
  - Open Models
summary: "Qwen3.8-Max combines sparse model scale with an agent-focused release, but its strongest autonomy and benchmark claims still need independent testing."
additional_sources:
  - name: "Qwen3.8-2.4T-A95B model card"
    url: "https://huggingface.co/Qwen/Qwen3.8-2.4T-A95B"
  - name: "Qwen3.8-Max license"
    url: "https://huggingface.co/Qwen/Qwen3.8-2.4T-A95B/blob/main/LICENSE"
  - name: "oh-my-cli public repository"
    url: "https://github.com/qwen-code-dev-bot/oh-my-cli"
  - name: "Artificial Analysis Terminal-Bench v2.1 leaderboard"
    url: "https://artificialanalysis.ai/evaluations/terminalbench-v2-1"
---

## What happened

On August 3, 2026, the Qwen Team announced **Qwen3.8-Max**, a model aimed at coding, professional work, multimodal interaction, and long-running agent tasks. Qwen describes it as a mixture-of-experts system with 2.4 trillion total parameters and 95 billion active for each token. The managed model became available through QwenCloud at launch.

The announcement said open weights would follow the next week. They did: Qwen published **Qwen3.8-2.4T-A95B** on Hugging Face on August 8. The official model card also draws an important boundary. The hosted Max service adds features such as vision input, non-thinking mode, a default one-million-token context, and built-in tools; the downloadable artifact should not be treated as identical to the managed product.

## Why it matters

The release matters for reasons beyond parameter count. Qwen is packaging sparse scale, multimodal input, adjustable reasoning effort, tool-compatible APIs, and training for multi-step execution as one agent platform. The service supports OpenAI-compatible chat and responses interfaces plus an Anthropic-compatible interface. Existing coding and agent harnesses can therefore connect with less custom integration work.

Researchers and infrastructure teams now have a checkpoint they can inspect and deploy outside QwenCloud. That helps with controlled evaluation, customization, and data-governance requirements. Still, a multi-trillion-parameter checkpoint demands unusually substantial storage and inference infrastructure.

## Technical context

Qwen says Qwen3.8-Max improves on Qwen3.7-Max across coding and general-agent evaluations. Its table reports 86.6 on Terminal-Bench 2.1, 67.7 on SWE-bench Pro, and 93.0 on PaperBench. Read those as vendor results, not a universal ranking. The post mixes public and in-house benchmarks, uses different harnesses and run counts, and supplies extensive protocol footnotes. Artificial Analysis, for example, evaluates Terminal-Bench v2.1 independently with the Terminus 2 harness and pass@1 over three repeats, while Qwen reports its model with Claude Code and an avg@10 setup.

The post's more ambitious evidence comes from long-horizon demonstrations. Qwen says the model spent days reproducing and extending a research pipeline, iteratively optimized a hardware design, and operated a self-evolving coding project. The linked `oh-my-cli` repository provides a public artifact trail that readers can inspect. It does not, by itself, independently verify the claim that the entire process ran without human help.

## What remains uncertain

Independent evaluations have not yet established how reliably the reported long runs reproduce across environments, tool permissions, budgets, and failure-recovery policies. Several showcased tasks and benchmarks were designed or evaluated by Qwen, so contamination, judge choice, and harness effects remain relevant questions.

Deployment terms also deserve attention. The weights use Qwen's own license, which permits broad use but adds naming and separate-license conditions for specified high-scale commercial products and certain model-service or AI-work-assistant businesses. Teams should review those terms rather than equating “open weights” with an unconditional permissive license.

## Practical takeaways

- Evaluate the hosted Max service and the downloadable A95B model as related but distinct products.
- Re-run agent benchmarks in the exact harness, timeout, tool, and scoring configuration relevant to deployment.
- Inspect the public project traces, but do not treat repository activity as an independent audit of autonomy.
- Budget for the full checkpoint footprint, not only the 95-billion active-parameter figure.
- Review the model license before building a commercial hosted service or work assistant.

## Sources

- [Qwen Team — Qwen3.8-Max: A New Bar for Coding and Cowork](https://qwen.ai/blog?id=qwen3.8)
- [Qwen — Qwen3.8-2.4T-A95B model card](https://huggingface.co/Qwen/Qwen3.8-2.4T-A95B)
- [Qwen — Qwen3.8-Max license](https://huggingface.co/Qwen/Qwen3.8-2.4T-A95B/blob/main/LICENSE)
- [GitHub — qwen-code-dev-bot/oh-my-cli](https://github.com/qwen-code-dev-bot/oh-my-cli)
- [Artificial Analysis — Terminal-Bench v2.1 leaderboard](https://artificialanalysis.ai/evaluations/terminalbench-v2-1)
