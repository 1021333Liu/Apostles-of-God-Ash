# Jin Rongjun Enemy Empty Frame Delivery - 2026-06-29

Source request read from `origin/handoff/to-jin-rongjun@8389c29`.

This pass implements the requested first runtime frame set for `enemy_empty`, based only on the provided clean reference.

2026-06-29 v2 note: the frame generation was rebuilt conservatively after review feedback. No old enemy, farmer, scarecrow, boss, or previous proxy body image is used for these frames.

```text
assets/concepts/jin_rongjun_delivery_20260629_enemy_empty_frames/source/enemy_empty_fullbody_clean_reference.png
```

The reference was copied from the request file:

```text
assets/concepts/artist_thread_image2_scene_round_20260620/enemy_empty_frame_request_20260629/enemy_empty_fullbody_clean_reference.png
```

## Delivered Runtime Frames

```text
assets/sprites/characters/enemies/enemy_empty_idle_0.png
assets/sprites/characters/enemies/enemy_empty_idle_1.png
assets/sprites/characters/enemies/enemy_empty_idle_2.png
assets/sprites/characters/enemies/enemy_empty_idle_3.png

assets/sprites/characters/enemies/enemy_empty_walk_0.png
assets/sprites/characters/enemies/enemy_empty_walk_1.png
assets/sprites/characters/enemies/enemy_empty_walk_2.png
assets/sprites/characters/enemies/enemy_empty_walk_3.png

assets/sprites/characters/enemies/enemy_empty_attack_0.png
assets/sprites/characters/enemies/enemy_empty_attack_1.png
assets/sprites/characters/enemies/enemy_empty_attack_2.png
assets/sprites/characters/enemies/enemy_empty_attack_3.png

assets/sprites/characters/enemies/enemy_empty_hit_0.png
assets/sprites/characters/enemies/enemy_empty_hit_1.png
assets/sprites/characters/enemies/enemy_empty_hit_2.png
```

The legacy single-frame alias was also refreshed from `enemy_empty_idle_0.png`:

```text
assets/sprites/characters/enemies/enemy_empty_idle.png
```

## Method

`generate_enemy_empty_frames.py` creates light runtime animation variants from the clean source:

- `idle`: subtle breathing and shoulder sink.
- `walk`: weak dragging step, no run cycle.
- `attack`: forward bowl reach / grasping posture.
- `hit`: upper body recoils, bowl stays with the character.

The v2 process is intentionally conservative to preserve:

- face
- hair
- body type
- ragged clothing
- empty bowl
- old paper tags
- transparent background

## Validation

- All runtime frames are `768x768 RGBA PNG`.
- Transparent channel is present.
- Feet / bottom alpha stay near `y=720`.
- No background, floor shadow, text, UI, dice, card, blood, or FX is baked into the frames.
- `preview_contact_sheet.png` provides the quick visual review sheet.

## Known Limits

These are first-pass production frames made by controlled 2D transforms from one source image. They keep identity and anchor stability. The action poses are deliberately restrained so the frames do not drift away from the approved `enemy_empty` reference; a later human polish pass can improve limb-specific deformation and robe overlap.
