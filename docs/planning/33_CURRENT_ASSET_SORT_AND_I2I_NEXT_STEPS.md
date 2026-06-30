# Current Asset Sort and I2I Next Steps

本文件承接 `ART_CURRENT_ASSET_SORT_AND_NEXT_REQUEST_20260628.md` 与 `32_NANOBANANA_CARD_COMBAT_ART_PROMPTS.md`，用于下一轮本地改图、nanobanana / image-to-image 生成、清洁去噪和 Godot 接入准备。

本轮结论：不要继续主攻场景图。场景当前够用，下一批最影响试玩观感的是收藏家半身像清洁、主角和敌人动作补齐、四张行动牌、骰子、投掷舞台和核心 FX。

## 00 当前资产分级

### A 类：直接作为身份基准

这些资产定义角色或 UI 的正式方向。后续 i2i 必须保留身份，不可重设定。

| 资产 | 当前用途 | 处理建议 |
| --- | --- | --- |
| `assets/portraits/portrait_collector_halfbody.png` | 开场收藏家主视觉 | P0 清洁版，去噪、补边、检查 alpha；不要改成全身 |
| `assets/card_demo/actors/player_echo/source/player_echo_fullbody_20260610_alpha.png` | 主角动作身份基准 | 作为主角动作 i2i 参考，动作要 body-only |
| `assets/card_demo/actors/enemy_empty/source/fullbody_clean.png` | 空腹者身份基准 | 补齐动作，保留空碗/等粮/空腹状态 |
| `assets/card_demo/actors/enemy_farmer/source/fullbody_clean.png` | 农夫身份基准 | 补齐动作，强调制度执行者与受害者双重身份 |
| `assets/card_demo/actors/enemy_scarecrow/source/fullbody_clean.png` | 稻草人身份基准 | 补齐动作，必须是真稻草人结构 |
| `assets/card_demo/actors/boss_barn_king/source/fullbody_clean.png` | 谷仓王身份基准 | 补齐 Boss 动作，保留人类/制度残影 |

### B 类：当前可跑但仍是 P0 代理

这些资产可继续支撑 playable，但不应被当作最终标准。

| 资产组 | 当前问题 | 下一步 |
| --- | --- | --- |
| `player_echo/field_*`、`card_*` 旧动作 | 动作来源不统一，部分帧仍像代理 | 逐步迁移到 `idle/attack/heavy_attack/defend/hurt/talk/ultimate_cast` 新结构 |
| `enemy_farmer/card_*` | 能跑，但动作含义仍偏旧机制 | 重命名或重做为 attack/heavy/defend/hurt/talk |
| `enemy_empty/idle` | 只有 idle，不足以支撑战斗 | P0 先补 attack/heavy/defend/hurt/talk |
| `enemy_scarecrow/idle` | 只有 idle | P0.5 补齐全套动作 |
| `boss_barn_king/idle` | 只有 idle | P1 补 Boss 动作 |

### C 类：场景只轻修，不重画

这些背景目前够用，下一轮只做轻度去噪、统一色阶和 UI 留白检查。

```text
assets/card_demo/backgrounds/bg_silent_casket_collector_intro.png
assets/card_demo/backgrounds/bg_silent_casket_intro.png
assets/card_demo/backgrounds/bg_empty_stomach_queue.png
assets/card_demo/backgrounds/bg_farmer_field_register.png
assets/card_demo/backgrounds/bg_scarecrow_blood_wheat.png
assets/card_demo/backgrounds/bg_hungry_barn_exterior.png
assets/card_demo/backgrounds/bg_barn_king_chamber.png
assets/card_demo/backgrounds/bg_card_field_entrance.png
```

场景处理原则：

- 保留干燥油画/蛋彩/干刷质感。
- 压低满屏高频噪点、AI 碎色块、压缩颗粒。
- UI 区、角色站位区、骰子舞台出现区要更干净。
- 不要继续堆新场景数量。

## 01 收藏家半身像清洁任务

### 输入

```text
assets/portraits/portrait_collector_halfbody.png
```

### 输出

