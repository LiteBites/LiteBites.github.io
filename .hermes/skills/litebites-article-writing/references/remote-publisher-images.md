# Publisher-Hosted Inline Images

Use this reference only when the site owner explicitly requests embedding a publisher-hosted original without storing a repository copy, and `POLICY_ARTICLE.md` permits the exception.

## Admission checklist

- The figure materially explains architecture, evidence, an interface, or a result discussed in the Article.
- The URL is HTTPS and belongs to the canonical publisher's media infrastructure.
- The canonical source page uses the same asset; record that provenance.
- The prose remains understandable if the publisher removes or replaces the image.
- The image is not used as `card_image` or another discovery-surface dependency.

## Recommended markup

```html
<figure>
  <a href="https://publisher.example/media/figure.webp">
    <img
      src="https://publisher.example/media/figure.webp"
      width="1999"
      height="1126"
      loading="lazy"
      decoding="async"
      referrerpolicy="no-referrer"
      alt="Concrete description of the diagram's components and relationships.">
  </a>
  <figcaption>
    Figure description. Image served from the publisher's original media URL;
    caption adapted from the
    <a href="https://publisher.example/canonical-article">canonical source</a>.
    <a href="https://publisher.example/media/figure.webp">Open full-resolution image ↗</a>
  </figcaption>
</figure>
```

Use the asset's decoded intrinsic dimensions, not dimensions guessed from a rendered thumbnail. Preserve aspect ratio through responsive CSS.

## Verification

1. Confirm the endpoint returns HTTP 200 and an expected image content type.
2. In a real browser, scroll the lazy image into view and assert `complete`, nonzero `naturalWidth` and `naturalHeight`, and the expected `currentSrc`.
3. Check 320px, 375/390px, and desktop widths in light and dark themes.
4. Assert no horizontal overflow, failed requests, or console errors.
5. Verify alt text, source-linked caption, and a visible full-resolution link. Dense technical diagrams may be too small on mobile; the full-resolution link is the fallback.
6. Simulate image failure. The preceding prose, alt text, caption, source link, and full-resolution link must retain the explanation and provenance.
7. Confirm no copy of the asset was added under repository image paths.

## Privacy and durability disclosure

`referrerpolicy="no-referrer"` prevents disclosure of the Article URL, but the remote request still exposes the visitor's IP address and ordinary request metadata to the publisher. The publisher can also replace or remove the asset. Disclose both trade-offs at the review checkpoint; do not claim that `no-referrer` eliminates the third-party request.

## Publication verification

A successful Pages build is not the same as a successful deployment. After push:

1. Identify the Pages workflow run for the pushed commit.
2. Verify its head SHA matches the commit.
3. Wait for the deployment job—not only the build job—to complete successfully.
4. Fetch the live Article with a cache-busting query and look for a revision-specific marker such as the full-resolution link text.
5. Load the live page in a browser, scroll the image into view, and recheck natural dimensions and request success.

If the deploy job remains queued, report that the commit is pushed but deployment is externally queued. Use a bounded background verifier that checks both workflow conclusion and the live marker; do not announce deployment before both pass.
