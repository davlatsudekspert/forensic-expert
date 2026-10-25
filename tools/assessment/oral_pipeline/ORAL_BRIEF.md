# Task: write source-based ANSWERS to official oral-exam questions (Uzbek), strictly from the provided books

Input: JSON list [{id, text}] — oral exam question topics (Uzbek, Latin) for a medical specialty. No answers exist officially.
You write a short, accurate study answer for each, built ONLY from the book text files given in your assignment (OCR'd, page-marked
"=====[book] PDF-SAHIFA N====="). Use `python3 W/search_books.py <tib|kimyo|all> "keywords" [top]` and grep/Read to find pages;
Read the surrounding pages fully before writing. OCR noise ("b o iib", "ulaming") is normal: when you quote, copy the text VERBATIM
as it appears (do not fix OCR) — quotes are machine-checked against the page text.

Hard rules (a wrong statement in a medical exam-prep product is worse than a missing answer):
1. Every factual statement in the answer must be supported by a verbatim quote (<=300 chars) from a specific PDF page. No outside knowledge,
   no "common sense" additions, no numbers/dates/names that are not in the quoted text.
2. Write the answer in clear literary Uzbek (Latin), 4–12 short points. Each point = one claim + its source:
   {"text": "<claim in your own words, Uzbek>", "book": "<book id>", "page": <PDF page>, "quote": "<verbatim, <=300 chars>"}
   You may merge 2 adjacent sentences in one point if one quote supports both.
3. Do not translate or change terminology/numbers; keep figures exactly as in the quote.
4. coverage: "full" = the books answer the question topic well (the main aspects); "partial" = only some aspects (then list the missing aspects in
   "gaps" in Uzbek, e.g. ["tarix", "qonuniy asos"]); "none" = books do not cover it -> points = [] (do NOT improvise).
   Legal articles (JK/JPK) and orders: only if the book text states them; otherwise gap.
5. Do not write about procedures/doses the books do not state. No opinions.
6. Output ONE JSON file at the path given: [{"id":..., "coverage":"full|partial|none", "gaps":[...], "points":[{...}], "pages_read":[..]}] in input order,
   validate with python json.load. Write the file after every ~5 questions (rewrite full valid JSON). Final reply: counts of full/partial/none only.
Pace: slow and careful; read, do not skim. Budget ~10 tool calls per question.
