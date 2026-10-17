---
layout: article
title: "MarkItDown: When Document-to-Markdown Is Good Enough"
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
summary: "Microsoft's MarkItDown makes documents usable as Markdown for text-analysis pipelines, but a small DOCX/PDF test shows why structure, OCR, and input trust still need checking."
additional_sources:
  - name: "MarkItDown README and security considerations"
    url: "https://github.com/microsoft/markitdown"
---
A document can become Markdown without becoming a faithful copy of its original layout. That is the useful boundary of [Microsoft's MarkItDown](https://github.com/microsoft/markitdown): a Python library and CLI for preparing files for LLMs and other text-analysis tools. Its [September 21, 2026 v0.1.8 release](https://github.com/microsoft/markitdown/releases/tag/v0.1.8) mostly rolls up fixes; Microsoft expects typical output to remain largely unchanged from v0.1.7. This is a workflow to understand, not a dramatic new-model launch.

## Markdown for analysis, not an exact replica

The [README](https://github.com/microsoft/markitdown#readme) lists PDF, Word, PowerPoint, Excel, HTML, images, audio, and other inputs. Markdown keeps headings, lists, links, and tables readable as text, which is handy before retrieval or summarization. But the project explicitly aims at **text analysis**, not high-fidelity document conversion for human presentation. Format support also depends on optional packages: installing the base package alone is not the same as installing every converter.

That distinction matters if a document's visual layout carries meaning. A heading and a table can survive conversion differently from a PDF's positioned text. The [built-in and cloud-converter comparison](https://github.com/microsoft/markitdown#azure-content-understanding) distinguishes offline, format-specific extraction from billable Azure layout/OCR analysis. The separate `markitdown-ocr` plugin uses an LLM client for image text inside Office documents and PDFs; it is **not** automatic built-in OCR. Do not assume a scanned PDF will yield the words visible on its pages.

## A small DOCX/PDF smoke test

For a reproducible check, we ran the **v0.1.8** CLI locally on two tiny, synthetic documents with the same content: a DOCX with a level-one heading, sentence, and two-column table, and a PDF drawing those words at page coordinates. Neither used Azure, plugins, or an LLM. To try a local file yourself in a Python 3.10–3.14 virtual environment:

```bash
pip install 'markitdown[docx,pdf]==0.1.8'
markitdown review.docx -o review.md
```

The DOCX became a heading followed by the sentence and this Markdown table. Notice the **empty first row** before `Item | Owner`:

```md
# Quarterly review

The launch is on Tuesday.

|  |  |
| --- | --- |
| Item | Owner |
| Checklist | Alex |
```

The PDF preserved the words but produced plain lines, not a heading or table. These are observations from **our two constructed files**, not a quality score or a claim about all DOCX and PDF conversions. Inspect the output before using headings or tables as retrieval boundaries. For a scanned page or a complex layout, this tiny test says nothing about extraction quality.

## Where the convenience ends

MarkItDown's default `convert()` API accepts local files, remote URIs, and streams. The project's [security guidance](https://github.com/microsoft/markitdown#security-considerations) says it performs I/O with the privileges of your process. In a service, passing a user-supplied path or URL straight to it can expose local or internal resources; validate allowed paths, URI schemes, and destinations, or use the narrower `convert_local()` or `convert_stream()` APIs. **Local conversion of these test files did not use a cloud service**, but that is not a promise for every converter: URL inputs fetch remotely, and configured OCR, vision, or Azure routes can send data outside the process. Plugins are disabled by default and should be enabled only when the extra code and its data flow are understood.

For a research-paper PDF where layout and OCR are central, see our [MinerU field guide]({{ '/articles/mineru-papers-code-and-models/' | relative_url }}). The two tools are not compared on a common benchmark here; they answer different starting questions.

## Before you put it in a pipeline

- Install only the extras your formats need; pin the version when reproducibility matters.
- Compare source and Markdown on a few representative files, especially tables, ordering, and missing text.
- Decide whether OCR or a billable cloud service is appropriate before sending sensitive documents anywhere.
- Constrain untrusted paths and URLs; prefer the narrowest conversion method your application actually needs.

## Sources

- [MarkItDown v0.1.8 release — Microsoft, September 21, 2026](https://github.com/microsoft/markitdown/releases/tag/v0.1.8)
- [MarkItDown repository, installation, converter options, and security guidance](https://github.com/microsoft/markitdown)
