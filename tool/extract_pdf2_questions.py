"""Read AMATEGEKO_YUMUHANDA_IBIBAZO_IBISUBIZO_2.pdf into a review package.

Writes to questions_sources/review/ (never to the app or Supabase):
  questions_pdf2.json  every question, answers, marked answer, pictures, flags
  images/              each distinct picture, saved once as a small JPEG
  review.xlsx          one row per question, to check and correct
  pictures.html        every picture next to its question, to check by eye

In this PDF the correct answer is the RED line, usually also written in
brackets, e.g. "(c) ...". Where the marking is missing or contradictory the
question is flagged instead of guessed.
"""

from __future__ import annotations

import difflib
import hashlib
import html
import json
import re
from collections import Counter
from pathlib import Path

import pymupdf

ROOT = Path(__file__).resolve().parents[1]
PDF = ROOT / "questions_sources" / "AMATEGEKO_YUMUHANDA_IBIBAZO_IBISUBIZO_2.pdf"
OUT = ROOT / "questions_sources" / "review"
IMAGES = OUT / "images"
RED = {0xFF0000, 0xC00000}
LETTERS = "abcdefghijklmnopqrstuvwxyz"

# "12. text", "12.text", "12." (text on the next line) or "225Text" (no dot).
QUESTION = re.compile(r"^\s*(\d{1,3})\s*(?:\.(?!\d)\s*|(?=[A-Z]))(.*)$")
OPTION = re.compile(r"^\s*(?:\(\s*([a-eA-E])\s*\.?\s*\)\.?|([a-eA-E])\s*[.)])\s*(.*)$")


def clean(text: str) -> str:
    return re.sub(r"\s+", " ", text.replace("�", "'").replace("’", "'")).strip()


