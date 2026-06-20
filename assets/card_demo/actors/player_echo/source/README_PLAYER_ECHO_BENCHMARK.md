# Player Echo Visual Benchmark

`player_echo_visual_benchmark_20260610.png` is now the approved visual benchmark for the playable character.

It was copied from:

`assets/concepts/art_clean_color_round_20260610/art_clean_color_player_echo_20260610.png`

## Role

- Use this image as the identity, silhouette, palette, material, and costume reference for all future `player_echo` runtime frames.
- The current files under `assets/card_demo/actors/player_echo/` are still P0 proxy frames. They make the demo playable, but they are not the final character look.
- Do not continue expanding the older low-resolution placeholder sprite as the main character standard.

## Cleanup Requirement

Before producing final runtime frames, run the source through an image cleanup pass:

- reduce high-frequency speckle, compression noise, and dirty background contamination;
- preserve controlled painterly brush texture and dry rural material feel;
- keep the character readable at game scale;
- output transparent PNG frames at `768x768`;
- keep feet anchor near `x=384, y=720`.

## Required Runtime Actions

Generate separate action groups instead of one mixed atlas:

- `field_idle_0..5.png`
- `field_walk_0..7.png`
- `card_attack_0..7.png`
- `card_defend_0..7.png`
- `card_hurt_0..5.png`
- `card_win_0..7.png`

Attack body frames should stay body-only. Wide slash arcs, dust, dice effects, and hit sparks should be separate FX sheets.
