# Task: find the correct answer for multiple-choice questions from the provided books ONLY

You get a JSON file of questions: [{n, q, options:[4 strings]}] (Uzbek, Latin script, official specialty test bank for
forensic medicine / forensic chemistry attestation). The bank has NO answer key. For each question decide which of the 4
options (index 0..3) is correct, using ONLY the book text files listed in your assignment (OCR'd Uzbek textbooks, OCR noise
like "b o iib", "o iim", "ulaming" = "ularning" is normal). Files have page markers "=====[book] PDF-SAHIFA N=====".

Rules (strict - an owner-facing product; a wrong key is far worse than no key):
1. Use grep/Read on the book files (Bash `grep -n -i` with several keyword variants incl. OCR variants; then Read the surrounding lines).
   Do not answer from memory/general knowledge. The book passage must state or directly imply the answer.
2. If the book passage clearly supports exactly one option -> key = that index, give book id, PDF-SAHIFA number, and a
   verbatim quote (<=200 chars, copy as in OCR text) in "quote".
3. If the passage is not found, ambiguous, supports more than one option, concerns legal article numbers (JK/JPK modda raqami),
   dates, or you are not sure -> key = null and a short "reason". NEVER guess. Expect many nulls; that is fine.
4. If the book contradicts every option, key = null, reason "kitobga zid".
5. Questions are not trick questions; options often differ by one word. Compare options against the passage word by word.
6. Do NOT modify any book/question file. Write ONLY your output file (path in assignment) as valid JSON:
   [{"n":1,"key":2,"book":"giyosov_3_...","page":41,"quote":"...","reason":""}, {"n":2,"key":null,"book":null,"page":null,"quote":"","reason":"topilmadi"}, ...]
   One entry for every input question, same order. Validate with `python3 -c "import json;json.load(open(PATH))"`.
7. Work through all questions in your file; keep going until all are done. Final reply: just counts (keyed / null), nothing else.
