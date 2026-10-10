---
layout: article
title: "Orca Puts Coding Agents in Separate Git Worktrees"
short_title: "Orca: One Task per Worktree"
date: 2026-10-10
type: "Article Bite"
read_time: "4 min read"
source_name: "Stably AI / Orca"
source_url: "https://github.com/stablyai/orca/releases/tag/v1.4.224"
source_published: 2026-10-10
last_reviewed: 2026-10-10
tags:
  - Developer Tools
  - AI Coding Agents
  - Agent Infrastructure
summary: "Orca gives each coding-agent task a real Git worktree and a reviewable diff; this beginner walkthrough starts with just one agent."
additional_sources:
  - name: "Orca first-session guide"
    url: "https://www.onorca.dev/docs/first-session"
  - name: "Orca installation guide"
    url: "https://www.onorca.dev/docs/install"
  - name: "Orca source repository and README"
    url: "https://github.com/stablyai/orca"
---

Orca's [October 10 release](https://github.com/stablyai/orca/releases/tag/v1.4.224) adds managed SSH servers and changes to an experimental chat view. But the simpler reason to try [Orca](https://www.onorca.dev/docs) is older than either feature: it gives a coding agent its **own Git worktree**, with terminals and a diff viewer beside it. You can review one task without mixing its edits into your main checkout.

## One task, one branch, one agent

Orca calls itself an agent development environment. It is **not another AI model**: you bring an existing CLI agent such as Codex or Claude Code, plus that provider's account. Orca opens the agent in a separate Git checkout derived from a chosen branch or commit. Its [first-session guide](https://www.onorca.dev/docs/first-session) demonstrates three worktrees tackling one task in parallel, but you can learn the workflow with just one.

The practical loop is **add repo → create worktree → run agent → inspect diff**. Its [diff viewer](https://www.onorca.dev/docs/review/diff-viewer) compares a task against its start-from ref and includes staged, unstaged, and untracked changes. This is more useful than watching three terminal transcripts if the goal is to decide what code should survive. The worktrees remain ordinary Git worktrees; Orca is a graphical organizer, not a new version-control system.

<figure class="remote-publisher-image" data-source-url="https://github.com/stablyai/orca">
  <a href="https://github.com/stablyai/orca/raw/main/docs/assets/readme-hero.jpg">
    <img src="https://github.com/stablyai/orca/raw/main/docs/assets/readme-hero.jpg" width="1998" height="1250" loading="lazy" decoding="async" referrerpolicy="no-referrer" alt="Orca desktop screenshot showing a sidebar of worktrees, separate Claude Code and Codex terminal panes, and the mobile companion overlaid at the right.">
  </a>
  <figcaption>Stably AI's <a href="https://github.com/stablyai/orca">README screenshot</a> shows the worktree sidebar and separate agent terminals, with a mobile companion overlay. Publisher-hosted documentation image, © 2026 Lovecast Inc.; <a href="https://github.com/stablyai/orca/blob/main/LICENSE">MIT license</a>. <a href="https://github.com/stablyai/orca/raw/main/docs/assets/readme-hero.jpg">Open the original full-resolution image ↗</a></figcaption>
</figure>

## Try one agent before three

You need a local Git repository and an installed, signed-in coding-agent CLI. The [installation guide](https://www.onorca.dev/docs/install) offers macOS, Windows, and Linux builds; Orca does not supply the model or your provider subscription. Here is a deliberately small first session, adapted from Orca's [official walkthrough](https://www.onorca.dev/docs/first-session):

1. Install Orca, open it, and choose **Add Repo**. Point it at a local project you can safely edit, preferably one with a working test command.
2. Click **+** beside that repo. Name the task `add-one-test`, leave the **start-from** ref on your intended base branch, and create the worktree. Orca opens a separate checkout rather than editing the main folder.
3. Choose your already-installed CLI in the agent selector. For Codex, [Orca's guide](https://www.onorca.dev/docs/agents/codex) says to install Codex and log in separately first. Give it a bounded prompt: “Add one test for an existing function. Run only the relevant tests. Do not commit or push. Tell me what changed.”
4. Open the worktree's **diff view**. Read the test and any unexpected edits, rerun the relevant test yourself, then decide whether to stage or discard. Orca can [commit and push](https://www.onorca.dev/docs/review/commit-push), but do that only after review. You do not need three agents or a phone to finish this exercise.

## Where isolation ends

A separate checkout prevents simultaneous agents from overwriting the same working files; it does **not** sandbox what their CLIs can read, execute, or send to their model providers. Review agent permissions and repo secrets before giving access. Orca's [privacy documentation](https://www.onorca.dev/docs/telemetry) describes anonymous product telemetry and a toggle under **Settings → Privacy**; that telemetry is distinct from traffic to the agent provider. Remote SSH hosts and mobile pairing are optional, not part of this local tutorial.

The October 10 release also labels native chat **experimental** and lists known update and downgrade issues. Start with the ordinary terminal workflow rather than treating every newer surface as required. No independent productivity benchmark is established by the site’s “100x” tagline, and this walkthrough was checked against documentation rather than exercised in a local Orca installation.

## Before adopting it

- Start with one disposable task and confirm the agent is operating in the intended worktree, not `main`.
- Inspect the complete diff, including untracked files; run the test command outside the agent's summary.
- Keep each agent's provider permissions and Orca's telemetry setting separate in your privacy review.
- Do not delete a worktree until you have checked whether its branch holds changes you still need.

## Sources

- [Orca v1.4.224 release — Stably AI, October 10, 2026](https://github.com/stablyai/orca/releases/tag/v1.4.224)
- [Orca README and publisher-hosted interface screenshot](https://github.com/stablyai/orca)
- [First-session walkthrough](https://www.onorca.dev/docs/first-session)
- [Install Orca](https://www.onorca.dev/docs/install)
- [Diff viewer and comparison scope](https://www.onorca.dev/docs/review/diff-viewer)
- [Codex setup in Orca](https://www.onorca.dev/docs/agents/codex)
- [Privacy and telemetry controls](https://www.onorca.dev/docs/telemetry)
- [Repository MIT license](https://github.com/stablyai/orca/blob/main/LICENSE)
