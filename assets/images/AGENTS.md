# assets/images/: repository images

| Bite | Folder | Front-matter field |
|---|---|---|
| Article | `assets/images/articles/<slug>/` | `card_image` + `card_image_alt` (optional) |
| Paper | `assets/images/papers/<slug>/` | `card_image` + `card_image_alt` (optional) |
| Data | `assets/images/datasets/<slug>.<ext>` | `image` + `image_alt` (optional) |

- Use simple, stable file names (`method-01.jpg`, `results-01.png`). Never rename a published file without updating every reference.
- Store an image only when its license or permission allows it. Record the license in the figure caption, as the existing papers do.
- Paper figures: complete and uncropped where labels matter; at most about two per post (`POLICY_POST.md`).
- LiteBites diagrams (`LiteBites synthesis`) are SVG or raster files in the article's folder. SVGs must have no scripts, event handlers, or external fetches; the validator checks this.
- Publisher images that stay remote are never downloaded into this folder (`POLICY_REMOTE_IMAGES.md`).
- No screenshots of build output, previews, or tests here.