```text
assets/portraits/portrait_collector_halfbody_clean.png
```

### 中文 i2i prompt

```text
基于输入图清洁收藏家半身像，不改变人物设定、脸、手、衣领、旧纸和档案管理员气质。保留医生、研究者、档案管理员、圣物保管者的冷静感，保留银灰衣物、旧纸、脏银金属、封蜡和样本标签气质。降低高频噪点、AI 脏边、压缩颗粒和背景污染，轻微补齐边缘，让半身像适合 Godot 开场对话居中放大显示。透明背景或干净 alpha 边缘，不要重画成全身，不要改成人物设定，不要加文字。
```

### English i2i prompt

```text
Clean up the input Collector half-body portrait without changing the character design, face, hands, collar, old paper, or archivist identity. Preserve the calm doctor / researcher / archivist / reliquary caretaker feeling, silver-gray clothing, old paper, tarnished metal, sealing wax, and sample-tag mood. Reduce high-frequency noise, AI dirty edges, compression speckles, and background contamination. Slightly repair the portrait edges so it can be displayed large and centered in a Godot opening dialogue scene. Transparent background or clean alpha edge. Do not turn it into a full-body character, do not redesign the character, no text.
```

### Negative prompt

```text
全身版，重新设计角色，恶魔，巫师，商人，赛博科学家，现代实验室，霓虹，二次元脸，高饱和魔法光，恐怖血腥，塑料质感，大段文字，logo，水印，复杂背景。
```

### 验收标准

- 仍然一眼看出是第一版收藏家半身像。
- 边缘干净，头发、手、衣领不被过度磨平。
- 1920x1080 开场画面中可居中放大使用。
- 不使用后续全身版替代开场主视觉。

## 02 角色动作 i2i 生产规格

### 统一输出

- `768x768 RGBA PNG`
- 透明背景
- feet anchor：`x=384, y=720`
- 角色必须 body-only
- 不带场景、投影、文字、骰子、刀光、命中特效
- 每个动作单独生成或处理，不做混合大图

### 目录结构

```text
assets/card_demo/actors/{actor_key}/source/fullbody_clean.png
assets/card_demo/actors/{actor_key}/idle/idle_0.png ... idle_5.png
assets/card_demo/actors/{actor_key}/attack/attack_0.png ... attack_7.png
assets/card_demo/actors/{actor_key}/heavy_attack/heavy_attack_0.png ... heavy_attack_7.png
assets/card_demo/actors/{actor_key}/defend/defend_0.png ... defend_7.png
assets/card_demo/actors/{actor_key}/hurt/hurt_0.png ... hurt_5.png
assets/card_demo/actors/{actor_key}/talk/talk_0.png ... talk_5.png
```

主角额外：

```text
assets/card_demo/actors/player_echo/ultimate_cast/ultimate_cast_0.png ... ultimate_cast_7.png
```

### 角色通用中文 prompt

```text
使用输入 fullbody_clean 作为唯一身份参考，为 Godot 2D 卡牌骰子战斗生成全身透明动作帧。保持同一角色的轮廓、服装、材质、颜色和世界观身份。低饱和、乡土、干燥、旧纸、泥土、脏银、暗红点缀。每帧 768x768 RGBA PNG，透明背景，脚底完整，feet anchor 接近 x=384 y=720。动作清晰可读，缩小后仍能看出姿态。不要场景背景，不要投影，不要文字，不要 UI，不要骰子，不要刀光，不要命中特效；角色帧只保留 body-only。
```

### Character universal English prompt

```text
Use the input fullbody_clean image as the only identity reference. Generate full-body transparent action frames for a Godot 2D card-and-dice combat game. Preserve the same character silhouette, costume, materials, palette, and narrative identity. Low-saturation rural dark fantasy, dry old paper, dirt, tarnished silver, restrained dark red accents. Each frame is 768x768 RGBA PNG with transparent background, complete feet, feet anchor near x=384 y=720. The action must be readable at small game scale. No scene background, no shadow, no text, no UI, no dice, no slash effects, no hit effects; body-only character frames.
```

### 动作补充

idle：

