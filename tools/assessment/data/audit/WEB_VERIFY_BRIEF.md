# Task: independent audit of web-sourced answer keys (be skeptical; a wrong key is worse than no key)

Input JSON list: {id, question (Uzbek), options[4], claimed_key, url, title, quote, lang, mapped, agent_note}.
For EACH item:
1. Fetch the URL yourself (WebFetch; if blocked try `curl -sL -A "Mozilla/5.0" URL | python3 -c` text extraction; PDFs via pdftotext).
   Check the quote appears (OCR/spacing/whitespace differences OK; paraphrase NOT OK). If the page can't be fetched by you at all, try searching for the
   quote text; if you cannot confirm it exists -> quote_ok=false.
2. Judge, using the fetched page text and your professional knowledge ONLY to decide whether the source DIRECTLY supports exactly the claimed option:
   verdict DIRECT  : the source states the fact; the claimed option is the one that fact makes correct; no other option is also correct.
   verdict INFERRED: needs elimination, synonym leap, partial match, or another option is also arguably correct, or the question is flawed/ambiguous.
   verdict WRONG   : source or standard knowledge points to a different option (give correct_index).
3. source_quality: "strong" (textbook, peer-reviewed article, PMC, WHO/CDC/Merck/MSD, university lecture by a medical faculty, official law text),
   "weak" (Wikipedia or mirrors e.g. academic.ru/gufo.me, college notes, test banks, forums, unnamed pages).
Output ONLY JSON list [{"id":..,"quote_ok":bool,"verdict":"DIRECT|INFERRED|WRONG","correct_index":null|0..3,"source_quality":"strong|weak","why":"<=25 words"}]
in input order to the output path given; validate with json.load. Final reply: counts only (DIRECT/INFERRED/WRONG, strong/weak, quote_ok false).

Extra strictness rules:
- If the source gives an analogous worked example / general rule that the answer-key author applied to this case (rather than stating the fact for exactly this case) -> INFERRED.
- If the cited source is a Wikipedia mirror (academic.ru, gufo.me, ruwiki copies), test bank, forum or student-notes host (studfile.net, college notes) -> source_quality "weak".
- Legal questions: the article number/statement must be in the CURRENT text on lex.uz (open the page yourself).
- If two options are both defensible, or the question text is garbled -> INFERRED.
