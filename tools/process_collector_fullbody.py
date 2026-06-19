from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image, ImageEnhance


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SOURCE = ROOT / "assets" / "card_demo" / "actors" / "collector" / "source" / "collector_fullbody_front.png"
OUT_DIR = ROOT / "assets" / "card_demo" / "actors" / "collector"
MANIFEST = ROOT / "assets" / "card_demo" / "card_demo_art_manifest.json"
FRAME_SIZE = (768, 768)
FEET_ANCHOR = {"mode": "feet", "x": 384, "y": 720}
DRAW_SIZE = [320, 420]


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("source image has no visible alpha pixels")
    return bbox


def fit_to_canvas(source: Image.Image, target_height: int = 620) -> Image.Image:
    bbox = alpha_bbox(source)
    cropped = source.crop(bbox)
    scale = target_height / cropped.height
    target_width = max(1, round(cropped.width * scale))
    return cropped.resize((target_width, target_height), Image.Resampling.LANCZOS)


def compose_frame(body: Image.Image, target: Path, y_offset: int = 0, x_offset: int = 0, brightness: float = 1.0) -> dict:
    if brightness != 1.0:
        body = ImageEnhance.Brightness(body).enhance(brightness)
    canvas = Image.new("RGBA", FRAME_SIZE, (0, 0, 0, 0))
    bbox = alpha_bbox(body)
    feet_x = (bbox[0] + bbox[2]) // 2
    feet_y = bbox[3]
    paste_x = FEET_ANCHOR["x"] - feet_x + x_offset
    paste_y = FEET_ANCHOR["y"] - feet_y + y_offset
    canvas.alpha_composite(body, (paste_x, paste_y))
    target.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(target)
    return {
        "path": relative(target),
        "size": list(FRAME_SIZE),
        "alpha_bbox": list(alpha_bbox(canvas)),
    }


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def make_frames(source: Path) -> dict[str, list[dict]]:
    image = Image.open(source).convert("RGBA")
    body = fit_to_canvas(image)
    frame_specs = {
        "fullbody_idle": [
            (0, 0, 1.00),
            (-2, 0, 1.01),
            (-1, 1, 1.00),
            (0, 0, 0.995),
        ],
        "fullbody_speak": [
            (0, 0, 1.00),
            (-2, -1, 1.01),
            (-3, -1, 1.015),
            (-1, 1, 1.005),
            (0, 0, 1.00),
            (-1, 0, 1.01),
        ],
    }
    result: dict[str, list[dict]] = {}
    for action, specs in frame_specs.items():
        frames = []
        for index, (y_offset, x_offset, brightness) in enumerate(specs):
            target = OUT_DIR / f"collector_{action}_{index}.png"
            frames.append(compose_frame(body, target, y_offset=y_offset, x_offset=x_offset, brightness=brightness))
        result[action] = frames
    return result


def action_entry(action: str, frames: list[dict], fps: int, description: str) -> dict:
    return {
        "actor": "collector",
        "action": action,
        "frame_count": len(frames),
        "fps": fps,
        "anchor": FEET_ANCHOR,
        "draw_size": DRAW_SIZE,
        "description": description,
        "paths": [frame["path"] for frame in frames],
        "source": relative(DEFAULT_SOURCE),
        "status": "p0_processed_from_artist_source",
    }


def update_manifest(frames: dict[str, list[dict]]) -> None:
    data = json.loads(MANIFEST.read_text(encoding="utf-8"))
    actions = data.setdefault("actions", [])
    actions[:] = [
        action
        for action in actions
        if not (action.get("actor") == "collector" and action.get("action") in {"fullbody_idle", "fullbody_speak"})
    ]
    actions.append(
        action_entry(
            "fullbody_idle",
            frames["fullbody_idle"],
            6,
            "收藏家全身场景待机；由画师全身源图确定性处理，脚底锚点稳定。",
        )
    )
    actions.append(
        action_entry(
            "fullbody_speak",
            frames["fullbody_speak"],
            8,
            "收藏家全身开场说话；轻微记录/抬眼节奏，保留全身站位。",
        )
    )
    data.setdefault("qc", {})["collector_fullbody"] = {
        "source": relative(DEFAULT_SOURCE),
        "frame_size": list(FRAME_SIZE),
        "anchor": FEET_ANCHOR,
        "frames_checked": sum(len(group) for group in frames.values()),
        "note": "Generated only after artist source exists. No AI-generated collector art is used by this processor.",
    }
    MANIFEST.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Process artist-provided Collector fullbody source into Godot-ready frames.")
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--update-manifest", action="store_true")
    args = parser.parse_args()

    source = args.source
    if not source.exists():
        print(f"Missing artist source: {source}")
        print("Expected a transparent fullbody PNG before generating collector_fullbody_* runtime frames.")
        return 2

    frames = make_frames(source)
    if args.update_manifest:
        update_manifest(frames)
    print(json.dumps({"generated": frames, "manifest_updated": args.update_manifest}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
