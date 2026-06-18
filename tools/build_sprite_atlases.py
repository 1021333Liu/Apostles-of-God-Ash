from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "assets" / "sprites" / "atlases"


@dataclass(frozen=True)
class FrameGroup:
    name: str
    files: list[Path]


@dataclass(frozen=True)
class AtlasSpec:
    slug: str
    texture_res: str
    cell_size: tuple[int, int]
    anchor: dict[str, float]
    draw_size: tuple[float, float]
    groups: list[FrameGroup]


def p(*parts: str) -> Path:
    return ROOT.joinpath(*parts)


def frame_series(folder: Path, names: Iterable[str]) -> list[Path]:
    return [folder / name for name in names]


def numbered(folder: Path, prefix: str, count: int) -> list[Path]:
    return [folder / f"{prefix}_{index}.png" for index in range(count)]


PLAYER = p("assets", "sprites", "characters", "player")
ENEMIES = p("assets", "sprites", "characters", "enemies")
BOSSES = p("assets", "sprites", "characters", "bosses")
PICKUPS = p("assets", "sprites", "pickups")


SPECS: list[AtlasSpec] = [
    AtlasSpec(
        slug="player_echo",
        texture_res="res://assets/sprites/atlases/player_echo_atlas.png",
        cell_size=(128, 128),
        anchor={"mode": "feet", "x": 64, "y": 104},
        draw_size=(82.0, 82.0),
        groups=[
            FrameGroup("idle", numbered(PLAYER, "player_echo_idle", 4)),
            FrameGroup("walk", numbered(PLAYER, "player_echo_walk", 4)),
            FrameGroup("attack", numbered(PLAYER, "player_echo_attack", 4)),
            FrameGroup("hit", numbered(PLAYER, "player_echo_hit", 3)),
        ],
    ),
    AtlasSpec(
        slug="enemy_empty",
        texture_res="res://assets/sprites/atlases/enemy_empty_atlas.png",
        cell_size=(128, 128),
        anchor={"mode": "feet", "x": 64, "y": 104},
        draw_size=(76.0, 76.0),
        groups=[
            FrameGroup("idle", numbered(ENEMIES, "enemy_empty_idle", 4)),
            FrameGroup("walk", numbered(ENEMIES, "enemy_empty_walk", 4)),
            FrameGroup("attack", numbered(ENEMIES, "enemy_empty_attack", 4)),
            FrameGroup("hit", numbered(ENEMIES, "enemy_empty_hit", 3)),
        ],
    ),
    AtlasSpec(
        slug="enemy_farmer",
        texture_res="res://assets/sprites/atlases/enemy_farmer_atlas.png",
        cell_size=(128, 128),
        anchor={"mode": "feet", "x": 64, "y": 104},
        draw_size=(86.0, 86.0),
        groups=[
            FrameGroup("idle", numbered(ENEMIES, "enemy_farmer_idle", 4)),
            FrameGroup("walk", numbered(ENEMIES, "enemy_farmer_walk", 4)),
            FrameGroup("attack", numbered(ENEMIES, "enemy_farmer_attack", 4)),
            FrameGroup("hit", numbered(ENEMIES, "enemy_farmer_hit", 3)),
        ],
    ),
    AtlasSpec(
        slug="enemy_scarecrow",
        texture_res="res://assets/sprites/atlases/enemy_scarecrow_atlas.png",
        cell_size=(128, 128),
        anchor={"mode": "feet", "x": 64, "y": 104},
        draw_size=(104.0, 104.0),
        groups=[
            FrameGroup("idle", numbered(ENEMIES, "enemy_scarecrow_idle", 4)),
            FrameGroup("walk", numbered(ENEMIES, "enemy_scarecrow_walk", 4)),
            FrameGroup("attack", numbered(ENEMIES, "enemy_scarecrow_attack", 4)),
            FrameGroup("hit", numbered(ENEMIES, "enemy_scarecrow_hit", 3)),
        ],
    ),
    AtlasSpec(
        slug="boss_barn_king",
        texture_res="res://assets/sprites/atlases/boss_barn_king_atlas.png",
        cell_size=(384, 384),
        anchor={"mode": "feet", "x": 192, "y": 315},
        draw_size=(260.0, 260.0),
        groups=[
            FrameGroup("phase1", numbered(BOSSES, "boss_barn_king_phase1_idle", 4)),
            FrameGroup("phase2", numbered(BOSSES, "boss_barn_king_phase2_idle", 4)),
            FrameGroup("phase3", numbered(BOSSES, "boss_barn_king_phase3_idle", 4)),
            FrameGroup("phase1_attack", numbered(BOSSES, "boss_barn_king_phase1_attack", 3)),
            FrameGroup("phase2_attack", numbered(BOSSES, "boss_barn_king_phase2_attack", 3)),
            FrameGroup("phase3_attack", numbered(BOSSES, "boss_barn_king_phase3_attack", 3)),
            FrameGroup("phase1_hit", numbered(BOSSES, "boss_barn_king_phase1_hit", 2)),
            FrameGroup("phase2_hit", numbered(BOSSES, "boss_barn_king_phase2_hit", 2)),
            FrameGroup("phase3_hit", numbered(BOSSES, "boss_barn_king_phase3_hit", 2)),
        ],
    ),
    AtlasSpec(
        slug="log_fragment",
        texture_res="res://assets/sprites/atlases/log_fragment_atlas.png",
        cell_size=(96, 96),
        anchor={"mode": "center", "x": 48, "y": 48},
        draw_size=(42.0, 42.0),
        groups=[
            FrameGroup("pulse", numbered(PICKUPS, "log_fragment_pulse", 5)),
            FrameGroup("idle", numbered(PICKUPS, "log_fragment", 5)),
        ],
    ),
]


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    if image.mode != "RGBA":
        image = image.convert("RGBA")
    return image.getchannel("A").getbbox()