```text
轻微呼吸、衣摆、肩颈微动，站姿稳定，脚底不漂移。P0 4 帧可用，最终 6 帧。
```

attack：

```text
普通攻击，短促克制，武器/手臂前出，重心轻微前移。不要大刀光。6-8 帧。
```

heavy_attack：

```text
重击，比 attack 更低重心、更沉，先蓄力再砸/劈/刺。不要动漫大招姿势。6-8 帧。
```

defend：

```text
防御/蓄防，身体、双手、衣摆或残片向内收拢，护住胸口/腹部核心。不要蓝色魔法盾。4-8 帧。
```

hurt：

```text
受击后退、蜷缩、失衡，不能血腥爆裂，脚底锚点尽量稳定。4-6 帧。
```

talk：

```text
轻微说话/登记/喃喃自语动作，上身和头部微动，不影响对话框布局。4-6 帧。
```

ultimate_cast：

```text
仅主角。表现神之胃囊/圣匣记录被打开，胸口暗红标记短促回应。不是能量炮，不是二次元必杀。body-only，吞噬痕迹另做 FX。6-8 帧。
```

## 03 角色身份约束

### player_echo

- 使用 `player_echo_fullbody_20260610_alpha.png` 或已确认 clean 版本。
- 银灰盔甲空壳使徒，无脸/封闭头部，破碎衣摆，胸口暗红胃囊/圣痕。
- 不要回到旧低清占位精灵。

### enemy_empty

- 不是僵尸。
- 必须有空碗、等粮、被等待掏空的姿态。
- 攻击像饥饿扑咬/抓挠，防御像身体收缩护住空腹。

### enemy_farmer

- 制度执行者和受害者混合。
- 农具、粗布、播种/登记/执行劳动感。
- 不要普通稻田怪。

### enemy_scarecrow

- 必须是真稻草人结构：木杆、稻草、绑缚物、旧衣服、守卫感。
- 不要画成人形巫师或普通骷髅。

### boss_barn_king

- 不要纯怪物化。
- 保留“曾经开仓救人的王”的人类/制度残影。
- 谷仓、胃囊、王权、献祭制度融合。
- 体积大但仍是可在房间里战斗的角色资产。

## 04 卡牌 UI 下一批提示词

### 输入参考

```text
assets/card_demo/ui/cards/card_attack_base.png
assets/card_demo/ui/cards/card_defend_base.png
assets/card_demo/cards/card_basic_attack_art.png
assets/card_demo/cards/card_basic_defense_art.png
docs/planning/32_NANOBANANA_CARD_COMBAT_ART_PROMPTS.md
```

### 输出

```text
assets/card_demo/ui/cards/card_attack_base.png
assets/card_demo/ui/cards/card_heavy_base.png
assets/card_demo/ui/cards/card_guard_base.png
assets/card_demo/ui/cards/card_ultimate_base.png
assets/card_demo/ui/cards/card_hover_frame.png
assets/card_demo/ui/cards/card_selected_frame.png
assets/card_demo/ui/cards/card_disabled_overlay.png
```

### 中文 prompt

```text
生成 Godot 2D 行动牌 UI，512x768 RGBA PNG，透明或干净 alpha 边缘。旧纸卡面，脏银边框，封蜡、档案标签、医学样本标签，低饱和暗红点缀。顶部留小行动图标，中央和下半留干净文字区，Godot 会渲染标题、数值和规则，所以不要烘焙文字。文字区低噪点、高可读，边框可以有旧纸和金属纹理。不是现代手游按钮，不是赛博 UI，不是二次元卡面，不要满屏插画。
```

### English prompt

```text
Generate a Godot 2D action card UI asset, 512x768 RGBA PNG, transparent or clean alpha edges. Old paper card face, tarnished silver frame, sealing wax, archive label, medical sample tag, restrained dark red accents. Top area reserved for a small action icon; center and lower half reserved as a clean text area. Godot will render title, values, and rules, so do not bake any text. Low-noise readable text area, old paper and metal texture allowed on the frame. Not a modern mobile game button, not cyber UI, not anime card art, no full-card illustration.
```

