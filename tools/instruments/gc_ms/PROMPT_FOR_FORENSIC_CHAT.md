# Prompt (paste into the Forensic app chat together with this ZIP)

You have received `labguide_gc_pack.zip`: a ready, self-contained module "Gas chromatograph–mass spectrometer (GC-MS)" taken from the LabGuide app (Flutter, uz/ru/en). **Use it** in the Forensic app as follows.

## What is inside
- `assets/mass_spec_gc_1200.png`, `_480.png`, `mass_spec_gc.svg` — ORIGINAL class-level schematic drawn by LabGuide (own generator, no third-party image). 10 numbered part markers. NOT a manufacturer photo, NOT a specific model.
- `data/gc_ms_parts_3lang.json` — ready texts in uz/ru/en: title, alt text, "schematic — not a real model" caption + note, 10 parts (number, name, function), working principle, result.
- `data/gc_ms_catalog_card_and_sources.json` — LabGuide catalog card (technology, principle, specimens, tasks, QC note) and its source (`a3-statpearls-ms`, StatPearls, NCBI Bookshelf).
- `docs/` — per-part source / NEEDS_EXPERT table and SHA-256 provenance of the picture.
- `viewer.html` — open in a browser to see exactly how the picture + numbered legend must look (works on phone width).
- `reference_code/` — LabGuide Flutter sources (`schematic_parts.dart`, `instrument_image.dart`) and the generator (`gen_schematics.py`, `render.cjs`) for reference only; adapt to the Forensic app's own architecture, do not copy blindly.

## Task
1. Add a "GC-MS" screen/section to the Forensic app: the picture (tap = zoom/pan full screen, readable on phone and tablet, light and dark theme), caption + "not a real model" note directly under it, and a collapsible panel "Parts and working principle" listing numbered parts (name + function), then Working principle, then Result. Language follows the app language (uz/ru/en); all texts come from the JSON — do not retype or "improve" them.
2. Keep the caption and the "not a photo / not a specific model" note ALWAYS visible with the picture. Never label the picture as a photo of any manufacturer's instrument.
3. Do NOT invent forensic content. The sourced statement is only: GC-MS is used in forensic toxicology and drug testing (card `tasks`). Do not add chain-of-custody, legal-admissibility, cut-off values, validation claims, derivatization recipes, or case workflows unless the owner supplies sources. Mark any additional forensic text as `NEEDS_SOURCE` and keep it hidden until sourced.
4. Part texts that have no catalog source are textbook-level and marked NEEDS_EXPERT in `docs/` (e.g. electron ionisation, carrier gas, injector, transfer line). Keep an "expert review pending" status in your content registry; do not remove it yourself.
5. Keep provenance: record the SHA-256 of the PNG/SVG, source ids, and "original, created in LabGuide repo, 2026-10-25" in the Forensic app's own provenance doc. Verify the SHA-256 of the files you ship against `docs/`.
6. Tests: a unit test that every part number 1..10 has uz/ru/en name+function; a widget test that the caption/note is shown with the image; check 320 px width at 2.0 text scale for overflow in both themes. Report real results only (PASS / FAIL / NOT RUN); do not claim real-phone testing.
7. No paid CI, no store build, no push to main without the owner's explicit permission.

Report back: files changed, test output, screenshots (uz/ru/en, light/dark, 320 and 390 px), and anything marked NEEDS_EXPERT / NEEDS_SOURCE.