def validate_frame(path: Path, expected_size: tuple[int, int]) -> dict:
    if not path.exists():
        return {"path": rel(path), "ok": False, "error": "missing"}
    with Image.open(path) as raw:
        image = raw.convert("RGBA")
        bbox = alpha_bbox(image)
        width, height = image.size
    ok = (width, height) == expected_size
    touches_edge = False
    if bbox:
        touches_edge = bbox[0] <= 0 or bbox[1] <= 0 or bbox[2] >= width or bbox[3] >= height
    return {
        "path": rel(path),
        "ok": ok,
        "size": [width, height],
        "alpha_bbox": list(bbox) if bbox else None,
        "touches_edge": touches_edge,
    }


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def build_atlas(spec: AtlasSpec) -> dict:
    cell_w, cell_h = spec.cell_size
    frames: list[tuple[str, Path]] = []
    for group in spec.groups:
        frames.extend((group.name, path) for path in group.files)

    cols = 4 if cell_w <= 128 else 3
    rows = (len(frames) + cols - 1) // cols
    atlas = Image.new("RGBA", (cols * cell_w, rows * cell_h), (0, 0, 0, 0))

    groups: dict[str, list[dict]] = {group.name: [] for group in spec.groups}
    qc: list[dict] = []

    for index, (group_name, path) in enumerate(frames):
        frame_qc = validate_frame(path, spec.cell_size)
        qc.append(frame_qc)
        if not frame_qc.get("ok", False):
            continue
        with Image.open(path) as raw:
            image = raw.convert("RGBA")
        x = (index % cols) * cell_w
        y = (index // cols) * cell_h
        atlas.alpha_composite(image, (x, y))
        groups[group_name].append(
            {
                "source": rel(path),
                "region": [x, y, cell_w, cell_h],
                "anchor": spec.anchor,
            }
        )

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    atlas_path = OUT_DIR / f"{spec.slug}_atlas.png"
    manifest_path = OUT_DIR / f"{spec.slug}_atlas.json"
    atlas.save(atlas_path)

    manifest = {
        "schema": "godash.sprite_atlas.v1",
        "source": "tools/build_sprite_atlases.py",
        "texture": spec.texture_res,
        "cell_size": list(spec.cell_size),
        "draw_size": list(spec.draw_size),
        "anchor": spec.anchor,
        "groups": groups,
        "qc": {
            "frames": qc,
            "edge_touch_frames": [item["path"] for item in qc if item.get("touches_edge")],
            "missing_or_bad_frames": [item["path"] for item in qc if not item.get("ok", False)],
        },
    }
    manifest_path.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return {"atlas": rel(atlas_path), "manifest": rel(manifest_path), "frames": len(frames)}


def main() -> None:
    summary = [build_atlas(spec) for spec in SPECS]
    summary_path = OUT_DIR / "sprite_atlas_build_summary.json"
    summary_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
