# Slug and URL Consistency

Use this reference when an Article Bite subject contains punctuation, version dots, slashes, spaces, symbols, or mixed casing.

## Failure mode

Different parts of a static-site pipeline may derive slugs differently:

- Jekyll can normalize punctuation in a collection document's rendered permalink.
- A custom knowledge-graph generator may preserve the raw filename basename.
- An index template may use Jekyll's computed `url`, while graph JSON constructs `/articles/<basename>/` itself.

This can produce a page that builds and appears in the archive while the graph's **Open Bite** link returns 404.

Example:

```text
Source name:        GLM-5.3-Flash
Unsafe filename:   _articles/glm-5.3-flash.md
Jekyll URL:        /articles/glm-5-3-flash/
Raw-basename URL:  /articles/glm-5.3-flash/
```

## Prevention

Normalize the filename before drafting:

1. lowercase ASCII letters;
2. replace every punctuation/whitespace run with one hyphen;
3. trim leading/trailing hyphens;
4. allow only `^[a-z0-9]+(?:-[a-z0-9]+)*$` before `.md`.

Safe example:

```text
_articles/glm-5-3-flash.md
/articles/glm-5-3-flash/
article:glm-5-3-flash
```

Do not solve this by adding a one-off front-matter permalink unless repository policy intentionally supports it; one canonical slug should drive the filename, Jekyll URL, graph id, graph URL, asset directory, and review commands.

## Verification

After generating the graph and building the site, compare—not infer—all representations:

```text
filename basename
rendered Article archive href
built page path
knowledge-graph node slug
knowledge-graph node id
knowledge-graph node url
inspector Open Bite href
```

Require:

```text
archive href == graph node url == inspector href == HTTP-200 built page path
```

Also assert exactly one graph node exists for the slug. Click the visible SVG node shape, then verify the selected state, inspector title, and exact href. A successful Jekyll build alone is not sufficient.

## Repair pattern

For an uncommitted new Article, rename the source file to the normalized slug, regenerate the graph twice, rebuild, and re-run URL/interaction checks. For an already published Article, treat a slug change as a migration: preserve or redirect the old public URL according to repository policy rather than silently breaking inbound links.