### 四张牌图标方向

- `card_attack_base`：短刃/残片划痕，D20 vs D20，D3 伤害，不写数字。
- `card_heavy_base`：更重的压痕、断麦秆、重残片武器，表示高出 5 点和 D3 x2，不写数字。
- `card_guard_base`：身体收拢、残片护身、双骰取高的档案标记感，不要蓝盾。
- `card_ultimate_base`：圣匣记录/神之胃囊/暗红封蜡被打开，D6 直伤无视防御，不写数字。

## 05 骰子与投掷舞台

### 输入参考

```text
assets/card_demo/ui/dice/d20_attack_die.png
assets/card_demo/ui/dice/d20_defense_die.png
assets/card_demo/ui/dice/d3_effect_die.png
assets/card_demo/ui/dice/dice_roll_stage.png
assets/card_demo/ui/dice/ui_die_hit_d20.png
assets/card_demo/ui/dice/ui_die_defense_d20.png
assets/card_demo/ui/dice/ui_die_effect_d3.png
```

### 输出

```text
assets/card_demo/ui/dice/d20_attack_die.png
assets/card_demo/ui/dice/d20_defense_die.png
assets/card_demo/ui/dice/d3_effect_die.png
assets/card_demo/ui/dice/d6_ultimate_die.png
assets/card_demo/ui/dice/dice_roll_stage.png
```

可选 roll 序列：

```text
assets/card_demo/ui/dice/d20_attack_roll_0.png ... d20_attack_roll_5.png
assets/card_demo/ui/dice/d20_defense_roll_0.png ... d20_defense_roll_5.png
assets/card_demo/ui/dice/d3_effect_roll_0.png ... d3_effect_roll_5.png
assets/card_demo/ui/dice/d6_ultimate_roll_0.png ... d6_ultimate_roll_5.png
```

### 中文 prompt

```text
生成 Godot 2D 骰子 UI 资产，单骰 512x512 RGBA PNG，透明背景，干净 alpha 边缘。低饱和乡土暗黑奇幻，材质像旧骨、旧象牙、脏银、旧铁、封蜡或麦粒，不是塑料桌游骰子。刻痕可以是暗红或冷灰，边缘有手工磨损，实体感更强但不要 3D 写实塑料。不要文字、logo、高饱和发光、赛博蓝光。
```

### English prompt

```text
Generate a Godot 2D dice UI asset, single die 512x512 RGBA PNG, transparent background, clean alpha edge. Low-saturation rural dark fantasy. Material feels like old bone, aged ivory, tarnished silver, old iron, sealing wax, or rough grain, not plastic tabletop dice. Engraved marks may be dark red or cold gray, handmade worn edges, stronger physical presence but not realistic plastic 3D. No text, no logo, no high-saturation glow, no cyber blue light.
```

### D6 大招骰补充

```text
D6 ultimate die：圣匣/胃纹/暗红封蜡感，像被打开的仪式骰。方体或近似方体可读，但不要塑料方块，不要能量水晶。
```

### 投掷舞台 prompt

```text
生成 Godot 2D 投掷舞台，768x384 或 640x320 RGBA PNG，透明背景或干净 alpha。旧木盘、档案托盘、圣匣托盘混合体，中心留骰子位置，边缘有脏银夹、旧纸标签、少量封蜡。低噪点，不遮挡整屏，适合画面中央短暂显示。
```

## 06 FX 下一批提示词

### 输出

```text
assets/card_demo/fx/fx_attack_slash/fx_attack_slash_0.png ... fx_attack_slash_5.png
assets/card_demo/fx/fx_heavy_impact/fx_heavy_impact_0.png ... fx_heavy_impact_7.png
assets/card_demo/fx/fx_guard_ready/fx_guard_ready_0.png ... fx_guard_ready_5.png
assets/card_demo/fx/fx_ultimate_digest/fx_ultimate_digest_0.png ... fx_ultimate_digest_7.png
assets/card_demo/fx/fx_reflect/fx_reflect_0.png ... fx_reflect_5.png
```

### 通用 prompt

