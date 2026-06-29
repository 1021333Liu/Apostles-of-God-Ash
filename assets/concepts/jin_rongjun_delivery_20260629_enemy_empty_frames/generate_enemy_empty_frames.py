from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[3]
DELIVERY = ROOT / "assets" / "concepts" / "jin_rongjun_delivery_20260629_enemy_empty_frames"
SOURCE = DELIVERY / "source" / "enemy_empty_fullbody_clean_reference.png"
OUT_DIR = ROOT / "assets" / "sprites" / "characters" / "enemies"
SIZE = (768, 768)
ANCHOR = (384, 720)


def alpha_bbox(img: Image.Image):
    return img.getchannel("A").getbbox()


def place_on_canvas(img: Image.Image) -> Image.Image:
    canvas = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    if img.size != SIZE:
        canvas.alpha_composite(img, ((SIZE[0] - img.width) // 2, (SIZE[1] - img.height) // 2))
        return canvas
    return img.copy()


def scale_about_anchor(img: Image.Image, sx: float = 1.0, sy: float = 1.0, dx: int = 0, dy: int = 0) -> Image.Image:
    bbox = alpha_bbox(img)
    if not bbox:
        return img.copy()
    crop = img.crop(bbox)
    new_size = (max(1, int(crop.width * sx)), max(1, int(crop.height * sy)))
    crop = crop.resize(new_size, Image.Resampling.BICUBIC)
    x0 = int(ANCHOR[0] + (bbox[0] - ANCHOR[0]) * sx + dx)
    y0 = int(ANCHOR[1] + (bbox[1] - ANCHOR[1]) * sy + dy)
    out = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    out.alpha_composite(crop, (x0, y0))
    return out


def lean(img: Image.Image, amount: int = 0, y_start: int = 80, y_end: int = 720) -> Image.Image:
    out = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    for y in range(0, SIZE[1], 3):
        band = img.crop((0, y, SIZE[0], min(SIZE[1], y + 3)))
        if y < y_end:
            t = max(0.0, min(1.0, (y_end - y) / max(1, y_end - y_start)))
            shift = int(amount * t)
        else:
            shift = 0
        out.alpha_composite(band, (shift, y))
    return out


def upper_shift(img: Image.Image, dx: int = 0, dy: int = 0, cutoff: int = 430, feather: int = 90) -> Image.Image:
    out = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    for y in range(0, SIZE[1], 2):
        band = img.crop((0, y, SIZE[0], min(SIZE[1], y + 2)))
        if y < cutoff:
            t = 1.0
        elif y < cutoff + feather:
            t = 1.0 - (y - cutoff) / feather
        else:
            t = 0.0
        out.alpha_composite(band, (int(dx * t), y + int(dy * t)))
    return out


def rotate_about_center(img: Image.Image, degrees: float, translate=(0, 0), center=(384, 430)) -> Image.Image:
    return img.rotate(
        degrees,
        resample=Image.Resampling.BICUBIC,
        center=center,
        translate=translate,
        fillcolor=(0, 0, 0, 0),
    )


def normalize_anchor(img: Image.Image) -> Image.Image:
    bbox = alpha_bbox(img)
    if not bbox:
        return img
    dx = ANCHOR[0] - ((bbox[0] + bbox[2]) // 2)
    dy = ANCHOR[1] - bbox[3]
    # Keep horizontal movement readable but protect the requested foot anchor.
    dx = int(dx * 0.35)
    shifted = Image.new("RGBA", SIZE, (0, 0, 0, 0))
    shifted.alpha_composite(img, (dx, dy))
    return shifted


def make_frame(base: Image.Image, action: str, index: int) -> Image.Image:
    img = base.copy()
    if action == "idle":
        settings = [
            (1.000, 1.000, 0, 0, 0),
            (1.006, 0.995, -2, 1, -2),
            (0.996, 1.006, 2, -1, 2),
            (1.002, 1.000, 0, 0, 0),
        ][index]
        sx, sy, dx, dy, l = settings
        img = scale_about_anchor(img, sx, sy, dx, dy)
        img = lean(img, l)
    elif action == "walk":
        settings = [
            (0.998, 1.000, -18, 2, -14, 10),
            (1.003, 0.997, -5, 0, -6, -4),
            (0.998, 1.000, 16, 2, 14, -10),
            (1.002, 1.000, 5, 0, 7, 5),
        ][index]
        sx, sy, dx, dy, l, upper_dx = settings
        img = scale_about_anchor(img, sx, sy, dx, dy)
        img = lean(img, l)
        img = upper_shift(img, upper_dx, 0, cutoff=500, feather=120)
    elif action == "attack":
        settings = [
            (-16, -2, -16, 0, 0),
            (-42, -8, -42, 5, -4),
            (-70, -16, -70, 9, -7),
            (-30, -5, -28, 3, -2),
        ][index]
        l, dx, upper_dx, upper_dy, rot = settings
        img = lean(img, l)
        img = upper_shift(img, upper_dx, upper_dy, cutoff=470, feather=120)
        if rot:
            img = rotate_about_center(img, rot, translate=(dx, 0), center=(384, 450))
        else:
            img = scale_about_anchor(img, 1.0, 1.0, dx, 0)
    elif action == "hit":
        settings = [
            (24, 18, 24, -5, 7),
            (40, 30, 36, -8, 9),
            (14, 10, 10, -2, 4),
        ][index]
        l, dx, upper_dx, upper_dy, rot = settings
        img = lean(img, l)
        img = upper_shift(img, upper_dx, upper_dy, cutoff=430, feather=130)
        img = rotate_about_center(img, rot, translate=(dx, 0), center=(384, 470))
    return normalize_anchor(img)


def make_contact_sheet(files: list[Path], out_path: Path):
    cols = 5
    thumb = 150
    label_h = 34
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
        draw.text(((i % cols) * thumb + 4, (i // cols) * (thumb + label_h) + thumb + 4), path.stem, fill=(230, 225, 210, 255), font=font)
    sheet.convert("RGB").save(out_path)


def main():
    base = place_on_canvas(Image.open(SOURCE).convert("RGBA"))
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    outputs: list[Path] = []
    for action, count in [("idle", 4), ("walk", 4), ("attack", 4), ("hit", 3)]:
        for index in range(count):
            frame = make_frame(base, action, index)
            path = OUT_DIR / f"enemy_empty_{action}_{index}.png"
            frame.save(path)
            outputs.append(path)
    # Keep the legacy single idle image aligned with the first runtime frame.
    (OUT_DIR / "enemy_empty_idle.png").write_bytes((OUT_DIR / "enemy_empty_idle_0.png").read_bytes())
    make_contact_sheet(outputs, DELIVERY / "preview_contact_sheet.png")
    print(f"generated {len(outputs)} enemy_empty frames")


if __name__ == "__main__":
    main()
