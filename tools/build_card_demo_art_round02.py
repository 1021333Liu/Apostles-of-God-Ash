from __future__ import annotations

import json
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "card_demo"
CANVAS = (768, 768)
ANCHOR = {"mode": "feet", "x": 384, "y": 720}
SOURCE_ANCHOR = (64, 104)
SCALE = 4.45


def alpha_bbox(image: Image.Image) -> tuple[int, int, int, int] | None:
    return image.getchannel("A").getbbox()


def paste_frame(source: Path, target: Path, tint: tuple[int, int, int, int] | None = None) -> dict:
    image = Image.open(source).convert("RGBA")
    resized = image.resize((round(image.width * SCALE), round(image.height * SCALE)), Image.Resampling.LANCZOS)
    if tint:
        overlay = Image.new("RGBA", resized.size, tint)
        mask = resized.getchannel("A")
        resized = Image.alpha_composite(resized, Image.composite(overlay, Image.new("RGBA", resized.size), mask))

    canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
    offset_x = round(ANCHOR["x"] - SOURCE_ANCHOR[0] * SCALE)
    offset_y = round(ANCHOR["y"] - SOURCE_ANCHOR[1] * SCALE)
    canvas.alpha_composite(resized, (offset_x, offset_y))
    target.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(target)
    return {
        "path": target.as_posix(),
        "source": source.as_posix(),
        "size": list(CANVAS),
        "alpha_bbox": list(alpha_bbox(canvas) or (0, 0, 0, 0)),
    }


def expand(source_pattern: str, indices: Iterable[int], target_dir: Path, target_prefix: str, tint=None) -> list[dict]:
    sources = sorted(ROOT.glob(source_pattern))
    if not sources:
        raise FileNotFoundError(source_pattern)
    frames = []
    for out_index, source_index in enumerate(indices):
        source = sources[source_index % len(sources)]
        target = target_dir / f"{target_prefix}_{out_index}.png"
        frames.append(paste_frame(source, target, tint=tint))
    return frames


