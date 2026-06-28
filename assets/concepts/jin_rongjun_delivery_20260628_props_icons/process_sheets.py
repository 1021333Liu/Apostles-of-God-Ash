from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[3]
DELIVERY = ROOT / "assets" / "concepts" / "jin_rongjun_delivery_20260628_props_icons"
SOURCE = DELIVERY / "source"


def remove_green(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    px = rgba.load()
    w, h = rgba.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            green_score = g - max(r, b)
            if g > 105 and green_score > 28:
                if green_score > 85 and g > 145:
                    px[x, y] = (r, g, b, 0)
                else:
                    alpha = max(0, min(255, int((85 - green_score) * 4.5)))
                    px[x, y] = (r, g, b, min(a, alpha))
    return rgba


def alpha_bbox(img: Image.Image):
    alpha = img.getchannel("A")
    return alpha.getbbox()


def trim_and_fit(img: Image.Image, size: tuple[int, int], pad: int = 18) -> Image.Image:
    bbox = alpha_bbox(img)
    if bbox:
        img = img.crop(bbox)
    target_w, target_h = size
    max_w = max(1, target_w - pad * 2)
    max_h = max(1, target_h - pad * 2)
    scale = min(max_w / img.width, max_h / img.height, 1.0)
    new_size = (max(1, int(img.width * scale)), max(1, int(img.height * scale)))
    img = img.resize(new_size, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    canvas.alpha_composite(img, ((target_w - new_size[0]) // 2, (target_h - new_size[1]) // 2))
    return canvas


def crop_grid(sheet_path: Path, cols: int, rows: int, names: list[str], out_dir: Path, target_sizes: dict[str, tuple[int, int]], top_rows: int | None = None):
    sheet = Image.open(sheet_path).convert("RGB")
    out_dir.mkdir(parents=True, exist_ok=True)
    for index, name in enumerate(names):
        if top_rows is None:
            col = index % cols
            row = index // cols
            x0 = round(sheet.width * col / cols)
            x1 = round(sheet.width * (col + 1) / cols)
            y0 = round(sheet.height * row / rows)
            y1 = round(sheet.height * (row + 1) / rows)
        else:
            if index < top_rows:
                col = index
                x0 = round(sheet.width * col / top_rows)
                x1 = round(sheet.width * (col + 1) / top_rows)
                y0 = 0
                y1 = round(sheet.height / 2)
            else:
                bottom_cols = len(names) - top_rows
                col = index - top_rows
                x0 = round(sheet.width * col / bottom_cols)
                x1 = round(sheet.width * (col + 1) / bottom_cols)
                y0 = round(sheet.height / 2)
                y1 = sheet.height
        cell = sheet.crop((x0, y0, x1, y1))
        transparent = remove_green(cell)
        out = trim_and_fit(transparent, target_sizes.get(name, (512, 512)))
        out.save(out_dir / f"{name}.png")


def make_contact_sheet(files: list[Path], out_path: Path, thumb_size=(160, 160), cols=5):
    rows = (len(files) + cols - 1) // cols
    label_h = 34
    sheet = Image.new("RGBA", (cols * thumb_size[0], rows * (thumb_size[1] + label_h)), (38, 38, 34, 255))
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for i, path in enumerate(files):
        img = Image.open(path).convert("RGBA")
        bg = Image.new("RGBA", img.size, (52, 58, 48, 255))
        bg.alpha_composite(img)
        bg.thumbnail(thumb_size, Image.Resampling.LANCZOS)
        x = (i % cols) * thumb_size[0] + (thumb_size[0] - bg.width) // 2
        y = (i // cols) * (thumb_size[1] + label_h) + (thumb_size[1] - bg.height) // 2
        sheet.alpha_composite(bg, (x, y))
        draw.text(((i % cols) * thumb_size[0] + 4, (i // cols) * (thumb_size[1] + label_h) + thumb_size[1] + 4), path.stem[:22], fill=(230, 225, 210, 255), font=font)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.convert("RGB").save(out_path)


props = [
    "dead_tree_01",
    "dead_tree_02",
    "dry_bush_01",
    "dry_bush_02",
    "broken_fence_01",
    "broken_fence_02",
    "field_ridge_01",
    "empty_bowl_pile_01",
    "register_sign_01",
    "blood_wheat_clump_01",
    "blood_wheat_clump_02",
    "barn_post_01",
    "hanging_cloth_01",
    "grain_sack_rotten_01",
    "wooden_stake_01",
]

foreground = [
    "fg_wheat_blades_01",
    "fg_dead_branch_01",
    "fg_barn_door_frame_01",
    "fg_hanging_cloth_strip_01",
    "fg_blood_wheat_edge_01",
]

skills = [
    "skill_attack",
    "skill_heavy_attack",
    "skill_guard_charge",
    "skill_ultimate",
    "skill_locked_overlay",
    "skill_selected_frame",
    "skill_cooldown_overlay",
]

items = [
    "item_empty_bowl_cracked",
    "item_farmer_sickle",
    "item_farmer_hat",
    "item_blood_wheat_seed",
    "item_register_tag",
    "item_scarecrow_straw_bundle",
    "item_barn_key_rusty",
    "item_god_ash_fragment",
    "item_stomach_seal_wax",
    "item_old_cloth_strip",
]

prop_sizes = {name: (512, 512) for name in props}
prop_sizes.update({
    "broken_fence_01": (768, 384),
    "broken_fence_02": (768, 384),
    "field_ridge_01": (768, 384),
})
fg_sizes = {name: (1024, 512) for name in foreground}
skill_sizes = {name: (256, 256) for name in skills}
item_sizes = {name: (256, 256) for name in items}

crop_grid(SOURCE / "props_sheet.png", 5, 3, props, ROOT / "assets" / "card_demo" / "props", prop_sizes)
crop_grid(SOURCE / "foreground_sheet.png", 5, 1, foreground, ROOT / "assets" / "card_demo" / "props", fg_sizes)
crop_grid(SOURCE / "skills_sheet.png", 4, 2, skills, ROOT / "assets" / "card_demo" / "ui" / "skills", skill_sizes, top_rows=4)
crop_grid(SOURCE / "items_sheet.png", 5, 2, items, ROOT / "assets" / "card_demo" / "ui" / "items", item_sizes)

all_outputs = (
    [ROOT / "assets" / "card_demo" / "props" / f"{name}.png" for name in props]
    + [ROOT / "assets" / "card_demo" / "props" / f"{name}.png" for name in foreground]
    + [ROOT / "assets" / "card_demo" / "ui" / "skills" / f"{name}.png" for name in skills]
    + [ROOT / "assets" / "card_demo" / "ui" / "items" / f"{name}.png" for name in items]
)
make_contact_sheet(all_outputs, DELIVERY / "preview_contact_sheet.png")

print(f"generated {len(all_outputs)} png assets")
