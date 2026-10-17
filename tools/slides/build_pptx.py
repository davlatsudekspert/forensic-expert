"""JSON -> 16:9 .pptx (kontent vositasi). Katta ekran/AirPlay uchun yirik shrift, tahrirlanadigan shakllar."""
import json, sys
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import MSO_ANCHOR, PP_ALIGN
from pptx.util import Inches, Pt

NAVY, GOLD, INK, GREY = RGBColor(0x0B, 0x1F, 0x3A), RGBColor(0xC9, 0xA2, 0x27), RGBColor(0x1F, 0x29, 0x37), RGBColor(0x6B, 0x72, 0x80)
PAPER, SOFT, WHITE = RGBColor(0xFB, 0xF8, 0xF1), RGBColor(0xE8, 0xEE, 0xF6), RGBColor(255, 255, 255)
W, H = Inches(13.333), Inches(7.5)
MX = Inches(0.7)  # overscan uchun chekka


def _box(slide, x, y, w, h, fill, shape=MSO_SHAPE.RECTANGLE):
    s = slide.shapes.add_shape(shape, x, y, w, h)
    s.fill.solid(); s.fill.fore_color.rgb = fill; s.line.fill.background(); s.shadow.inherit = False
    return s


def _text(slide, x, y, w, h, text, size, color, bold=False, font="Calibri", align=None, anchor=None):
    tb = slide.shapes.add_textbox(x, y, w, h)
    tf = tb.text_frame; tf.word_wrap = True
    if anchor: tf.vertical_anchor = anchor
    p = tf.paragraphs[0]
    if align: p.alignment = align
    r = p.add_run(); r.text = text
    r.font.size, r.font.bold, r.font.name = Pt(size), bold, font
    r.font.color.rgb = color
    return tf


def _src(b):
    s = b.get("source") or {}
    t = (s.get("title") or "").split("(")[0].split(",")[0].strip()
    return f"{(s.get('author') or '').rstrip('.')}., {t}, {s.get('page','')}-bet"


def _srcline(items):
    by = {}
    for b in items:
        s = b.get("source") or {}
        k = ((s.get("author") or "").rstrip("."), (s.get("title") or "").split("(")[0].split(",")[0].strip())
        by.setdefault(k, [])
        p = str(s.get("page", "")).strip()
        if p and p not in by[k]:
            by[k].append(p)
    return "; ".join(f"{a}., {t}, betlar: {', '.join(ps)}" for (a, t), ps in by.items())


def _frame(prs, title, n, total, topic):
    s = prs.slides.add_slide(prs.slide_layouts[6])
    _box(s, 0, 0, W, H, PAPER)
    _box(s, 0, 0, W, Inches(1.25), NAVY)
    _box(s, 0, Inches(1.25), W, Inches(0.06), GOLD)
    _text(s, MX, Inches(0.12), W - 2 * MX, Inches(1.05), title, 30, WHITE, True, "Georgia", anchor=MSO_ANCHOR.MIDDLE)
    _text(s, MX, Inches(7.0), Inches(9), Inches(0.35), topic[:90], 11, GREY)
    _text(s, W - MX - Inches(1.5), Inches(7.0), Inches(1.5), Inches(0.35), f"{n} / {total}", 11, GREY, align=PP_ALIGN.RIGHT)
    return s


def _bullets(slide, items, x, y, w, h, size=22, gap=12):
    tb = slide.shapes.add_textbox(x, y, w, h); tf = tb.text_frame; tf.word_wrap = True
    for i, b in enumerate(items):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        r = p.add_run(); r.text = "▸  " + b["text"] + (" (?)" if b.get("uncertain") else "")
        r.font.size, r.font.name = Pt(size), "Calibri"; r.font.color.rgb = INK
        p.space_after = Pt(gap)


