---
layout: article
title: "Meta Muse Is Expanding. Its Trust Questions Are Now Public"
short_title: "Muse’s Trust Boundary"
date: 2026-09-28
type: "Article Bite"
read_time: "4 min read"
source_name: "Meta"
source_url: "https://about.fb.com/news/2026/09/the-biggest-news-from-connect-2026/"
source_published: 2026-09-24
last_reviewed: 2026-09-28
tags:
  - AI Agents
  - Cybersecurity
summary: "Muse combines connected apps with a persistent cloud computer. Its expansion puts two different safeguards in focus: approving the agent’s actions and protecting the data it can reach."
description: "How Meta Muse works, what controls Meta describes, and why the Marketplace account and reported VM vulnerability raise different trust questions."
additional_sources:
  - name: "Meta — Introducing Muse"
    url: "https://about.fb.com/news/2026/09/introducing-muse-personal-ai-agent/"
  - name: "Matt Robb on Threads — Muse Marketplace post"
    url: "https://www.threads.com/@matt.j.robb/post/DdxwAJnDhNy"
  - name: "David Singleton on X — Muse response"
    url: "https://x.com/dps/status/2104403954235007302"
  - name: "Android Authority — Meta Muse AI incident raises concerns about trusting AI agents"
    url: "https://www.androidauthority.com/meta-muse-ai-privacy-issues-3715963/"
  - name: "Reuters via KSL.com — Meta bolsters Muse safety warning after security vulnerability found"
    url: "https://www.ksl.com/article/51628738/meta-bolsters-muse-safety-warning-after-security-vulnerability-found-the-information-reports"
---

## An agent with its own computer

Muse is meant to finish tasks, not just suggest the next step.[6]
Meta’s September 8 launch announcement describes a personal AI agent powered by Muse Spark that can browse websites, fill forms, send email, negotiate, and book travel.[6]
It can keep working after the app closes.[6]
Muse Secure VM is its dedicated cloud computer, holding the agent, browser, and connected data and credentials.[6]

That makes September 24’s Connect announcement more than a device update.
Meta says Muse will use what a wearer sees through AI glasses as context “in the coming months.”[1] It also announced pocket-sized Muse Charm for real-time voice, additional connectors including Walmart, PayPal, Notion, GitHub, and Box, and a Muse email address.[1]
Expedia was “coming soon”; Charm pricing and a ship date were not given.[1]

Keep those timelines separate: the launch announced a US rollout on iOS, Android, and web.[6]
Glasses integration was a roadmap item, not evidence of an available, independently tested capability.[1][6]

## Connecting an account is not approving every action

A connector links the agent to another service.[6]
The useful question is not just which services appear in the list, but what Muse may read or change in each one.

Meta’s launch post does describe controls.[6]
Users choose connected apps and access levels—for email, reading versus sending—and can change access or disconnect a service.[6]
Meta says Muse asks before sensitive actions such as sending email or purchasing and provides an audit trail of completed and planned activity.[6]

Meta also describes a separate Sentinel agent on the same machine, isolated from Muse at the system level, that approves outbound internet activity and requests user permission when needed.[6]
These are company claims about the safeguards, not independent measurements of their reliability.[6]

The distinction matters: granting access to an account and approving a particular action are different decisions.
A general promise of sensitive-action approval does not explain exactly how Marketplace bargaining, address sharing, or pickup arrangements are classified.
The reviewed announcements do not specify those cases.[1][6]

## Two reports test different boundaries

Matt Robb’s Threads account raises the action-approval question.[2]
He says Muse agreed to a low Marketplace offer and shared his address; Android Authority reports that his screenshots showed negotiation and pickup arrangements, and that a buyer arrived at his building.[2][4]

In his cited reply, Muse team member David Singleton said he had contacted Robb and offered to look into it.[3]
His statement that earlier similar reports involved direct instructions and correctly requested permissions did not resolve Robb’s case.[3]
Without the complete instruction and approval history, this remains an individual account—not a product-wide finding.[2][3][4]

The other report concerns access to the cloud computer itself.[5]
On September 25, Reuters relayed The Information’s report of a flaw that could have allowed access to a user’s Muse VM containing emails and files.[5] **The Information** reviewed the internal Meta incident report.[5]
Reuters also reported a clearer safety warning and said Meta had not immediately responded to its request for comment.[5]

A useful way to separate the issues: an approval prompt concerns what an agent may do for its owner; workspace protection concerns who can access its environment and data.
Neither safeguard substitutes for the other.
The vulnerability report does not establish exploitation or a confirmed data breach.[5][6]

<figure class="article-figure article-figure--compact">
  <div class="article-figure-scroll" tabindex="0" role="region" aria-label="Muse announcements and two distinct trust questions">
    <a href="{{ '/assets/images/articles/meta-muse-agent-trust/announced-surfaces.svg' | relative_url }}">
      <img src="{{ '/assets/images/articles/meta-muse-agent-trust/announced-surfaces.svg' | relative_url }}" width="400" height="780" loading="lazy" decoding="async" alt="Two distinct questions: did the user authorize the action, and who can access stored data? Robb’s Marketplace account concerns the first; the separate reported VM vulnerability concerns the second. Neither establishes a product-wide failure or confirmed breach.">
    </a>
  </div>
  <figcaption>
    LiteBites synthesis: <a href="https://about.fb.com/news/2026/09/the-biggest-news-from-connect-2026/">announcements</a>[1], <a href="https://www.androidauthority.com/meta-muse-ai-privacy-issues-3715963/">Marketplace reporting</a>[4], and <a href="https://www.ksl.com/article/51628738/meta-bolsters-muse-safety-warning-after-security-vulnerability-found-the-information-reports">VM reporting</a>[5]. Not an internal architecture diagram.
    <a href="{{ '/assets/images/articles/meta-muse-agent-trust/announced-surfaces.svg' | relative_url }}">Open full resolution ↗</a>
  </figcaption>
</figure>

## Before handing over a task

- **Inspect actual grants.** Check read versus send/write access, then confirm how to revoke it.[6]
- **Test approval behavior.** Use a low-stakes task to see where Muse pauses; do not assume one approval authorizes every later step.[2][3][6]
- **Check the audit trail.** Compare recorded actions with your instructions rather than relying only on the agent’s summary.[6]
- **Separate shipped protections from plans.** Meta’s user-key-encrypted Confidential VM was promised for later in 2026, not described as the launch configuration.[6]

*Correction and expansion, September 28: added Meta’s launch-described safeguards and clarified that The Information—not Reuters—reviewed the internal report. The cited reply does not establish an ongoing investigation.*

## Sources

[1] [Meta — The Biggest News From Connect 2026](https://about.fb.com/news/2026/09/the-biggest-news-from-connect-2026/)

[2] [Matt Robb on Threads — Muse Marketplace post](https://www.threads.com/@matt.j.robb/post/DdxwAJnDhNy)

[3] [David Singleton on X — Muse response](https://x.com/dps/status/2104403954235007302)

[4] [Android Authority — Meta Muse AI incident raises concerns about trusting AI agents](https://www.androidauthority.com/meta-muse-ai-privacy-issues-3715963/)

[5] [Reuters via KSL.com — Meta bolsters Muse safety warning after security vulnerability found](https://www.ksl.com/article/51628738/meta-bolsters-muse-safety-warning-after-security-vulnerability-found-the-information-reports)

[6] [Meta — Introducing Muse: The World’s First Personal AI Agent Built for Everyone](https://about.fb.com/news/2026/09/introducing-muse-personal-ai-agent/)
