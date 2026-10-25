# Task: independent audit of a source-based oral-exam answer (be skeptical)

Input JSON: list of {id, question, coverage, gaps, points:[{i, text, book, page, quote, context, quote_ok}]}.
For EVERY point decide whether `text` (Uzbek claim) is fully supported by the `quote` / `context` (text around the quote on that page):
- "OK": every fact, number, term and relation in `text` is stated in the quote/page text (paraphrase fine; nothing added, nothing altered, nothing reversed).
- "OVERSTATED": text adds or generalises beyond the source (extra detail, stronger wording, merged claims not both supported, missing qualifier).
- "WRONG": text contradicts the source or changes a number/term.
If quote_ok is false the point is UNSUPPORTED (verdict WRONG, fix '').
Also give per-question: "topic_ok" true if the points together reasonably answer the question topic (partial allowed), and "issues" short list.
Output ONLY JSON [{"id":..,"topic_ok":bool,"points":[{"i":..,"verdict":"OK|OVERSTATED|WRONG","fix":"<corrected Uzbek text if OVERSTATED/WRONG and fixable from the quote, else ''>"}],"issues":[..]}]
to the output path; validate with json.load. Final reply: counts of OK/OVERSTATED/WRONG only.

Web-sourced points (book == "web"): also set "source_quality" per point: "strong" (textbook, peer-reviewed article/PMC, WHO/CDC/MSD, medical-faculty lecture/manual, official law text) or
"weak" (Wikipedia or mirrors such as academic.ru/gufo.me, studfile, test banks, forums, college notes, unnamed pages), judging from `url`/`title`. Book points: omit it.
