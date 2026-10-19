"""Extract numbered quiz items and blue-highlighted answers from the supplied PDF."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import fitz


QUESTION_START = re.compile(r"^\s*(\d{1,3})(?:\.|\s+(?=[A-Z]))\s*(.*)$")
OPTION_START = re.compile(r"^\s*([a-eA-E])\)\s*(.*)$")
BLUE = 0x3F51B5


def extract(path: Path) -> list[dict[str, object]]:
    document = fitz.open(path)
    questions: list[dict[str, object]] = []
    for page_index in range(1, min(20, len(document))):
        page = document[page_index]
        records: list[tuple[str, bool]] = []
        for block in page.get_text("dict")["blocks"]:
            for line in block.get("lines", []):
                spans = line.get("spans", [])
                text = "".join(span.get("text", "") for span in spans).strip()
                if text:
                    records.append((text.replace("\u2019", "'").replace("\ufffd", "'"), any(span.get("color") == BLUE for span in spans)))

        current: dict[str, object] | None = None
        for text, blue in records:
            match = QUESTION_START.match(text)
            if match:
                if current is not None:
                    questions.append(current)
                current = {"number": int(match.group(1)), "lines": [(match.group(2).strip(), blue)]}
            elif current is not None and not text.startswith("Niba iyi button"):
                current["lines"].append((text, blue))
        if current is not None:
            questions.append(current)

    parsed: list[dict[str, object]] = []
    for item in questions:
        prompt: list[str] = []
        options: list[dict[str, object]] = []
        active: dict[str, object] | None = None
        for text, blue in item["lines"]:
            match = OPTION_START.match(text)
            if match:
                active = {"letter": match.group(1).upper(), "text": match.group(2).strip(), "correct": blue}
                options.append(active)
            elif active is not None:
                active["text"] = (str(active["text"]) + " " + text).strip()
                active["correct"] = bool(active["correct"]) or blue
            else:
                prompt.append(text)
        parsed.append({
            "number": item["number"],
            "prompt": " ".join(prompt).strip(),
            "options": options,
            "correctIndex": next((i for i, option in enumerate(options) if option["correct"]), -1),
            "answerCount": sum(bool(option["correct"]) for option in options),
        })
    return parsed


if __name__ == "__main__":
    questions = extract(Path(sys.argv[1]))
    output = Path(sys.argv[2])
    output.write_text(json.dumps(questions, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Extracted {len(questions)} questions to {output}")
    print("Question numbers:", [q["number"] for q in questions[:3]], "...", [q["number"] for q in questions[-3:]])
    print("Invalid answer counts:", [(q["number"], q["answerCount"]) for q in questions if q["answerCount"] != 1])
