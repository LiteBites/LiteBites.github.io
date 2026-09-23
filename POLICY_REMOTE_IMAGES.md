# LiteBites Remote Image Policy

This policy governs publisher-hosted inline images in all LiteBites public post types, including Article Bites, Paper Bites, and other editorial entries. It does not authorize remote card images, homepage thumbnails, graph assets, or other discovery-surface dependencies.

## Default decision

Remote images are allowed when they materially improve the explanation of a technical development, interface, architecture, workflow, or result. They are optional, not mandatory. Omit an image when provenance, permission, delivery, accessibility, or durability is unclear.

Use the exact original HTTPS asset referenced by the canonical source page. Do not capture screenshots, download publisher media into the repository, hotlink a visually similar asset, or use a remote image solely as decoration.

## Admission requirements

Every remote image must pass all of these checks before publication:

- The exact asset URL appears on the canonical source page.
- The asset is served from infrastructure controlled by the canonical publisher or clearly authorized media host.
- The publisher's terms, license, or asset-specific guidance provides a compatible permission basis for public display. Citation alone is not permission.
- The fetched bytes decode as the declared image format. Do not trust a filename suffix.
- The normal response uses an image content type such as `image/webp`, `image/jpeg`, `image/png`, `image/avif`, or `image/svg+xml`.
- A generic content type such as `application/octet-stream` is admissible only as a narrow exception when the payload signature is valid **and** a real browser successfully decodes the exact URL with nonzero intrinsic dimensions. A generic content type never overrides a browser failure.
- The image materially supports the adjacent prose and the prose remains understandable if the image disappears.
- The image has descriptive alt text and decoded intrinsic dimensions.
- The publisher's CDN successfully serves the image in the target deployment environment.
- The image renders at desktop and 320/390px mobile widths without page-level horizontal overflow.
- The request, privacy, and publisher-controlled durability trade-offs are disclosed at local review.

## Required markup

Use exactly one figure per remote image:

```html
<figure class="remote-publisher-image" data-source-url="https://publisher.example/article">
  <a href="https://media.publisher.example/figure.webp">
    <img
      src="https://media.publisher.example/figure.webp"
      width="1600"
      height="900"
      loading="lazy"
      decoding="async"
      referrerpolicy="no-referrer"
      alt="Specific description of the visual content and its relevant relationship.">
  </a>
  <figcaption>
    Explanation of what the image contributes.
    <a href="https://publisher.example/article">Canonical source page</a> ·
    <a href="https://media.publisher.example/figure.webp">Open full-resolution image ↗</a>
  </figcaption>
</figure>
```

The `data-source-url` value must appear as an exact link destination under the final `## Sources` section. Remote Markdown image syntax, `srcset`, `<picture>`, and `<source>` are not allowed. Remote images must never be used as `card_image` or another discovery-surface dependency.

## Review record

Before markup, record locally:

```text
decision: embed | omit
post_type: Article Bite | Paper Bite | other
canonical_page: <exact page URL>
asset_url: <exact image URL>
publisher_media_origin: <origin and control evidence>
permission_basis: <terms, license, or asset-specific permission>
technical_value: <what the image explains>
format_and_dimensions: <decoded format and intrinsic width × height>
content_type: <response content type>
browser_decode: <browser, complete, naturalWidth × naturalHeight>
privacy_and_durability: <request metadata and mutability notes>
```

If any field is unknown or unfavorable, choose `omit`. Keep the record local; it is a review artifact, not public metadata.

## Verification boundary

The normal Markdown validator remains deterministic and offline. It checks the markup contract, URLs, dimensions, alt text, and Sources linkage. A separate pre-publication media audit must check the network response, payload signature, decoded dimensions, browser rendering, responsive behavior, failure behavior, and console/request errors.

Do not claim a remote image is live merely because the URL returns HTTP 200. A successful deployment requires the exact live page to be loaded, the lazy image to be scrolled into view, and the browser to report successful decoding.

## Privacy and durability

`referrerpolicy="no-referrer"` prevents the image request from sending the Article URL as a referrer, but the publisher or CDN still receives the visitor's IP address, user agent, timing, and ordinary connection metadata. Image and caption links are separate navigations and may send a referrer unless controlled independently. The publisher can replace or remove the asset at any time.

## Failure behavior

If a publisher removes the asset, changes its response type, blocks delivery, or causes browser decoding to fail, remove the figure and retain the prose. Never substitute a screenshot, downloaded copy, or locally recreated promotional visual without a separate explicit and permission-compatible editorial decision.