def draw_bubble(path: Path, mode: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image = Image.new("RGBA", (320, 168), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    if mode == "attack":
        fill = (214, 200, 176, 225)
        outline = (91, 47, 39, 245)
        accent = (113, 30, 27, 220)
    else:
        fill = (198, 202, 194, 225)
        outline = (58, 69, 67, 245)
        accent = (72, 91, 86, 220)
    draw.rounded_rectangle((22, 18, 298, 116), radius=42, fill=fill, outline=outline, width=6)
    draw.ellipse((72, 116, 104, 146), fill=fill, outline=outline, width=4)
    draw.ellipse((48, 146, 66, 162), fill=fill, outline=outline, width=3)
    draw.arc((42, 36, 132, 104), 215, 330, fill=(255, 250, 232, 95), width=5)
    if mode == "attack":
        draw.line((214, 48, 252, 88), fill=accent, width=9)
        draw.polygon([(252, 88), (234, 81), (244, 70)], fill=accent)
    else:
        draw.polygon([(214, 48), (252, 60), (246, 96), (218, 106), (198, 82)], outline=accent, fill=None)
        draw.line((212, 74, 246, 82), fill=accent, width=7)
    image = image.filter(ImageFilter.UnsharpMask(radius=1.0, percent=110))
    image.save(path)


def draw_dice_stage(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image = Image.new("RGBA", (512, 256), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.ellipse((56, 120, 456, 226), fill=(48, 43, 34, 132))
    draw.rounded_rectangle((72, 54, 440, 194), radius=30, fill=(150, 137, 112, 218), outline=(71, 58, 44, 245), width=7)
    draw.rounded_rectangle((106, 82, 406, 166), radius=18, fill=(218, 207, 181, 232), outline=(95, 78, 57, 220), width=4)
    draw.polygon([(184, 114), (214, 88), (250, 104), (250, 144), (214, 164), (184, 144)], fill=(91, 43, 39, 230))
    draw.polygon([(282, 96), (334, 96), (356, 132), (330, 166), (282, 154), (264, 122)], fill=(66, 77, 72, 230))
    image = image.filter(ImageFilter.UnsharpMask(radius=1.0, percent=115))
    image.save(path)


def action_entry(actor: str, action: str, frame_count: int, fps: int, description: str, paths: list[str], reuse_from: str | None = None, status: str = "p0_proxy") -> dict:
    entry = {
        "actor": actor,
        "action": action,
        "frame_count": frame_count,
        "fps": fps,
        "anchor": ANCHOR,
        "draw_size": [256, 256],
        "flip_policy": "mirror_x_by_direction",
        "description": description,
        "paths": paths,
        "status": status,
    }
    if reuse_from:
        entry["reuse_from"] = reuse_from
    return entry


def main() -> None:
    player_dir = OUT / "actors" / "player_echo"
    farmer_dir = OUT / "actors" / "enemy_farmer"
    actions = []
    qc_frames = []

    specs = [
        ("player_echo", "field_idle", 6, 6, "田野探索待机；呼吸、布条和身体轻晃，右向基准。", "assets/sprites/characters/player/player_echo_idle_*.png", [0, 1, 2, 3, 2, 1], player_dir, None, None),
        ("player_echo", "field_walk", 8, 10, "田野探索行走循环；脚底锚点稳定在 y=720，程序侧平移角色。", "assets/sprites/characters/player/player_echo_walk_*.png", [0, 1, 2, 3, 2, 1, 0, 1], player_dir, None, None),
        ("player_echo", "card_attack", 8, 12, "卡牌战斗出牌攻击；复用旧攻击帧，武器过宽问题标记为后续重画。", "assets/sprites/characters/player/player_echo_attack_*.png", [0, 1, 2, 3, 2, 1, 0, 3], player_dir, "actor_player_echo_attack_*", None),
        ("player_echo", "card_defend", 8, 8, "卡牌防御；首版用待机压低节奏替代，后续需画举刃/护胃动作。", "assets/sprites/characters/player/player_echo_idle_*.png", [0, 1, 2, 3, 2, 1, 0, 1], player_dir, "player_echo_idle_*", (48, 66, 76, 36)),
        ("player_echo", "card_hurt", 6, 10, "受击后仰；复用旧 hit 帧扩展到 6 帧。", "assets/sprites/characters/player/player_echo_hit_*.png", [0, 1, 2, 1, 0, 2], player_dir, "player_echo_hit_*", None),
        ("player_echo", "card_win", 8, 8, "胜利收刀；首版用待机回稳替代，后续需画胸口暗红圣痕收束。", "assets/sprites/characters/player/player_echo_idle_*.png", [3, 2, 1, 0, 1, 2, 3, 0], player_dir, "player_echo_idle_*", (185, 178, 150, 24)),
        ("enemy_farmer", "field_idle", 6, 6, "农夫田路待机；佝偻颤动，面向主角。", "assets/sprites/characters/enemies/enemy_farmer_idle_*.png", [0, 1, 2, 3, 2, 1], farmer_dir, None, None),
        ("enemy_farmer", "field_mutter", 8, 8, "农夫喃喃自语；用行走/待机节奏临时表现身体前后晃动。", "assets/sprites/characters/enemies/enemy_farmer_walk_*.png", [1, 0, 1, 2, 3, 2, 1, 0], farmer_dir, "enemy_farmer_walk_*", (88, 62, 45, 30)),
        ("enemy_farmer", "card_attack", 8, 12, "农夫出牌攻击；复用旧农具攻击帧扩展到 8 帧。", "assets/sprites/characters/enemies/enemy_farmer_attack_*.png", [0, 1, 2, 3, 2, 1, 0, 3], farmer_dir, "actor_enemy_farmer_attack_*", None),
        ("enemy_farmer", "card_defend", 8, 8, "农夫防御；首版用待机收缩替代，后续需画抱碗/护身动作。", "assets/sprites/characters/enemies/enemy_farmer_idle_*.png", [0, 1, 2, 3, 2, 1, 0, 1], farmer_dir, "enemy_farmer_idle_*", (52, 67, 58, 34)),
        ("enemy_farmer", "card_hurt", 6, 10, "农夫受击踉跄；复用旧 hit 帧扩展到 6 帧。", "assets/sprites/characters/enemies/enemy_farmer_hit_*.png", [0, 1, 2, 1, 0, 2], farmer_dir, "enemy_farmer_hit_*", None),
        ("enemy_farmer", "card_mutter", 8, 8, "农夫战斗喃喃；用于回合等待和骰子判定前。", "assets/sprites/characters/enemies/enemy_farmer_idle_*.png", [0, 1, 2, 3, 2, 1, 0, 1], farmer_dir, "enemy_farmer_idle_*", (91, 62, 41, 30)),
        ("enemy_farmer", "card_confess", 8, 7, "农夫坦白/崩溃；首版用受击回到待机替代，后续需画跪低和松手。", "assets/sprites/characters/enemies/enemy_farmer_hit_*.png", [0, 1, 2, 2, 1, 0, 2, 2], farmer_dir, "enemy_farmer_hit_*", (105, 83, 66, 34)),
    ]

    for actor, action, count, fps, desc, pattern, indices, target_dir, reuse, tint in specs:
        frames = expand(pattern, indices, target_dir, action, tint=tint)
        qc_frames.extend(frames)
        actions.append(action_entry(actor, action, count, fps, desc, [f["path"].replace((ROOT.as_posix() + "/"), "") for f in frames], reuse_from=reuse))

    draw_bubble(OUT / "ui" / "intent" / "bubble_attack.png", "attack")
    draw_bubble(OUT / "ui" / "intent" / "bubble_defend.png", "defend")
    draw_dice_stage(OUT / "ui" / "dice" / "dice_roll_stage.png")

    manifest = {
        "schema": "godash.card_demo_art.v1",
        "source": "tools/build_card_demo_art_round02.py",
        "style_contract": "P0 proxy assets adapted from current project sprites; Wyeth-like low-saturation rural mood remains the final redraw target.",
        "coordinate_contract": {
            "character_frame_size": list(CANVAS),
            "anchor": ANCHOR,
            "direction_policy": "Author frames face right/right-front. Runtime should mirror around the feet anchor for left-facing states instead of swapping differently centered art.",
        },
        "actions": actions,
        "ui": [
            {
                "id": "intent_attack",
                "path": "assets/card_demo/ui/intent/bubble_attack.png",
                "size": [320, 168],
                "anchor": {"mode": "bottom_center", "x": 160, "y": 150},
                "description": "攻击意图气泡；透明 PNG，左侧留文字区，右侧有短刃符号。",
                "status": "p0_proxy",
            },
            {
                "id": "intent_defend",
                "path": "assets/card_demo/ui/intent/bubble_defend.png",
                "size": [320, 168],
                "anchor": {"mode": "bottom_center", "x": 160, "y": 150},
                "description": "防御意图气泡；透明 PNG，左侧留文字区，右侧有盾形符号。",
                "status": "p0_proxy",
            },
            {
                "id": "dice_roll_stage",
                "path": "assets/card_demo/ui/dice/dice_roll_stage.png",
                "size": [512, 256],
                "anchor": {"mode": "center", "x": 256, "y": 128},
                "description": "骰子滚动底座；用于屏幕中央承载 D20 / D3 结果。",
                "status": "p0_proxy",
            },
        ],
        "reusable_existing_icons": [
            {
                "id": "memory_shard",
                "path": "assets/sprites/ui/ui_memory_shard.svg",
                "use": "可临时作为战斗胜利后的记忆样本奖励图标，不建议直接当暴击/大失败图标。",
            },
            {
                "id": "stomach_open_closed_overflow",
                "paths": [
                    "assets/sprites/ui/ui_stomach_open.svg",
                    "assets/sprites/ui/ui_stomach_closed.svg",
                    "assets/sprites/ui/ui_stomach_overflow.svg",
                ],
                "use": "可复用到回合结果或胃囊系统提示；反弹、完美防御、暴击、大失败仍需独立重画。",
            },
        ],
        "qc": {
            "frames_checked": len(qc_frames),
            "required_character_size": list(CANVAS),
            "required_anchor_y": 720,
            "note": "All generated character files are RGBA 768x768 with stable paste anchor. Several attack/hurt frames reuse old edge-touch source art and should be repainted before final.",
        },
    }
    (OUT / "card_demo_art_manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
