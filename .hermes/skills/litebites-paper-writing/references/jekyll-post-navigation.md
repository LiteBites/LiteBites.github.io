# Verifying Shared Jekyll Post Navigation

Use this reference when a LiteBites layout change adds automatic previous/next controls or another shared post-level navigation feature.

## Implementation pattern

- Put the navigation in `_layouts/post.html`, not in individual Markdown posts.
- Use semantic `<nav aria-label="…">` and real anchors.
- For the current all-Paper-Bites `site.posts` architecture, Jekyll exposes `page.previous` as the older post and `page.next` as the newer post; verify this in generated output rather than relying on memory.
- Add `rel="prev"` and `rel="next"` to neighboring links.
- Do not render empty placeholder anchors at chronological boundaries.
- Before adding an index escape route such as `/papers/`, inspect the global header. If the same destination is already prominent, omit the duplicate footer link; usefulness matters more than three-column symmetry.
- If future non-paper content enters `site.posts`, replace direct `page.previous`/`page.next` use with type-filtered neighbor selection.

## Layout rules

For the current two-part desktop layout (previous / next):

- Use `grid-template-columns: repeat(2, minmax(0, 1fr))`.
- Explicitly place previous in column 1 and next in column 2. Missing boundary links then leave only a non-interactive empty grid track, not an empty anchor.
- Apply `min-width: 0` and `overflow-wrap: anywhere` to title cards so long paper titles wrap.
- Stack both controls into one grid column at the repository mobile breakpoint.
- Preserve at least 44px interactive height.
- Separate hover and `:focus-visible` rules so keyboard outlines do not appear merely on pointer hover.
- Reuse existing theme variables; inspect both light and dark themes.

If a future design genuinely needs a unique index action, use `minmax(0, 1fr) auto minmax(0, 1fr)` and place it in the center only after confirming it does not duplicate global navigation.

## Generated-output checks

Build to a temporary destination outside the repository, then inspect three cases:

1. Newest post: older neighbor only; no newer neighbor.
2. Middle post: older and newer neighbors.
3. Oldest post: newer neighbor only; no older neighbor.

For every generated link verify:

- The target exists under the temporary `_site` destination.
- The displayed title matches the target post.
- `rel` matches the chronological direction.
- No empty anchor or duplicate navigation landmark exists.

A small Python `html.parser.HTMLParser` probe is sufficient; it avoids adding a parser dependency. Resolve every root-relative URL against the build destination and assert that directory URLs contain `index.html`.

## Responsive browser probe

When a shared layout changes visually, use a real browser engine rather than inferring mobile behavior from CSS alone. If the standard browser tool cannot change viewport size, use an isolated Playwright environment and an already available Chromium/Chrome channel. Keep the environment under `/tmp`, not in the repository.

Core assertions at 320px, 375px, and desktop width:

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(channel="chrome", headless=True)
    for width in (320, 375, 1280):
        page = browser.new_page(viewport={"width": width, "height": 812})
        page.goto(url, wait_until="networkidle")
        nav = page.locator("#paper-bite-navigation")
        boxes = [link.bounding_box() for link in nav.locator("a").all()]
        assert page.evaluate("document.documentElement.scrollWidth") == width
        assert all(
            box and box["x"] >= 0 and box["x"] + box["width"] <= width
            for box in boxes
        )
        page.close()
    browser.close()
```

Also capture element-only screenshots with `locator.screenshot(...)`; this makes desktop/mobile review concise instead of returning a full long-form article screenshot.

For dark theme, seed the existing theme preference before navigation, focus a card, and inspect both the screenshot and computed styles:

```python
page.add_init_script("localStorage.setItem('litebites-theme', 'dark')")
page.goto(url, wait_until="networkidle")
card = page.locator("#paper-bite-navigation a").first
card.focus()
styles = card.evaluate(
    "e => { const s = getComputedStyle(e); "
    "return { outline: s.outline, background: s.backgroundColor, border: s.borderColor }; }"
)
```

## Final scope gate

Before review:

```bash
git diff --check
git status --short
git diff --stat
```

A shared pagination feature should normally modify only `_layouts/post.html` and `assets/css/styles.css`. Confirm temporary lockfiles, dependency directories, and build output did not enter the repository. Provide desktop and mobile preview images, then stop before commit/push unless the user explicitly authorizes publishing.