def _diagram(slide, d, x, y, w, h):
    kind = d.get("kind")
    if kind == "table" and d.get("header"):
        rows = [d["header"]] + list(d.get("rows", []))[:5]
        cols = len(d["header"])
        fs = 13 if cols <= 2 else (12 if cols == 3 else 11)
        lens = [min(40, max([len(str(r[j])) if j < len(r) else 0 for r in rows] + [len(str(d["header"][j])) + 6, 16])) for j in range(cols)]
        tot = sum(lens)
        gs = slide.shapes.add_table(len(rows), cols, x, y, w, Inches(0.5) * len(rows))
        t = gs.table
        for j in range(cols):
            t.columns[j].width = int(w * lens[j] / tot)
        for i, r in enumerate(rows):
            t.rows[i].height = Inches(0.45)
            for j in range(cols):
                c = t.cell(i, j); c.text = str(r[j]) if j < len(r) else ""
                c.margin_left = c.margin_right = Inches(0.08); c.margin_top = c.margin_bottom = Inches(0.04)
                c.fill.solid(); c.fill.fore_color.rgb = NAVY if i == 0 else (SOFT if i % 2 else WHITE)
                for p in c.text_frame.paragraphs:
                    for run in p.runs:
                        run.font.size = Pt(fs + (1 if i == 0 else 0)); run.font.bold = i == 0
                        run.font.color.rgb = WHITE if i == 0 else INK
    else:
        nodes = d.get("nodes", [])[:6]
        if not nodes:
            return
        gap = Inches(0.32); nh = min(Inches(0.85), (h - gap * (len(nodes) - 1)) / len(nodes))
        for i, n in enumerate(nodes):
            yy = y + i * (nh + gap)
            sh = _box(slide, x, yy, w, nh, NAVY if i % 2 == 0 else RGBColor(0x1F, 0x4E, 0x79), MSO_SHAPE.ROUNDED_RECTANGLE)
            tf = sh.text_frame; tf.word_wrap = True; tf.vertical_anchor = MSO_ANCHOR.MIDDLE
            tf.text = n
            for p in tf.paragraphs:
                p.alignment = PP_ALIGN.CENTER
                for run in p.runs:
                    run.font.size = Pt(16); run.font.color.rgb = WHITE; run.font.bold = True
            if i < len(nodes) - 1:
                a = _box(slide, x + w // 2 - Inches(0.15), yy + nh + Inches(0.02), Inches(0.3), gap - Inches(0.04), GOLD, MSO_SHAPE.DOWN_ARROW)
    if d.get("caption"):
        _text(slide, x, y + h + Inches(0.05), w, Inches(0.4), d["caption"][:70], 11, GREY)


def build(data, out_path):
    prs = Presentation(); prs.slide_width, prs.slide_height = W, H
    topic = data.get("topic", "")
    slides, mcq, extras = data["slides"], data.get("mcq", []), data.get("extras", [])
    total = 1 + len(slides) + (1 if extras else 0) + (1 + 2 * len(mcq) if mcq else 0) + 1
    n = 1
    s = prs.slides.add_slide(prs.slide_layouts[6])
    _box(s, 0, 0, W, H, NAVY); _box(s, MX, Inches(4.45), Inches(3), Inches(0.08), GOLD)
    _text(s, MX, Inches(1.9), W - 2 * MX, Inches(2.4), topic, 40, WHITE, True, "Georgia", anchor=MSO_ANCHOR.BOTTOM)
    _text(s, MX, Inches(4.75), W - 2 * MX, Inches(0.6), "Sud tibbiyoti · ma’ruza taqdimoti", 20, GOLD)
    for sl in slides:
        n += 1
        s = _frame(prs, sl["title"], n, total, topic)
        d = sl.get("diagram")
        has_d = bool(d and (d.get("nodes") or d.get("header")))
        bw = Inches(5.9) if has_d else W - 2 * MX
        tot_len = sum(len(x["text"]) for x in sl["bullets"])
        size = (22 if tot_len < 600 else 20) if not has_d else (18 if tot_len < 450 else 16)
        _bullets(s, sl["bullets"], MX, Inches(1.55), bw, Inches(4.9), size, 8 if has_d else 12)
        if has_d:
            _diagram(s, d, MX + Inches(6.15), Inches(1.6), W - 2 * MX - Inches(6.15), Inches(4.2))
        _text(s, MX, Inches(6.62), W - 2 * MX, Inches(0.35), "Manba: " + _srcline(sl["bullets"]), 10, GREY)
        s.notes_slide.notes_text_frame.text = sl.get("teacher_notes", "")
    if extras:
        n += 1
        s = _frame(prs, "Qiziqarli ma’lumotlar", n, total, topic)
        _bullets(s, [{"text": e["text"]} for e in extras], MX, Inches(1.6), W - 2 * MX, Inches(5.2), 18)
    if mcq:
        n += 1
        s = prs.slides.add_slide(prs.slide_layouts[6]); _box(s, 0, 0, W, H, NAVY)
        _text(s, MX, Inches(2.6), W - 2 * MX, Inches(1.4), "Bilimingizni sinang", 44, WHITE, True, "Georgia", anchor=MSO_ANCHOR.MIDDLE)
        _text(s, MX, Inches(4.1), W - 2 * MX, Inches(0.6), f"{len(mcq)} ta test savoli", 22, GOLD)
        for i, q in enumerate(mcq, 1):
            n += 1
            s = _frame(prs, f"Savol {i} / {len(mcq)}", n, total, topic)
            _text(s, MX, Inches(1.55), W - 2 * MX, Inches(1.6), q["question"], 24, INK, True)
            for k, opt in enumerate(q["options"][:4]):
                yy = Inches(3.3) + k * Inches(0.82)
                _box(s, MX, yy, Inches(0.7), Inches(0.68), GOLD, MSO_SHAPE.ROUNDED_RECTANGLE)
                _text(s, MX, yy, Inches(0.7), Inches(0.68), "ABCD"[k], 24, NAVY, True, align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)
                _text(s, MX + Inches(0.9), yy, W - 2 * MX - Inches(0.9), Inches(0.68), opt, 20, INK, anchor=MSO_ANCHOR.MIDDLE)
        for i, q in enumerate(mcq, 1):
            n += 1
            s = _frame(prs, f"Javob {i}: {'ABCD'[q['correct_index']]}", n, total, topic)
            _text(s, MX, Inches(1.6), W - 2 * MX, Inches(1.0), f"{'ABCD'[q['correct_index']]}. {q['options'][q['correct_index']]}", 24, NAVY, True)
            _text(s, MX, Inches(2.6), W - 2 * MX, Inches(3.6), q["explanation"], 20, INK)
            _text(s, MX, Inches(6.4), W - 2 * MX, Inches(0.5), "Manba: " + _src(q), 11, GREY)
    n += 1
    s = _frame(prs, "Adabiyotlar", n, total, topic)
    _bullets(s, [{"text": f"{(x.get('author') or '').rstrip('.')}. {x.get('title')}. {x.get('year') or ''}. {x.get('pages')}"} for x in data.get("sources", [])], MX, Inches(1.6), W - 2 * MX, Inches(5), 20)
    prs.save(out_path)
    return out_path


if __name__ == "__main__":
    d = json.load(open(sys.argv[1], encoding="utf-8"))
    print(build(d, sys.argv[2] if len(sys.argv) > 2 else sys.argv[1].replace(".json", ".pptx")))
