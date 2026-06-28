# 2026-06-28 当前确定美术资产分类与下一批需求

给金荣俊 / 美术处理线程：

这份文档是当前 playable 版本的美术同步单。请先按这里分类整理，不要再主攻场景图；场景目前够用。接下来最影响试玩观感的是：收藏家开场立绘、主角与敌人动作、技能栏图标、掉落物 / 道具栏图标、骰子、投掷舞台和核心 FX。

2026-06-28 修正：复杂大卡牌暂缓，优先做底部技能栏图标和道具栏掉落物图标。具体见 `ART_UI_ICON_AND_LOOT_REQUEST_20260628.md`。

## 当前确认采用的资产

### 1. 开场收藏家

确认使用第一版半身像作为开场收藏家主要表现，不使用后续全身版作为开场主视觉。

```text
assets/portraits/portrait_collector_halfbody.png
```

用途：

- 开局“收藏家站在玩家面前说话”的对话表现。
- 画面中应居中、放大，压过普通 NPC 小立绘的存在感。
- 后续可以基于这张做清洁、去噪、轻微补边、透明化质量检查。

全身版暂时只作为参考 / 后续可选源图，不作为开场首选：

```text
assets/card_demo/actors/collector/source/collector_fullbody_front_20260625_alpha.png
assets/card_demo/actors/collector/source/collector_fullbody_front_20260625_chroma.png
```

### 2. 当前可用场景

这些场景当前够用，只需要轻度去噪、统一干净度和 UI 留白，不要把主要产能放在重画场景。

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

分类建议：

- `bg_silent_casket_collector_intro.png`：开场收藏家对话背景。
- `bg_silent_casket_intro.png`：圣匣 / 档案空间背景。
- `bg_empty_stomach_queue.png`：空腹者关卡背景。
- `bg_farmer_field_register.png`：农夫关卡背景。
- `bg_scarecrow_blood_wheat.png`：饥饿稻草人关卡背景。
- `bg_hungry_barn_exterior.png`：谷仓前置 / 过渡背景。
- `bg_barn_king_chamber.png`：谷仓王 Boss 房背景。

### 3. 当前角色资产

这些已经能在游戏中跑，但很多是 P0 代理，需要继续重画或清洁。

主角：

```text
assets/card_demo/actors/player_echo/source/player_echo_fullbody_20260610_alpha.png
assets/card_demo/actors/player_echo/field_idle_0.png ... field_idle_5.png
assets/card_demo/actors/player_echo/field_walk_0.png ... field_walk_7.png
assets/card_demo/actors/player_echo/card_attack_0.png ... card_attack_7.png
assets/card_demo/actors/player_echo/card_defend_0.png ... card_defend_7.png
assets/card_demo/actors/player_echo/card_hurt_0.png ... card_hurt_5.png
assets/card_demo/actors/player_echo/card_win_0.png ... card_win_7.png
```

空腹者：

```text
assets/card_demo/actors/enemy_empty/source/fullbody_clean.png
assets/card_demo/actors/enemy_empty/idle/idle_0.png ... idle_3.png
```

农夫：

```text
assets/card_demo/actors/enemy_farmer/source/fullbody_clean.png
assets/card_demo/actors/enemy_farmer/idle/idle_0.png ... idle_3.png
assets/card_demo/actors/enemy_farmer/card_attack_0.png ... card_attack_7.png
assets/card_demo/actors/enemy_farmer/card_defend_0.png ... card_defend_7.png
assets/card_demo/actors/enemy_farmer/card_hurt_0.png ... card_hurt_5.png
assets/card_demo/actors/enemy_farmer/card_mutter_0.png ... card_mutter_7.png
assets/card_demo/actors/enemy_farmer/card_confess_0.png ... card_confess_7.png
```

饥饿稻草人：

```text
assets/card_demo/actors/enemy_scarecrow/source/fullbody_clean.png
assets/card_demo/actors/enemy_scarecrow/idle/idle_0.png ... idle_3.png
```

谷仓王：

