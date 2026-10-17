"""docs/curriculum/TOPICS.md -> topic records."""
import re
from pathlib import Path

DEFAULT = Path(__file__).resolve().parents[2] / "docs/curriculum/TOPICS.md"
BIOETIKA = Path(__file__).resolve().parents[2] / "docs/curriculum/BIOETIKA_TOPICS.md"
KTP = Path(__file__).resolve().parents[2] / "docs/curriculum/KTP_2026_TOPICS.md"
KTP_RE = re.compile(r"^- `(ktp26-[a-z]+-(?:[A-Za-z]+)?(\d+))` \| (.+?)(?: \| .*)?$")
COURSE_RE = re.compile(r"^##\s+(.+?)\s*$")
ITEM_RE = re.compile(r"^(\d+)\.\s+(.+?)\s*$")


def slug(s: str) -> str:
    s = s.lower().replace("‘", "").replace("’", "").replace("'", "")
    return re.sub(r"[^a-z0-9]+", "-", s).strip("-")


def parse_topics(path=DEFAULT):
    topics, course = [], None
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        m = COURSE_RE.match(line)
        if m:
            course = m.group(1)
            continue
        m = ITEM_RE.match(line)
        if m and course:
            n = int(m.group(1))
            topics.append({"id": f"{slug(course)}-{n:02d}", "course": course,
                           "number": n, "title": m.group(2)})
    return topics


def parse_ktp(path=KTP):
    """docs/curriculum/KTP_2026_TOPICS.md -> topic records (fakultet va `ktp26-u-NN` unique id lar)."""
    out = []
    if not Path(path).exists():
        return out
    for line in Path(path).read_text(encoding="utf-8").splitlines():
        m = KTP_RE.match(line)
        if m:
            tid = m.group(1)
            fak = tid.split("-")[1]
            out.append({"id": tid, "course": "KTP 2026 " + ("unique" if fak == "u" else fak),
                        "number": int(m.group(2)), "title": m.group(3).strip()})
    return out


def get_topic(topic_id, path=DEFAULT):
    for t in parse_topics(path):
        if t["id"] == topic_id:
            return t
    if path == DEFAULT and BIOETIKA.exists():
        for t in parse_topics(BIOETIKA):
            if t["id"] == topic_id:
                return t
    if path == DEFAULT and topic_id.startswith("ktp26-"):
        for t in parse_ktp():
            if t["id"] == topic_id:
                return t
    raise KeyError(topic_id)


if __name__ == "__main__":
    for t in parse_topics():
        print(t["id"], "|", t["title"][:80])
