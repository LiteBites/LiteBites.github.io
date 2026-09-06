---
layout: article
title: "slides-grab Treats AI Slide Generation as a Gated HTML Workflow"
short_title: "slides-grab"
date: 2026-09-04
type: "Article Bite"
read_time: "4 min read"
source_name: "NomaDamas"
source_url: "https://github.com/NomaDamas/slides-grab"
source_published: 2026-08-24
last_reviewed: 2026-09-05
tags:
  - Agentic AI
  - Developer Tools
  - Presentation Tools
summary: "NomaDamas' open-source slides-grab coordinates coding agents around editable HTML, browser validation, visual feedback, and a fingerprinted export gate, while leaving important network, model-provider, and format trade-offs to users."
additional_sources:
  - name: "slides-grab v1.5.1 release"
    url: "https://github.com/NomaDamas/slides-grab/releases/tag/v1.5.1"
  - name: "slides-grab v1.5.0 release"
    url: "https://github.com/NomaDamas/slides-grab/releases/tag/v1.5.0"
---

## The workflow change

NomaDamas released **slides-grab 1.5.1** on August 24, 2026. The open-source project packages agent skills and a Node.js command-line runtime for planning, generating, visually editing, validating, and exporting presentations with Claude Code or Codex. Instead of hiding a deck behind a hosted editor, it keeps one HTML file per slide, alongside deck-local assets.

Version 1.5.1 was a corrective release: it fixed card-news preview containment and repaired installation of the HTML and image skills. The larger workflow change arrived in 1.5.0, which split HTML and image-native editing, added template-pack import, and strengthened the pre-export design gate.

## Why the harness matters

The interesting part is not another route from a prompt to a deck. It is the **harness around the model**. Users can drag a box over a rendered slide, describe the desired change, and send the annotated screenshot plus instructions to a coding agent. The HTML remains inspectable, diffable, and manually editable afterward.

slides-grab also makes review state explicit. Before export through the public `slides-grab pdf`, `convert`, or `figma` commands, the CLI requires a design-gate receipt. The gate validates the deck, renders evidence images, checks the required structure of two user-supplied review reports, and fingerprints the slide HTML, referenced local assets, reports, and previews. Changes to those inputs block those CLI export paths until the gate is rerun. This is workflow control rather than a security boundary: invoking the underlying export scripts directly bypasses the receipt check.

## What gets checked—and what does not

The local runtime requires Node.js 20 or newer and Playwright Chromium. Its validator opens the HTML slides in a browser and checks conditions including overflow, sibling overlaps, clipped text, empty canvases, and missing or unsupported assets. Local files and data URLs satisfy the intended asset contract; remote image and video references, unsupported paths or schemes, and missing local assets are reported and block the normal CLI export paths. The editor’s HTML save route does not enforce that contract when writing a slide.

Export quality involves deliberate compromises. PDF capture mode and the default PPTX raster engine favor visual fidelity, but rasterization reduces searchability and editability. PDF print mode preserves browser text; the experimental PPTX text engine attempts best-effort DOM extraction. The project labels its PPTX and Figma paths experimental and warns users to expect layout shifts and manual cleanup. Hosted ChatGPT can use the packaged planning and design skills, but validation, editing, image generation, and export still need the local runtime and filesystem.

## Where the trade-offs show up

A successful upstream test workflow establishes that the checked code passes its automated suite; it does not establish presentation quality. The reviewed repository and releases provide no controlled comparison of visual fidelity, edit time, accessibility, or export reliability against other slide systems. The two-report gate is a reproducibility mechanism, not independent certification: its value depends on how honestly and carefully those reports are produced.

The local editor is a high-trust service. It listens without an explicit host restriction, and the reviewed implementation shows no authentication, authorization, or origin/CSRF control. Its routes can overwrite matching slide HTML, start or cancel edits, and disclose run prompts and logs. HTML edits launch Codex with approval and sandbox checks bypassed, or Claude in an edit-accepting mode, from the process working directory; the instruction to edit only one slide is a prompt, not an operating-system write boundary. Users should restrict the service with a host firewall to trusted local use and never expose it to untrusted users.

HTML editing can send an annotated full-slide screenshot, the user instruction, selected-element data, and local design context to Claude or Codex. Image generation sends prompts—and, on Codex reference-image paths, image data—to Codex, OpenAI, Gemini, or a configured compatible endpoint. The standalone image command may automatically fall back from Codex to another configured provider, so users should inspect available credentials and provider policies before processing confidential material. The default Codex image path uses an unsupported private backend that may change without notice.

## Before using it

- Keep generated decks in version control so HTML and asset changes remain reviewable.
- Treat a fresh design-gate receipt as change-control evidence, not proof of good design.
- Use HTML mode when editability and text extraction matter, assess accessibility separately, and test raster and text exports against the actual delivery format.
- Run the editor on a trusted machine and network, and review each model provider’s data handling before sending confidential slides.
- Budget for manual PowerPoint or Figma cleanup while those exporters remain experimental.

## Sources

- [NomaDamas — slides-grab repository](https://github.com/NomaDamas/slides-grab)
- [NomaDamas — slides-grab 1.5.1 release](https://github.com/NomaDamas/slides-grab/releases/tag/v1.5.1)
- [NomaDamas — slides-grab 1.5.0 release](https://github.com/NomaDamas/slides-grab/releases/tag/v1.5.0)
- [NomaDamas — design-gate implementation](https://github.com/NomaDamas/slides-grab/blob/b4434f12ca96097b24faded6c6003f216cd93885/src/design-gate-state.js)
- [NomaDamas — local editor server](https://github.com/NomaDamas/slides-grab/blob/b4434f12ca96097b24faded6c6003f216cd93885/scripts/editor-server.js)
- [NomaDamas — ChatGPT runtime boundary](https://github.com/NomaDamas/slides-grab/blob/b4434f12ca96097b24faded6c6003f216cd93885/CHATGPT.md)
- [NomaDamas — MIT License](https://github.com/NomaDamas/slides-grab/blob/main/LICENSE)
