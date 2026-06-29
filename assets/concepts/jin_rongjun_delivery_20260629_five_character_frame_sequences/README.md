# Five Character Frame Sequence Delivery - 2026-06-29

Source request read from `origin/handoff/to-jin-rongjun@ed8eec0`.

This delivery builds first-pass runtime frame sequences from the five approved 768x768 RGBA mother images in:

```text
assets/concepts/artist_thread_image2_scene_round_20260620/character_frame_sequence_brief_20260629/
```

2026-06-30 v4 update: replaced the script-warped lookalike frames with Image2 action sheets following the installed `generate2dsprite` workflow. Each of the five mother images now has separate generated action sheets for movement, attack, and hit/recovery, then deterministic chroma-key cleanup and frame extraction.

The five source images copied into `source/` are:

```text
player_echo_fullbody_20260610_alpha.png
enemy_empty_fullbody_clean.png
enemy_farmer_fullbody_clean.png
enemy_scarecrow_fullbody_clean.png
boss_barn_king_fullbody_clean.png
```

## Runtime Output

Generated runtime frames:

```text
player_echo:      idle 4, walk 6, attack 6, hit 4
enemy_empty:      idle 4, walk 6, attack 6, hit 4
enemy_farmer:     idle 4, walk 6, attack 6, hit 4
enemy_scarecrow:  idle 4, walk 6, attack 6, hit 4
boss_barn_king:   idle 4, advance 6, attack 6, hit 4
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

The v4 runtime frames were generated from Image2 raw action sheets, one action family at a time:

```text
image2_raw/<character>/<character>_<action>_sheet_image2.png
processed_image2/<character>/<action>/
```

The action sheet prompts used the approved mother images as visual references and preserved each character's silhouette, palette, costume markers, props, and material language. No mixed all-actions atlas was generated directly.

The local `generate2dsprite.py process` step was used only for deterministic cleanup:

- solid `#FF00FF` chroma-key removal
- per-action 2x3 or 2x2 frame extraction
- shared scale and feet/bottom alignment
- transparent PNG frame output
- GIF and `pipeline-meta.json` QA artifacts

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
preview_image2_action_contact_sheet.png
preview_enemy_empty_contact_sheet.png
preview_enemy_farmer_contact_sheet.png
preview_enemy_scarecrow_contact_sheet.png
preview_player_echo_contact_sheet.png
preview_boss_barn_king_contact_sheet.png
```

## Known Limits

The Image2 sheets now contain real pose changes instead of repeated mother-image warps. `enemy_empty` still has a restrained walk because its identity is a weak, bowl-holding figure, but its attack and hit frames have clear motion. Human paintover can later refine limb overlap and exact frame timing without changing the runtime paths.
