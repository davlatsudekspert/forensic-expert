# Task: write source-based ANSWERS to official oral-exam questions (Uzbek) for PATHOLOGICAL ANATOMY, from authoritative world literature (web)

Input: JSON [{id, text}] - oral exam question topics (Uzbek, Latin) for the specialty "Patologik anatomiya" (pathological anatomy).
You write a short, accurate study answer per question, built ONLY from fetched web pages / PDFs of authoritative sources.

Acceptable sources (prefer in this order): open textbooks and book chapters (e.g. Strukov & Serov "Патологическая анатомия" text on medchitalka.ru,
Pal'tsev-Anichkov, Davydovsky, Kumar-Robbins excerpts), PMC / Europe PMC review articles (use europepmc.org REST if PMC blocks), NCBI Bookshelf/StatPearls
(try `curl -sL -A "Mozilla/5.0"`; if captcha, skip), PathologyOutlines, Merck/MSD Manual, WHO/IARC/CDC, university lecture PDFs by medical faculties,
official Uzbek / Russian / Kazakh ministry standards for legal-regulatory questions (lex.uz). AVOID: Wikipedia and its mirrors (academic.ru, gufo.me),
studfile.net, test banks, forums, college notes.

Procedure per question: search (WebSearch), fetch the page (curl -sL -A "Mozilla/5.0" -o file, or WebFetch; for PDFs use pdftotext), SAVE the extracted plain text of each source
you use to W/oral_src/<question_id>__<n>.txt (UTF-8). All quotes must be copied VERBATIM from those saved files (a checker verifies the quote occurs in the
saved file; whitespace is normalised, nothing else). Read enough of the source to understand the topic; do not skim.

Hard rules (a wrong statement in medical exam-prep is worse than a missing answer):
1. Every factual statement must be supported by a verbatim quote (<=300 chars, original language of the source) from a saved source file. No outside knowledge.
2. Write the answer in clear literary Uzbek (Latin), 4–12 short points. Each point:
   {"text":"<claim in Uzbek, your own words>", "book":"web", "page":0, "src":"oral_src/<file>.txt", "url":"https://...", "title":"<source title, author/publisher, year>", "quote":"<verbatim>"}
   Keep numbers/terms exactly as in the quote; translate terminology faithfully (use standard Uzbek medical terms as in the question).
3. coverage: "full" = main aspects of the topic are answered; "partial" = list missing aspects in "gaps" (Uzbek); "none" = no suitable source -> points=[] (never improvise).
4. Output ONE JSON file at the path given: [{"id":..., "coverage":..., "gaps":[...], "points":[...]}] in input order; rewrite the whole valid JSON after every ~3 questions
   (validate with python json.load). Final reply: counts of full/partial/none only.
Pace: slow and careful. Budget ~12 tool calls per question.
