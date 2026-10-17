"""JSON -> 16:9 .pptx (kontent vositasi)."""
import json, sys
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.util import Inches, Pt

NAVY, GOLD, INK, GREY = RGBColor(0x0B, 0x1F, 0x3A), RGBColor(0xC9, 0xA2, 0x27), RGBColor(0x22, 0x22, 0x22), RGBColor(0x66, 0x66, 0x66)
W, H = Inches(13.333), Inches(7.5)


def _text(slide, x, y, w, h, text, size, color, bold=False, font="Calibri"):
    tb = slide.shapes.add_textbox(x, y, w, h)
    tf = tb.text_frame
    tf.word_wrap = True
    r = tf.paragraphs[0].add_run()
    r.text, r.font.size, r.font.bold, r.font.name = text, Pt(size), bold, font
    r.font.color.rgb = color
    return tf


def _bar(slide, x, y, w, h, color):
    s = slide.shapes.add_shape(1, x, y, w, h)
    s.fill.solid(); s.fill.fore_color.rgb = color; s.line.fill.background()


def _src(b):
    s = b.get("source") or {}
    return f"[{s.get('author','')}, {s.get('title','')}, {s.get('page','')}]"


def build(data, out_path):
    prs = Presentation()
    prs.slide_width, prs.slide_height = W, H
    blank = prs.slide_layouts[6]
    s = prs.slides.add_slide(blank)
    _bar(s, 0, 0, W, H, NAVY)
    _text(s, Inches(0.8), Inches(2.4), Inches(11.7), Inches(2), data["topic"], 38, RGBColor(255, 255, 255), True, "Georgia")
    _bar(s, Inches(0.8), Inches(4.5), Inches(2.5), Inches(0.07), GOLD)
    for sl in data["slides"]:
        s = prs.slides.add_slide(blank)
        _text(s, Inches(0.6), Inches(0.35), Inches(12.1), Inches(1), sl["title"], 30, NAVY, True, "Georgia")
        _bar(s, Inches(0.6), Inches(1.35), Inches(1.8), Inches(0.06), GOLD)
        tf = _text(s, Inches(0.6), Inches(1.65), Inches(12.1), Inches(4.7), "", 18, INK)
        first = True
        for b in sl["bullets"]:
            p = tf.paragraphs[0] if first else tf.add_paragraph()
            first = False
            r = p.add_run()
            r.text = ("• " + b["text"] + (" (?)" if b.get("uncertain") else ""))
            r.font.size, r.font.name = Pt(18), "Calibri"
            r.font.color.rgb = INK
            p.space_after = Pt(8)
        srcs = "; ".join(dict.fromkeys(_src(b) for b in sl["bullets"]))
        _text(s, Inches(0.6), Inches(6.7), Inches(12.1), Inches(0.6), "Manba: " + srcs, 10, GREY)
        s.notes_slide.notes_text_frame.text = sl.get("teacher_notes", "")
    s = prs.slides.add_slide(blank)
    _text(s, Inches(0.6), Inches(0.35), Inches(12), Inches(1), "Manbalar", 30, NAVY, True, "Georgia")
    _bar(s, Inches(0.6), Inches(1.35), Inches(1.8), Inches(0.06), GOLD)
    tf = _text(s, Inches(0.6), Inches(1.65), Inches(12.1), Inches(5), "", 16, INK)
    for i, src in enumerate(data.get("sources", [])):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = f"{src.get('author')}. {src.get('title')}. {src.get('year') or ''}. Betlar: {src.get('pages')}"
    prs.save(out_path)
    return out_path


if __name__ == "__main__":
    d = json.load(open(sys.argv[1], encoding="utf-8"))
    print(build(d, sys.argv[2] if len(sys.argv) > 2 else sys.argv[1].replace(".json", ".pptx")))
