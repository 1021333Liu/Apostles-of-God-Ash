# 2026-06-25 给金荣俊的美术更新需求：角色、骰子、卡牌 UI

本轮请优先用 image2 跑图和整理源图。当前场景图暂时能支撑 Demo，最影响试玩观感的是角色、骰子和攻击/防御选择的卡牌化表现。

游戏当前定位请按：**固定章节推进的叙事卡牌骰子 RPG**。不是随机地图 Roguelite，也不是实时动作战斗。

## 本轮优先级

1. 角色源图和动作帧方向
2. 骰子 UI 和投掷表现
3. 攻击 / 防御卡牌图面
4. 角色去噪、透明化、脚底锚点

场景背景暂时不是最高优先级，除非只是顺手修噪点和留 UI 空间。

## 统一美术标准

- 风格继续保持低饱和、乡土、干燥、冷清、旧纸、泥土、脏银、暗红血肉点缀。
- 画面要更干净，降低高频噪点、AI 脏边、破碎纹理和压缩颗粒。
- 不要赛博、不要二次元、不要高饱和魔法、不要塑料桌游感。
- 角色和 UI 不能和背景混成一团，放进 1920x1080 战斗界面后必须一眼可读。
- 角色 body 帧不要把刀光、骰子、尘土、文字、特效烘死进去；这些后续由程序或 FX 单独叠加。

## P0-1 主角：替换成 2026-06-10 方向

当前试玩里主角还不够像我们选定的 6.10 版本。请以这个视觉方向为准：

```text
assets/card_demo/actors/player_echo/source/player_echo_visual_benchmark_20260610.png
```

需要交付：

```text
assets/card_demo/actors/player_echo/source/player_echo_fullbody_clean.png
assets/card_demo/actors/player_echo/field_idle/field_idle_0.png ... field_idle_5.png
assets/card_demo/actors/player_echo/field_walk/field_walk_0.png ... field_walk_7.png
assets/card_demo/actors/player_echo/card_attack/card_attack_0.png ... card_attack_7.png
assets/card_demo/actors/player_echo/card_defend/card_defend_0.png ... card_defend_7.png
assets/card_demo/actors/player_echo/card_hurt/card_hurt_0.png ... card_hurt_5.png
assets/card_demo/actors/player_echo/card_win/card_win_0.png ... card_win_7.png
```

最低可先交：

- `player_echo_fullbody_clean.png`
- `field_idle` 6 帧
- `card_attack` 8 帧
- `card_defend` 8 帧

规格：

- 透明 PNG。
- 单帧建议 `768x768`。
- 脚底完整，feet anchor 约 `x=384, y=720`。
- 战斗中显示高度约 320-420px 时仍能看清轮廓。
- 主角不是普通骑士，不要退回旧占位主角。

## P0-2 小怪和 Boss：统一透明角色源图

需要优化这几个角色，不要只给静态概念海报：

1. 空腹者
2. 饥民农夫
3. 饥饿稻草人
4. 谷仓王

每个角色至少交：

```text
source/fullbody_clean.png
idle/idle_0.png ... idle_5.png
attack/attack_0.png ... attack_7.png
defend/defend_0.png ... defend_7.png
hurt/hurt_0.png ... hurt_5.png
talk/talk_0.png ... talk_5.png
```

如果时间不够，每个角色先交：

- 透明全身干净源图
- idle 4-6 帧
- attack 4-8 帧
- hurt 3-6 帧

角色方向：

- **空腹者**：饥饿、空碗、等粮队尾、身体被长期等待掏空；不要画成普通僵尸。
- **农夫**：制度执行者和受害者混合；农具、登记、疲惫、喃喃；不要画成普通稻田怪。
- **饥饿稻草人**：必须是真正的稻草人结构，木杆、稻草、绑缚物、旧衣物、守卫感；不要画成穿破衣的人。
- **谷仓王**：不是纯怪物巢穴 Boss，要保留“曾经开仓救人的王”的人类/制度残影；木梁、粮仓、胃囊、钥匙、救济失败的痕迹都可以成为设计元素。

## P0-3 骰子 UI：让玩家感觉真的在投骰子

当前骰子表现太像提示牌，不够像投掷过程。请优先跑三类骰子视觉：

