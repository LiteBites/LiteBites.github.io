# LiteBites Data Bite Policy

Data Bites are short, practical cards about public datasets: what the dataset contains, what it is good for, and what to check before using it. This policy covers editorial judgment. Field rules (required front matter, word range, image location, tags) live in `_data/bite_schema.yml` (`types.data`) and are enforced by `scripts/litebites validate`.

## Scope

Write a Data Bite for a dataset that LiteBites readers are likely to use or meet in papers: benchmarks, training corpora, and evaluation suites in AI and computer science. Do not write one for a dataset that cannot be obtained, or whose license you cannot find.

## Evidence

Use the dataset owner's own page, repository, paper, or license file as the source for every fact. Verify:

- **Owner and canonical URL** (`dataset_url`). Prefer the owner's page over a mirror.
- **Task and domain.** Use the owner's wording for the intended task.
- **Scale.** Counts with their unit (images, documents, hours, subjects). Name the subset when counts differ between subsets.
- **License and access.** The exact license name per subset, plus any registration, request, or non-commercial terms. If subsets differ, say so in `caveat`.
- **Known limits.** Label noise, domain shift, demographic gaps, deprecation, or "not for clinical use" statements made by the owner or by reputable follow-up work.

If a fact cannot be verified, leave it out rather than estimate it.

## Writing

- `summary`: one sentence on what the dataset is and why someone would use it.
- `use_for`: a short comma-separated list of concrete uses.
- `caveat`: the single most important thing to check before use. A license restriction or an owner warning comes first.
- Body: two or three short paragraphs. Explain what makes the dataset useful and how it is usually evaluated. Do not repeat the facts list; the layout renders it.
- Tone and voice follow `POLICY_POST.md` (plain, concrete, no hype).

## Images

An image is optional. Use one only when the license allows it, store it under `assets/images/datasets/<slug>.<ext>`, and describe it in `image_alt`. Remote publisher images follow `POLICY_REMOTE_IMAGES.md`.

## Review

Set `last_reviewed` when facts are checked. Licenses and access terms change, so re-check them before linking a Data Bite from new work.
