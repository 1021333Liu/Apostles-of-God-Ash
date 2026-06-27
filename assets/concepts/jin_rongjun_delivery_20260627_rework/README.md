# Jin Rongjun Rework Delivery 2026-06-27

Requirement branch read: `handoff/to-jin-rongjun` at `bceb9fa`.

Delivery branch: `handoff/from-jin-rongjun`.

This pass follows:

- `assets/concepts/artist_thread_image2_scene_round_20260620/ART_REWORK_REQUIRED_20260625.md`
- `assets/concepts/artist_thread_image2_scene_round_20260620/ART_REQUEST_20260625_CHARACTER_DICE_CARD_UI.md`

The images were generated through the opened ChatGPT / Image2 web workflow, then downloaded, reviewed, chroma-keyed locally, and organized for Godot use.

## Delivered Runtime PNGs

### Enemy Fullbody Sources

All source files are alpha PNGs. Chroma-key originals are kept beside them as `fullbody_clean_chroma.png`.

| Actor | Source | Size | Assessment |
| --- | --- | --- | --- |
| Empty Stomach | `assets/card_demo/actors/enemy_empty/source/fullbody_clean.png` | 1086x1448 | Usable. Reads as a hollow queue survivor with empty bowl, not a zombie. |
| Famine Farmer | `assets/card_demo/actors/enemy_farmer/source/fullbody_clean.png` | 941x1672 | Usable. Hat, sickle, seed bag, and registry tags are clear. |
| Hungry Scarecrow | `assets/card_demo/actors/enemy_scarecrow/source/fullbody_clean.png` | 1086x1448 | Usable. Clearly reads as wood / straw structure, not a torn-clothes human. |
| Barn King | `assets/card_demo/actors/boss_barn_king/source/fullbody_clean.png` | 1024x1536 | Usable. Preserves king, key, barn wood, grain sack, and weak-point traces without becoming a pure monster. |

### Idle Frames

Each actor has 4 transparent placeholder idle frames derived from the clean source.

```text
assets/card_demo/actors/enemy_empty/idle/idle_0.png ... idle_3.png
assets/card_demo/actors/enemy_farmer/idle/idle_0.png ... idle_3.png
assets/card_demo/actors/enemy_scarecrow/idle/idle_0.png ... idle_3.png
assets/card_demo/actors/boss_barn_king/idle/idle_0.png ... idle_3.png
```

These are light breathing / sway frames for immediate Godot testing. They are not final attack / hurt / talk animation sets.

### Dice UI

| File | Size | Transparency | Assessment |
| --- | --- | --- | --- |
| `assets/card_demo/ui/dice/d20_attack_die.png` | 512x512 | Alpha PNG | Usable attack D20. Bone / dirty silver / dark red cut marks. |
| `assets/card_demo/ui/dice/d20_defense_die.png` | 512x512 | Alpha PNG | Usable defense D20. Shield-like facets and wax accents distinguish it from attack. |
| `assets/card_demo/ui/dice/d3_effect_die.png` | 512x512 | Alpha PNG | Usable D3 effect die. Triangular bone / tooth profile reads differently from D20. |

The source green-screen versions are kept as `*_chroma.png`.

### Card UI

| File | Size | Transparency | Assessment |
| --- | --- | --- | --- |
| `assets/card_demo/ui/cards/card_attack_base.png` | 512x768 | Alpha PNG | Usable. Blank title and rules area; attack image uses blade / cut marks, no baked text. |
| `assets/card_demo/ui/cards/card_defend_base.png` | 512x768 | Alpha PNG | Usable. Blank title and rules area; bowl / guard motif, no blue magic shield. |
| `assets/card_demo/ui/cards/card_selected_frame.png` | 512x768 | Alpha PNG | Usable selected overlay frame. |
| `assets/card_demo/ui/cards/card_hover_frame.png` | 512x768 | Alpha PNG | Derived lower-intensity hover overlay from selected frame. |

The source green-screen versions are kept as `*_chroma.png` for the three Image2-generated card assets.

## Preview

`assets/concepts/jin_rongjun_delivery_20260627_rework/preview_contact_sheet.png`

## Known Gaps

- Attack, hurt, defend, and talk animation frames are not complete yet.
- The 4-frame idle sets are lightweight derived frames, not hand-painted animation.
- Dice roll animation frames are not delivered in this pass.
- `dice_roll_stage.png` and `dice_result_panel.png` were not regenerated because the shortest acceptance list prioritizes the three dice and card assets.
- The generated green backgrounds had slight lighting variation; local chroma-key removal was validated visually, but a few fine straw / cloth edges may still need manual cleanup before final production.

## Verification

- Confirmed all delivered runtime PNGs have alpha.
- Confirmed four actor source images are full-body and not cropped.
- Confirmed 16 idle frames were created.
- Confirmed dice and card UI files use the requested runtime names and dimensions.
- Visually reviewed `preview_contact_sheet.png` for readability, style fit, and green-edge problems.
