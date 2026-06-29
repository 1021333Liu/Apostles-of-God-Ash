# Five Character Frame Sequence Delivery - 2026-06-29

Source request read from `origin/handoff/to-jin-rongjun@ed8eec0`.

This delivery builds first-pass runtime frame sequences from the five approved 768x768 RGBA mother images in:

```text
assets/concepts/artist_thread_image2_scene_round_20260620/character_frame_sequence_brief_20260629/
```

2026-06-29 v3 update: regenerated the similar-looking frames with stronger pose separation. Walk, attack, heavy attack, hit, advance, and ultimate cast now use larger upper-body pressure, recovery poses, and recoil while still preserving the approved mother images, transparent canvas, and foot anchor.

The five source images copied into `source/` are:

```text
player_echo_fullbody_20260610_alpha.png
enemy_empty_fullbody_clean.png
enemy_farmer_fullbody_clean.png
enemy_scarecrow_fullbody_clean.png
boss_barn_king_fullbody_clean.png
```

## Runtime Output

Generated `124` runtime frames:

```text
enemy_empty:      idle 4, walk 6, attack 6, hit 4
enemy_farmer:     idle 4, walk 6, attack 6, hit 4
enemy_scarecrow:  idle 4, walk 6, attack 6, hit 4
player_echo:      idle 4, walk 6, attack 6, heavy_attack 8, defend 4, hit 4, ultimate_cast 8
boss_barn_king:   idle 6, advance 6, attack 8, hit 4
```

Runtime folders:

```text
assets/sprites/characters/enemies/
assets/sprites/characters/player/
assets/sprites/characters/bosses/
```

Idle aliases were refreshed where applicable:

```text
enemy_empty_idle.png
enemy_farmer_idle.png
enemy_scarecrow_idle.png
player_echo_idle.png
boss_barn_king_idle.png
```

## Method

`generate_five_character_sequences.py` uses only the approved source image for each character. It does not use old proxy bodies, old farmer frames, old scarecrow frames, old boss phase frames, or generated mixed-character sheets.

The script applies controlled 2D pose changes:

- subtle breathing for idle
- weak dragging / advance motion for walk and advance
- forward body pressure for attack
- restrained recoil for hit
- player-specific heavy attack, defend, and ultimate cast poses

No attack FX, dust, dice, card UI, text, logo, or background is baked into the frames.

## Validation

All generated runtime frames were checked for:

- `768x768`
- `RGBA`
- transparent corners
- non-empty alpha
- bottom alpha bound at `y=720`

Preview sheets:

```text
preview_enemy_empty_contact_sheet.png
preview_enemy_farmer_contact_sheet.png
preview_enemy_scarecrow_contact_sheet.png
preview_player_echo_contact_sheet.png
preview_boss_barn_king_contact_sheet.png
```

## Known Limits

This is a stable first-pass frame delivery from single mother images. It prioritizes identity, anchor stability, and Godot-ready file structure. Human paintover can later improve limb-specific deformation, cloth overlap, and stronger attack readability without changing the runtime paths.
