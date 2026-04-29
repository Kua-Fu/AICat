#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from PIL import Image


REPORT_PATH = Path("docs/ui_size_normalize_report.md")


@dataclass(frozen=True)
class AssetRule:
    name: str
    pattern: str
    target_size: tuple[int, int]
    content_ratio: float


ASSET_RULES = [
    AssetRule("status_icon", "assets/icons/status/*.png", (256, 256), 0.80),
    AssetRule("action_icon", "assets/icons/actions/*.png", (256, 256), 0.80),
    AssetRule("sparkle_icon", "assets/icons/common/*.png", (96, 96), 0.68),
    AssetRule("status_decor_bg", "assets/ui/status/*.png", (512, 170), 0.92),
    AssetRule("action_decor_bg", "assets/ui/actions/*.png", (192, 224), 0.92),
]


def iter_assets() -> list[tuple[Path, AssetRule]]:
    assets: list[tuple[Path, AssetRule]] = []
    for rule in ASSET_RULES:
        for path in sorted(Path().glob(rule.pattern)):
            if path.name.endswith(".bak.png"):
                continue
            assets.append((path, rule))
    return assets


def alpha_bbox(img: Image.Image) -> tuple[int, int, int, int] | None:
    alpha = img.getchannel("A")
    return alpha.point(lambda value: 255 if value > 8 else 0).getbbox()


def normalized_image(img: Image.Image, rule: AssetRule) -> tuple[Image.Image, tuple[int, int, int, int] | None, tuple[int, int]]:
    rgba = img.convert("RGBA")
    bbox = alpha_bbox(rgba)
    target_w, target_h = rule.target_size

    if bbox == None:
        return Image.new("RGBA", rule.target_size, (255, 255, 255, 0)), None, (0, 0)

    cropped = rgba.crop(bbox)
    max_w = max(1, int(target_w * rule.content_ratio))
    max_h = max(1, int(target_h * rule.content_ratio))
    scale = min(max_w / cropped.width, max_h / cropped.height)
    draw_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(draw_size, Image.Resampling.LANCZOS)

    canvas = Image.new("RGBA", rule.target_size, (255, 255, 255, 0))
    pos = ((target_w - draw_size[0]) // 2, (target_h - draw_size[1]) // 2)
    canvas.alpha_composite(resized, dest=pos)
    return canvas, bbox, draw_size


def process_one(path: Path, rule: AssetRule, apply: bool) -> dict[str, Any]:
    result: dict[str, Any] = {
        "path": str(path),
        "type": rule.name,
        "exists": path.exists(),
        "original_size": None,
        "bbox": None,
        "content_size": None,
        "target_size": rule.target_size,
        "output_size": None,
        "alpha": None,
        "changed": False,
        "backup": "",
        "note": "",
    }

    if not path.exists():
        result["note"] = "missing"
        return result

    img = Image.open(path).convert("RGBA")
    result["original_size"] = img.size
    result["alpha"] = img.getchannel("A").getextrema()
    fixed, bbox, content_size = normalized_image(img, rule)
    result["bbox"] = bbox
    result["content_size"] = content_size
    result["output_size"] = fixed.size
    result["changed"] = img.size != rule.target_size

    if not apply:
        result["note"] = "would normalize" if result["changed"] else "already normalized"
        return result

    if not result["changed"]:
        result["note"] = "already normalized"
        return result

    backup = path.with_name(f"{path.name}.bak.png")
    result["backup"] = str(backup)
    if not backup.exists():
        shutil.copy2(path, backup)
        result["note"] = "normalized, backup created"
    else:
        result["note"] = "normalized, existing backup kept"

    fixed.save(path)
    return result


def write_report(results: list[dict[str, Any]]) -> None:
    REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# UI 资源尺寸标准化报告",
        "",
        "| 文件 | 类型 | 原始尺寸 | 内容 bbox | 内容输出尺寸 | 目标尺寸 | 输出尺寸 | Alpha | 需要处理 | 备注 |",
        "|---|---|---:|---|---:|---:|---:|---|---:|---|",
    ]
    for result in results:
        lines.append(
            "| `{path}` | {type} | {original_size} | {bbox} | {content_size} | {target_size} | {output_size} | {alpha} | {changed} | {note} |".format(
                **result
            )
        )
    REPORT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


def print_result(result: dict[str, Any]) -> None:
    print(
        "{path}: type={type}, original={original_size}, bbox={bbox}, content={content_size}, "
        "target={target_size}, output={output_size}, alpha={alpha}, note={note}".format(**result)
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Normalize AICat UI PNG dimensions without losing alpha.")
    parser.add_argument("--check-only", action="store_true", help="Inspect assets without writing files.")
    parser.add_argument("--apply", action="store_true", help="Normalize assets in place.")
    args = parser.parse_args()

    if args.check_only == args.apply:
        parser.error("Choose exactly one of --check-only or --apply.")

    results = []
    for path, rule in iter_assets():
        result = process_one(path, rule, apply=args.apply)
        results.append(result)
        print_result(result)

    if args.apply:
        write_report(results)
        print(f"Report written to {REPORT_PATH}")


if __name__ == "__main__":
    main()
