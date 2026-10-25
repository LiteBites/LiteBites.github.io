# Extracting original figures from versioned arXiv sources

Use this when the PDF is readable but the post needs the paper's original architecture or results figures at publication quality.

## Why use the source archive

A versioned arXiv e-print archive often contains the exact vector PDF/PNG assets referenced by `\includegraphics`. Reusing those assets avoids screenshot crops, preserves labels and legends, and makes figure provenance easy to audit.

## Procedure

1. Pin the paper version actually reviewed:

```bash
mkdir -p /tmp/<task>/source
curl -fsSL --max-time 120 'https://arxiv.org/pdf/<id>v<N>' -o /tmp/<task>/paper.pdf
curl -fsSL --max-time 120 'https://arxiv.org/e-print/<id>v<N>' -o /tmp/<task>/source.tar
```

2. Extract safely with Python rather than blindly trusting archive paths:

```python
import tarfile

with tarfile.open('/tmp/<task>/source.tar', 'r:*') as archive:
    archive.extractall('/tmp/<task>/source', filter='data')
```

3. Read the main TeX and included section files. Map each `\includegraphics{...}` occurrence to its nearby `\caption{...}` and `\label{...}`. Select figures for a specific teaching purpose, not merely because assets are available.

4. Prefer original raster images when they are already sufficiently large. For vector PDF figures, rasterize at high resolution in a task-local environment:

```bash
python3 -m venv /tmp/<task>/venv
/tmp/<task>/venv/bin/pip install pymupdf
```

```python
import pymupdf

source = '/tmp/<task>/source/images/figure.pdf'
out = '/tmp/<task>/figure.png'
doc = pymupdf.open(source)
pix = doc[0].get_pixmap(matrix=pymupdf.Matrix(3, 3), alpha=False)
pix.save(out)
```

Use `alpha=False` for figures designed on white paper. An opaque white canvas keeps black labels readable when LiteBites is viewed in dark mode. Preserve transparency only when visual inspection confirms that all marks remain legible on both themes.

5. Verify before copying into the repository:

- Compare the rendered image with the TeX caption and surrounding discussion.
- Check that no labels, legends, axes, arrows, or panel letters were cropped.
- Record pixel dimensions and file size.
- Inspect at desktop and narrow widths; source plots may be technically responsive but too dense to read on mobile.
- Write alt text that describes the visual structure and the comparison being made.
- Use a caption that identifies the paper figure number and explains why it matters.

6. Copy approved assets to the repository's paper-specific directory and keep all download, extraction, virtual-environment, and intermediate files under `/tmp`.

## Evidence-ledger entry

For each selected figure, record:

- source paper version;
- source archive filename;
- paper figure number/caption;
- transformation performed (for example, vector PDF to 3x opaque PNG);
- final repository filename;
- proposed alt text;
- what claim or explanation the figure supports.

## Pitfalls

- Do not silently use an unversioned source archive after reviewing a versioned PDF.
- Do not infer a figure's meaning from appearance alone; verify the TeX caption and surrounding prose.
- Do not recreate a graph when the source archive contains the original vector asset.
- Do not use transparent raster output by default for black-on-white academic figures on a site with dark mode.
- Do not crop a multi-panel result if the omitted panel changes how the paper's claim should be interpreted.
