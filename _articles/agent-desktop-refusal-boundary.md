---
layout: article
title: "Agent Desktop Gives AI Agents a Refusal Path Before the Wrong Click"
short_title: "Agent Desktop's Refusal Path"
date: 2026-11-01
type: "Article Bite"
read_time: "4 min read"
source_name: "Vercel Labs — Agent Desktop"
source_url: "https://github.com/vercel-labs/agent-desktop"
source_published: 2026-10-30
last_reviewed: 2026-11-01
tags:
  - Computer Use
  - AI Agent Tooling
  - Agent Safety
summary: "Now under Vercel Labs, Agent Desktop turns OS accessibility trees into snapshot-qualified actions that can refuse stale targets, while leaving verification and privacy decisions to the calling agent."
additional_sources:
  - name: "Agent Desktop v1.0.0 release"
    url: "https://github.com/vercel-labs/agent-desktop/releases/tag/v1.0.0"
  - name: "Agent Desktop v1.0.2 release"
    url: "https://github.com/vercel-labs/agent-desktop/releases/tag/v1.0.2"
  - name: "Agent Desktop — snapshots and refs"
    url: "https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/snapshots-and-refs.mdx"
  - name: "Agent Desktop — errors and recovery"
    url: "https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/errors-and-recovery.mdx"
  - name: "Agent Desktop — privacy FAQ"
    url: "https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/docs/faq.md"
---

A desktop agent can find a button. The harder question comes a moment later: **is it still the same button?** [Agent Desktop](https://github.com/vercel-labs/agent-desktop), an existing open-source project now under Vercel Labs, puts that question in the interface between an agent and the operating system. Its [October 28, 2026 v1.0.0 release](https://github.com/vercel-labs/agent-desktop/releases/tag/v1.0.0) added Linux to its macOS/Windows CLI and C library; [v1.0.2 followed on October 30](https://github.com/vercel-labs/agent-desktop/releases/tag/v1.0.2), alongside the Vercel Labs repository presentation and new docs. This was not the project's first release or proof that agents can reliably finish desktop tasks.

## An element is more than a coordinate

The native Rust CLI reads an app through its OS accessibility API—AX on macOS, UI Automation on Windows, AT-SPI on Linux—and returns a JSON tree. A snapshot might label a Finder item as a `treeitem` and give it a qualified reference such as `@s8f3k2p9:e8`. The calling agent then uses `click @s8f3k2p9:e8` and takes another observation. [The project says](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/README.md) the agent, not the CLI, owns this observe–act–verify loop; its C library offers the same interface to other programs.

The ref is **not** a durable selector. [Before a ref action](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/snapshots-and-refs.mdx#how-a-ref-resolves), Agent Desktop loads the saved snapshot's identity evidence and tries to identify that element in the live process and window. If it cannot find a suitable match, it returns `STALE_REF`; if several plausible targets remain, `AMBIGUOUS_TARGET`. A changed interface can sometimes still yield a valid match, but the recommended response to change is a fresh observation—not an old screen coordinate or a guessed replacement.

## When a failed click may have landed

Finding the right target and knowing whether an action happened are separate problems. The project's [error contract](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/errors-and-recovery.mdx#disposition) distinguishes `not_delivered` (safe to retry after fixing the cause and following any supplied recovery plan) from `delivery_uncertain` and `delivered_unverified` (inspect the app before repeating). `unknown` also calls for inspection; `delivered_verified` confirms the named postcondition, not the whole task, and is unsafe to repeat. A second `click` might submit twice; a second `toggle` might undo the first. `ok: true` does not by itself establish that the app-level task was completed. The [workflow guide](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/guides/observe-act-verify.mdx) prefers state-setting commands such as `set-value` or `check` when they fit, followed by an independent read.

<figure class="article-figure article-figure--agent-desktop">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable diagram comparing safe and unsafe retry dispositions after a desktop action">
    <a href="{{ '/assets/images/articles/agent-desktop-refusal-boundary/delivery-before-retry.svg' | relative_url }}">
      <img src="{{ '/assets/images/articles/agent-desktop-refusal-boundary/delivery-before-retry.svg' | relative_url }}" width="600" height="715" loading="lazy" decoding="async" alt="Selected retry outcomes: not delivered means the requested input did not reach the app, so fix the cause and follow recovery before a safe retry. Delivery uncertain or delivered but unverified requires a new read. Other outcomes: unknown also requires observation; delivered and verified is unsafe to repeat. Delivery does not prove whole-task success.">
    </a>
  </div>
  <figcaption>LiteBites synthesis of Agent Desktop's <a href="https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/errors-and-recovery.mdx">delivery and retry contract</a>. The two large cases are selected examples; the footer covers the other dispositions. The figure concerns retry safety, not task success. On narrow screens, swipe horizontally or <a href="{{ '/assets/images/articles/agent-desktop-refusal-boundary/delivery-before-retry.svg' | relative_url }}">open full resolution ↗</a>.</figcaption>
</figure>

## What the accessibility boundary leaves open

Headless ref actions use accessibility APIs by default, without moving the pointer or taking focus; [screenshots and physical-input mode](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/README.md) are separate options, **not** an automatic visual-recognition fallback. Apps that expose poor accessibility data limit what the tree can tell the agent. Nor is support identical everywhere: macOS needs Accessibility permission, Windows is constrained by desktop integrity levels, and Linux's X11/Wayland capabilities differ. A version number and a list of commands cannot settle those gaps.

The native CLI does not need a model service, but that is not the same as a private agent. [The project's FAQ](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/docs/faq.md#what-data-can-contain-private-information) warns that snapshots, window titles, clipboard reads, traces and screenshots can contain sensitive content. Its separate, optional JEV helper sends screen descriptions to a configured model provider. Desktop permissions also grant broad reach; the CLI is not a per-app security sandbox. Code and cross-platform tests describe a careful interface, but they do not independently measure end-to-end agent success.

## Try the refusal path first

Start in an unimportant app. Take a snapshot, change the UI, and see whether a stale or ambiguous target is refused; then test a harmless state-setting action and verify its effect with a new read. Before using sensitive apps, check the platform's actual capabilities, grant only necessary OS permissions, and decide where snapshots, traces, screenshots and any agent-model prompts may go. The value here is a more explicit **contract for acting and stopping**—not a guarantee that every desktop task can be automated safely.

## Sources

- [Vercel Labs — Agent Desktop repository, CLI, platform notes and source code](https://github.com/vercel-labs/agent-desktop)
- [Agent Desktop v1.0.0 release — cross-platform milestone](https://github.com/vercel-labs/agent-desktop/releases/tag/v1.0.0)
- [Agent Desktop v1.0.2 release — October 30 update](https://github.com/vercel-labs/agent-desktop/releases/tag/v1.0.2)
- [Agent Desktop — snapshots and strict ref resolution, pinned source](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/snapshots-and-refs.mdx)
- [Agent Desktop — delivery dispositions and recovery, pinned source](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/errors-and-recovery.mdx)
- [Agent Desktop — observe, act, verify guide, pinned source](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/apps/docs/content/docs/guides/observe-act-verify.mdx)
- [Agent Desktop — privacy FAQ, pinned source](https://github.com/vercel-labs/agent-desktop/blob/5261b5287b5208e7c4bf3713df6f66faaaf2c4cc/docs/faq.md)
