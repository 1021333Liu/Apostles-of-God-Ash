# Artist Thread Image2 Scene Delivery: Blocked

Date: 2026-06-20
Role: painter / image2 scene thread
Scope requested: generate 5 clean 16:9 Godot scene backgrounds with `gpt-image-2`.

## Status

Blocked by API authentication.

I prepared the image2 batch prompt and attempted to call `gpt-image-2`, but the OpenAI Images API returned `401 invalid_api_key` for the current `OPENAI_API_KEY`.

No scene PNGs were generated. I did not fake placeholders or reuse old concept art as if it were new image2 output.

## Retry Attempt: 2026-06-21

The delivery was retried from the active `handoff/to-jin-rongjun` branch with both available generation routes:

- Built-in image generation: the first scene request failed with a network error while calling the ChatGPT image-generation endpoint.
- User-authorized Chrome Image2 session: Chrome could enumerate the open ChatGPT tab, but taking control of that tab repeatedly timed out before any prompt could be submitted or an image could be downloaded.

Result: all five target PNGs remain absent. This file remains a blocker record, not an art delivery. Do not mark any of the five scenes as complete until the final PNG and contact sheet are committed.

## Verified Existing Work

- The five prompts in `tmp/imagegen/artist_thread_scene_round_20260620.jsonl` are present and match the human artist brief.
- `HUMAN_ARTIST_SCENE_BRIEF.md` remains the authoritative filename, composition, and quality specification.
- No existing concept art was substituted into this folder.

## Output Directory

`assets/concepts/artist_thread_image2_scene_round_20260620/`

Expected image filenames after a successful rerun:

- `bg_silent_casket_intro.png`
- `bg_empty_stomach_queue.png`
- `bg_farmer_field_register.png`
- `bg_scarecrow_blood_wheat.png`
- `bg_barn_king_chamber.png`
- `preview_contact_sheet.png`

## Prepared Prompt Batch

`tmp/imagegen/artist_thread_scene_round_20260620.jsonl`

The batch contains 5 independent `gpt-image-2` jobs, each set to:

- `size`: `2048x1152`
- `quality`: `high`
- `model`: `gpt-image-2`
- output format: PNG via the imagegen CLI

## Command That Should Work With A Valid Key

```powershell
python C:\Users\94426\.codex\skills\.system\imagegen\scripts\image_gen.py generate-batch `
  --input tmp\imagegen\artist_thread_scene_round_20260620.jsonl `
  --out-dir assets\concepts\artist_thread_image2_scene_round_20260620 `
  --concurrency 2
```

## Failure Evidence

The imagegen CLI reached the API, but each job failed with:

```text
Error code: 401 - invalid_api_key
```

Before that, the local OpenAI Python SDK was upgraded from `1.65.5` to `2.43.0` because the older SDK rejected current `gpt-image-2` image parameters.

## Constraints Preserved In Prompts

- Horizontal 16:9 Godot scene backgrounds only.
- No character sheet, no character poster, no UI, no card frame.
- Bottom 25 percent kept quiet for dialogue / battle UI.
- Left / right / center standing spaces left clear for later overlaid sprites.
- Low saturation, rural, dry, cold, old paper, dirt, dirty silver, controlled dark red flesh-wheat / stomach-sac accents.
- No readable large text.
- No cyberpunk, anime, high-saturation magic, full-screen red-black monster texture, or gore spectacle.
- Andrew Wyeth handled only as rural loneliness / dry material guidance, without imitation of any specific artwork.

## Required Post-Generation Steps

After rerunning successfully with a valid key:

1. Verify every PNG is `2048x1152` or at least 16:9.
2. Reject any image that contains large readable text, UI, card frames, full-frame character art, or bottom-heavy key details.
3. Create `preview_contact_sheet.png` from the 5 scene PNGs.
4. Update this file with per-image assessment: direct Godot use vs cleanup required.
5. Return the final file path list to the main thread.
