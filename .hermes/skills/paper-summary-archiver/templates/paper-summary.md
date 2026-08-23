---
title: "{{ canonical_title }}"
date: {{ publication_or_archive_date }}
authors:
  - "{{ author_name }}"
venue: "{{ verified_venue_or_status }}"
summary: "{{ one_sentence_summary }}"
tags:
  - "{{ canonical_topic }}"
source_url: "{{ canonical_paper_url }}"
---

# {{ canonical_title }}

## Why it matters

Explain the practical or scientific problem and why the paper is worth understanding. Keep claims scoped to the source.

## Core idea

State the central idea in plain technical language before introducing module names or implementation detail.

## How it works

Describe the information flow, training or inference procedure, and the components necessary to understand the contribution.

<!-- Optional figure. Adapt syntax to the target adapter. -->

![Descriptive alternative text](relative/path/to/method-figure.png)

*Source: paper figure number/page. Explain what the reader should notice.*

## Evidence

Explain the evaluation setup and the comparisons that matter. Identify which results are produced by this paper and which come from cited prior work. For a non-experimental paper, describe its actual evidence type instead.

## Limitations

State meaningful scope conditions, unresolved questions, or limitations supported by the paper.

## Practical takeaways

- Add a concrete lesson that transfers beyond the benchmark.
- Add an implementation or evaluation consideration.
- Add a caution against overgeneralizing the result.

## Sources

- [Paper]({{ canonical_paper_url }})
- [Project]({{ optional_project_url }})
- [Code]({{ optional_code_url }})
