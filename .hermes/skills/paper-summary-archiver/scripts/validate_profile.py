#!/usr/bin/env python3
"""Validate a Paper Summary Archiver `.paper-archive.toml` profile."""

from __future__ import annotations

import argparse
import re
import sys
import tomllib
from pathlib import Path, PurePosixPath

ADAPTER_RE = re.compile(r"^[a-z][a-z0-9-]{0,63}$")
PLACEHOLDER_RE = re.compile(r"\{([a-z_][a-z0-9_]*)\}")
ALLOWED_PLACEHOLDERS = {
    "slug",
    "citekey",
    "published_date",
    "archive_date",
    "year",
    "month",
    "day",
}


class ProfileError(ValueError):
    pass


def require_table(data: dict, key: str) -> dict:
    value = data.get(key)
    if not isinstance(value, dict):
        raise ProfileError(f"[{key}] table is required")
    return value


def require_string(table: dict, key: str, context: str, *, allow_empty: bool = False) -> str:
    value = table.get(key)
    if not isinstance(value, str) or (not allow_empty and not value.strip()):
        raise ProfileError(f"{context}.{key} must be a non-empty string")
    return value


def require_string_list(table: dict, key: str, context: str, *, allow_empty: bool = False) -> list[str]:
    value = table.get(key)
    if not isinstance(value, list) or any(not isinstance(item, str) or not item.strip() for item in value):
        raise ProfileError(f"{context}.{key} must be a list of non-empty strings")
    if not allow_empty and not value:
        raise ProfileError(f"{context}.{key} must not be empty")
    return value


def validate_relative_template(value: str, context: str) -> None:
    normalized = value.replace("\\", "/")
    path = PurePosixPath(normalized)
    if path.is_absolute() or ".." in path.parts:
        raise ProfileError(f"{context} must stay inside the archive root")
    unknown = set(PLACEHOLDER_RE.findall(value)) - ALLOWED_PLACEHOLDERS
    if unknown:
        raise ProfileError(f"{context} contains unsupported placeholders: {sorted(unknown)}")


def validate_profile(path: Path) -> list[str]:
    try:
        with path.open("rb") as handle:
            data = tomllib.load(handle)
    except (OSError, tomllib.TOMLDecodeError) as exc:
        raise ProfileError(str(exc)) from exc

    if data.get("schema_version") != 1:
        raise ProfileError("schema_version must be 1")

    adapter = data.get("adapter")
    if not isinstance(adapter, str) or not ADAPTER_RE.fullmatch(adapter):
        raise ProfileError("adapter must be lowercase kebab-case and at most 64 characters")

    paths = require_table(data, "paths")
    content_dir = require_string(paths, "content_dir", "paths")
    assets_dir = require_string(paths, "assets_dir", "paths")
    filename = require_string(paths, "filename_template", "paths")
    validate_relative_template(content_dir, "paths.content_dir")
    validate_relative_template(assets_dir, "paths.assets_dir")
    validate_relative_template(filename, "paths.filename_template")
    if not filename.lower().endswith(".md"):
        raise ProfileError("paths.filename_template must end in .md")

    collision_policy = paths.get("collision_policy", "stop")
    if collision_policy not in {"stop", "revise", "suffix"}:
        raise ProfileError("paths.collision_policy must be stop, revise, or suffix")

    metadata = require_table(data, "metadata")
    required = require_string_list(metadata, "required", "metadata")
    field_map = metadata.get("field_map", {})
    if not isinstance(field_map, dict) or any(
        not isinstance(source, str)
        or not source.strip()
        or not isinstance(target, str)
        or not target.strip()
        for source, target in field_map.items()
    ):
        raise ProfileError("metadata.field_map must map non-empty semantic names to target field names")

    def target_field(semantic_name: str) -> str:
        return field_map.get(semantic_name, semantic_name)

    for semantic_name in ("title", "summary", "source_url"):
        target_name = target_field(semantic_name)
        if target_name not in required:
            raise ProfileError(
                f"metadata.required must include {target_name!r}, the target field for {semantic_name!r}"
            )
    if target_field("date") not in required and target_field("year") not in required:
        raise ProfileError(
            "metadata.required must include the mapped target for either 'date' or 'year'"
        )

    body = require_table(data, "body")
    sections = require_string_list(body, "sections", "body")
    if len(sections) != len(set(sections)):
        raise ProfileError("body.sections contains duplicates")
    minimum = body.get("min_words", 0)
    maximum = body.get("max_words", 0)
    if not isinstance(minimum, int) or not isinstance(maximum, int) or minimum < 0 or maximum < minimum:
        raise ProfileError("body min_words/max_words must be integers with 0 <= min <= max")

    figures = require_table(data, "figures")
    if figures.get("mode") not in {"none", "optional", "recommended", "required"}:
        raise ProfileError("figures.mode must be none, optional, recommended, or required")
    if figures.get("link_style") not in {"markdown", "liquid", "wikilink", "shortcode", "custom"}:
        raise ProfileError("figures.link_style is unsupported")

    hooks = data.get("hooks", {})
    if not isinstance(hooks, dict):
        raise ProfileError("[hooks] must be a table")
    after_write = hooks.get("after_write", [])
    if not isinstance(after_write, list):
        raise ProfileError("hooks.after_write must be an array of tables")
    hook_names: set[str] = set()
    for index, hook in enumerate(after_write):
        context = f"hooks.after_write[{index}]"
        if not isinstance(hook, dict):
            raise ProfileError(f"{context} must be a table")
        name = require_string(hook, "name", context)
        if name in hook_names:
            raise ProfileError(f"duplicate hook name: {name}")
        hook_names.add(name)
        command = require_string(hook, "command", context, allow_empty=True)
        enabled = hook.get("enabled", False)
        if not isinstance(enabled, bool):
            raise ProfileError(f"{context}.enabled must be boolean")
        if enabled and not command.strip():
            raise ProfileError(f"{context}.command is required when enabled")
        outputs = hook.get("expected_outputs", [])
        if not isinstance(outputs, list) or any(not isinstance(item, str) for item in outputs):
            raise ProfileError(f"{context}.expected_outputs must be a string list")
        for output in outputs:
            validate_relative_template(output, f"{context}.expected_outputs")

    validation = require_table(data, "validation")
    commands = validation.get("commands", [])
    if not isinstance(commands, list) or any(not isinstance(item, str) or not item.strip() for item in commands):
        raise ProfileError("validation.commands must be a list of non-empty strings")

    publishing = require_table(data, "publishing")
    if publishing.get("mode") not in {"review-only", "manual", "none"}:
        raise ProfileError("publishing.mode must be review-only, manual, or none")

    return [
        f"adapter={adapter}",
        f"content_dir={content_dir}",
        f"filename_template={filename}",
        f"sections={len(sections)}",
        f"after_write_hooks={len(after_write)}",
    ]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("profile", type=Path)
    args = parser.parse_args()
    try:
        summary = validate_profile(args.profile)
    except ProfileError as exc:
        print(f"INVALID: {exc}", file=sys.stderr)
        return 1
    print("VALID: " + " ".join(summary))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
