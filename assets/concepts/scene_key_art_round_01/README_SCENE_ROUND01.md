# Scene Key Art Round 01

This folder contains the first 10-scene key-art pass for the Low Whispering Field vertical slice.

The images are practical 1920x1080 PNG concept/blockout assets. They prioritize Godot room readability, 3/4 top-down composition, walkable center space, boundary clarity, and hazard-color separation. They are not final polished illustration layers.

## Concept Images

| File | Scene | Usage | Notes |
| --- | --- | --- | --- |
| `concept_png/scene_01_silent_casket_safe_room.png` | Silent Sacred Casket safe room | start, death recovery, archive background | casket and archive props are central; text should be rendered by Godot |
| `concept_png/scene_02_field_entrance.png` | Low Whispering Field entrance | first combat room | central dirt route is walkable; wheat and fences are boundaries |
| `concept_png/scene_03_empty_bowl_queue.png` | Empty bowl queue road | log/story illustration | narrative image; not intended as combat background |
| `concept_png/scene_04_blood_wheat_field.png` | Blood wheat field | second combat room | red oval marks are hazard reservations; red roots are decoration |
| `concept_png/scene_05_gut_irrigation_canal.png` | Intestinal irrigation canal | third combat room | three red-brown canals are hazard/slow zones; gaps are walkable lanes |
| `concept_png/scene_06_hungry_barn_exterior.png` | Hungry barn exterior | elite-room entrance | barn and wheat are far boundary; center is combat space |
| `concept_png/scene_07_scarecrow_ritual_yard.png` | Scarecrow ritual yard | elite combat room | faint wheat-wave lanes are spell-direction references, not constant hazards |
| `concept_png/scene_08_barn_king_stomach_chamber.png` | Barn King stomach chamber | boss room | circular red marks are low-brightness ritual marks, not the boss weak point |
| `concept_png/scene_09_barn_king_open_granary_memory.png` | Barn King opening the granary | post-boss story illustration | narrative image; empty bowls and few sacks carry the story |
| `concept_png/scene_10_casket_truth_archive.png` | Return-to-casket truth archive | result/archive UI background | center paper is intentionally blank for Godot-rendered text |

## Godot Background Copies

Five P0 combat scenes were also copied into the paths currently auto-loaded by `scripts/systems/art_asset_registry.gd`:

| Runtime file | Source concept |
| --- | --- |
| `assets/backgrounds/rooms/bg_field_gate_base.png` | `scene_02_field_entrance.png` |
| `assets/backgrounds/rooms/bg_blood_wheat_base.png` | `scene_04_blood_wheat_field.png` |
| `assets/backgrounds/rooms/bg_gut_canal_base.png` | `scene_05_gut_irrigation_canal.png` |
| `assets/backgrounds/rooms/bg_hungry_barn_base.png` | `scene_06_hungry_barn_exterior.png` |
| `assets/backgrounds/rooms/bg_barn_king_base.png` | `scene_08_barn_king_stomach_chamber.png` |

## Readability Rules

- Walkable ground is the muted gray-brown center or lane space.
- Blocking boundaries are wheat borders, barn walls, fences, large props, and edge structures.
- Red-brown canal water is a hazard or slow-zone reference.
- Clear red ovals in the blood wheat room are reserved biting-wheat hazard zones.
- Small dark red roots, wax seals, stamps, and ritual scratches are decorative or worldbuilding accents.
- Story text, sample lists, stomach records, progress bars, and body copy must be rendered by Godot, not baked into the images.

## Next Art Pass

The next pass should paint over these files rather than changing the gameplay layout:

1. Keep the 16:9 frame and 3/4 top-down floor plane.
2. Preserve combat-center emptiness for rooms 02, 04, 05, 06, and 08.
3. Keep hazard red visually distinct from decorative red.
4. Split P0 rooms into `floor`, `boundary`, `props_mid`, `foreground`, and `collision_paintover` layers.
5. Avoid side-view platformer staging, pure top-down maps, poster close-ups, gore, cyber UI, and baked body text.
