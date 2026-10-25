# Browser Verification

`scripts/litebites check` proves the site builds. It does not prove pages look or behave right. Use this for any layout, CSS, include, navigation, or graph-UI change, and for spot-checking new Bites.

## Route matrix

| Surface | Route |
|---|---|
| Home | `/` |
| Archives | `/articles/`, `/papers/`, `/data/` |
| Graph | `/graph/` |
| Detail pages | one Article, one Paper (prefer a long unbroken title), one Data Bite |
| Changed pages | every page class the change touches |

Check each at 320px, ~375/390px, and desktop (~1280px), in light and dark themes.

## Assertions

- `document.documentElement.scrollWidth == clientWidth` (no horizontal overflow). If it fails, find the element whose `scrollWidth > clientWidth`; long unbroken titles need `overflow-wrap: anywhere` and `min-width: 0` on grid children; oversized single display words may need a smaller mobile size.
- `main`, navigation, and footer landmarks exist; headings are in order.
- Interactive targets are at least 44px high; keyboard focus is visible (`:focus-visible`, not hover-only).
- No console errors or failed requests.
- Images load after being scrolled into view (lazy images report `naturalWidth == 0` while offscreen; that is not a failure).
- Theme toggle changes state and survives reload.
- Root-relative internal links and assets resolve: parse built HTML (Python `html.parser` is enough) and check each URL maps to a file under the build destination (`index.html` for directory URLs).

## Playwright probe

Keep any Playwright environment under `/tmp`, never in the repo. Use an installed Chrome channel when available.

```python
from playwright.sync_api import sync_playwright

with sync_playwright() as p:
    browser = p.chromium.launch(channel="chrome", headless=True)
    for width in (320, 375, 1280):
        page = browser.new_page(viewport={"width": width, "height": 812})
        page.add_init_script("localStorage.setItem('litebites-theme', 'dark')")  # omit for light
        page.goto(url, wait_until="networkidle")
        assert page.evaluate("document.documentElement.scrollWidth") == width
        page.locator("main").screenshot(path=f"/tmp/shot-{width}.png")
        page.close()
    browser.close()
```

Prefer element screenshots (`locator.screenshot`) over full long-page shots for review previews. If the available browser tool cannot set the viewport, load the page in same-origin iframes of the target widths; each iframe gets real media queries.

## Post navigation (Paper Bites)

Previous/next lives in `_layouts/post.html`. In the current `site.posts` (Paper Bites only), `page.previous` is the older post and `page.next` the newer one; verify in generated output. Check the newest (older link only), a middle, and the oldest (newer link only) post: targets exist, titles match, `rel` matches direction, and no empty anchors render at boundaries. If non-paper content ever enters `site.posts`, switch to type-filtered neighbors.

## Design conventions to preserve

Grid-led editorial system: thin rules, square modules, oversized uppercase display type on discovery pages, IBM Plex Sans for reading and IBM Plex Mono for metadata, one signal-green accent. Detail pages stay quiet with a readable measure. Reuse CSS tokens (`--bg`, `--surface`, `--ink`, `--muted`, `--faint`, `--line`, `--line-strong`, `--signal`, `--grid-bg`, `--image-bg`) instead of literal colours. Do not duplicate a destination the global header already provides. Never use invisible placeholder links; explicit grid columns can keep alignment instead.

## Reference-inspired redesigns

Extract principles (grid, hierarchy, type posture, density, image treatment), never branded assets or code. When taste is the main decision, prototype as standalone HTML under `/tmp` with real LiteBites content, show desktop/mobile previews, and wait for approval. Then translate into shared layouts and Liquid loops; do not paste the prototype.