```text
assets/card_demo/actors/boss_barn_king/source/fullbody_clean.png
assets/card_demo/actors/boss_barn_king/idle/idle_0.png ... idle_3.png
```

### 4. 当前行动 UI

目前游戏机制已经不是单纯“攻击 / 防御按钮”。UI 方向暂定优先做技能栏图标，而不是复杂大卡牌：

- 攻击
- 重击
- 蓄防
- 大招

已有基础牌面可作为旧参考，但不作为本轮主任务：

```text
assets/card_demo/ui/cards/card_attack_base.png
assets/card_demo/ui/cards/card_defend_base.png
assets/card_demo/ui/cards/card_hover_frame.png
assets/card_demo/ui/cards/card_selected_frame.png
assets/card_demo/cards/card_basic_attack_art.png
assets/card_demo/cards/card_basic_defense_art.png
```

问题：

- 只有攻击 / 防御方向，不够支撑当前机制。
- 本轮优先新增技能栏 icon：攻击、重击、蓄防、大招。
- 复杂卡牌大图可以暂缓。
- UI 图不要烘焙大段中文规则，Godot 会渲染中文标题、数值和规则。

### 5. 当前骰子与投掷舞台

```text
assets/card_demo/ui/dice/d20_attack_die.png
assets/card_demo/ui/dice/d20_defense_die.png
assets/card_demo/ui/dice/d3_effect_die.png
assets/card_demo/ui/dice/dice_roll_stage.png
assets/card_demo/ui/dice/ui_dice_result_panel.png
assets/card_demo/ui/dice/ui_die_hit_d20.png
assets/card_demo/ui/dice/ui_die_defense_d20.png
assets/card_demo/ui/dice/ui_die_effect_d3.png
assets/card_demo/ui/dice/ui_roll_critical_success.png
assets/card_demo/ui/dice/ui_roll_critical_fail.png
assets/card_demo/ui/dice/ui_roll_perfect_defense.png
assets/card_demo/ui/dice/ui_roll_reflect.png
```

问题：

- D20 / D3 已有基础方向，但还需要更强的“投骰子”实体感。
- 新机制需要大招 D6 直伤骰。
- 骰子不能塑料桌游感，不能赛博蓝光。

## 下一批需要你补的图

### P0：最先补

1. 收藏家半身像清洁版

```text
assets/portraits/portrait_collector_halfbody_clean.png
```

要求：

- 基于 `portrait_collector_halfbody.png`。
- 保留第一版脸、手、衣领、旧纸和档案气质。
- 降低噪点和脏边。
- 不要改成全身版，不要改成人物设定。

2. 主角动作重画 / 清洁

```text
assets/card_demo/actors/player_echo/idle/idle_0.png ... idle_5.png
assets/card_demo/actors/player_echo/attack/attack_0.png ... attack_7.png
assets/card_demo/actors/player_echo/heavy_attack/heavy_attack_0.png ... heavy_attack_7.png
assets/card_demo/actors/player_echo/defend/defend_0.png ... defend_7.png
assets/card_demo/actors/player_echo/hurt/hurt_0.png ... hurt_5.png
assets/card_demo/actors/player_echo/talk/talk_0.png ... talk_5.png
assets/card_demo/actors/player_echo/ultimate_cast/ultimate_cast_0.png ... ultimate_cast_7.png
```

3. 四个敌人动作补齐

每个角色都需要：

```text
source/fullbody_clean.png
idle/idle_0.png ... idle_5.png
attack/attack_0.png ... attack_7.png
heavy_attack/heavy_attack_0.png ... heavy_attack_7.png
defend/defend_0.png ... defend_7.png
hurt/hurt_0.png ... hurt_5.png
talk/talk_0.png ... talk_5.png
```

角色列表：

```text
assets/card_demo/actors/enemy_empty/
assets/card_demo/actors/enemy_farmer/
assets/card_demo/actors/enemy_scarecrow/
assets/card_demo/actors/boss_barn_king/
```

重点：