def norm(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", clean(text).lower().replace("'", "")).strip()


# ---------------------------------------------------------------- reading
def read_elements(doc: pymupdf.Document):
    """Yield text lines and pictures page by page, top to bottom."""
    for page_index, page in enumerate(doc):
        items = []
        for block in page.get_text("dict")["blocks"]:
            if block["type"] == 1:
                x0, y0, x1, y1 = block["bbox"]
                if x1 - x0 >= 25 and y1 - y0 >= 25:
                    items.append((y0, x0, "img", block))
                continue
            for line in block["lines"]:
                raw = "".join(span["text"] for span in line["spans"])
                text = clean(raw)
                if not text or text == "RESTRICTED":
                    continue
                if re.fullmatch(r"\d{1,3}", text) and line["bbox"][1] < 60:
                    continue  # page number
                ranges, start = [], 0
                for span in line["spans"]:
                    ranges.append((start, start + len(span["text"]), span["color"] in RED and bool(span["text"].strip())))
                    start += len(span["text"])
                items.append((line["bbox"][1], line["bbox"][0], "txt", (raw, ranges)))
        for y, x, kind, payload in sorted(items, key=lambda i: (i[0], i[1])):
            yield page_index, page, kind, payload


# A question number glued into the middle of a line, e.g. "... ihoni 225Wegereye ...".
MERGED = re.compile(r"\s(\d{3})\s*\.?\s*(?=[A-Z][a-z])")


def split_merged_line(raw: str, ranges: list, previous: dict | None) -> list[tuple[str, bool]]:
    """Split a line in two where the next question starts inside it."""
    def red_in(start: int, end: int) -> bool:
        return any(is_red and s < end and e > start for s, e, is_red in ranges)

    cut = None
    if previous is not None and len(previous["options"]) >= 2:
        for match in MERGED.finditer(raw):
            if abs(int(match.group(1)) - previous["n"]) <= 3 and match.start() > 0:
                cut = match
                break
    if cut is None:
        return [(clean(raw), red_in(0, len(raw)))]
    head, tail = raw[: cut.start()], raw[cut.start():].lstrip()
    return [(clean(head), red_in(0, cut.start())), (clean(tail), red_in(cut.start(), len(raw)))]


def handle_line(questions: list[dict], current: dict | None, text: str, red: bool, page_index: int) -> dict | None:
    match = QUESTION.match(text)
    option = OPTION.match(text)
    # The PDF's printed numbers are not reliable (a block of questions is out of
    # order and one number appears twice), so a numbered line starts a new
    # question when the previous one already has its answers, or when it simply
    # continues the numbering.
    follows = bool(questions) and (
        len(questions[-1]["options"]) >= 2 or (match is not None and int(match.group(1)) == questions[-1]["n"] + 1)
    )
    if match and not option and (not questions or follows) and 1 <= int(match.group(1)) <= 600:
        current = {
            "seq": len(questions) + 1,
            "n": int(match.group(1)),
            "page": page_index + 1,
            "text": match.group(2),
            "options": [],
            "images": [],
        }
        questions.append(current)
    elif current is None:
        pass
    elif option:
        label = (option.group(1) or option.group(2)).lower()
        current["options"].append({
            "label": label,
            "text": option.group(3),
            "red": red,
            "bracket": text.lstrip().startswith("("),
            "images": [],
        })
    elif current["options"]:
        last = current["options"][-1]
        last["text"] += " " + text
        last["red"] = last["red"] or red
    else:
        current["text"] += " " + text
    return current


def parse(doc: pymupdf.Document) -> list[dict]:
    questions: list[dict] = []
    current: dict | None = None
    seen_images: dict[str, str] = {}
    # A picture printed after a question's last (text) answer belongs to the NEXT
    # question: the pictures of a question sit between its text and its answers.
    pending: list[str] = []

    for page_index, page, kind, payload in read_elements(doc):
        if kind == "img":
            if current is None:
                continue
            after_text_answers = len(current["options"]) >= 4 and bool(current["options"][-1]["text"].strip())
            owner = len(questions) + 1 if after_text_answers else current["seq"]
            digest = hashlib.md5(payload["image"]).hexdigest()
            if digest not in seen_images:
                name = f"pdf2-q{owner:03d}-{len(seen_images) + 1:03d}.jpeg"
                pix = page.get_pixmap(clip=pymupdf.Rect(payload["bbox"]), dpi=150)
                IMAGES.mkdir(parents=True, exist_ok=True)
                (IMAGES / name).write_bytes(pix.tobytes("jpeg", jpg_quality=85))
                seen_images[digest] = name
            if after_text_answers:
                if seen_images[digest] not in pending:
                    pending.append(seen_images[digest])
                continue
            target = current["options"][-1]["images"] if current["options"] else current["images"]
            if seen_images[digest] not in target:
                target.append(seen_images[digest])
            continue
        raw, ranges = payload
        for text, red in split_merged_line(raw, ranges, questions[-1] if questions else None):
            before = len(questions)
            current = handle_line(questions, current, text, red, page_index)
            if len(questions) > before and pending:
                current["images"].extend(pending)
                pending.clear()
    return questions


# ---------------------------------------------------------------- checking
def decide_answer(q: dict) -> None:
    options = q["options"]
    red = [i for i, o in enumerate(options) if o["red"]]
    bracket = [i for i, o in enumerate(options) if o["bracket"]]
    flags: list[str] = []
    answer = None
    if len(red) == 1:
        answer = red[0]
        if bracket and bracket != red:
            flags.append("RED_AND_BRACKET_DISAGREE")
    elif len(red) > 1:
        flags.append("MORE_THAN_ONE_MARKED")
    elif len(bracket) == 1:
        answer = bracket[0]
        flags.append("MARKED_BY_BRACKET_ONLY")
    elif len(bracket) > 1:
        flags.append("MORE_THAN_ONE_MARKED")
    else:
        flags.append("NO_ANSWER_MARKED")

    labels = [o["label"] for o in options]
    if labels != list(LETTERS[: len(labels)]):
        flags.append("OPTION_LETTERS_OUT_OF_ORDER")
    elif answer is not None and options[answer]["label"] != LETTERS[answer]:
        flags.append("MARKED_LETTER_DOES_NOT_MATCH_POSITION")
    if len(options) < 3:
        flags.append("FEWER_THAN_3_OPTIONS")
    if len(options) > 5:
        flags.append("MORE_THAN_5_OPTIONS")
    if len({norm(o["text"]) for o in options}) < len(options):
        flags.append("REPEATED_ANSWER")
    if any(o["images"] for o in options):
        flags.append("PICTURE_INSIDE_ANSWERS")
    if len(norm(q["text"])) < 12:
        flags.append("QUESTION_TEXT_VERY_SHORT")
    q["answer_index"] = answer
    q["flags"] = flags


def mark_numbering(questions: list[dict]) -> None:
    counts = Counter(q["n"] for q in questions)
    previous = 0
    for q in questions:
        if counts[q["n"]] > 1:
            q["flags"].append("PRINTED_NUMBER_USED_TWICE")
        if q["n"] != previous + 1:
            q["flags"].append("PRINTED_NUMBER_OUT_OF_ORDER")
        previous = q["n"]


CATEGORY_RULES = [
    ("imirongo", r"murongo|imirongo|ibisate|ahanyurwa n abanyamaguru|zebra"),
    ("amatara", r"\bitara|amatara|kamenabihu|ndanga|akagarurarumuri|utugarurarumuri"),
    ("umutekano", r"munyamaguru|abanyamaguru|abana|inzoga|ubusinzi|ubumuga|impanuka|ubutabazi"),
    ("amategeko", r"uruhushya|ihazabu|amande|iteka|ingingo|icyemezo|ubwishingizi|polisi|ibyangombwa|ikarita"),
    ("modoka", r"feri|ipine|inziga|moteri|uburemere|uburebure|ubugari|ubuhagarike|remoroki|amavuta|bateri|imizigo|ihoni"),
    ("imyitwarire", r"kunyuranaho|kubisikana|isangano|guhagarara|kwitonda|umuvuduko|guhindura|kuzenguruka|gusubira inyuma"),
]


def suggest_category(q: dict) -> tuple[str, str]:
    body = norm(q["text"] + " " + " ".join(o["text"] for o in q["options"]))
    if (q["images"] or any(o["images"] for o in q["options"])) and re.search(r"cyapa|ibyapa", body):
        return "ibimenyetso", "medium"
    for category, pattern in CATEGORY_RULES:
        if re.search(pattern, norm(q["text"])):
            return category, "medium"
    for category, pattern in CATEGORY_RULES:
        if re.search(pattern, body):
            return category, "low"
    return "amategeko", "low"


def option_similarity(mine: list[str], other: list[str]) -> float:
    """How alike two answer lists are (0-1), ignoring order."""
    if not mine or not other:
        return 0.0

    def best(left: list[str], right: list[str]) -> float:
        return sum(max(difflib.SequenceMatcher(None, a, b).ratio() for b in right) for a in left) / len(left)

    return min(best(mine, other), best(other, mine))


def compare_with_existing(questions: list[dict]) -> None:
    """Flag questions already in the first PDF's 160, or repeated inside this PDF.

    A duplicate needs the same question AND the same answers. Several different
    questions share a stem such as "... aha hakurikira :", so a matching stem
    with different answers is only reported as SIMILAR.
    """
    pool = []
    for item in json.loads((ROOT / "tool" / "pdf_question_extract.json").read_text(encoding="utf-8")):
        options = [norm(o["text"]) for o in item["options"]]
        correct = options[item["correctIndex"]] if 0 <= item["correctIndex"] < len(options) else None
        pool.append((f"#{item['number']} (PDF 1)", norm(item["prompt"]), options, correct, 0))

    for q in questions:
        q["same_as"], q["same_kind"] = "", ""
        text = norm(q["text"])
        options = [norm(o["text"]) for o in q["options"]]
        mine = options[q["answer_index"]] if q["answer_index"] is not None else None
        best = None
        for label, other_text, other_options, other_correct, _ in pool:
            matcher = difflib.SequenceMatcher(None, text, other_text)
            if matcher.real_quick_ratio() < 0.85 or matcher.quick_ratio() < 0.85:
                continue
            stem = matcher.ratio()
            if stem < 0.85:
                continue
            answers = option_similarity(options, other_options)
            score = (answers, stem)
            if best is None or score > best[0]:
                best = (score, label, stem, answers, other_correct)
        if best is not None:
            _, label, stem, answers, other_correct = best
            note = f"{label}: wording {round(stem * 100)}%, answers {round(answers * 100)}% alike"
            if stem >= 0.97 and answers >= 0.85:
                same_answer = bool(mine and other_correct) and difflib.SequenceMatcher(None, mine, other_correct).ratio() >= 0.8
                q["same_kind"] = "DUPLICATE" if same_answer or not (mine and other_correct) else "CONFLICT"
            else:
                q["same_kind"] = "SIMILAR"
            q["same_as"] = note
            if q["same_kind"] == "CONFLICT":
                q["flags"].append("SAME_QUESTION_DIFFERENT_ANSWER")
        pool.append((f"PDF 2 row {q['seq']}", text, options, mine, q["seq"]))


# ---------------------------------------------------------------- outputs
def write_json(questions: list[dict]) -> None:
    (OUT / "questions_pdf2.json").write_text(json.dumps(questions, ensure_ascii=False, indent=1), encoding="utf-8")


def default_action(q: dict) -> str:
    if q["same_kind"] == "DUPLICATE":
        return "SKIP (duplicate)"
    if (q["same_kind"] == "CONFLICT" or q["answer_index"] is None or "MORE_THAN_ONE_MARKED" in q["flags"]
            or "PICTURE_INSIDE_ANSWERS" in q["flags"] or any(not o["text"] for o in q["options"])):
        return "DECIDE"
    return "ADD"


def write_excel(questions: list[dict]) -> None:
    from openpyxl import Workbook
    from openpyxl.styles import Alignment, Font, PatternFill
    from openpyxl.utils import get_column_letter

    book = Workbook()
    sheet = book.active
    sheet.title = "Questions"
    headers = ["Row", "Printed no.", "Page", "Action (ADD / SKIP / DECIDE)", "Category (suggested)", "Confidence", "Question",
               "A", "B", "C", "D", "E", "Marked correct", "Correct answer (fix if wrong: A/B/C/D)",
               "Pictures", "Flags", "Same as", "Your notes"]
    sheet.append(headers)
    fills = {"ADD": "E7F5EE", "SKIP (duplicate)": "EEEEEE", "DECIDE": "FFF4E0"}
    for q in questions:
        cells = [""] * 5
        for i, o in enumerate(q["options"][:5]):
            cells[i] = o["text"]
        category, confidence = suggest_category(q)
        marked = LETTERS[q["answer_index"]].upper() if q["answer_index"] is not None else ""
        pictures = list(q["images"]) + [f"{LETTERS[i].upper()}:{img}" for i, o in enumerate(q["options"]) for img in o["images"]]
        action = default_action(q)
        row = [q["seq"], q["n"], q["page"], action, category, confidence, q["text"], *cells, marked, marked,
               ", ".join(pictures), ", ".join(q["flags"]), q["same_as"], ""]
        sheet.append(row)
        sheet.cell(row=sheet.max_row, column=4).fill = PatternFill("solid", fgColor=fills[action])
    for cell in sheet[1]:
        cell.font = Font(bold=True, color="FFFFFF")
        cell.fill = PatternFill("solid", fgColor="1E3A8A")
        cell.alignment = Alignment(wrap_text=True, vertical="center")
    widths = [6, 8, 6, 16, 16, 10, 60, 32, 32, 32, 32, 20, 10, 16, 28, 34, 34, 24]
    for index, width in enumerate(widths, start=1):
        sheet.column_dimensions[get_column_letter(index)].width = width
    for row in sheet.iter_rows(min_row=2):
        for cell in row:
            cell.alignment = Alignment(wrap_text=True, vertical="top")
    sheet.freeze_panes = "G2"
    sheet.auto_filter.ref = sheet.dimensions

    notes = book.create_sheet("How to use")
    for line in [
        "One row per question in the PDF. Edit this file, save it, and tell Claude.",
        "Action: ADD = upload as a Draft. SKIP = leave out. DECIDE = needs your decision (change it to ADD or SKIP).",
        "Correct answer: the letter of the right answer. Fix it where the PDF marking is wrong or missing.",
        "Category: a suggestion from keywords. Change it to one of: amategeko, ibimenyetso, amatara, imirongo, modoka, imyitwarire, umutekano.",
        "Flags explain what looked doubtful; see pictures.html to check pictures next to their questions.",
        "Nothing is published from this file until you approve it.",
    ]:
        notes.append([line])
    notes.column_dimensions["A"].width = 140
    book.save(OUT / "review.xlsx")


def write_html(questions: list[dict]) -> None:
    cards = []
    for q in questions:
        if not (q["images"] or any(o["images"] for o in q["options"])):
            continue
        parts = [f'<section><h3>Row {q["seq"]} <small>printed no. {q["n"]} · page {q["page"]}</small></h3><p>{html.escape(q["text"])}</p>']
        parts += [f'<img src="images/{name}" alt="">' for name in q["images"]]
        parts.append("<ol type='A'>")
        for i, o in enumerate(q["options"]):
            mark = " class='ok'" if i == q["answer_index"] else ""
            pics = "".join(f'<img src="images/{name}" alt="">' for name in o["images"])
            parts.append(f"<li{mark}>{html.escape(o['text'])}{pics}</li>")
        parts.append("</ol>")
        if q["flags"]:
            parts.append(f"<p class='flag'>{html.escape(', '.join(q['flags']))}</p>")
        parts.append("</section>")
        cards.append("".join(parts))
    style = ("body{font:14px system-ui;margin:20px;background:#f3f6fb}section{background:#fff;border:1.5px solid #aebbd0;"
             "border-radius:12px;padding:14px 18px;margin:0 0 14px;max-width:760px}h3{margin:0 0 6px}small{color:#666;font-weight:400}"
             "img{max-width:260px;max-height:180px;display:block;margin:8px 0;border:1px solid #ddd}li.ok{color:#14532d;font-weight:700}"
             ".flag{color:#92400e;background:#fff4e0;padding:4px 8px;border-radius:6px}")
    (OUT / "pictures.html").write_text(
        f"<!doctype html><meta charset='utf-8'><title>Pictures to check</title><style>{style}</style>"
        f"<h1>{len(cards)} questions with pictures</h1>{''.join(cards)}", encoding="utf-8")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    doc = pymupdf.open(PDF)
    questions = parse(doc)
    for q in questions:
        q["text"] = clean(q["text"])
        for o in q["options"]:
            o["text"] = clean(o["text"])
        decide_answer(q)
    mark_numbering(questions)
    compare_with_existing(questions)
    write_json(questions)
    write_excel(questions)
    write_html(questions)

    numbers = [q["n"] for q in questions]
    print(f"Questions read: {len(questions)} (printed numbers {min(numbers)} to {max(numbers)})")
    print("Printed numbers the PDF never uses:", [n for n in range(1, max(numbers) + 1) if n not in numbers])
    print("Printed numbers used twice:", sorted(n for n, c in Counter(numbers).items() if c > 1))
    print("Pictures saved:", len(list(IMAGES.glob('*.jpeg'))), "| questions with pictures:", sum(1 for q in questions if q["images"] or any(o["images"] for o in q["options"])))
    print("Actions:", dict(Counter(default_action(q) for q in questions)))
    print("Duplicate kinds:", dict(Counter(q["same_kind"] or "new" for q in questions)))
    print("Flags:", dict(Counter(flag.split("_FROM_")[0] for q in questions for flag in q["flags"])))
    print("Options per question:", dict(Counter(len(q["options"]) for q in questions)))


if __name__ == "__main__":
    main()
