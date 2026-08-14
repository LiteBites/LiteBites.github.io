---
layout: post
title: "Small Language Models are the Future of Agentic AI"
short_title: "SLMs for Agentic AI"
date: 2026-08-14
type: "Paper brief"
read_time: "5 min read"
venue: "arXiv preprint (v2, 2025)"
tags:
  - Agentic AI
  - Small Language Models
  - Model Routing
  - Efficient Inference
summary: "This position paper argues for SLM-first agents: route repetitive, narrow calls to specialized small models and retain large models for tasks that need broad generality."
paper_url: "https://arxiv.org/abs/2506.02153v2"
project_url: "https://research.nvidia.com/labs/lpr/slm-agents/"
---

## Why this paper matters

Many AI agents use one general-purpose large language model for every model call. That choice is convenient, but the calls inside an agent are rarely identical. Some require open-ended planning or dialogue. Others repeatedly classify intent, fill a schema, summarize one document type, or call a fixed set of tools.

This paper asks whether those narrow internal calls need a large model at all. Its answer is a deliberately strong position: small language models (SLMs) should handle a substantial share of agentic work because they can be specialized, deployed closer to the application, and served with less memory and computation.

The distinction is functional rather than permanent. The authors define an SLM as a model that fits on a common consumer device and can serve one user's agent requests at practical latency. They note that most models below 10 billion parameters fit that description in 2025, while recognizing that the boundary will move with hardware and model design.

## The bite

The key idea is **SLM-first, not SLM-only**. Use specialized small models for recurring, well-scoped operations, then invoke a larger generalist when a request is novel, ambiguous, conversational, or requires broader reasoning.

This fits agent architecture naturally. Controller code can select a model for each call, or a root language model can invoke another model as a tool. The agent therefore becomes a heterogeneous system: a router chooses among specialists and preserves an LLM fallback rather than forcing one model to cover every task.

The paper supports this position with three claims. Modern SLMs are capable enough for many constrained tasks; their smaller size can reduce inference and adaptation costs; and agent calls expose narrow behaviors that are easier to specialize than general conversation. The important qualifier is **many** calls, not all calls.

## How it works

The paper turns its position into a six-step conversion workflow for an existing LLM-backed agent:

1. **Instrument non-user-facing calls.** Securely log prompts, responses, tool calls, and useful latency signals.
2. **Curate the traces.** Filter unsuccessful examples and remove personally identifiable, health, confidential, or application-specific sensitive information. The paper gives 10,000–100,000 examples as a cited rule of thumb, not a guarantee.
3. **Cluster recurring tasks.** Group similar prompts and actions into candidate specializations such as intent recognition, structured extraction, domain-specific summarization, or tool-constrained code generation.
4. **Select candidate SLMs.** Consider task capability, context length, license, memory footprint, and deployment requirements.
5. **Adapt and route.** Fine-tune with methods such as LoRA or QLoRA, use full tuning when justified, or distill outputs from the original LLM. Route suitable calls to the specialist while retaining fallback behavior.
6. **Iterate.** Monitor failures, collect new traces, retrain specialists, and revise the router as the workload changes.

<figure>
  <img src="{{ '/assets/images/papers/slm-agents/method-01.png' | relative_url }}" alt="Two agent architectures: one where a language model orchestrates tools and another where controller code routes calls among tools and language models, with optional logging and example execution sequences." />
  <figcaption>Paper Figure 1: model agency and code agency both provide places to route calls to specialists and, with appropriate privacy controls, collect traces for later adaptation.</figcaption>
</figure>

A useful way to read the figure is that specialization does not require one fixed architecture. In the left design, an orchestrating model calls tools and subordinate models. In the right design, controller code owns the sequence. Both can introduce task-specific SLMs and an optional logger without removing the general model entirely.

## What to look at in the results

This is a **position paper**, not a new benchmark study. It does not train a specialist model, deploy the proposed router, or report a controlled end-to-end comparison. Its evidence comes from prior SLM capability and efficiency studies, arguments about agent structure, responses to alternative views, and three qualitative case studies.

The appendix estimates that appropriately specialized SLMs could handle about 60% of MetaGPT's model calls, 40% of Open Operator's, and 70% of Cradle's. These percentages are the authors' assessments of each framework's task mix. They are not measured replacement rates or demonstrated success rates. Their best use is as hypotheses: instrument a real workload, identify repetitive call classes, and test replacement under the application's own quality constraints.

The economic argument needs similar care. The paper cites work suggesting that serving a 7B model can be 10–30× cheaper than serving 70–175B models across latency, energy, or floating-point-operation comparisons. That range is not one standardized total-cost benchmark. A fleet of specialists also creates routing, monitoring, fine-tuning, versioning, and utilization overhead.

The authors directly acknowledge the strongest counterpoint: centralized general-purpose LLM endpoints may retain economies of scale, while smaller dedicated endpoints can be harder to keep fully utilized. They describe the exact economics as case-specific and say the jury is still out. This caveat makes the practical claim narrower and more useful: model size alone does not decide system cost.

Another boundary is data governance. The migration workflow depends on production traces, which may contain user inputs, tool arguments, internal documents, or generated sensitive data. Encryption, access controls, retention limits, anonymization, and task-specific filtering are part of the system design, not optional cleanup after fine-tuning.

## Practical takeaways

- Optimize **call classes**, not the agent as one indivisible workload. Measure which operations are frequent, narrow, and verifiable.
- Use escalation rather than hard replacement: route to a specialist by default and fall back to a general model for low-confidence or unfamiliar requests.
- Evaluate task success, format compliance, latency, cost, and recovery behavior together. A cheaper model that breaks tool contracts is not an optimization.
- Treat agent traces as sensitive production data. Decide what may be logged and retained before building a training pipeline.
- Include fleet-level costs—routing, monitoring, adaptation, and utilization—when comparing an SLM portfolio with one centralized LLM endpoint.
- Read the paper's case-study percentages as testable estimates, not published performance results.

## Links

- [Paper on arXiv (v2)](https://arxiv.org/abs/2506.02153v2)
- [Versioned PDF](https://arxiv.org/pdf/2506.02153v2)
- [NVIDIA Research project page](https://research.nvidia.com/labs/lpr/slm-agents/)
- [Published correspondence and critiques](https://research.nvidia.com/labs/lpr/slm-agents/correspondence.html)
