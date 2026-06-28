# Jin Rongjun Props And Icon Delivery - 2026-06-28

Source request read from `origin/handoff/to-jin-rongjun@2b6dd45`.

This pass follows the updated direction:

- No new `background` scene art.
- No complex full card faces.
- Focus on `walkable_props`, `foreground_occluders`, bottom skill bar icons, and loot / inventory icons.

## Method

Generated four GPT Image2 sheet images in the existing Chrome ChatGPT session, then split them locally with `process_sheets.py`.

The source sheets use a flat `#00ff00` chroma-key background. The script:

1. Crops each sheet by its grid.
2. Removes the green background into alpha.
3. Auto-trims each subject.
4. Fits the subject into the requested runtime canvas size.
5. Builds `preview_contact_sheet.png` for review.

## Delivered Files

Walkable props:

```text
assets/card_demo/props/dead_tree_01.png
assets/card_demo/props/dead_tree_02.png
assets/card_demo/props/dry_bush_01.png
assets/card_demo/props/dry_bush_02.png
assets/card_demo/props/broken_fence_01.png
assets/card_demo/props/broken_fence_02.png
assets/card_demo/props/field_ridge_01.png
assets/card_demo/props/empty_bowl_pile_01.png
assets/card_demo/props/register_sign_01.png
assets/card_demo/props/blood_wheat_clump_01.png
assets/card_demo/props/blood_wheat_clump_02.png
assets/card_demo/props/barn_post_01.png
assets/card_demo/props/hanging_cloth_01.png
assets/card_demo/props/grain_sack_rotten_01.png
assets/card_demo/props/wooden_stake_01.png
```

Foreground occluders:

```text
assets/card_demo/props/fg_wheat_blades_01.png
assets/card_demo/props/fg_dead_branch_01.png
assets/card_demo/props/fg_barn_door_frame_01.png
assets/card_demo/props/fg_hanging_cloth_strip_01.png
assets/card_demo/props/fg_blood_wheat_edge_01.png
```

Skill icons:

```text
assets/card_demo/ui/skills/skill_attack.png
assets/card_demo/ui/skills/skill_heavy_attack.png
assets/card_demo/ui/skills/skill_guard_charge.png
assets/card_demo/ui/skills/skill_ultimate.png
assets/card_demo/ui/skills/skill_locked_overlay.png
assets/card_demo/ui/skills/skill_selected_frame.png
assets/card_demo/ui/skills/skill_cooldown_overlay.png
```

Loot / inventory icons:

```text
assets/card_demo/ui/items/item_empty_bowl_cracked.png
assets/card_demo/ui/items/item_farmer_sickle.png
assets/card_demo/ui/items/item_farmer_hat.png
assets/card_demo/ui/items/item_blood_wheat_seed.png
assets/card_demo/ui/items/item_register_tag.png
assets/card_demo/ui/items/item_scarecrow_straw_bundle.png
assets/card_demo/ui/items/item_barn_key_rusty.png
assets/card_demo/ui/items/item_god_ash_fragment.png
assets/card_demo/ui/items/item_stomach_seal_wax.png
assets/card_demo/ui/items/item_old_cloth_strip.png
```

## Sizes

- Small props: `512x512 RGBA PNG`
- Fence / ridge props: `768x384 RGBA PNG`
- Foreground occluders: `1024x512 RGBA PNG`
- Skill and item icons: `256x256 RGBA PNG`

## Review Notes

- `preview_contact_sheet.png` is the fastest review artifact.
- Source Image2 sheets are kept under `source/` for traceability.
- These are first-pass runtime assets. A human artist can still polish edges, repaint minor semantic misses, or make alternate variants without changing the runtime paths.
