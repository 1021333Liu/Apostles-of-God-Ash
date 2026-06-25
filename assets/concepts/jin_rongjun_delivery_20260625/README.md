# Jin Rongjun Delivery 2026-06-25

Branch read for requirements: `handoff/to-jin-rongjun`

Delivery branch: `handoff/from-jin-rongjun`

This delivery follows `assets/concepts/artist_thread_image2_scene_round_20260620/HUMAN_ARTIST_SCENE_BRIEF.md`.

## Delivered Godot-Ready PNGs

### Scene Backgrounds

All six scene backgrounds are PNG, 16:9, `1672x941`. They were generated with the built-in ChatGPT image workflow and copied into the runtime-facing background directory.

| File | Size | Assessment |
| --- | --- | --- |
| `assets/card_demo/backgrounds/bg_silent_casket_collector_intro.png` | 1672x941 | Usable opening non-combat room. Collector is present in the Silent Casket room; bottom area is quiet enough for dialogue UI. |
| `assets/card_demo/backgrounds/bg_empty_stomach_queue.png` | 1672x941 | Usable first chapter queue ruin. Empty road and field boundaries leave clear character space. |
| `assets/card_demo/backgrounds/bg_farmer_field_register.png` | 1672x941 | Usable farmer register field. Registry board and field corridor are readable without blocking the center. |
| `assets/card_demo/backgrounds/bg_scarecrow_blood_wheat.png` | 1672x941 | Usable scarecrow / blood-wheat guard zone. It avoids a giant scarecrow character and leaves a central staging area. |
| `assets/card_demo/backgrounds/bg_hungry_barn_exterior.png` | 1672x941 | Usable pre-boss barn entrance. Barn pressure reads without becoming a monster-mouth poster. |
| `assets/card_demo/backgrounds/bg_barn_king_chamber.png` | 1672x941 | Usable boss chamber. Open center, key hook, wooden beam skeleton, and dim stomach-sac hints are present. |

### Character Source PNGs

| File | Size | Transparency | Assessment |
| --- | --- | --- | --- |
| `assets/card_demo/actors/collector/source/collector_fullbody_front_20260625_alpha.png` | 1024x1536 | Alpha PNG | Usable alternate full-body source. Has paper/clip recording tools and complete feet. Style still leans hooded archivist; needs later idle/speak frames and possible face/costume pass. The existing `collector_fullbody_front.png` on this branch was preserved and not overwritten. |
| `assets/card_demo/actors/player_echo/source/player_echo_fullbody_20260610_alpha.png` | 1024x1536 | Alpha PNG | Usable cleaned source aligned to the 2026-06-10 benchmark: white hair, white/dirty-silver body, dark blue cloak panels, gold trim, dark red chest mark. Left blade edge is close to canvas edge; add padding before frame splitting. |

The original chroma-key sources are kept beside the alpha files:

- `assets/card_demo/actors/collector/source/collector_fullbody_front_20260625_chroma.png`
- `assets/card_demo/actors/player_echo/source/player_echo_fullbody_20260610_chroma.png`

## Preview

`assets/concepts/jin_rongjun_delivery_20260625/preview_contact_sheet.png`

The contact sheet contains all six backgrounds plus the two alpha character sources on a checkerboard preview.

## Known Gaps

- Collector animation frames are not yet delivered. Next pass should create `idle` 4 frames and `speak` 6 frames from the source.
- Player Echo action frames are not yet delivered. Next pass should split or repaint `field_idle`, `field_walk`, `card_attack`, `card_defend`, `card_hurt`, and `card_win`.
- Scene dimensions are 16:9 but not exactly `2048x1152` or `1920x1080`; scale or regenerate if exact production resolution becomes mandatory.
- These files have not been wired into Godot scenes yet. This branch only delivers image assets and review documentation.

## Verification

- Confirmed all six backgrounds are PNG and 16:9.
- Confirmed both character source outputs have alpha channels.
- Visually reviewed `preview_contact_sheet.png` for staging space, bottom UI quiet area, and obvious green-edge problems.