```text
生成 Godot 2D 透明战斗 FX 序列帧，512x512 或 768x768 RGBA PNG，透明背景，干净 alpha。低饱和乡土暗黑奇幻，干燥旧纸、尘土、脏银、暗红裂纹。效果短促、克制、可读，不遮挡角色 body。不要高饱和魔法，不要赛博能量波，不要动漫大刀光，不要满屏粒子。
```

### 单项方向

- `fx_attack_slash`：短刀痕/残片划痕，贴近武器轨迹，1-6 帧。
- `fx_heavy_impact`：压痕、尘土、暗红裂纹，沉重但不满屏，4-8 帧。
- `fx_guard_ready`：残片护身、衣摆收拢、旧纸标签被压住，不是蓝盾，4-6 帧。
- `fx_ultimate_digest`：圣匣记录/神之胃囊暗红吞噬痕迹，旧纸档案打开、胃纹收束、封蜡裂开，6-8 帧。
- `fx_reflect`：短促反咬/碎片回弹，暗红和脏银小范围闪回，P0.5。

## 07 清洁/去噪操作建议

### 模型级或人工级处理

必须认真处理：

- `portrait_collector_halfbody.png`
- `player_echo` 全套动作
- `enemy_empty` 全套动作
- `enemy_farmer` 全套动作
- `enemy_scarecrow` 全套动作
- `boss_barn_king` 全套动作
- 需要长期使用的卡牌、骰子和核心 FX

处理步骤：

1. 源图轻度去噪，降低 AI 颗粒。
2. 抠透明或修 alpha 边。
3. 检查缩小到游戏尺寸是否可读。
4. 统一色阶和饱和度。
5. 对角色帧做 feet anchor 对齐。
6. 输出后跑尺寸、RGBA、alpha bbox、脚底完整性检查。

### 轻修即可

- 当前背景图。
- 旧日志碎片。
- 小图标。
- 临时骰子结果图标。
- 临时意图气泡。

轻修方式：

- 文本/按钮附近降噪。
- 边缘轻微锐化。
- 色阶统一。
- 不要大改构图。

## 08 P0 执行清单

第一批只做这些：

1. `portrait_collector_halfbody_clean.png`
2. `player_echo`：idle、attack、heavy_attack、defend、hurt、talk、ultimate_cast
3. `enemy_empty`：idle、attack、heavy_attack、defend、hurt、talk
4. 四张行动牌：attack、heavy、guard、ultimate
5. 骰子：d20 attack、d20 defense、d3 effect、d6 ultimate、roll stage
6. FX：attack slash、heavy impact、guard ready、ultimate digest

第二批：

1. `enemy_farmer` 动作补齐
2. `enemy_scarecrow` 动作补齐
3. card hover / selected / disabled
4. fx_reflect

第三批：

1. `boss_barn_king` 动作补齐
2. collector talk 轻动画
3. 背景轻度统一清洁

## 09 给本地改图者的短版任务

```text
先不要继续画新场景。请优先处理 playable 观感最明显的资产：

1. 基于 assets/portraits/portrait_collector_halfbody.png 做 portrait_collector_halfbody_clean.png，只清洁去噪补边，不改设定，不改全身。
2. 基于各角色 source/fullbody_clean.png 补动作帧。每帧 768x768 RGBA 透明，feet anchor x=384 y=720，body-only。
3. 主角优先补 idle、attack、heavy_attack、defend、hurt、talk、ultimate_cast。
4. 空腹者优先补 idle、attack、heavy_attack、defend、hurt、talk。
5. 补四张行动牌：attack、heavy、guard、ultimate。512x768 RGBA，不烘焙文字。
6. 补 D6 大招骰并清洁 D20/D3 与投掷舞台。单骰 512x512，舞台 768x384 或 640x320。
7. 补核心 FX：attack_slash、heavy_impact、guard_ready、ultimate_digest。

统一风格：低饱和、乡土、干燥、旧纸、泥土、脏银、暗红点缀。禁止赛博、二次元、高饱和魔法光、塑料骰子、按钮式 UI、大段烘焙文字、角色海报替代透明动作帧。
```
