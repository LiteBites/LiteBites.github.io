# Article Bite Validation Hardening

Use this checklist when changing `scripts/validate_article_bites.rb`, Article front matter, graph category behavior, or pre-publication tests.

## Adversarial metadata cases

A valid example is not enough. Add tests proving rejection of:

- whitespace-only required strings;
- numeric, boolean, empty, or whitespace-only tags;
- dates that are parseable but not exact `YYYY-MM-DD` values;
- non-HTTPS or malformed canonical and additional-source URLs;
- missing canonical `source_url` from the `## Sources` section, even if it appears elsewhere;
- missing, duplicated, reordered, or extra level-two headings;
- unresolved `TODO` or `TBD` markers;
- bodies outside 400–800 words;
- `card_image` without non-empty alt text;
- `card_image` traversal such as `/assets/images/articles/../../...`.

Canonicalize a local image candidate before checking its prefix and existence. A raw `start_with?` check before path normalization can accept `..` traversal.

## Graph category ordering

Do not alphabetically sort content types when the product order is semantic. Use an explicit rank:

```text
article: 0
paper: 1
dataset: 2
```

Apply it to every user-visible category surface, including navigation, filters, legends, accessible directories, and fallback content. Sorting labels with `localeCompare` produces Article, Data, Paper and violates the intended order.

## Accessibility checks

- Give related filter and view controls `role="group"` with accessible labels.
- Do not describe an SVG as a static image when it contains keyboard-focusable button nodes; expose it as an interactive group.
- Test keyboard node selection, filter state, no-JavaScript fallback, visible focus, and shape-based type distinctions.

## Review freshness

An asynchronous review describes the exact tree it inspected. If any file changes after dispatch—even to fix findings—the verdict is stale. Re-run tests and dispatch a fresh independent review against the current tree. Do not report the earlier verdict as approval.

For untracked implementation files, tell the reviewer to inspect those paths explicitly; `git diff` alone omits them.
