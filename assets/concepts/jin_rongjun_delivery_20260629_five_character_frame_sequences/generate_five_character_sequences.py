from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[3]
DELIVERY = ROOT / "assets" / "concepts" / "jin_rongjun_delivery_20260629_five_character_frame_sequences"
SOURCE = DELIVERY / "source"
SIZE = (768, 768)
ANCHOR = (384, 720)


CHARACTERS = {
    "enemy_empty": {
        "source": "enemy_empty_fullbody_clean.png",
        "out": ROOT / "assets" / "sprites" / "characters" / "enemies",
        "actions": {"idle": 4, "walk": 6, "attack": 6, "hit": 4},
        "profile": "empty",
    },
    "enemy_farmer": {
        "source": "enemy_farmer_fullbody_clean.png",
        "out": ROOT / "assets" / "sprites" / "characters" / "enemies",
        "actions": {"idle": 4, "walk": 6, "attack": 6, "hit": 4},
        "profile": "farmer",
    },
    "enemy_scarecrow": {
        "source": "enemy_scarecrow_fullbody_clean.png",
        "out": ROOT / "assets" / "sprites" / "characters" / "enemies",
        "actions": {"idle": 4, "walk": 6, "attack": 6, "hit": 4},
        "profile": "scarecrow",
    },
    "player_echo": {
        "source": "player_echo_fullbody_20260610_alpha.png",
        "out": ROOT / "assets" / "sprites" / "characters" / "player",
        "actions": {
            "idle": 4,
            "walk": 6,
            "attack": 6,
            "heavy_attack": 8,
            "defend": 4,
            "hit": 4,
            "ultimate_cast": 8,
        },
        "profile": "player",
    },
    "boss_barn_king": {
        "source": "boss_barn_king_fullbody_clean.png",
        "out": ROOT / "assets" / "sprites" / "characters" / "bosses",
        "actions": {"idle": 6, "advance": 6, "attack": 8, "hit": 4},
        "profile": "boss",
    },
}


def alpha_bbox(img: Image.Image):
    return img.getchannel("A").getbbox()


