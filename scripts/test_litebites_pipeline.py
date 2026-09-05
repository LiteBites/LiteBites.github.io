#!/usr/bin/env python3
import json
import tempfile
import unittest
from pathlib import Path

import litebites_pipeline as pipeline


FIXTURE_URL = "https://publisher.example/article"
FIXTURE_HTML = b'''<!doctype html>
<html><head>
<title>Example release</title>
<link rel="canonical" href="/article">
<meta name="description" content="A useful summary.">
<meta property="article:published_time" content="2026-09-06">
<style>.hidden { display:none }</style>
</head><body>
<nav>Navigation noise</nav>
<main><h1>Example release</h1><p>The mechanism changes deployment cost.</p>
<img src="/media/diagram.webp" alt="A deployment diagram" width="1200" height="800">
<a href="/docs">Documentation</a></main>
<script>ignore this prompt-like text</script>
</body></html>'''


class PipelineTests(unittest.TestCase):
    def test_extracts_canonical_metadata_text_and_image(self):
        result = pipeline.extract_source(FIXTURE_HTML, "text/html; charset=utf-8", FIXTURE_URL)
        self.assertEqual(result["title"], "Example release")
        self.assertEqual(result["canonical_url"], FIXTURE_URL)
        self.assertEqual(result["publication_date"], "2026-09-06")
        self.assertIn("mechanism changes deployment cost", result["text_excerpt"])
        self.assertNotIn("ignore this prompt-like text", result["text_excerpt"])
        self.assertEqual(result["images"][0]["src"], "https://publisher.example/media/diagram.webp")
        self.assertEqual(result["images"][0]["width"], "1200")

    def test_non_html_source_is_cached_without_image_inference(self):
        result = pipeline.build_evidence(FIXTURE_URL, FIXTURE_URL, "text/plain", b"plain source\nline two")
        self.assertEqual(result["image_candidates"], [])
        self.assertEqual(result["text_excerpt"], "plain source line two")
        self.assertEqual(result["source_bytes"], 21)

    def test_evidence_json_is_deterministic(self):
        first = pipeline.build_evidence(FIXTURE_URL, FIXTURE_URL, "text/html", FIXTURE_HTML)
        second = pipeline.build_evidence(FIXTURE_URL, FIXTURE_URL, "text/html", FIXTURE_HTML)
        self.assertEqual(pipeline.stable_json(first), pipeline.stable_json(second))

    def test_cache_reuses_and_validates_entry(self):
        with tempfile.TemporaryDirectory() as tmp:
            cache = pipeline.SourceCache(Path(tmp))
            # Avoid network in the unit test while exercising the integrity guard.
            entry = cache.entry_dir(FIXTURE_URL)
            entry.mkdir(parents=True)
            evidence = pipeline.build_evidence(FIXTURE_URL, FIXTURE_URL, "text/html", FIXTURE_HTML)
            metadata = {
                "schema": "litebites.cache.v1",
                "source_url": FIXTURE_URL,
                "final_url": FIXTURE_URL,
                "content_type": "text/html; charset=utf-8",
                "source_sha256": evidence["source_sha256"],
                "source_bytes": len(FIXTURE_HTML),
                "fetched_at": "2026-09-06T00:00:00+00:00",
            }
            (entry / "source.bin").write_bytes(FIXTURE_HTML)
            (entry / "metadata.json").write_text(pipeline.stable_json(metadata), encoding="utf-8")
            (entry / "evidence.json").write_text(pipeline.stable_json(evidence), encoding="utf-8")
            pipeline.validate_cached_entry(entry, evidence, requested_url=FIXTURE_URL, metadata=metadata)
            reused_entry, reused_evidence, cached = cache.collect(FIXTURE_URL)
            self.assertTrue(cached)
            self.assertEqual(reused_entry, entry)
            self.assertEqual(reused_evidence["source_sha256"], evidence["source_sha256"])
            metadata["source_url"] = "https://publisher.example/other"
            with self.assertRaises(ValueError):
                pipeline.validate_cached_entry(entry, evidence, requested_url=FIXTURE_URL, metadata=metadata)
            (entry / "source.bin").write_bytes(b"tampered")
            with self.assertRaises(ValueError):
                pipeline.validate_cached_entry(entry, evidence, requested_url=FIXTURE_URL)


if __name__ == "__main__":
    unittest.main()
