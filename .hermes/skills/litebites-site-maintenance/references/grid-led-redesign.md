# Grid-led redesign: prototype-to-Jekyll reference

Use this reference for large LiteBites visual redesigns that begin from an external reference site and need a local review checkpoint before publication.

## Design translation

Extract principles, not branded surfaces:

- strict modular grid and thin rules
- oversized editorial headlines on discovery pages
- compact mono metadata
- monochrome surfaces with one signal accent
- real research figures/dataset imagery instead of decorative illustrations
- pill controls only for compact global actions; square modules for content

Keep detail pages quieter than discovery pages. A Paper Bite should retain a readable line length, clear section rules, full-width figures inside the reading column, and title-aware Previous/Next navigation.

## Prototype checkpoint

1. Inspect the live reference visually; note transferable hierarchy, grid, type, spacing, color, image treatment, and responsive patterns.
2. Build a standalone HTML prototype under `/tmp`, not in the repository.
3. Use real LiteBites titles, summaries, tags, and existing local/public figure assets. Do not invent metrics or copy branded assets.
4. Serve the prototype locally and inspect desktop and mobile screenshots.
5. Check console errors, image loading, horizontal overflow, focus states, and reduced motion.
6. Show desktop/mobile previews and the HTML artifact. Wait for direction approval before editing production source.

## Jekyll mapping after approval

- `_layouts/default.html`: utility bar, global navigation, brand, theme control, footer, and existing analytics behavior.
- `index.html`: dynamic latest-post loop, archive preview, and editorial statement.
- `papers.html`: data-driven archive rows from `site.posts`.
- `data.html`: data-driven cards from `site.datasets`.
- `_layouts/post.html` and `_layouts/dataset.html`: preserve semantic detail-page structure; prefer adapting via shared CSS unless markup genuinely needs to change.
- `assets/css/styles.css`: tokens, grid primitives, responsive layouts, focus states, themes, and reduced motion.
- Post front matter: add `card_image` and `card_image_alt` only where a stable featured figure is needed. Templates must have a no-image fallback.

## Validation matrix

Build into a temporary destination, then test at least:

| Surface | Representative route |
|---|---|
| Home | `/` |
| Paper archive | `/papers/` |
| Data archive | `/data/` |
| Long-title Paper Bite | a post with an unbroken technical term |
| Data Bite detail | one generated dataset route |

Check each surface at 320px, approximately 390px, and desktop width. Assert:

- `document.documentElement.scrollWidth == viewport width`
- global `main`, navigation, and footer landmarks exist
- all images load after scrolling lazy images into view
- no page-level JavaScript exceptions
- theme toggle changes state and survives reload
- keyboard focus is visible
- long titles wrap without widening the document

Also parse generated HTML and verify root-relative internal links/assets resolve under the temporary Jekyll destination. Finish with `git diff --check`, a generated-artifact guard, and an exact modified-file report.

## Durable pitfalls

- Lazy images can report `naturalWidth == 0` while still offscreen. Scroll the page before declaring them broken.
- A long unbroken term can create only a few pixels of mobile overflow. Inspect the element whose `scrollWidth` exceeds `clientWidth`; use `overflow-wrap: anywhere` on meaningful titles.
- Global utility breadcrumbs should not grow to several lines on detail pages. Keep the first utility item `min-width: 0`, `white-space: nowrap`, `overflow: hidden`, and `text-overflow: ellipsis`.
- Do not paste standalone prototype HTML directly into Jekyll. Replace repeated prototype content with Liquid loops and shared layout structure.
- Large CSS rewrites need visual inspection of every page class, not only the homepage.
