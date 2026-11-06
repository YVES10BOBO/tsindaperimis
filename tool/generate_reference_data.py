"""Generate the bundled Dart question/sign catalogs from extracted source JSON."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


# Reviewed against the PDF's wording: these were filed under a neighbouring
# category by the number ranges below, so they are moved to the topic they ask about.
RECATEGORISED = {
    5: "amategeko",    # orders given by authorised officers (with Q7, Q8)
    20: "amategeko", 21: "amategeko", 22: "amategeko",  # driver minimum ages
    23: "amategeko", 24: "amategeko",                   # belong with licence rules
    126: "amatara",    # reflectors
    127: "amatara",    # flashing yellow light
    144: "amatara",    # lit traffic signals
    154: "ibimenyetso",  # what traffic signals are made of
}


def category_for(number: int) -> str:
    if number in RECATEGORISED:
        return RECATEGORISED[number]
    explicit = {
        1: "amategeko", 2: "modoka", 3: "amatara", 4: "modoka", 5: "imyitwarire",
        6: "modoka", 7: "amategeko", 8: "amategeko", 9: "amategeko",
        10: "amategeko", 11: "amategeko", 12: "amategeko", 13: "amategeko",
        14: "amategeko", 15: "amategeko", 16: "modoka", 17: "amategeko",
        18: "modoka", 19: "imirongo", 20: "modoka", 21: "modoka", 22: "modoka",
        23: "modoka", 24: "modoka", 25: "modoka", 26: "umutekano", 27: "umutekano",
        28: "imyitwarire", 29: "imyitwarire", 30: "amategeko", 31: "imyitwarire",
        32: "imyitwarire", 33: "imyitwarire", 34: "imyitwarire", 35: "imyitwarire",
        36: "imyitwarire", 37: "amategeko", 38: "amategeko", 39: "amategeko",
        40: "amategeko", 41: "imyitwarire", 46: "ibimenyetso", 47: "amategeko",
        48: "amategeko", 49: "imirongo", 50: "amategeko", 51: "amategeko",
        52: "imyitwarire", 53: "modoka", 54: "modoka", 55: "amategeko",
        56: "amatara", 57: "amatara", 58: "amatara", 59: "amatara", 60: "amatara",
        61: "amatara", 62: "amatara", 63: "umutekano", 64: "umutekano",
        65: "umutekano", 66: "umutekano", 67: "umutekano", 71: "modoka",
        79: "imyitwarire", 90: "amatara", 91: "amatara", 92: "amatara", 93: "amatara",
        94: "amatara", 98: "ibimenyetso", 103: "amatara", 104: "amatara",
        105: "amatara", 106: "amatara", 107: "amatara", 110: "amatara",
        111: "amatara", 112: "amatara", 113: "amatara", 114: "amatara",
        115: "amatara", 116: "modoka", 117: "amatara", 118: "amatara",
        119: "modoka", 120: "amatara", 121: "ibimenyetso", 122: "ibimenyetso",
        123: "amatara", 124: "amatara", 125: "amatara", 126: "ibimenyetso",
        127: "ibimenyetso", 137: "imirongo", 141: "ibimenyetso", 142: "imirongo",
        147: "modoka", 149: "amatara", 150: "ibimenyetso", 151: "ibimenyetso",
        152: "imirongo", 153: "ibimenyetso", 154: "amatara", 155: "imirongo",
        156: "ibimenyetso", 157: "ibimenyetso", 158: "ibimenyetso", 159: "imirongo",
        160: "ibimenyetso",
    }
    if number in explicit:
        return explicit[number]
    if 42 <= number <= 45 or 68 <= number <= 89 or 95 <= number <= 102 or 108 <= number <= 109:
        return "modoka"
    if 128 <= number <= 146 or number in {148}:
        return "imirongo"
    if 143 <= number <= 146:
        return "imirongo"
    if 149 <= number <= 160:
        return "ibimenyetso"
    return "amategeko"


def dart_string(value: str) -> str:
    return "'" + value.replace("\\", "\\\\").replace("'", "\\'").replace("$", "\\$") + "'"


def main() -> None:
    questions = json.loads((ROOT / "tool/pdf_question_extract.json").read_text(encoding="utf-8"))
    signs = json.loads((ROOT / "tool/pdf_sign_catalog.json").read_text(encoding="utf-8"))
    lines = ["import 'models.dart';", "", "/// Ibibazo 160 byakuwe mu gice cya mbere cy'igitabo cyatanzwe.", "const List<Question> pdfQuestionBank = <Question>[" ]
    category_counts: dict[str, int] = {}
    for question in questions:
        number = int(question["number"])
        category = category_for(number)
        category_counts[category] = category_counts.get(category, 0) + 1
        # The PDF prints the same answer twice in a few questions (Q10, Q78);
        # keep the first copy so a learner never has two identical choices.
        options, seen = [], set()
        for option in question["options"]:
            key = " ".join(str(option["text"]).lower().split())
            if key in seen:
                continue
            seen.add(key)
            options.append(option)
        # The PDF's Q92 marks "Metero 10" as correct, but Article 79 requires
        # a visible brake light at 150 m at night and 20 m by day. None of its
        # printed choices states that, so the correct choice is "none".
        correct_index = 3 if number == 92 else question["correctIndex"]
        explanation = (
            "Nta gisubizo cy’ukuri kirimo: itara rigomba kugaragara mu ntera "
            "ya m 150 nijoro na m 20 ku manywa. Iteka rya Perezida No 85/01, "
            "Ingingo ya 79."
            if number == 92
            else ""
        )
        lines.extend([
            "  Question(",
            f"    id: 'pdf-q-{number:03d}',",
            f"    categoryId: '{category}',",
            f"    text: {dart_string(question['prompt'])},",
            "    options: <String>[" + ", ".join(dart_string(option["text"]) for option in options) + "],",
            f"    correctIndex: {correct_index},",
            f"    explanation: {dart_string(explanation)},",
            "  ),",
        ])
    lines.extend(["];"])

    grouped: dict[str, list[dict[str, object]]] = {}
    titles: dict[str, str] = {}
    for sign in signs:
        key = str(sign["sectionId"])
        grouped.setdefault(key, []).append(sign)
        titles[key] = str(sign["sectionTitle"])
    lesson_minutes = {
        "ibimenyetso-biburira": 12,
        "ibimenyetso-bibuza": 10,
        "ibimenyetso-bitegeka": 6,
        "ibimenyetso-bindi": 8,
    }
    lines.extend(["", "/// Amasomo ane arimo ibisobanuro n'amashusho 106 by'ibyapa byo mu gitabo.", "const List<Lesson> pdfSignLessons = <Lesson>[" ])
    for key, items in grouped.items():
        lines.extend([
            "  Lesson(",
            f"    id: '{key}',",
            "    categoryId: 'ibimenyetso',",
            f"    title: {dart_string(titles[key])},",
            f"    minutes: {lesson_minutes[key]},",
            "    sections: <LessonSection>[",
        ])
        for item in items:
            lines.extend([
                "      LessonSection(",
                f"        {dart_string(str(item['heading']))},",
                f"        {dart_string(str(item['body']))},",
                f"        imagePath: {dart_string(str(item['imagePath']))},",
                "      ),",
            ])
        lines.extend(["    ],", "  ),"])
    lines.append("];")
    output = ROOT / "lib/data/pdf_reference_data.dart"
    output.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Generated {len(questions)} questions across {category_counts}")
    print(f"Generated {len(signs)} sign descriptions in {len(grouped)} lessons at {output}")


if __name__ == "__main__":
    main()
