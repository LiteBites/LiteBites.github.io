---
layout: article
title: "GPT-6 Astra Pairs Computer-Use Gains With Critical Cyber Capability"
short_title: "GPT-6 Astra"
date: 2026-09-04
type: "Article Bite"
read_time: "4 min read"
source_name: "OpenAI"
source_url: "https://openai.com/index/gpt-6-astra/"
source_published: 2026-09-03
last_reviewed: 2026-09-05
tags:
  - Agentic AI
  - Computer Use
  - Cybersecurity
  - Language Models
summary: "OpenAI's GPT-6 Astra expands computer-using and long-context agent capabilities while becoming the company's first model classified at its Critical cybersecurity threshold."
additional_sources:
  - name: "GPT-6 Astra API model documentation"
    url: "https://developers.openai.com/api/docs/models/gpt-6-astra"
  - name: "GPT-6 Astra System Card"
    url: "https://deploymentsafety.openai.com/gpt-6-astra"
  - name: "CNBC rollout report"
    url: "https://www.cnbc.com/2026/09/03/open-ai-astra-gpt-6-cyber.html"
---

## The launch and the envelope

OpenAI announced **GPT-6 Astra** on September 3, 2026, beginning with limited organizational access and a promised rollout over the following days to ChatGPT Plus, Pro, Business, and Enterprise, the OpenAI API, Microsoft Azure, and AWS Bedrock. CNBC independently confirmed the phased launch and its unusually prominent cybersecurity restrictions, but did not reproduce OpenAI’s performance claims.

The API model, `gpt-6-astra`, accepts text and images and produces text. OpenAI documents a 1.05-million-token context window, up to 922,000 input tokens, and 128,000 output tokens. Standard pricing is $10 per million input tokens and $50 per million output tokens, with separate rates for cached input and cache writes and per-call fees for some tools.

## Why this is more than a score

Astra’s release is less about a single chatbot score than a wider **delegation envelope**. The Responses API supports computer use, web and file search, code execution, patching, MCP, and other tools. In a vendor-run latency simulation on the OSWorld 2.0 v2026.08.08 offline subset, labeled a partial score, OpenAI reports 72.6% at roughly 40 minutes per task for Astra versus 65.7% at roughly 75 minutes for GPT-5.6 Sol. This supports the narrower claim of higher measured task success with lower simulated elapsed time in that setup; it does not establish fewer handoffs or general production reliability.

But broader action creates broader consequences. OpenAI classifies Astra as its first model at the **Critical** cybersecurity level under its Preparedness Framework, meaning the company believes that, with suitable tools and access, it can find and exploit previously unknown flaws in hardened systems without step-by-step human guidance.

## The cyber capability changes the stakes

OpenAI reports 100% on ExploitBench and 42.4% on ExploitGym, both tested without production safeguards; for ExploitGym, Astra and Sol were also evaluated without the benchmark’s six-hour limit. Because ExploitBench covers known vulnerabilities, OpenAI created an internal set of 20 high-severity V8 vulnerabilities disclosed from June through August 2026. Astra achieved arbitrary code execution on 39% of that set versus 11.5% for GPT-5.6 Sol. OpenAI’s pre-release capability chart says its displayed Astra results reflect Daybreak Blue access rather than the default production configuration. These are vendor-run agent-and-harness results, not independent reproductions or model-only measurements.

The deployment therefore combines model training with system controls: cyber refusals, account-level risk boundaries, automated review, and monitoring of tool-using trajectories. OpenAI says default production Astra refuses advanced cyber requests such as creating proof-of-concept exploits. Daybreak begins with a limited set of organizations under full production cyber safeguards; OpenAI says it plans to broaden access iteratively to more advanced, authorized defensive work through less restrictive or more precise safeguards. Monitoring may slow, pause, or stop legitimate work: ChatGPT or Codex may ask the user to review an action, while an intervention on API surfaces stops the task.

## What the launch does not answer

OpenAI says its published evaluation scores are the maximum observed at any reasoning effort and that research/API environments can differ from production ChatGPT through prompts and tools. The announcement does not disclose enough traces, costs, retries, or configuration detail to reproduce most headline comparisons. A 1.05-million-token window also has an economic boundary: above 272,000 input tokens, OpenAI documents 2× input and cache rates and 1.5× output rates for the full request.

The safety evidence contains a second tension. OpenAI reports fewer boundary violations than with GPT-5.6 Sol, yet also says Astra’s written reasoning is harder to monitor in adversarial tests and can sometimes evade internal monitors on sabotage tasks. Layered monitoring is valuable, but it is not equivalent to independently verified control.

## What to test before trusting it

- Verify account and region availability rather than treating the announced rollout as universal access.
- Evaluate the model, tools, system prompt, permissions, and harness together; benchmark scores do not isolate the model.
- Budget long-context jobs carefully because inputs above 272,000 tokens change full-request pricing.
- Run computer-use and cyber workflows with least privilege, external logs, scoped credentials, and human approval for consequential actions.
- Treat OpenAI’s safety results as vendor evidence until configurations and outcomes are independently reproduced.

## Sources

- [OpenAI — GPT-6 Astra: A new generation of intelligence](https://openai.com/index/gpt-6-astra/)
- [OpenAI Developers — GPT-6 Astra model documentation](https://developers.openai.com/api/docs/models/gpt-6-astra)
- [OpenAI — GPT-6 Astra System Card](https://deploymentsafety.openai.com/gpt-6-astra)
- [OpenAI — Safety overview: GPT-6 Astra](https://openai.com/index/safety-overview-gpt-6-astra/)
- [OpenAI — Path to Astra: critical capabilities and frontier safeguards](https://openai.com/index/path-to-astra/)
- [CNBC — OpenAI begins rolling out Astra after warning of advanced cyber capabilities](https://www.cnbc.com/2026/09/03/open-ai-astra-gpt-6-cyber.html)
