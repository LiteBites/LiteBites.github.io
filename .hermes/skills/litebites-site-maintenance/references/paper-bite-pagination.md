# Paper Bite title-card pagination

A proven implementation for bottom-of-post chronological navigation in LiteBites.

## Source files

- `_layouts/post.html`
- `assets/css/styles.css`

No post Markdown, JavaScript, dependency, or configuration file is required.

## Markup pattern

Place the navigation after `.post-body` and before the closing `</article>`:

```liquid
{% if page.previous or page.next %}
  <nav id="paper-bite-navigation" class="post-pagination" aria-label="Paper Bite navigation">
    <div class="post-pagination-links">
      {% if page.previous %}
        <a class="post-pagination-card post-pagination-previous"
           href="{{ page.previous.url | relative_url }}" rel="prev">
          <span class="post-pagination-label">← Previous</span>
          <span class="post-pagination-title">{{ page.previous.title }}</span>
        </a>
      {% endif %}

      {% if page.next %}
        <a class="post-pagination-card post-pagination-next"
           href="{{ page.next.url | relative_url }}" rel="next">
          <span class="post-pagination-label">Next →</span>
          <span class="post-pagination-title">{{ page.next.title }}</span>
        </a>
      {% endif %}
    </div>
  </nav>
{% endif %}
```

Do not add an “All Paper Bites” link here: the global header already supplies the Paper Bites index control, and the user prefers not to duplicate that function.

## Layout behavior

Desktop:

```css
.post-pagination-links {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
}
.post-pagination-previous { grid-column: 1; }
.post-pagination-next { grid-column: 2; text-align: right; }
```

This keeps the single available previous card left-aligned on the newest post and the single available next card right-aligned on the oldest post without empty links.

Mobile at `max-width: 760px`:

```css
.post-pagination-links { grid-template-columns: 1fr; }
.post-pagination-previous,
.post-pagination-next { grid-column: 1; }
.post-pagination-next { text-align: left; }
```

Cards should use the existing surface, border, radius, ink, faint, and active-background variables; wrap long titles; expose a visible `:focus-visible` outline; and maintain a minimum touch height.

## Verification matrix

| Case | Expected links |
|---|---|
| Newest (`slm-agents`) | one `rel="prev"` link |
| Middle (`pagedattention`) | `rel="prev"`, then `rel="next"` |
| Oldest (`vit-comer`) | one `rel="next"` link |

Representative expected destinations when recorded:

- `slm-agents` previous → `pagedattention`
- `pagedattention` previous → `mmr-ad`
- `pagedattention` next → `slm-agents`
- `vit-comer` next → `controlnet`

The post set will evolve, so use these only as a sanity example; derive current expected neighbors from generated output.

## Responsive probe

A Playwright probe can verify link containment and overflow at 320, 375, and 1280px:

```python
for width in (320, 375, 1280):
    page = browser.new_page(viewport={"width": width, "height": 812})
    page.goto(base + "pagedattention/", wait_until="networkidle")
    nav = page.locator("#paper-bite-navigation")
    boxes = [a.bounding_box() for a in nav.locator("a").all()]
    assert page.evaluate("document.documentElement.scrollWidth") == width
    assert all(
        box and box["x"] >= 0 and box["x"] + box["width"] <= width
        for box in boxes
    )
```

Also capture element-level screenshots with `nav.screenshot(...)` for concise desktop/mobile review previews.

## Deployment verification

After an explicitly approved push, poll a cache-busted live post URL until all are true:

- `id="paper-bite-navigation"` appears.
- Expected `post-pagination-previous` / `post-pagination-next` markup appears.
- The removed `All Paper Bites` text does not appear inside the pager.

Finally inspect the live DOM and verify link text, `href`, and `rel` values.
