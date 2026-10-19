"""Extract the illustrated road-sign catalog from the supplied PDF."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

import pymupdf


GROUPS = {
    20: ("ibimenyetso-biburira", "Ibyapa biburira n’ibyo gutambuka mbere"),
    27: ("ibimenyetso-bibuza", "Ibyapa bibuza"),
    32: ("ibimenyetso-bitegeka", "Ibyapa bitegeka"),
    34: ("ibimenyetso-bindi", "Ibindi byapa"),
}


def group_for_page(page_index: int) -> tuple[str, str]:
    if page_index <= 26:
        return GROUPS[20]
    if page_index <= 31:
        return GROUPS[27]
    if page_index <= 33:
        return GROUPS[32]
    return GROUPS[34]


def clean(text: str) -> str:
    return re.sub(r"\s+", " ", text.replace("\u2019", "'").replace("\ufffd", "'")).strip()


def extract(pdf_path: Path, output_dir: Path, image_dir: Path) -> list[dict[str, object]]:
    doc = pymupdf.open(pdf_path)
    image_dir.mkdir(parents=True, exist_ok=True)
    signs: list[dict[str, object]] = []
    section_counts: dict[str, int] = {}
    for page_index in range(20, min(38, len(doc))):
        page = doc[page_index]
        descriptions: list[tuple[float, str]] = []
        for block in page.get_text("dict")["blocks"]:
            if "lines" not in block:
                continue
            x0, y0, x1, y1 = block["bbox"]
            text = clean(" ".join(span["text"] for line in block["lines"] for span in line["spans"]))
            if x0 >= 230 and y0 > 65 and y1 < 715 and text:
                descriptions.append(((y0 + y1) / 2, text))

        images = []
        for info in page.get_image_info(xrefs=True):
            x0, y0, x1, y1 = info["bbox"]
            if info["xref"] > 0 and x0 < 240 and 65 < y0 < 715 and info["width"] >= 350 and info["height"] >= 350:
                images.append(((y0 + y1) / 2, info["xref"]))

        section_id, section_title = group_for_page(page_index)
        for row_index, (center_y, xref) in enumerate(sorted(images), 1):
            if not descriptions:
                continue
            description = min(descriptions, key=lambda row: abs(row[0] - center_y))[1]
            image_data = doc.extract_image(xref)
            filename = f"pdf-sign-{page_index + 1:02d}-{row_index:02d}.{image_data['ext']}"
            (image_dir / filename).write_bytes(image_data["image"])
            section_counts[section_id] = section_counts.get(section_id, 0) + 1
            signs.append({
                "id": f"pdf-sign-{page_index + 1:02d}-{row_index:02d}",
                "sectionId": section_id,
                "sectionTitle": section_title,
                "heading": f"Icyapa {section_counts[section_id]}",
                "body": description,
                "imagePath": f"assets/images/road_signs/pdf/{filename}",
            })
    output_dir.parent.mkdir(parents=True, exist_ok=True)
    output_dir.write_text(json.dumps(signs, ensure_ascii=False, indent=2), encoding="utf-8")
    return signs


if __name__ == "__main__":
    result = extract(Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]))
    print(f"Extracted {len(result)} sign catalog entries")
    print("Entries per section:", {key: sum(item["sectionId"] == key for item in result) for key, _ in GROUPS.values()})
    print("Repeated descriptions:", len(result) - len({item["body"] for item in result}))
