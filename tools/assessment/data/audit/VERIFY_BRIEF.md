# Task: independent audit of proposed answer keys (be skeptical)

Input JSON: list of {id, question, options[4], claimed_key (0..3), book, page, quote, agent_note, page_text}.
page_text is the OCR text of the cited book page (+/- 1 page). OCR noise ("b o iib", "ulaming") is normal.
For EACH item decide, using ONLY page_text (you may grep the book file given in the brief for more context):
- "DIRECT": page_text states the fact that makes exactly option claimed_key correct, and the other 3 options are not equally supported.
- "INFERRED": needs a guess, synonym leap, elimination, or the text only partly matches the option (numbers/terms differ).
- "WRONG": text supports a different option or contradicts claimed_key.
- "NOSUPPORT": cited text does not address the question.
Be strict: when in doubt choose INFERRED. Output ONLY a JSON list [{"id":..,"verdict":"DIRECT|INFERRED|WRONG|NOSUPPORT","correct_index":null or 0..3,"why":"<=25 words"}], same order, to the output path given. Validate with python json.load. Final reply: counts per verdict only.
