#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shutil
from collections import deque
from pathlib import Path
from typing import Any

import numpy as np
from PIL import Image, ImageFilter


RESOURCE_PATHS = [
    "assets/icons/status/status_hunger.png",
    "assets/icons/status/status_mood.png",
    "assets/icons/status/status_energy.png",
    "assets/icons/status/status_clean.png",
    "assets/icons/actions/action_feed.png",
    "assets/icons/actions/action_play.png",
    "assets/icons/actions/action_pet.png",
    "assets/icons/actions/action_bath.png",
    "assets/icons/actions/action_sleep.png",
    "assets/ui/status/status_card_hunger_bg.png",
    "assets/ui/status/status_card_mood_bg.png",
    "assets/ui/status/status_card_energy_bg.png",
    "assets/ui/status/status_card_clean_bg.png",
    "assets/ui/actions/action_button_feed_bg.png",
    "assets/ui/actions/action_button_play_bg.png",
    "assets/ui/actions/action_button_pet_bg.png",
    "assets/ui/actions/action_button_bath_bg.png",
    "assets/ui/actions/action_button_sleep_bg.png",
    "assets/icons/common/sparkle_gold.png",
    "assets/icons/common/sparkle_pink.png",
    "assets/icons/common/sparkle_blue.png",
    "assets/icons/common/sparkle_green.png",
    "assets/icons/common/sparkle_purple.png",
]


REPORT_PATH = Path("docs/ui_transparency_fix_report.md")


def load_rgba(path: Path) -> Image.Image:
    return Image.open(path).convert("RGBA")


def alpha_extrema(img: Image.Image) -> tuple[int, int]:
    return img.getchannel("A").getextrema()


def color_distance(a: np.ndarray | tuple[int, int, int], b: np.ndarray | tuple[int, int, int]) -> float:
    aa = np.asarray(a, dtype=np.int32)
    bb = np.asarray(b, dtype=np.int32)
    return float(np.sqrt(np.sum((aa - bb) ** 2)))


