---
layout: article
title: "Ponytail and Caveman Take Different Swings at the Cost of AI Coding Agents"
short_title: "Ponytail × Caveman"
date: 2026-09-08
type: "Article Bite"
read_time: "4 min read"
source_name: "Dietrich Gebert and Julius Brussee"
source_url: "https://github.com/dietrichgebert/ponytail"
source_published: 2026-09-08
last_reviewed: 2026-09-08
tags:
  - AI Coding Agents
  - Developer Tools
  - Token Efficiency
  - Open Source
summary: "Ponytail tries to stop coding agents from building unnecessary things, while Caveman compresses what agents say and read; together they expose two different bills hiding inside an AI coding session."
additional_sources:
  - name: "Caveman repository"
    url: "https://github.com/JuliusBrussee/caveman"
  - name: "Ponytail issue tracker"
    url: "https://github.com/dietrichgebert/ponytail/issues"
  - name: "Caveman issue tracker"
    url: "https://github.com/JuliusBrussee/caveman/issues"
---

## Two ways an agent wastes your budget

AI coding tools have at least two different efficiency problems. They can build more code than the task needs, and they can spend a surprising number of tokens narrating, rereading, and relaying work. Ponytail and Caveman approach those problems from opposite sides of the terminal.

Ponytail, Dietrich Gebert's repository, is an agent ruleset and plugin collection built around a blunt idea: the best code is often the code the agent never wrote. Its modes—lite, full, and ultra—push an always-on preference for smaller designs, fewer abstractions, and explicit resistance to speculative features. Review, audit, debt, and gain commands turn that preference into recurring checks rather than leaving it as a slogan.

Caveman, Julius Brussee's project, makes the agent talk less. Its small-rock option is a skill that shortens the prose around an answer while preserving code, commands, paths, and exact errors. Its big-rock option is a local proxy that compresses what the agent reads before sending it to a provider. The repository says the original payloads remain recoverable on the user's machine, which is a materially different promise from silently dropping context.

| Project | Main intervention | Claimed evidence | Important boundary |
| --- | --- | --- | --- |
| Ponytail | Reduce unnecessary implementation and process overhead | A bundled benchmark and review/audit commands | “Less code” is a design judgment, not automatically a faster or safer change |
| Caveman skill | Reduce generated prose | Ten-prompt comparison averaging 65% fewer output tokens | The skill's own rules add input tokens, and terse tasks may save little or lose money |
| Caveman proxy | Reduce repeated input such as logs and diffs | A pinned 54-run benchmark reporting 33.2% fewer input tokens | Compression depends on payload type; one HTML case in the README gets worse |

The distinction matters because a cheaper conversation is not necessarily a smaller patch. Caveman's README explicitly says its code-change count stays at zero in the skill comparison. Ponytail is trying to change the shape of the work; Caveman is trying to change the amount of text moving through the work.

## The README numbers come with their own warnings

Caveman is unusually direct about its numbers. The skill benchmark uses ten ordinary coding prompts and reports an average fall from 1,214 to 294 output tokens, but the repository warns that this excludes input and reasoning tokens and that the skill itself costs roughly 1,000–1,500 input tokens per turn. Its proxy benchmark reports 885,793 direct input tokens versus 591,673 through Caveman, while one dashboard-HTML case increases by 9.9%. Those caveats make the headline less exciting—and more useful.

Ponytail's pitch is less naturally reducible to one token percentage. Its value is closer to a review posture: ask whether a cache, abstraction, hook, or subsystem should exist at all. That can prevent maintenance cost, but it can also become overconfident minimalism if “do less” replaces understanding the requirements.

The issue trackers show the operational edge of both approaches. Ponytail has open reports about lifecycle-hook shell interpolation, security-sensitive paths being limited to one runnable check, and a Codex SessionStart behavior that can make a compacted session greet like a new one. Caveman's tracker includes reports about a browser wrapper leaking Chrome and temporary profiles on termination, a recovery handle intermittently disappearing from its SQLite-backed store, and a recent high-risk `caveman-setup` report. These are issue titles and active investigations, not proof that the projects are broadly unsafe; they are reminders that efficiency layers add lifecycle and recovery code of their own.

## Use the bill you can measure

The practical pairing is straightforward: Ponytail can challenge whether the agent should implement a proposed solution, while Caveman can reduce the tokens spent discussing and inspecting that solution. They may stack, and Ponytail's README even describes Caveman as a compatible complement: one shrinks what the agent builds, the other what it says.

Before adopting either, run a small local comparison. Record output and input tokens, wall-clock time, retries, changed lines, test results, and whether a human had to restore omitted context. Try a terse task and a log-heavy task, not only a benchmark-shaped prompt. For Ponytail, inspect whether the smaller implementation still preserves the requirement. For Caveman, verify that recovery works when compression is wrong or a process is interrupted. The useful question is not “which tool saves 65%?” It is “which part of this session is actually costing us money, time, or code?”

## Sources

- [Ponytail repository](https://github.com/dietrichgebert/ponytail)
- [Caveman repository](https://github.com/JuliusBrussee/caveman)
- [Ponytail issue tracker](https://github.com/dietrichgebert/ponytail/issues)
- [Ponytail issue #810: ponytail-debt comment matching](https://github.com/dietrichgebert/ponytail/issues/810)
- [Ponytail issue #821: Codex SessionStart after compact](https://github.com/dietrichgebert/ponytail/issues/821)
- [Ponytail issue #823: security-sensitive runnable checks](https://github.com/dietrichgebert/ponytail/issues/823)
- [Ponytail issue #824: lifecycle-hook shell interpolation](https://github.com/dietrichgebert/ponytail/issues/824)
- [Caveman issue tracker](https://github.com/JuliusBrussee/caveman/issues)
- [Caveman issue #1008: recovery handle intermittently missing](https://github.com/JuliusBrussee/caveman/issues/1008)
- [Caveman issue #1016: browser cleanup on SIGTERM](https://github.com/JuliusBrussee/caveman/issues/1016)
- [Caveman issue #1017: high-risk setup report](https://github.com/JuliusBrussee/caveman/issues/1017)