- 饥饿稻草人必须是真稻草人结构：木杆、稻草、绑缚物、旧衣服、守卫感。
- 谷仓王不能纯怪物化，要保留“曾经开仓救人的王”的人类 / 制度残影。
- 空腹者不是普通僵尸，要有空碗、等粮、被等待掏空的状态。
- 农夫是制度执行者和受害者混合，不是普通稻田怪。

4. 技能栏图标，复杂卡牌暂缓

```text
assets/card_demo/ui/skills/skill_attack.png
assets/card_demo/ui/skills/skill_heavy_attack.png
assets/card_demo/ui/skills/skill_guard_charge.png
assets/card_demo/ui/skills/skill_ultimate.png
assets/card_demo/ui/skills/skill_locked_overlay.png
assets/card_demo/ui/skills/skill_selected_frame.png
assets/card_demo/ui/skills/skill_cooldown_overlay.png
```

规则对应：

- 攻击：D20 命中 vs 敌方 D20 防御，命中后 D3 伤害。
- 重击：攻击骰必须比敌方防御骰高 5 点，成功后 D3 伤害翻倍。
- 蓄防：本回合不攻击；下一次敌人攻击时，玩家防御 D20 投两次取最高。
- 大招：攻击 / 重击累计 3 次后可用；D6 直伤，无视敌方防御。

4.5 掉落物 / 道具栏图标

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

5. 骰子与投掷舞台

```text
assets/card_demo/ui/dice/d20_attack_die.png
assets/card_demo/ui/dice/d20_defense_die.png
assets/card_demo/ui/dice/d3_effect_die.png
assets/card_demo/ui/dice/d6_ultimate_die.png
assets/card_demo/ui/dice/dice_roll_stage.png
```

可选滚动序列：

```text
assets/card_demo/ui/dice/d20_attack_roll_0.png ... d20_attack_roll_5.png
assets/card_demo/ui/dice/d20_defense_roll_0.png ... d20_defense_roll_5.png
assets/card_demo/ui/dice/d3_effect_roll_0.png ... d3_effect_roll_5.png
assets/card_demo/ui/dice/d6_ultimate_roll_0.png ... d6_ultimate_roll_5.png
```

6. 核心 FX

```text
assets/card_demo/fx/fx_attack_slash/fx_attack_slash_0.png ... fx_attack_slash_5.png
assets/card_demo/fx/fx_heavy_impact/fx_heavy_impact_0.png ... fx_heavy_impact_7.png
assets/card_demo/fx/fx_guard_ready/fx_guard_ready_0.png ... fx_guard_ready_5.png
assets/card_demo/fx/fx_ultimate_digest/fx_ultimate_digest_0.png ... fx_ultimate_digest_7.png
```

可 P0.5 再做：

```text
assets/card_demo/fx/fx_reflect/fx_reflect_0.png ... fx_reflect_5.png
```

## 通用规格

- 角色动作帧：`768x768 RGBA PNG`，透明背景。
- 脚底锚点：`x=384, y=720`。
- 角色帧必须 body-only；刀光、尘土、骰子、文字、命中特效不要画进角色 body 帧。
- 技能栏图标：`256x256 RGBA PNG`，不要烘焙长文字。
- 掉落物 / 道具栏图标：`256x256 RGBA PNG`，透明背景，单物件为主。
- 骰子：单骰 `512x512 RGBA PNG`。
- 投掷舞台：`768x384` 或 `640x320 RGBA PNG`。
- FX：`512x512` 或 `768x768 RGBA PNG` 序列帧。
- 画面要干净：降低高频噪点、AI 脏边、碎色块和压缩颗粒。

## 风格禁止项

明确不要：

- 赛博朋克
- 二次元 / 日系手游脸
- 高饱和魔法光效
- 塑料桌游骰子
- 按钮式 UI
- 大段烘焙文字
- 角色海报图替代透明动作帧
- 场景图继续堆数量

## 可直接参考的提示词文档

请优先看：

```text
docs/planning/32_NANOBANANA_CARD_COMBAT_ART_PROMPTS.md
```

这里已经包含 nanobanana / image-to-image 的中文和英文提示词、负面提示词、文件命名、QC 和 P0/P1 清单。