def edge_pixels(arr: np.ndarray, sample_width: int) -> np.ndarray:
    h, w, _ = arr.shape
    sw = max(1, min(sample_width, h // 2 or 1, w // 2 or 1))
    return np.concatenate(
        [
            arr[:sw, :, :3].reshape(-1, 3),
            arr[-sw:, :, :3].reshape(-1, 3),
            arr[:, :sw, :3].reshape(-1, 3),
            arr[:, -sw:, :3].reshape(-1, 3),
        ],
        axis=0,
    )


def estimate_edge_backgrounds(arr: np.ndarray, sample_width: int = 8) -> list[tuple[int, int, int]]:
    edges = edge_pixels(arr, sample_width)
    saturation = edges.max(axis=1) - edges.min(axis=1)
    light = edges[(saturation <= 8) & (edges.mean(axis=1) >= 210)]
    if len(light) == 0:
        return []

    candidates: list[tuple[int, int, int]] = []
    for q in (5, 20, 35, 50, 65, 80, 95):
        candidate = tuple(int(v) for v in np.percentile(light, q, axis=0))
        if all(color_distance(candidate, existing) > 7 for existing in candidates):
            candidates.append(candidate)

    mean = tuple(int(v) for v in np.mean(light, axis=0))
    if all(color_distance(mean, existing) > 7 for existing in candidates):
        candidates.append(mean)
    return candidates


def light_background_mask(rgb: np.ndarray) -> np.ndarray:
    channel_min = rgb.min(axis=2)
    channel_max = rgb.max(axis=2)
    saturation = channel_max - channel_min
    avg = rgb.mean(axis=2)

    neutral_light = (avg >= 218) & (saturation <= 8)
    near_white = (channel_min >= 248) & (saturation <= 10)
    return neutral_light | near_white


def make_background_mask(arr: np.ndarray, candidates: list[tuple[int, int, int]], tolerance: int) -> np.ndarray:
    rgb = arr[:, :, :3]
    alpha = arr[:, :, 3]
    mask = alpha < 8

    for candidate in candidates:
        diff = np.sqrt(
            np.sum((rgb.astype(np.int32) - np.asarray(candidate, dtype=np.int32)) ** 2, axis=2)
        )
        saturation = rgb.max(axis=2) - rgb.min(axis=2)
        mask |= (diff <= tolerance) & (saturation <= 8)

    mask |= light_background_mask(rgb)
    return mask


def flood_fill_from_edges(mask: np.ndarray) -> np.ndarray:
    h, w = mask.shape
    visited = np.zeros((h, w), dtype=bool)
    queue: deque[tuple[int, int]] = deque()

    for x in range(w):
        if mask[0, x]:
            queue.append((0, x))
        if mask[h - 1, x]:
            queue.append((h - 1, x))
    for y in range(h):
        if mask[y, 0]:
            queue.append((y, 0))
        if mask[y, w - 1]:
            queue.append((y, w - 1))

    while queue:
        y, x = queue.popleft()
        if y < 0 or y >= h or x < 0 or x >= w:
            continue
        if visited[y, x] or not mask[y, x]:
            continue
        visited[y, x] = True
        queue.append((y - 1, x))
        queue.append((y + 1, x))
        queue.append((y, x - 1))
        queue.append((y, x + 1))

    return visited


def soften_alpha(img: Image.Image, background: np.ndarray) -> Image.Image:
    arr = np.asarray(img).copy()
    alpha = arr[:, :, 3].copy()
    alpha[background] = 0

    mask = Image.fromarray((background.astype(np.uint8) * 255), mode="L")
    blur = np.asarray(mask.filter(ImageFilter.GaussianBlur(radius=1)))
    edge = (blur > 0) & (~background)
    alpha[edge] = np.minimum(alpha[edge], 255 - (blur[edge] // 3))

    arr[:, :, 3] = alpha
    return Image.fromarray(arr, mode="RGBA")


def backup_path_for(path: Path) -> Path:
    return path.with_name(f"{path.name}.bak.png")


def process_one(path: Path, check_only: bool, tolerance: int) -> dict[str, Any]:
    result: dict[str, Any] = {
        "path": str(path),
        "exists": path.exists(),
        "size": None,
        "alpha_before": None,
        "alpha_after": None,
        "edge_background_ratio": None,
        "background_ratio": None,
        "opaque_background_ratio": None,
        "has_fake_bg": False,
        "fixed": False,
        "note": "",
    }

    if not path.exists():
        result["note"] = "missing"
        return result

    img = load_rgba(path)
    result["size"] = img.size
    result["alpha_before"] = alpha_extrema(img)
    arr = np.asarray(img)
    candidates = estimate_edge_backgrounds(arr)

    if not candidates:
        result["alpha_after"] = result["alpha_before"]
        result["note"] = "no light edge background candidates"
        return result

    mask = make_background_mask(arr, candidates, tolerance)
    connected = flood_fill_from_edges(mask)
    edge = edge_pixels(np.dstack([connected.astype(np.uint8)] * 4), 2)[:, 0]
    edge_ratio = float(edge.mean()) if len(edge) else 0.0
    background_ratio = float(connected.mean())
    opaque_connected = connected & (arr[:, :, 3] > 245)
    opaque_edge = edge_pixels(np.dstack([opaque_connected.astype(np.uint8)] * 4), 2)[:, 0]
    opaque_edge_ratio = float(opaque_edge.mean()) if len(opaque_edge) else 0.0
    opaque_background_ratio = float(opaque_connected.mean())
    result["edge_background_ratio"] = f"{edge_ratio:.3f}"
    result["background_ratio"] = f"{background_ratio:.3f}"
    result["opaque_background_ratio"] = f"{opaque_background_ratio:.3f}"

    alpha_min, alpha_max = result["alpha_before"]
    has_opaque_alpha = alpha_min == 255 and alpha_max == 255
    result["has_fake_bg"] = (
        opaque_background_ratio > 0.01
        and (has_opaque_alpha or opaque_edge_ratio > 0.35)
    )

    if not result["has_fake_bg"]:
        result["alpha_after"] = result["alpha_before"]
        result["note"] = "edge-connected fake background not detected"
        return result

    if check_only:
        result["alpha_after"] = result["alpha_before"]
        result["note"] = f"would fix, candidates={candidates}"
        return result

    backup_path = backup_path_for(path)
    if not backup_path.exists():
        shutil.copy2(path, backup_path)

    fixed = soften_alpha(img, connected)
    fixed.save(path)
    result["fixed"] = True
    result["alpha_after"] = alpha_extrema(fixed)
    result["note"] = f"fixed, backup={backup_path.name}, candidates={candidates}"
    return result


def write_report(results: list[dict[str, Any]], report_path: Path) -> None:
    report_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "# UI 资源透明度修复报告",
        "",
        "## 修复结果",
        "",
        "| 文件 | 存在 | 尺寸 | 修复前 Alpha | 修复后 Alpha | 边缘背景占比 | 背景占比 | 疑似伪透明 | 已修复 | 备注 |",
        "|---|---:|---|---|---|---:|---:|---:|---:|---|",
    ]
    for result in results:
        lines.append(
            "| `{path}` | {exists} | {size} | {alpha_before} | {alpha_after} | {edge_background_ratio} | {background_ratio} | {has_fake_bg} | {fixed} | {note} |".format(
                **result
            )
        )
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def print_result(result: dict[str, Any]) -> None:
    print(
        "{path}: exists={exists}, size={size}, alpha={alpha_before}->{alpha_after}, "
        "fake_bg={has_fake_bg}, fixed={fixed}, note={note}".format(**result)
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Fix edge-connected fake transparent backgrounds in UI PNGs.")
    parser.add_argument("--check-only", action="store_true", help="Inspect resources without modifying PNG files.")
    parser.add_argument("--tolerance", type=int, default=40, help="RGB distance tolerance for background matching.")
    args = parser.parse_args()

    results = []
    for resource in RESOURCE_PATHS:
        result = process_one(Path(resource), check_only=args.check_only, tolerance=args.tolerance)
        results.append(result)
        print_result(result)

    if not args.check_only:
        write_report(results, REPORT_PATH)
        print(f"Report written to {REPORT_PATH}")


if __name__ == "__main__":
    main()
