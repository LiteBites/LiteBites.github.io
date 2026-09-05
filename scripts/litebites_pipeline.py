#!/usr/bin/env python3
"""Local-first LiteBites source collection and evidence-bundle pipeline.

This tool deliberately stops before drafting. It performs deterministic work that
should not consume an LLM call: fetching and caching a source, extracting a
compact evidence bundle, inventorying publisher image candidates, and checking
bundle integrity. LLMs/subagents can consume the resulting evidence.json and
review-input.md only when editorial judgment is needed.
"""
from __future__ import annotations

import argparse
import hashlib
import html
import json
import os
import re
import sys
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from typing import Any
from urllib.parse import urljoin, urlparse
from urllib.request import Request, urlopen

USER_AGENT = "LiteBites-local-source-pipeline/1.0"
MAX_SOURCE_BYTES = 12 * 1024 * 1024
MAX_TEXT_CHARS = 16_000


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def normalize_url(url: str) -> str:
    parsed = urlparse(url.strip())
    if parsed.scheme not in {"http", "https"} or not parsed.netloc:
        raise ValueError("source URL must be an absolute HTTP(S) URL")
    return parsed._replace(fragment="").geturl()


def default_cache_dir() -> Path:
    configured = os.environ.get("LITEBITES_CACHE_DIR")
    if configured:
        return Path(configured).expanduser()
    xdg = os.environ.get("XDG_CACHE_HOME")
    if xdg:
        return Path(xdg).expanduser() / "litebites"
    return Path.home() / ".cache" / "litebites"


class SourceHTMLParser(HTMLParser):
    """Small, dependency-free extractor for source triage, not article parsing."""

    def __init__(self, base_url: str) -> None:
        super().__init__(convert_charrefs=True)
        self.base_url = base_url
        self.title_parts: list[str] = []
        self.text_parts: list[str] = []
        self.links: list[str] = []
        self.images: list[dict[str, str]] = []
        self.meta: dict[str, str] = {}
        self.canonical_url: str | None = None
        self._in_title = False
        self._skip_depth = 0

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attr_map = {key.lower(): value or "" for key, value in attrs}
        tag = tag.lower()
        if tag in {"script", "style", "noscript", "template", "svg"}:
            self._skip_depth += 1
            return
        if self._skip_depth:
            return
        if tag == "title":
            self._in_title = True
        if tag == "meta":
            key = attr_map.get("property") or attr_map.get("name") or attr_map.get("itemprop")
            value = attr_map.get("content")
            if key and value:
                self.meta[key.lower()] = value.strip()
        if tag == "link" and attr_map.get("rel", "").lower() == "canonical" and attr_map.get("href"):
            self.canonical_url = urljoin(self.base_url, attr_map["href"])
        if tag == "a" and attr_map.get("href"):
            self.links.append(urljoin(self.base_url, attr_map["href"]))
        if tag == "img" and attr_map.get("src"):
            self.images.append(
                {
                    "src": urljoin(self.base_url, attr_map["src"]),
                    "alt": attr_map.get("alt", "").strip(),
                    "width": attr_map.get("width", "").strip(),
                    "height": attr_map.get("height", "").strip(),
                }
            )

    def handle_endtag(self, tag: str) -> None:
        tag = tag.lower()
        if tag in {"script", "style", "noscript", "template", "svg"} and self._skip_depth:
            self._skip_depth -= 1
            return
        if tag == "title":
            self._in_title = False

    def handle_data(self, data: str) -> None:
        if self._skip_depth:
            return
        cleaned = re.sub(r"\s+", " ", html.unescape(data)).strip()
        if not cleaned:
            return
        if self._in_title:
            self.title_parts.append(cleaned)
        self.text_parts.append(cleaned)

    def result(self) -> dict[str, Any]:
        date_keys = (
            "article:published_time",
            "datepublished",
            "date",
            "publication_date",
            "pubdate",
        )
        publication_date = next((self.meta[key] for key in date_keys if key in self.meta), None)
        title = " ".join(self.title_parts).strip() or self.meta.get("og:title", "")
        visible_text = re.sub(r"\s+", " ", " ".join(self.text_parts)).strip()
        return {
            "title": title,
            "canonical_url": self.canonical_url or self.base_url,
            "description": self.meta.get("description") or self.meta.get("og:description", ""),
            "publication_date": publication_date or "",
            "text_excerpt": visible_text[:MAX_TEXT_CHARS],
            "text_characters": len(visible_text),
            "images": self.images,
            "links": sorted(set(self.links))[:250],
        }


