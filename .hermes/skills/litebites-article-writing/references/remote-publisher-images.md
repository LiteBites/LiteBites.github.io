# Publisher-Hosted Inline Images

Use this reference whenever an Article Bite would benefit from an informative image that can remain at its canonical publisher-hosted URL. The site owner's standing preference is to render the verified original rather than download a repository copy. Images remain optional: propose the exact asset during local review, and omit it when it is decorative, unstable, untraceable, lacks compatible display permission, or adds no explanatory value. If no candidate is admissible, stop at prose plus a normal source link—do not capture a screenshot, download publisher media, or create a local presentation replacement.

## Admission checklist

- The figure materially explains architecture, evidence, an interface, or a result discussed in the Article.
- The URL is HTTPS and belongs to the canonical publisher's media infrastructure.
- The canonical source page uses the exact same asset URL; record that provenance and list the page under `## Sources`.
- The publisher's terms, robots/access behavior, or explicit media guidance do not prohibit direct embedding; if permission is unclear or the endpoint blocks third-party delivery, use a descriptive source link instead.
- The prose remains understandable if the publisher removes or replaces the image.
- The image is not used as `card_image` or another discovery-surface dependency.
- The local checkpoint names the exact image, source page, intrinsic dimensions, and third-party privacy/durability trade-off.

## Recommended markup

```html
<figure class="remote-publisher-image" data-source-url="https://publisher.example/canonical-article">
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

Use the asset's decoded intrinsic dimensions, not dimensions guessed from a rendered thumbnail. Preserve aspect ratio through responsive CSS. Use exactly one `<img>` per remote figure. Do not use Markdown image syntax, `<picture>`, `<source>`, or `srcset`; those forms bypass the validator's provenance and request-boundary checks. The `data-source-url` value must be HTTPS, match a link in the caption, and appear as an exact link destination under `## Sources`. The caption must also contain a visible link whose `href` exactly matches the image `src`.

## Verification

1. Run `ruby scripts/validate_article_bites.rb _articles/<slug>.md` and require `PASS`; do not bypass a remote-image validation failure.
2. Confirm the endpoint returns HTTP 200 and an expected image content type. Do not trust the filename suffix or response header alone: decode or identify the downloaded payload and record its actual format and intrinsic dimensions. A `.png` URL may serve JPEG bytes.
3. Inspect the canonical page's live DOM and record the exact `src`/`currentSrc`, not a visually similar URL inferred from a filename or CDN path. If several candidate URLs appear, hash the fetched payloads to detect aliases or duplicate images before treating them as distinct figures.
4. In a real browser, scroll the lazy image into view and assert `complete`, nonzero `naturalWidth` and `naturalHeight`, and the expected `currentSrc`.
5. Check 320px, 375/390px, and desktop widths in light and dark themes.
6. Assert no horizontal overflow, failed requests, or console errors.
7. Verify alt text, source-linked caption, and a visible full-resolution link. Dense technical diagrams may be too small on mobile; the full-resolution link is the fallback.
8. Simulate image failure. The preceding prose, alt text, caption, source link, and full-resolution link must retain the explanation and provenance.
9. Confirm no copy of the asset was added under repository image paths.

When no candidate passes permission review, still return a compact reject ledger for the strongest explanatory candidates: canonical page, exact asset URL, actual payload format and dimensions, provenance evidence, permission gap, editorial value, proposed placement/alt/caption if permission is later obtained, privacy host, and mutability risk. This distinguishes “useful but unlicensed” from decorative or technically unsuitable assets without weakening the fail-closed decision.

## Existing-post policy migrations

When applying this policy to several published Articles, migrate one Article at a time. For each Article: record its current figure and asset, decide between a fully admissible original-source embed and no figure, remove stale markup and repository assets, search for lingering references, and run the single-Article validator before continuing. After the sequence is complete, run the full Article tests, regenerate the graph twice, build to a temporary destination, and assert the expected figure and image count for every affected route. Keep publisher-hosted figures only when their provenance and permission evidence remain current.

## Privacy and durability disclosure

The image element's `referrerpolicy="no-referrer"` prevents the automatic image request from disclosing the Article URL, but that request still exposes the visitor's IP address, user agent, timing, and ordinary connection metadata to the publisher or CDN. The surrounding image link and caption links are separate navigations and may send a referrer unless they carry their own navigation policy; never imply that the image attribute governs those clicks. The publisher can also replace or remove the asset. Disclose the automatic-request, click-through, and durability trade-offs at the review checkpoint; do not call the embed privacy-neutral.

## Publication verification

A successful Pages build is not the same as a successful deployment. After push:

1. Identify the Pages workflow run for the pushed commit.
2. Verify its head SHA matches the commit.
3. Wait for the deployment job—not only the build job—to complete successfully.
4. Fetch the live Article with a cache-busting query and look for a revision-specific marker such as the full-resolution link text.
5. Load the live page in a browser, scroll the image into view, and recheck natural dimensions and request success.

If the deploy job remains queued, report that the commit is pushed but deployment is externally queued. Use a bounded background verifier that checks both workflow conclusion and the live marker; do not announce deployment before both pass.
