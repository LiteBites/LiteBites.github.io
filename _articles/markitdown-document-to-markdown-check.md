---
layout: article
title: "MarkItDown: The Markdown Is Not the Document"
short_title: "MarkItDown: Check the Output"
date: 2026-10-17
type: "Article Bite"
read_time: "3 min read"
source_name: "Microsoft MarkItDown"
source_url: "https://github.com/microsoft/markitdown/releases/tag/v0.1.8"
source_published: 2026-09-21
last_reviewed: 2026-10-17
tags:
  - Document Parsing
  - Developer Tools
summary: "MarkItDown is useful for feeding document text to an LLM, not for guaranteeing layout or OCR: our tiny DOCX kept a heading, a text PDF lost structure, and an image-only PDF yielded no text."
additional_sources:
  - name: "MarkItDown v0.1.8 documentation and security guidance"
    url: "https://github.com/microsoft/markitdown/blob/v0.1.8/README.md"
  - name: "Built-in PDF converter implementation"
    url: "https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown/src/markitdown/converters/_pdf_converter.py"
  - name: "Built-in DOCX converter implementation"
    url: "https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown/src/markitdown/converters/_docx_converter.py"
  - name: "Optional OCR plugin documentation"
    url: "https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown-ocr/README.md"
---
**The quick take:** MarkItDown gives text-analysis systems Markdown, not a promise that every word or layout feature survived. In our three-file local check, one DOCX kept its heading, a text PDF lost that structure, and an image-only PDF produced an empty output. These are deliberately small examples, **not a benchmark**.

Microsoft's [v0.1.8 release](https://github.com/microsoft/markitdown/releases/tag/v0.1.8), published September 21, 2026, largely rolls up fixes rather than launching a new parser. The reason to look at the tool is its workflow: one Python library or CLI can turn [many input formats](https://github.com/microsoft/markitdown/blob/v0.1.8/README.md) into Markdown for LLMs and other text-processing systems. The question is what that common format leaves behind.

## Three files, three outcomes

We generated three **synthetic, one-page** files: a DOCX with a heading, sentence, and two-column table; a PDF with those words drawn as selectable text; and a PDF containing only an image of text. Then we ran the **v0.1.8 CLI** with `[docx,pdf]` extras and no plugin, LLM, or Azure integration. Here is the actual outcome, not a format-wide success rate:

<div class="paper-results-scroll" role="region" aria-label="MarkItDown v0.1.8 results on three synthetic documents" tabindex="0">
  <table class="paper-results-table">
    <caption>Our three-file local smoke test; swipe horizontally on small screens. No quality ranking across file types.</caption>
    <thead><tr><th scope="col">Input</th><th scope="col">Markdown output</th><th scope="col">Check before reuse</th></tr></thead>
    <tbody>
      <tr><th scope="row">DOCX</th><td>Heading, sentence, and table</td><td>An empty table header row appeared in this sample</td></tr>
      <tr><th scope="row">Text PDF</th><td>The words as plain lines</td><td>No heading or table structure in this sample</td></tr>
      <tr><th scope="row">Image-only PDF</th><td>Empty file</td><td>Text needs an OCR-capable route</td></tr>
    </tbody>
  </table>
</div>

The DOCX table's `Item | Owner` row was made from ordinary table cells, not explicitly marked as a header; it came through as **data**, below a blank Markdown header. The text PDF preserved `Quarterly review` and `The launch is on Tuesday.` but not a Markdown heading. This is why a quick look at generated text matters more than a supported-format checklist.

## Why the routes differ

The [DOCX converter](https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown/src/markitdown/converters/_docx_converter.py) passes the document through Mammoth's HTML conversion, then turns that HTML into Markdown, preserving styles and tables where possible. The [built-in PDF converter](https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown/src/markitdown/converters/_pdf_converter.py) extracts text using pdfplumber and pdfminer; it can recognize some form-style tables, so our plain-lines result **does not mean all PDF tables fail**. Neither path implies OCR for an image-only PDF.

If images contain needed words, the separately installed [MarkItDown OCR plugin](https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown-ocr/README.md) can process embedded images and scanned PDF pages **when configured with a vision-capable LLM client**. Microsoft also documents billable Azure conversion routes for layout analysis and OCR. Those are different data and cost decisions from our local built-in test. The project's own [README](https://github.com/microsoft/markitdown/blob/v0.1.8/README.md) targets text analysis rather than presentation-perfect conversion; our [MinerU guide]({{ '/articles/mineru-papers-code-and-models/' | relative_url }}) examines another PDF-oriented ecosystem, not a head-to-head benchmark.

## Run a safe first check

In a Python 3.10–3.14 virtual environment, install only the converters you need and inspect their output:

<div class="article-ascii-scroll" role="region" aria-label="MarkItDown installation and conversion commands; scroll horizontally if needed" tabindex="0">
  <pre><code>pip install 'markitdown[docx,pdf]==0.1.8'
markitdown review.docx -o review.md
markitdown review.pdf -o review-pdf.md</code></pre>
</div>
<p class="paper-results-note">On a narrow screen, swipe the commands sideways or focus this block and use the arrow keys.</p>

For production inputs, the [security guidance](https://github.com/microsoft/markitdown/blob/v0.1.8/README.md#security-considerations) matters too: permissive `convert()` can read local paths and fetch URLs with your process's privileges. A local DOCX/PDF run need not call a cloud service, but URL inputs and configured vision or Azure routes may send data outside your machine. Do not pass arbitrary user-controlled paths or URLs into a service; validate them and use narrower APIs such as `convert_local()` or `convert_stream()`.

- Check representative source/output pairs for missing text, reading order, and table semantics.
- Treat an empty scanned-PDF result as a signal to evaluate OCR, not as a successful conversion.
- Decide whether optional vision or cloud processing is acceptable for sensitive files.
- Restrict untrusted inputs before conversion; a file-to-Markdown library is not an access-control boundary.

## Sources

- [MarkItDown v0.1.8 release — Microsoft, September 21, 2026](https://github.com/microsoft/markitdown/releases/tag/v0.1.8)
- [MarkItDown v0.1.8 README, installation, Azure paths, and security guidance](https://github.com/microsoft/markitdown/blob/v0.1.8/README.md)
- [MarkItDown v0.1.8 DOCX converter](https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown/src/markitdown/converters/_docx_converter.py)
- [MarkItDown v0.1.8 PDF converter](https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown/src/markitdown/converters/_pdf_converter.py)
- [MarkItDown OCR plugin documentation](https://github.com/microsoft/markitdown/blob/v0.1.8/packages/markitdown-ocr/README.md)