def extract_source(body: bytes, content_type: str, final_url: str) -> dict[str, Any]:
    charset = "utf-8"
    match = re.search(r"charset=([^;\s]+)", content_type, flags=re.I)
    if match:
        charset = match.group(1).strip('"\'')
    try:
        text = body.decode(charset, errors="replace")
    except LookupError:
        text = body.decode("utf-8", errors="replace")
    if "html" not in content_type.lower() and not re.search(r"<html\b|<title\b", text, re.I):
        return {
            "title": "",
            "canonical_url": final_url,
            "description": "",
            "publication_date": "",
            "text_excerpt": re.sub(r"\s+", " ", text).strip()[:MAX_TEXT_CHARS],
            "text_characters": len(text),
            "images": [],
            "links": [],
        }
    parser = SourceHTMLParser(final_url)
    parser.feed(text)
    return parser.result()


def build_evidence(url: str, final_url: str, content_type: str, body: bytes) -> dict[str, Any]:
    source = extract_source(body, content_type, final_url)
    return {
        "schema": "litebites.evidence.v1",
        "source_url": url,
        "final_url": final_url,
        "content_type": content_type.split(";", 1)[0].strip().lower(),
        "source_sha256": sha256_bytes(body),
        "source_bytes": len(body),
        "title": source["title"],
        "canonical_url": source["canonical_url"],
        "description": source["description"],
        "publication_date": source["publication_date"],
        "text_excerpt": source["text_excerpt"],
        "text_characters": source["text_characters"],
        "image_candidates": source["images"],
        "link_count": len(source["links"]),
        "links": source["links"],
    }


def stable_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def render_review_input(evidence: dict[str, Any]) -> str:
    images = evidence.get("image_candidates", [])
    lines = [
        "# LiteBites Source Review Input",
        "",
        "This file is generated locally from a cached source. It is an input packet for editorial review, not evidence by itself.",
        "",
        f"- Source URL: {evidence['source_url']}",
        f"- Final URL: {evidence['final_url']}",
        f"- Canonical URL: {evidence['canonical_url']}",
        f"- Source SHA-256: `{evidence['source_sha256']}`",
        f"- Content type: `{evidence['content_type']}`",
        f"- Source bytes: {evidence['source_bytes']}",
        f"- Title: {evidence['title'] or '(not extracted)'}",
        f"- Publication date: {evidence['publication_date'] or '(not extracted)'}",
        "",
        "## Image candidates",
        "",
    ]
    if not images:
        lines.append("No image candidates were extracted. Do not infer that no images exist; inspect the canonical page if a figure would materially help.")
    else:
        for index, image in enumerate(images, 1):
            lines.extend([
                f"### Candidate {index}",
                f"- URL: {image['src']}",
                f"- Alt: {image['alt'] or '(empty)'}",
                f"- Declared dimensions: {image['width'] or '?'} × {image['height'] or '?'}",
                "",
            ])
    lines.extend([
        "## Extracted source text",
        "",
        evidence["text_excerpt"] or "(no text extracted)",
        "",
        "## Review boundary",
        "",
        "Confirm consequential claims against the canonical source and complete the Tier A image admission record before embedding any image.",
        "",
    ])
    return "\n".join(lines)


class SourceCache:
    def __init__(self, root: Path) -> None:
        self.root = root.expanduser()

    def entry_dir(self, url: str) -> Path:
        return self.root / sha256_bytes(url.encode("utf-8"))[:24]

    def collect(self, input_url: str, refresh: bool = False) -> tuple[Path, dict[str, Any], bool]:
        url = normalize_url(input_url)
        entry = self.entry_dir(url)
        source_path = entry / "source.bin"
        metadata_path = entry / "metadata.json"
        evidence_path = entry / "evidence.json"
        if not refresh and source_path.is_file() and metadata_path.is_file() and evidence_path.is_file():
            metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
            evidence = json.loads(evidence_path.read_text(encoding="utf-8"))
            validate_cached_entry(entry, evidence, requested_url=url, metadata=metadata)
            return entry, evidence, True
        request = Request(url, headers={"User-Agent": USER_AGENT, "Accept": "text/html,application/xhtml+xml,text/plain;q=0.8,*/*;q=0.1"})
        with urlopen(request, timeout=30) as response:
            body = response.read(MAX_SOURCE_BYTES + 1)
            if len(body) > MAX_SOURCE_BYTES:
                raise ValueError(f"source exceeds {MAX_SOURCE_BYTES} bytes")
            final_url = response.geturl()
            content_type = response.headers.get("Content-Type", "application/octet-stream")
        evidence = build_evidence(url, final_url, content_type, body)
        metadata = {
            "schema": "litebites.cache.v1",
            "source_url": url,
            "final_url": final_url,
            "content_type": content_type,
            "source_sha256": evidence["source_sha256"],
            "source_bytes": len(body),
            "fetched_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
        }
        entry.mkdir(parents=True, exist_ok=True)
        source_path.write_bytes(body)
        metadata_path.write_text(stable_json(metadata), encoding="utf-8")
        evidence_path.write_text(stable_json(evidence), encoding="utf-8")
        (entry / "review-input.md").write_text(render_review_input(evidence), encoding="utf-8")
        validate_cached_entry(entry, evidence)
        return entry, evidence, False


