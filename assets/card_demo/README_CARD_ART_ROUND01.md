# Card Demo Art Round 01

This package is the P0 runtime art set for the first card-and-dice duel against the Famine Farmer.

## Runtime-ready files

All PNG files below are intended for the Godot demo and are stored at the stable paths requested in `docs/planning/29_CARD_DEMO_ART_BRIEF.md`.

| Area | Files | Notes |
| --- | --- | --- |
| Background | `backgrounds/bg_card_field_entrance.png` | 1920x1080 Image2-generated field entrance. The central road is intentionally quiet for the two actors; the lower band is darker for cards. The untouched 1672x941 source is retained at `source/bg_card_field_entrance_image2_source.png`. |
| Player actor | `actors/player_echo/actor_player_echo_<action>_<frame>.png` | 768x768 transparent PNGs. Actions: idle (6), attack (8), defend (6), hit (4), victory (6). Faces right. |
| Farmer actor | `actors/enemy_farmer/actor_enemy_farmer_<action>_<frame>.png` | 768x768 transparent PNGs. Actions: idle (6), mutter (6), attack (8), defend (6), hit (4), confess (8). Faces left. |
| Basic cards | `cards/card_basic_attack_art.png`, `cards/card_basic_defense_art.png` | 512x768. Top, lower, and action-seal zones have no baked text. |
| Dice and intent | `ui/dice/`, `ui/intent/` | Dice faces and roll markers intentionally contain no result numerals or status text. |
| Log and archive | `ui/log/` | The archive banner and story page reserve their central parchment regions for program-rendered text. |
| Rewards | `ui/rewards/` | 256x256 sickle, hat, wheat icons plus a 420x560 blank reward frame. |
| Previews | `preview/combat_screen_mockup_1920x1080.png`, `preview/reward_screen_mockup_1920x1080.png` | Visual integration references, not runtime UI layouts. |

## Animation hookup

Use the bottom center of each 768x768 actor frame as the sprite anchor. The actual feet remain close to y=720 across every action frame. Suggested FPS: idle and mutter 6; attack 12; defend 9; hit 12; victory and confess 7.

## Transparency and text reservations

- Actor PNGs are RGBA with transparent corners and transparent backgrounds.
- Cards retain a blank header, main art area, lower effect area, and top-left action-seal area for program UI.
- `ui_victory_story_page.png` has an unmarked center body for the story text.
- The roll-state markers are symbolic only, so localized labels can be rendered by Godot.

## Source and scope

No large editable source files are included. The actor silhouettes were rebuilt from the repository's existing approved concept sheets to keep the demo visually continuous with the old action prototype. The battle background was generated through the user's authenticated ChatGPT Image2 session and its original export is retained in `source/`.

The included previews are a readability pass for this art package. The next iteration should replace the concept-derived actor silhouettes with final hand-painted action poses once the combat scene and exact sprite placement are locked.