def load_base(path: Path) -> Image.Image:
    img = Image.open(path).convert("RGBA")
    if img.size == SIZE:
        return img
    canvas = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    canvas.alpha_composite(img, ((SIZE[0] - img.width) // 2, (SIZE[1] - img.height) // 2))
    return canvas


def scale_anchor(img: Image.Image, sx=1.0, sy=1.0, dx=0, dy=0) -> Image.Image:
    bbox = alpha_bbox(img)
    if not bbox:
        return img.copy()
    crop = img.crop(bbox)
    new_size = (max(1, int(crop.width * sx)), max(1, int(crop.height * sy)))
    crop = crop.resize(new_size, Image.Resampling.BICUBIC)
    x = int(ANCHOR[0] + (bbox[0] - ANCHOR[0]) * sx + dx)
    y = int(ANCHOR[1] + (bbox[1] - ANCHOR[1]) * sy + dy)
    out = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    out.alpha_composite(crop, (x, y))
    return out


def band_shift(img: Image.Image, upper_dx=0, upper_dy=0, mid_dx=0, lower_dx=0, cutoff=420, feather=160) -> Image.Image:
    out = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    for y in range(0, SIZE[1], 2):
        band = img.crop((0, y, SIZE[0], min(SIZE[1], y + 2)))
        upper_t = 1.0 if y < cutoff else max(0.0, 1.0 - (y - cutoff) / max(1, feather))
        lower_t = max(0.0, min(1.0, (y - 500) / 170))
        mid_t = max(0.0, 1.0 - abs(y - 450) / 230)
        dx = int(upper_dx * upper_t + mid_dx * mid_t + lower_dx * lower_t)
        dy = int(upper_dy * upper_t)
        out.alpha_composite(band, (dx, y + dy))
    return out


def vertical_pulse(img: Image.Image, shoulder=0, waist=0, hem=0) -> Image.Image:
    out = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    for y in range(0, SIZE[1], 2):
        band = img.crop((0, y, SIZE[0], min(SIZE[1], y + 2)))
        shoulder_t = max(0.0, 1.0 - abs(y - 220) / 220)
        waist_t = max(0.0, 1.0 - abs(y - 430) / 170)
        hem_t = max(0.0, min(1.0, (y - 500) / 190))
        dy = int(shoulder * shoulder_t + waist * waist_t + hem * hem_t)
        out.alpha_composite(band, (0, y + dy))
    return out


def lean(img: Image.Image, amount=0, top=60, bottom=720) -> Image.Image:
    out = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    for y in range(0, SIZE[1], 2):
        band = img.crop((0, y, SIZE[0], min(SIZE[1], y + 2)))
        t = max(0.0, min(1.0, (bottom - y) / max(1, bottom - top)))
        out.alpha_composite(band, (int(amount * t), y))
    return out


def normalize_bottom(img: Image.Image) -> Image.Image:
    bbox = alpha_bbox(img)
    if not bbox:
        return img
    dy = ANCHOR[1] - bbox[3]
    out = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    out.alpha_composite(img, (0, dy))
    return out


def postprocess(img: Image.Image) -> Image.Image:
    # Never crop; preserve the 768x768 runtime canvas and transparent corners.
    return normalize_bottom(img)


def pose_values(profile: str, action: str, index: int, count: int):
    wave = [0, -1, 1, 0, -1, 1, 0, 0][index % 8]

    if action == "idle":
        return dict(sx=1.0 + 0.004 * wave, sy=1.0 - 0.006 * wave, lean=5 * wave, upper_dy=2 * wave, shoulder=2 * wave)

    if action in ("walk", "advance"):
        cycle = [-1.0, -0.65, 0.35, 1.0, 0.55, 0.0][index % 6]
        if profile == "scarecrow":
            return dict(lean=-28 * cycle, upper_dx=-24 * cycle, mid_dx=18 * cycle, lower_dx=-18 * cycle, dx=8 * cycle, hem=6 * abs(cycle))
        if profile == "boss":
            return dict(lean=-22 * cycle, upper_dx=-22 * cycle, mid_dx=-12 * cycle, lower_dx=8 * cycle, dx=-10 * cycle, sy=1.0 + 0.012 * abs(cycle), shoulder=4 * abs(cycle))
        return dict(lean=-24 * cycle, upper_dx=-30 * cycle, mid_dx=12 * cycle, lower_dx=-12 * cycle, dx=-12 * cycle, sy=1.0 + 0.009 * abs(cycle), hem=4 * abs(cycle))

    if action == "attack":
        # Anticipation -> extension -> hold -> recovery, no baked slash.
        seq6 = [
            dict(lean=18, upper_dx=22, upper_dy=4, mid_dx=8, dx=2, shoulder=4),
            dict(lean=-16, upper_dx=-34, upper_dy=2, mid_dx=-10, dx=-7, shoulder=2),
            dict(lean=-42, upper_dx=-72, upper_dy=5, mid_dx=-24, dx=-14, shoulder=-2),
            dict(lean=-58, upper_dx=-96, upper_dy=8, mid_dx=-36, dx=-18, shoulder=-4),
            dict(lean=-28, upper_dx=-44, upper_dy=3, mid_dx=-12, dx=-7, shoulder=0),
            dict(lean=0, upper_dx=0, upper_dy=0, mid_dx=0, dx=0),
        ]
        seq8 = [
            dict(lean=18, upper_dx=20, upper_dy=3, mid_dx=8, dx=1),
            dict(lean=4, upper_dx=0, upper_dy=4, mid_dx=0, dx=0),
            dict(lean=-16, upper_dx=-30, upper_dy=3, mid_dx=-8, dx=-5),
            dict(lean=-34, upper_dx=-58, upper_dy=5, mid_dx=-18, dx=-11),
            dict(lean=-48, upper_dx=-78, upper_dy=7, mid_dx=-28, dx=-15),
            dict(lean=-46, upper_dx=-70, upper_dy=6, mid_dx=-22, dx=-13),
            dict(lean=-20, upper_dx=-28, upper_dy=2, mid_dx=-6, dx=-5),
            dict(lean=0, upper_dx=0, upper_dy=0, mid_dx=0, dx=0),
        ]
        values = seq8 if count == 8 else seq6
        v = values[index]
        if profile == "boss":
            v = {k: val * 0.9 if isinstance(val, (int, float)) else val for k, val in v.items()}
        if profile == "scarecrow":
            v = {k: val * 0.58 if isinstance(val, (int, float)) else val for k, val in v.items()}
        return v

    if action == "heavy_attack":
        seq = [
            dict(lean=28, upper_dx=26, upper_dy=8, mid_dx=10, sy=0.985, shoulder=8),
            dict(lean=18, upper_dx=10, upper_dy=12, mid_dx=3, sy=0.975, shoulder=12),
            dict(lean=-10, upper_dx=-24, upper_dy=4, mid_dx=-8, sy=1.000),
            dict(lean=-34, upper_dx=-58, upper_dy=2, mid_dx=-20, sy=1.010),
            dict(lean=-58, upper_dx=-96, upper_dy=4, mid_dx=-36, sy=1.016),
            dict(lean=-60, upper_dx=-92, upper_dy=5, mid_dx=-30, sy=1.012),
            dict(lean=-26, upper_dx=-38, upper_dy=1, mid_dx=-10, sy=1.000),
            dict(lean=0, upper_dx=0, upper_dy=0, sy=1.000),
        ]
        return seq[index]

    if action == "defend":
        seq = [
            dict(lean=0, upper_dx=0, upper_dy=0, sy=1.0),
            dict(lean=16, upper_dx=22, upper_dy=-4, mid_dx=8, sy=0.992),
            dict(lean=26, upper_dx=34, upper_dy=-7, mid_dx=14, sy=0.986),
            dict(lean=20, upper_dx=28, upper_dy=-5, mid_dx=10, sy=0.990),
        ]
        return seq[index]

    if action == "ultimate_cast":
        seq = [
            dict(lean=0, upper_dx=0, upper_dy=0),
            dict(lean=12, upper_dx=16, upper_dy=8, mid_dx=6, sy=0.990),
            dict(lean=-8, upper_dx=-12, upper_dy=-8, mid_dx=-3, sy=1.004),
            dict(lean=-24, upper_dx=-36, upper_dy=-12, mid_dx=-12, sy=1.010),
            dict(lean=-34, upper_dx=-50, upper_dy=-16, mid_dx=-18, sy=1.014),
            dict(lean=-24, upper_dx=-34, upper_dy=-8, mid_dx=-10, sy=1.006),
            dict(lean=-12, upper_dx=-18, upper_dy=-5, mid_dx=-6, sy=1.002),
            dict(lean=0, upper_dx=0, upper_dy=0),
        ]
        return seq[index]

    if action == "hit":
        seq4 = [
            dict(lean=0, upper_dx=0, upper_dy=0),
            dict(lean=26, upper_dx=38, upper_dy=-5, mid_dx=12, dx=7, shoulder=-2),
            dict(lean=42, upper_dx=60, upper_dy=-9, mid_dx=20, dx=12, shoulder=-4),
            dict(lean=12, upper_dx=18, upper_dy=-2, mid_dx=4, dx=3),
        ]
        v = seq4[index]
        if profile == "boss":
            v = {k: val * 0.8 if isinstance(val, (int, float)) else val for k, val in v.items()}
        return v

    return {}


def make_frame(base: Image.Image, profile: str, action: str, index: int, count: int) -> Image.Image:
    v = pose_values(profile, action, index, count)
    img = scale_anchor(base, sx=v.get("sx", 1.0), sy=v.get("sy", 1.0), dx=int(v.get("dx", 0)), dy=int(v.get("dy", 0)))
    img = vertical_pulse(img, shoulder=int(v.get("shoulder", 0)), waist=int(v.get("waist", 0)), hem=int(v.get("hem", 0)))
    img = lean(img, int(v.get("lean", 0)))
    img = band_shift(
        img,
        upper_dx=int(v.get("upper_dx", 0)),
        upper_dy=int(v.get("upper_dy", 0)),
        mid_dx=int(v.get("mid_dx", 0)),
        lower_dx=int(v.get("lower_dx", 0)),
        cutoff=430 if profile != "boss" else 470,
        feather=150 if profile != "boss" else 180,
    )
    return postprocess(img)


def make_contact_sheet(char_name: str, files: list[Path]):
    cols = 6
    thumb = 126
    label_h = 28
    rows = (len(files) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * thumb, rows * (thumb + label_h)), (36, 36, 32, 255))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for i, path in enumerate(files):
        img = Image.open(path).convert("RGBA")
        bg = Image.new("RGBA", img.size, (48, 52, 44, 255))
        bg.alpha_composite(img)
        bg.thumbnail((thumb, thumb), Image.Resampling.LANCZOS)
        x = (i % cols) * thumb + (thumb - bg.width) // 2
        y = (i // cols) * (thumb + label_h) + (thumb - bg.height) // 2
        sheet.alpha_composite(bg, (x, y))
        draw.text(((i % cols) * thumb + 3, (i // cols) * (thumb + label_h) + thumb + 3), path.stem.replace(char_name + "_", ""), fill=(230, 225, 210, 255), font=font)
    out = DELIVERY / f"preview_{char_name}_contact_sheet.png"
    sheet.convert("RGB").save(out)


def main():
    total = 0
    for char_name, spec in CHARACTERS.items():
        base = load_base(SOURCE / spec["source"])
        spec["out"].mkdir(parents=True, exist_ok=True)
        files: list[Path] = []
        for action, count in spec["actions"].items():
            for index in range(count):
                frame = make_frame(base, spec["profile"], action, index, count)
                path = spec["out"] / f"{char_name}_{action}_{index}.png"
                frame.save(path)
                files.append(path)
                total += 1
        idle0 = spec["out"] / f"{char_name}_idle_0.png"
        idle_alias = spec["out"] / f"{char_name}_idle.png"
        if idle0.exists():
            idle_alias.write_bytes(idle0.read_bytes())
        make_contact_sheet(char_name, files)
    print(f"generated {total} runtime frames for {len(CHARACTERS)} characters")


if __name__ == "__main__":
    main()