def validate_cached_entry(
    entry: Path,
    evidence: dict[str, Any],
    requested_url: str | None = None,
    metadata: dict[str, Any] | None = None,
) -> None:
    source_path = entry / "source.bin"
    metadata_path = entry / "metadata.json"
    metadata_record: dict[str, Any]
    if metadata is None:
        if not metadata_path.is_file():
            raise ValueError(f"cache integrity failure: missing {metadata_path}")
        metadata_record = json.loads(metadata_path.read_text(encoding="utf-8"))
    else:
        metadata_record = metadata
    try:
        expected_url = normalize_url(requested_url or evidence["source_url"])
        evidence_url = normalize_url(evidence["source_url"])
        metadata_url = normalize_url(metadata_record["source_url"])
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError("cache integrity failure: invalid source URL metadata") from exc
    if evidence_url != expected_url or metadata_url != expected_url:
        raise ValueError("cache integrity failure: requested URL does not match cache metadata")
    expected_entry = sha256_bytes(expected_url.encode("utf-8"))[:24]
    if entry.name != expected_entry:
        raise ValueError("cache integrity failure: cache directory does not match source URL")
    if metadata_record.get("final_url") != evidence.get("final_url"):
        raise ValueError("cache integrity failure: final URL metadata mismatch")
    if metadata_record.get("source_sha256") != evidence.get("source_sha256"):
        raise ValueError("cache integrity failure: metadata/evidence hash mismatch")
    if metadata_record.get("content_type", "").split(";", 1)[0].strip().lower() != evidence.get("content_type"):
        raise ValueError("cache integrity failure: content type metadata mismatch")
    if not source_path.is_file():
        raise ValueError(f"cache integrity failure: missing {source_path}")
    body = source_path.read_bytes()
    actual_hash = sha256_bytes(body)
    if actual_hash != evidence.get("source_sha256"):
        raise ValueError(f"cache integrity failure: {source_path}")
    if len(body) != evidence.get("source_bytes") or len(body) != metadata_record.get("source_bytes"):
        raise ValueError("cache integrity failure: source byte count mismatch")
    required = {"schema", "source_url", "final_url", "source_sha256", "content_type", "text_excerpt", "image_candidates"}
    missing = sorted(required - set(evidence))
    if missing:
        raise ValueError(f"evidence bundle missing fields: {', '.join(missing)}")
    if metadata_record.get("schema") != "litebites.cache.v1":
        raise ValueError("cache integrity failure: unsupported metadata schema")


def command_collect(args: argparse.Namespace) -> int:
    entry, evidence, cached = SourceCache(args.cache_dir).collect(args.url, refresh=args.refresh)
    print(stable_json({
        "cache_entry": str(entry),
        "cached": cached,
        "source_url": evidence["source_url"],
        "source_sha256": evidence["source_sha256"],
        "title": evidence["title"],
        "image_candidates": len(evidence["image_candidates"]),
        "review_input": str(entry / "review-input.md"),
    }), end="")
    return 0


def command_validate(args: argparse.Namespace) -> int:
    path = Path(args.evidence).expanduser().resolve()
    evidence = json.loads(path.read_text(encoding="utf-8"))
    validate_cached_entry(path.parent, evidence)
    regenerated = build_evidence(
        evidence["source_url"], evidence["final_url"], evidence["content_type"], (path.parent / "source.bin").read_bytes()
    )
    if stable_json(regenerated) != stable_json(evidence):
        raise ValueError(f"evidence bundle is stale or non-deterministic: {path}")
    print(f"PASS {path}")
    return 0


def command_review_input(args: argparse.Namespace) -> int:
    path = Path(args.evidence).expanduser().resolve()
    evidence = json.loads(path.read_text(encoding="utf-8"))
    output = Path(args.output).expanduser() if args.output else path.with_name("review-input.md")
    output.write_text(render_review_input(evidence), encoding="utf-8")
    print(output)
    return 0


def parser() -> argparse.ArgumentParser:
    root = argparse.ArgumentParser(description=__doc__)
    sub = root.add_subparsers(dest="command", required=True)
    collect = sub.add_parser("collect", help="fetch or reuse a cached source and evidence bundle")
    collect.add_argument("url")
    collect.add_argument("--cache-dir", type=Path, default=default_cache_dir())
    collect.add_argument("--refresh", action="store_true")
    collect.set_defaults(function=command_collect)
    validate = sub.add_parser("validate", help="verify cache integrity and deterministic evidence extraction")
    validate.add_argument("evidence", type=Path)
    validate.set_defaults(function=command_validate)
    review = sub.add_parser("review-input", help="regenerate the compact LLM/subagent input packet")
    review.add_argument("evidence", type=Path)
    review.add_argument("--output", type=Path)
    review.set_defaults(function=command_review_input)
    return root


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    try:
        return args.function(args)
    except KeyboardInterrupt:
        print("Interrupted", file=sys.stderr)
        return 130
    except Exception as exc:  # CLI boundary: concise failure, nonzero status.
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