```text
assets/card_demo/ui/dice/d20_attack_die.png
assets/card_demo/ui/dice/d20_defense_die.png
assets/card_demo/ui/dice/d3_effect_die.png
assets/card_demo/ui/dice/dice_roll_stage.png
assets/card_demo/ui/dice/dice_result_panel.png
```

可选动画帧：

```text
assets/card_demo/ui/dice/d20_attack_roll_0.png ... d20_attack_roll_5.png
assets/card_demo/ui/dice/d20_defense_roll_0.png ... d20_defense_roll_5.png
assets/card_demo/ui/dice/d3_effect_roll_0.png ... d3_effect_roll_5.png
```

方向：

- 骰子可以是骨质、脏银、旧牙、封蜡刻面。
- D20 攻击、D20 防御、D3 效果要有视觉差异。
- 不要现代塑料桌游骰。
- 不要科幻蓝光。
- 点数/数字区域要清楚，但不要把固定结果写死。
- 骰子底板要适合放在战斗画面中央，不能遮住双方角色。

## P0-4 攻击 / 防御改成卡牌图面

技术侧会把攻击、防御从按钮改成底部手牌区，所以需要真正的卡牌图面。

请先做两张基础牌：

```text
assets/card_demo/ui/cards/card_attack_base.png
assets/card_demo/ui/cards/card_defend_base.png
```

以及选中 / hover 边框：

```text
assets/card_demo/ui/cards/card_selected_frame.png
assets/card_demo/ui/cards/card_hover_frame.png
```

卡牌规格建议：

- 单张卡牌：`360x520` 或 `512x768`，透明 PNG。
- 文本区域留白，不要把具体数值和长文字画死。
- 牌面只放图形、标题框、规则区框架、图标位。
- 攻击牌要能读出“出手 / 命中 / 伤害”。
- 防御牌要能读出“抵挡 / 完美防御 / 反弹”。
- 需要能承载后续加成，比如 `奖励D3 x2`、`防御加值` 等程序文本。

攻击牌方向：

- 旧纸牌面、脏银边框、暗红割痕、胃囊纹路。
- 不要画成普通火球攻击卡。

防御牌方向：

- 旧纸牌面、脏银护片、封蜡、空碗或手臂护住胸口的符号。
- 不要画成蓝色魔法盾。

## image2 prompt 方向

跑图时可以使用下面方向作为统一提示骨架，再按具体资产替换主体：

```text
Low-saturation rural dark fantasy game asset, dry old-paper texture, dirty silver details, muted earth colors, small dark red flesh accents, clean readable silhouette, hand-painted 2D illustration, transparent background for character or UI asset, no text, no logo, no UI labels, no cyberpunk, no anime, no high saturation magic, no plastic board-game look, no noisy AI artifacts.
```

角色类补充：

```text
Full-body front-facing character source for a 2D Godot card dice RPG, feet visible, centered pose, clean transparent background, suitable for splitting into idle, attack, defend, hurt and talk animation frames.
```

UI 类补充：

```text
Readable 2D game UI asset, transparent PNG, old paper and dirty silver material, reserved blank area for dynamic text, no baked words or numbers, suitable for bottom card hand area or center dice roll stage.
```

## 交付方式

请不要直接改 `main`。完成后交到：

```text
handoff/from-jin-rongjun
```

建议目录：

```text
assets/concepts/jin_rongjun_delivery_20260625/
assets/card_demo/actors/player_echo/
assets/card_demo/actors/enemy_empty/
assets/card_demo/actors/enemy_farmer/
assets/card_demo/actors/enemy_scarecrow/
assets/card_demo/actors/boss_barn_king/
assets/card_demo/ui/dice/
assets/card_demo/ui/cards/
```

每次交付请附 README，写清楚：

- 哪些是可直接进 Godot 的 PNG。
- 哪些只是概念参考。
- 每张图尺寸。
- 是否透明。
- 动作帧数量。
- 是否已去噪。
- 已知问题，例如边缘污染、脚底不完整、需要继续拆帧。

## 验收红线

以下情况先不要进游戏：

- 角色只有海报，没有透明全身源图。
- 角色像素噪点太高，放进游戏很糊。
- 饥饿稻草人画成普通人。
- 谷仓王画成纯怪物，完全没有粮仓、王权、救济失败残影。
- 骰子像现代塑料桌游骰。
- 卡牌把大段规则文字画死。
- 攻击 / 防御仍然像按钮，不像卡牌。
- UI 使用高饱和蓝光、赛博边框或二次元卡牌风。
