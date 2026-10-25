# Task: find the correct answer to multiple-choice questions from AUTHORITATIVE WORLD LITERATURE (web)

Input: JSON list [{n, q, options:[4 strings]}] (Uzbek, Latin script; official attestation test bank for pathological
anatomy / forensic medicine / forensic chemistry). Question wording is sometimes clumsy or has typos; understand the
intended medical concept, translate it to English/Russian terms, and search.

For each question decide which option (index 0..3) is correct, using WebSearch + WebFetch ONLY (not memory):
1. Find a source that DIRECTLY states the fact. Acceptable: NCBI Bookshelf (StatPearls, Robbins/Kumar excerpts, other open books),
   PubMed/PMC review articles, WHO/IARC/CDC, Merck Manual, Radiopaedia/Pathology Outlines (pathologyoutlines.com), university
   open course pages, official Uzbek law texts on lex.uz / gov.uz for legal questions. Avoid forums, Wikipedia-only answers
   (Wikipedia allowed ONLY when it cites a standard textbook and states the fact plainly - then prefer the cited primary source).
2. WebFetch the page and copy a VERBATIM quote (<=300 chars, original language of the source) that states the fact. Do not
   fabricate quotes: the quote must literally appear in the fetched text.
3. key = index of the option that matches the quote. If matching requires a terminology leap, elimination of the others, or the
   question is ambiguous / has two correct options / options are garbled -> key = null with a short reason. Never guess.
4. Uzbek-specific content (Uzbek laws, Uzbek ministry orders, local standards): use lex.uz/gov.uz text. Article numbers must
   match the CURRENT edition of the cited law.
5. Output: ONLY a JSON file at the path given, list in input order, one entry per question:
   {"n":1,"key":2,"url":"https://...","title":"<source title, publisher, year>","quote":"...","lang":"en","mapped":false,"reason":""}
   mapped=true when the source uses different (English/Russian) terminology than the option (a direct translation, not a leap).
   For key=null: {"n":..,"key":null,"url":null,"title":"","quote":"","lang":"","mapped":false,"reason":"..."}.
6. Be efficient: reuse a good source for several questions (e.g. one StatPearls chapter). Budget ~6 tool calls per question max.
   Write the output file incrementally (rewrite the complete valid JSON after every ~10 questions) so nothing is lost.
   Validate with `python3 -c "import json;json.load(open(PATH))"`. Final reply: counts only (keyed / null).
