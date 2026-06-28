# 2026-06-28 技能栏图标与掉落物道具图需求

给金荣俊 / 美术处理线程：

这是对上一份美术需求的修正。当前不一定要继续做复杂卡牌 UI。用户倾向把攻击、重击、技能做成底部技能栏图标，而不是大卡牌。请先按技能图标方案产出，卡牌大图可以暂缓。

## 本轮不做

明确不做：

- 不生产新的 `background` 场景图。
- 不继续主攻完整 16:9 大场景。
- 不做复杂大卡牌整牌面。
- 不做按钮式现代 UI。
- 不烘焙中文规则文本。

## 本轮要做

优先级：

1. `walkable_props`：可走场景里的树、篱笆、田埂、空碗、血麦等透明小物件。
2. `foreground_occluders`：前景麦穗、枯枝、门框、谷仓木梁等遮挡层。
3. `skill_icons`：攻击、重击、蓄防、大招等技能栏图标。
4. `loot_icons`：战斗掉落物 / 道具栏图标。

## 技能栏图标

建议路径：

```text
assets/card_demo/ui/skills/skill_attack.png
assets/card_demo/ui/skills/skill_heavy_attack.png
assets/card_demo/ui/skills/skill_guard_charge.png
assets/card_demo/ui/skills/skill_ultimate.png
assets/card_demo/ui/skills/skill_locked_overlay.png
assets/card_demo/ui/skills/skill_selected_frame.png
assets/card_demo/ui/skills/skill_cooldown_overlay.png
```

规格：

```text
256x256 RGBA PNG
transparent background
clean silhouette
no text
no big button frame baked in
readable at 64x64 and 96x96
```

表现方向：

- `skill_attack`：普通攻击，短刃、暗红切痕、旧银刃光，不要大魔法波。
- `skill_heavy_attack`：重击，压低的刃、裂开的旧纸 / 木纹、重量感。
- `skill_guard_charge`：蓄防，脏银护片、空碗护在胸口、旧布封缠，强调“下一次防御更稳”。
- `skill_ultimate`：大招占位，圣匣 / 胃囊 / 暗红封蜡 / 神烬纹路，强调无视防御的直伤。

统一 prompt：

```text
Create a transparent PNG skill icon for a 2D narrative card-dice RPG. Low-saturation rural famine horror, old paper, tarnished silver, dry mud, muted gray-brown palette, sparse dark red organic accents. The icon must be readable at small UI size, no text, no numbers, no cyberpunk, no anime, no glossy mobile button, no plastic look, no full card frame. Clean silhouette, centered object, transparent background.
```

单图补充：

```text
basic attack icon, short tarnished blade, dark red cut mark, restrained impact, old silver and dry paper texture
```

```text
heavy attack icon, heavy downward blade, cracked old wood and paper, stronger dark red slash, weight and risk
```

```text
guard charge icon, tarnished silver guard plate, cracked empty bowl symbol, tied gray cloth, defensive preparation
```

```text
ultimate skill icon, sacred casket symbol, stomach-like dark red seal, old wax, god-ash mark, direct damage ritual
```

## 掉落物 / 道具栏图标

这些图后续会放在道具栏、奖励选择、战斗后掉落提示里。请做透明 PNG 小图，不要大海报。

建议路径：

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

规格：

```text
256x256 RGBA PNG
transparent background
no text
single object or small object cluster
readable at 48x48 and 64x64
low saturation
clean alpha edge
```

道具方向：

- `item_empty_bowl_cracked`：裂开的空碗，空腹者 / 饥荒证据。
- `item_farmer_sickle`：旧镰刀，农夫掉落物，不要华丽武器。
- `item_farmer_hat`：破草帽 / 粗布帽，泥土和汗渍。
- `item_blood_wheat_seed`：血麦种子，干麦粒里带暗红肉质。
- `item_register_tag`：登记木牌 / 旧纸牌，不能有可读文字。
- `item_scarecrow_straw_bundle`：绑扎稻草，旧布条，稻草人掉落。
- `item_barn_key_rusty`：锈谷仓钥匙，谷仓王线索。
- `item_god_ash_fragment`：神烬碎片，暗淡、灰白、非宝石感。
- `item_stomach_seal_wax`：胃囊封蜡，暗红旧蜡印。
- `item_old_cloth_strip`：旧布条，灰白、风干、绑缚痕迹。

统一 prompt：

```text
Create a transparent PNG inventory item icon for a 2D narrative card-dice RPG. The item belongs to a bleak rural famine horror world: old paper, mud, tarnished metal, cracked ceramic, dry straw, muted gray-brown colors, sparse dark red organic accents. Single object, centered, clean alpha edge, readable at 48x48, no text, no character, no UI frame, no cyberpunk, no anime, no shiny loot glow, no plastic look.
```

## 技术接入预期

技术侧后续更可能做成：

```text
BottomSkillBar
  skill_attack
  skill_heavy_attack
  skill_guard_charge
  skill_ultimate

InventoryPanel
  item_empty_bowl_cracked
  item_farmer_sickle
  item_blood_wheat_seed
  item_barn_key_rusty
```

所以图标要像游戏 UI 资源，不要像整张卡牌。卡牌大图可以以后再考虑。

