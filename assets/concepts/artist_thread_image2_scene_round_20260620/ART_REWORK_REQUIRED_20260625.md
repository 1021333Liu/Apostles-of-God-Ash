# 2026-06-25 返工必做项：不要再主攻场景

金荣俊，这轮场景图和收藏家 / 主角透明源图已经收到，并已接入试玩分支。场景目前够用，下一轮请**不要继续主攻场景图**。

本轮真正缺口仍然是：

1. 四个敌人透明全身角色和动作帧。
2. 骰子 UI。
3. 攻击 / 防御卡牌 UI。

如果没有下面这些内容，就不能算完成本轮美术需求。

## 1. 敌人透明全身角色 + 动作帧

请优先画 / 生成以下四个角色：

- 空腹者
- 饥民农夫
- 饥饿稻草人
- 谷仓王

每个角色至少交：

```text
source/fullbody_clean.png
idle/idle_0.png ... idle_5.png
attack/attack_0.png ... attack_7.png
defend/defend_0.png ... defend_7.png
hurt/hurt_0.png ... hurt_5.png
talk/talk_0.png ... talk_5.png
```

如果时间不够，每个角色最低也要交：

- `source/fullbody_clean.png`
- `idle` 4-6 帧
- `attack` 4-8 帧
- `hurt` 3-6 帧

不要只交概念海报。必须是可抠、可进 Godot、可做动作的透明角色源图或帧。

### 空腹者

关键词：等粮队尾、空碗、长期等待后的空、身体被饥饿掏空。

不要画成普通僵尸，也不要画成纯怪物。

### 饥民农夫

关键词：登记牌、旧农具、制度执行者、被秩序吃掉的人、疲惫、喃喃。

不要画成普通稻田怪，也不要画成单纯反派。

### 饥饿稻草人

关键词：真正的稻草人结构、木杆、稻草、旧衣物、绑缚物、守卫边界、暗红血麦。

红线：不要画成穿破衣服的人。必须一眼读成“稻草人”。

### 谷仓王

关键词：粮仓、木梁、胃囊、钥匙、救济失败、曾经开仓救人的王、王权残影。

红线：不要画成纯怪物。需要保留人类 / 制度 / 王权的残影。

## 2. 骰子 UI

当前游戏里骰子只是临时提示，不够像“投骰子”。请交以下 UI：

```text
assets/card_demo/ui/dice/d20_attack_die.png
assets/card_demo/ui/dice/d20_defense_die.png
assets/card_demo/ui/dice/d3_effect_die.png
assets/card_demo/ui/dice/dice_roll_stage.png
assets/card_demo/ui/dice/dice_result_panel.png
```

最好再交滚动帧：

```text
assets/card_demo/ui/dice/d20_attack_roll_0.png ... d20_attack_roll_5.png
assets/card_demo/ui/dice/d20_defense_roll_0.png ... d20_defense_roll_5.png
assets/card_demo/ui/dice/d3_effect_roll_0.png ... d3_effect_roll_5.png
```

风格要求：

- 骰子可以是骨质、脏银、旧牙、封蜡刻面。
- D20 攻击、D20 防御、D3 效果需要有视觉差异。
- 数字区域要清楚，但不要把固定结果写死。
- 不要现代塑料桌游骰。
- 不要赛博蓝光。
- 不要二次元魔法 UI。

## 3. 攻击 / 防御卡牌 UI

技术侧会把攻击、防御从按钮改成底部手牌区，所以必须有真正的卡牌图面。

请交：

```text
assets/card_demo/ui/cards/card_attack_base.png
assets/card_demo/ui/cards/card_defend_base.png
assets/card_demo/ui/cards/card_selected_frame.png
assets/card_demo/ui/cards/card_hover_frame.png
```

规格建议：

- 单张卡牌：`360x520` 或 `512x768`。
- 透明 PNG。
- 文本区留白，不要把规则文字画死。
- 只画牌面框架、图形、标题框、规则区框架、图标位。
- 攻击牌要读出“出手 / 命中 / 伤害”。
- 防御牌要读出“抵挡 / 完美防御 / 反弹”。
- 后续程序会叠加 `D20`、`D3`、`奖励D3 x2` 等动态文字。

攻击牌方向：

- 旧纸牌面、脏银边框、暗红割痕、胃囊纹路。
- 不要普通火球卡。

防御牌方向：

- 旧纸牌面、脏银护片、封蜡、空碗、护住胸口的符号。
- 不要蓝色魔法盾。

## 4. 风格红线

这轮请明确避免：

- 不要继续主攻场景图，场景目前够用。
- 不要赛博。
- 不要二次元。
- 不要高饱和魔法。
- 不要塑料桌游骰。
- 不要按钮式 UI。
- 不要把卡牌规则文字画死。
- 不要交只有一张静态图、无法拆动作的角色。
- 不要让角色和背景糊成一团。

## 5. 交付目录

请交到 `handoff/from-jin-rongjun`，建议目录：

```text
assets/concepts/jin_rongjun_delivery_20260625_rework/
assets/card_demo/actors/enemy_empty/
assets/card_demo/actors/enemy_farmer/
assets/card_demo/actors/enemy_scarecrow/
assets/card_demo/actors/boss_barn_king/
assets/card_demo/ui/dice/
assets/card_demo/ui/cards/
```

请附 README，写清楚：

- 哪些是可直接进 Godot 的 PNG。
- 哪些只是概念参考。
- 每张图尺寸。
- 是否透明。
- 动作帧数量。
- 是否已去噪。
- 已知问题，例如边缘污染、脚底不完整、动作帧还不够。

## 6. 最短交付版本

如果时间非常紧，请至少交：

1. 四个敌人的透明全身源图。
2. 每个敌人的 `idle` 4 帧。
3. `d20_attack_die.png`、`d20_defense_die.png`、`d3_effect_die.png`。
4. `card_attack_base.png`、`card_defend_base.png`、`card_selected_frame.png`。

这四项比继续补场景图更重要。
