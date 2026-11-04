---
layout: article
title: "terminal-mac Gives Agents a Virtual Mac, Not a Hardened Sandbox"
short_title: "terminal-mac's Virtual Mac Boundary"
date: 2026-11-05
type: "Article Bite"
read_time: "4 min read"
source_name: "govijr — terminal-mac"
source_url: "https://github.com/govijr/terminal-mac/releases/tag/v0.2.0-6"
source_published: 2026-11-03
last_reviewed: 2026-11-05
tags:
  - Computer Use
  - AI Agent Tooling
  - Apple Silicon
summary: "terminal-mac routes agent screenshots and input through a separate macOS guest, but its live end-to-end validation and security isolation remain important open questions."
additional_sources:
  - name: "terminal-mac repository and README, pinned at release commit"
    url: "https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/README.md"
  - name: "VM configuration, pinned source"
    url: "https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/VirtualMachine.swift"
  - name: "Guest helper, pinned source"
    url: "https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/Guest.swift"
  - name: "MCP server, pinned source"
    url: "https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/AgentServer.swift"
  - name: "Validation record, pinned at release commit"
    url: "https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/docs/VALIDATION.md"
  - name: "First-launch issue report"
    url: "https://github.com/govijr/terminal-mac/issues/1"
  - name: "Distribution and signing notes, pinned source"
    url: "https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/RELEASING.md"
---

A computer-use agent needs a desktop to click around. Does that desktop have to be *yours*? [terminal-mac's November 3, 2026 release](https://github.com/govijr/terminal-mac/releases/tag/v0.2.0-6) offers another arrangement: an Apple-silicon Mac runs a separate macOS virtual machine, whose screen appears in a terminal and whose controls are exposed to agents. The name describes the view, not the host requirement. This does **not** run macOS on Linux or Windows, and the project calls itself an early release candidate.

## The agent clicks inside the guest

The [host configures](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/VirtualMachine.swift) Apple's Virtualization framework with a Mac guest, a display, a disk, and normally a network adapter. A helper running *inside* that guest captures the display and posts mouse and keyboard events there. It needs Screen Recording and Accessibility approval in the **guest**, not on the physical Mac. A shared `control` folder carries requests, replies and screen data; a read-only-from-guest `tools` folder supplies the helper. The [terminal viewer](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/README.md) renders frames, while the [MCP server](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/AgentServer.swift) exposes screenshots and input actions to an agent. `snapshot` is a screenshot alias, **not** an accessibility-tree snapshot.

That split is the interesting part. The agent can work in a guest with its own apps, files and sign-ins rather than acting directly on the host's active desktop. The [guest helper's virtual-machine check](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/Guest.swift) guards against accidentally running it on the physical Mac; it is not hardware attestation. Nor has the project yet demonstrated, in its published acceptance record, that host focus, pointer and clipboard remain untouched during live guest input.

<figure class="article-figure article-figure--agent-desktop">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Scrollable diagram of terminal-mac host, shared folders, guest helper, and network boundary">
    <a href="{{ '/assets/images/articles/terminal-mac-guest-control-boundary/host-guest-control.svg' | relative_url }}">
      <img src="{{ '/assets/images/articles/terminal-mac-guest-control-boundary/host-guest-control.svg' | relative_url }}" width="600" height="780" loading="lazy" decoding="async" alt="On an Apple-silicon Mac, terminal viewer and agent MCP send actions through a writable control share to a helper inside a virtual Mac. The guest sends screen data back. A separate tools share is read-only from the guest. Default NAT networking can reach outside the guest; offline mode removes the network adapter, not the shares. Schematic of code, not a live demonstration.">
    </a>
  </div>
  <figcaption>LiteBites synthesis of the <a href="https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/VirtualMachine.swift">host VM configuration</a> and <a href="https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/README.md">documented control and isolation model</a>. This is a code-grounded boundary map, not evidence of a completed live guest test. On narrow screens, swipe horizontally or <a href="{{ '/assets/images/articles/terminal-mac-guest-control-boundary/host-guest-control.svg' | relative_url }}">open full resolution ↗</a>.</figcaption>
</figure>

## Separate desktop, porous network

The VM keeps normal host folders, microphone, camera and clipboard out of its *explicit* shares. But the [README's isolation model](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/README.md#isolation-model) is careful: default NAT networking may still reach services on the host or local network. `--offline` removes the guest's network adapter; it does not remove the two shared folders. This separates desktop interactions; it is **not a hardened environment for hostile code**. A user still needs to set up macOS inside the guest and grant the helper its permissions interactively.

Distribution deserves the same restraint. The [latest release](https://github.com/govijr/terminal-mac/releases/tag/v0.2.0-6) contains an Apple-silicon ZIP and a checksum-checking installer, but [public builds are self-signed and not notarized](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/RELEASING.md). A checksum delivered by the same download path checks transfer integrity; it does not independently authenticate the publisher. Read the installer and release assets before running the documented `curl | bash` command.

## What a clean-Mac run still has to prove

The project's [validation record](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/docs/VALIDATION.md) reports successful build, packaging and protocol tests. It also explicitly leaves the full guest installation, privacy grants, screenshot alignment, input, and terminal viewing on its **uncompleted live acceptance checklist**. An [open first-launch issue](https://github.com/govijr/terminal-mac/issues/1) reports a guest-helper relaunch loop on macOS 27.2; its suggested cause is a commenter's unconfirmed theory, not a diagnosed defect across all versions.

For an agent workflow, the next useful evidence is a clean-Mac run: install and sign into the guest, grant its permissions, check that screen and input actually work, then observe whether the physical desktop stays undisturbed. Until then, terminal-mac is a concrete, unusually candid *design for a separate agent desktop*—not proof of reliable end-to-end automation or a hardened security boundary.

## Sources

- [govijr — terminal-mac v0.2.0-6 release, November 3, 2026](https://github.com/govijr/terminal-mac/releases/tag/v0.2.0-6)
- [terminal-mac README — requirements, workflow and isolation model, pinned source](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/README.md)
- [VM configuration — boot, shares and networking, pinned source](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/VirtualMachine.swift)
- [Guest helper — capture and input path, pinned source](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/Guest.swift)
- [Agent MCP tools, pinned source](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/Sources/TerminalMac/AgentServer.swift)
- [Maintainer validation record and live acceptance checklist, pinned source](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/docs/VALIDATION.md)
- [Distribution and signing guide, pinned source](https://github.com/govijr/terminal-mac/blob/7009117f9e910c3dd4b4bd863e8bc331bd3c9d96/RELEASING.md)
- [First-launch issue report](https://github.com/govijr/terminal-mac/issues/1)
