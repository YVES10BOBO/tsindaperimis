"""Turn the reviewed questions_sources/review/review.xlsx into a Supabase SQL file.

Reads the Action, Correct answer and Category columns of the sheet (so any edit
you make there is respected), writes supabase/migrations/202611070001_questions_pdf2_draft.sql
and copies the pictures of the questions being added into the app and dashboard.

Every question is inserted as a DRAFT (published = false); nothing is visible
to learners until it is published in the dashboard.
"""

from __future__ import annotations

import json
import shutil
from collections import Counter
from pathlib import Path

from openpyxl import load_workbook

ROOT = Path(__file__).resolve().parents[1]
REVIEW = ROOT / "questions_sources" / "review"
SQL_OUT = ROOT / "supabase" / "migrations" / "202611070001_questions_pdf2_draft.sql"
APP_IMAGES = ROOT / "assets" / "images" / "road_signs" / "pdf2"
DASHBOARD_IMAGES = ROOT / "admin-dashboard" / "public" / "road-signs" / "pdf2"
EXISTING_QUESTIONS = 160  # the first PDF; new questions continue at #161
CATEGORIES = {"amategeko", "ibimenyetso", "amatara", "imirongo", "modoka", "imyitwarire", "umutekano"}


def quote(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def main() -> None:
    questions = {q["seq"]: q for q in json.loads((REVIEW / "questions_pdf2.json").read_text(encoding="utf-8"))}
    sheet = load_workbook(REVIEW / "review.xlsx", data_only=True)["Questions"]
    head = {cell.value: index for index, cell in enumerate(sheet[1])}
    action_col = head["Action (ADD / SKIP / DECIDE)"]
    category_col = head["Category (suggested)"]
    answer_col = head["Correct answer (fix if wrong: A/B/C/D)"]

    rows, problems = [], []
    for row in sheet.iter_rows(min_row=2, values_only=True):
        seq, action = int(row[head["Row"]]), str(row[action_col] or "").strip()
        if action.upper().startswith("DECIDE"):
            problems.append(f"row {seq}: still DECIDE")
        if not action.upper().startswith("ADD"):
            continue
        q = questions[seq]
        category = str(row[category_col] or "").strip().lower()
        letter = str(row[answer_col] or "").strip().lower()
        if category not in CATEGORIES:
            problems.append(f"row {seq}: category '{category}' is not one of {sorted(CATEGORIES)}")
        if len(letter) != 1 or not 0 <= ord(letter) - 97 < len(q["options"]):
            problems.append(f"row {seq}: correct answer '{letter}' is not a valid letter")
            continue
        if any(not o["text"].strip() for o in q["options"]) or not q["text"].strip():
            problems.append(f"row {seq}: empty question or answer text")
        rows.append((seq, q, category, ord(letter) - 97))
    if problems:
        raise SystemExit("Fix the sheet first:\n  " + "\n  ".join(problems))

    for folder in (APP_IMAGES, DASHBOARD_IMAGES):
        folder.mkdir(parents=True, exist_ok=True)
    question_sql, option_sql, copied = [], [], set()
    for k, (seq, q, category, correct) in enumerate(rows, start=1):
        number = EXISTING_QUESTIONS + k
        qid = f"pdf2-q-{seq:03d}"
        image = None
        if q["images"]:
            name = q["images"][0]
            image = f"assets/images/road_signs/pdf2/{name}"
            if name not in copied:
                shutil.copyfile(REVIEW / "images" / name, APP_IMAGES / name)
                shutil.copyfile(REVIEW / "images" / name, DASHBOARD_IMAGES / name)
                copied.add(name)
        question_sql.append(
            f"({quote(qid)}, {quote(category)}, {quote(q['text'])}, '', null, null, "
            f"{quote(image) if image else 'null'}, true, {number - 1}, false, {number})"
        )
        for position, option in enumerate(q["options"]):
            option_sql.append(
                f"({quote(f'{qid}-{position}')}, {quote(qid)}, {position}, {quote(option['text'])}, "
                f"{'true' if position == correct else 'false'})"
            )

    # Which dashboard #number each PDF row got, so a row can be found by search.
    numbers = {seq: EXISTING_QUESTIONS + k for k, (seq, _, _, _) in enumerate(rows, start=1)}
    lines = ["pdf_row,printed_no,dashboard_no,same_question_as"]
    for seq, q, _, _ in rows:
        other = ""
        if q["same_kind"] == "CONFLICT" and "PDF 2 row" in q["same_as"]:
            ref = int(q["same_as"].split("PDF 2 row ")[1].split(":")[0])
            other = f"#{numbers[ref]}" if ref in numbers else f"row {ref}"
        lines.append(f"{seq},{q['n']},#{numbers[seq]},{other}")
    (REVIEW / "number_map.csv").write_text("\n".join(lines) + "\n", encoding="utf-8")
    pairs = [(numbers[seq], numbers[int(q['same_as'].split('PDF 2 row ')[1].split(':')[0])]) for seq, q, _, _ in rows
             if q["same_kind"] == "CONFLICT" and "PDF 2 row" in q["same_as"] and int(q['same_as'].split('PDF 2 row ')[1].split(':')[0]) in numbers]

    total = EXISTING_QUESTIONS + len(rows)
    counts = Counter(category for _, _, category, _ in rows)
    SQL_OUT.write_text(f"""-- Adds {len(rows)} questions from AMATEGEKO_YUMUHANDA_IBIBAZO_IBISUBIZO_2.pdf as DRAFTS
-- (published = false): learners see nothing until you publish them in the dashboard.
-- They are numbered #{EXISTING_QUESTIONS + 1} to #{total}. Pictures are bundled in the app
-- (assets/images/road_signs/pdf2/). There are no explanations yet.
--
-- Run 202611060001_questions_match_pdf.sql FIRST: this file stops unless the
-- highest question number is exactly {EXISTING_QUESTIONS}. It runs as one transaction.
--
-- Categories: {', '.join(f'{c} {n}' for c, n in sorted(counts.items()))}.
begin;

do $$
begin
  if (select coalesce(max(number), 0) from public.questions) <> {EXISTING_QUESTIONS} then
    raise exception 'Expected the highest question number to be {EXISTING_QUESTIONS} (run 202611060001_questions_match_pdf.sql first). Nothing was changed.';
  end if;
end;
$$;

insert into public.questions
  (id, category_id, prompt, explanation, sign_type, sign_label, image_path, is_exam_question, sort_order, published, number)
values
{(',' + chr(10)).join(question_sql)};

insert into public.question_options (id, question_id, position, option_text, is_correct)
values
{(',' + chr(10)).join(option_sql)};

select setval('public.questions_number_seq', {total}, true);

commit;

-- Check: expect {len(rows)} drafts numbered {EXISTING_QUESTIONS + 1}..{total}, each with 4 answers and exactly 1 correct.
select count(*) as drafts, min(q.number) as first_no, max(q.number) as last_no,
       min(c.answers) as min_answers, max(c.answers) as max_answers, min(c.correct) as min_correct, max(c.correct) as max_correct
from public.questions q
join (select question_id, count(*) as answers, count(*) filter (where is_correct) as correct
      from public.question_options group by question_id) c on c.question_id = q.id
where q.id like 'pdf2-q-%';
""", encoding="utf-8")
    print(f"Wrote {SQL_OUT.relative_to(ROOT)}: {len(rows)} questions (#{EXISTING_QUESTIONS + 1} to #{total})")
    print("By category:", dict(sorted(counts.items())))
    print(f"Pictures copied: {len(copied)} -> assets/images/road_signs/pdf2/ and admin-dashboard/public/road-signs/pdf2/")
    print("With a picture:", sum(1 for _, q, _, _ in rows if q["images"]))
    print("Same question, different marked answers (compare in the dashboard):", ", ".join(f"#{a} vs #{b}" for a, b in pairs))


if __name__ == "__main__":
    main()
