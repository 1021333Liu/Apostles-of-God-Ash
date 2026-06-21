# 神烬使徒：给金荣俊的当前美术需求

本分支是我们发给金荣俊看的需求入口：`handoff/to-jin-rongjun`。

当前游戏方向已经转为“叙事场景 + 卡牌骰子决斗”。我们现在最缺的不是更多零散概念图，而是能放进 Godot Demo 的角色源图、场景背景和后续可拆帧素材。请先按下面优先级做，不要直接改 `main`，完成后把图和说明交到 `handoff/from-jin-rongjun`。

## 当前最优先

1. 收藏家
   - 开局必须先有收藏家场景，不是直接进入战斗。
   - 收藏家需要站在“无声圣匣”场景中间或中后景，玩家和他对话后才进入低语田野。
   - 收藏家不是 UI 半身像，也不是单独头像；需要全身站姿，后续可以拆 idle / speak 动作帧。

2. 六张 16:9 场景图
   - 不是五张，现在需要六张。
   - 第一张是开局非战斗场景：收藏家站在无声圣匣里。
   - 后五张对应章节推进和出场角色，每张都要适配故事和角色站位。

3. 主角替换
   - 当前游戏里主角还没有替换成 2026-06-10 版本的视觉方向。
   - 请以 `assets/card_demo/actors/player_echo/source/player_echo_visual_benchmark_20260610.png` 为主角方向基准。
   - 需要更干净、低噪点、透明、可拆帧的主角源图或动作帧，不要沿用旧占位角色。

## 总体规格

- 场景尺寸：优先 `2048x1152` 或 `1920x1080`，必须 16:9。
- 场景格式：PNG。
- 角色格式：透明 PNG，脚底完整，不带背景投影污染。
- 风格：低饱和、乡土、干燥、冷清、旧纸、泥土、脏银、少量暗红血肉点缀。
- 参考方向：可以参考 Andrew Wyeth 作品里的乡村孤独感、干燥材质和空旷构图，但不要临摹任何具体作品。
- 所有图都要降低噪点，画面要干净。不要满屏高频颗粒、AI 脏边、破碎纹理。
- 禁止：大字、UI、卡牌框、角色贴满画面、赛博风、二次元卡通、高饱和魔法、纯怪物海报、全屏红黑血肉纹理。

## 六张场景图

请把这六张图作为当前场景 P0 交付。底部 25% 尽量低细节，给对话框、卡牌和骰子 UI 留空间。角色站位不要被背景细节吃掉。

### 1. `bg_silent_casket_collector_intro.png`

开局非战斗场景。无声圣匣内部，收藏家站在画面中间或中后景，玩家第一次醒来并与他对话。

必须出现：
- 无声圣匣或档案台。
- 旧木柜、脏银档案匣、封存胃囊仪器。
- 油污纸张、封蜡、金属夹、空白样本签。
- 收藏家站位明确，不能只是背景里很小的人影。
- 下方留对话 UI 空间。

重点：这张不是战斗背景，不要做成左右对战构图。它是开局叙事房间。

### 2. `bg_empty_stomach_queue.png`

第一关“空腹者”。低语田野入口，一条等粮队伍遗址。

必须出现：
- 空碗、队尾标记、破碎名单。
- 被风吹散的登记纸。
- 远处贫瘠田路、枯麦、低矮乡村边界。
- 给“空腹者”站位留空间。

情绪是等待太久之后的空，不是热闹灾难。

### 3. `bg_farmer_field_register.png`

第二关“饥民农夫”。登记田路，像工作流程一样冷酷的田间通道。

必须出现：
- 登记牌、旧农具、半埋名单。
- 田垄、远处血麦、分粮痕迹。
- 给农夫站位留空间。

重点表达：农夫不是单纯坏人，而是被照常下田的秩序吃掉。

### 4. `bg_scarecrow_blood_wheat.png`

第三关“饥饿稻草人”。血肉麦田和稻草人守卫区。

必须出现：
- 被绑过的衣物、麦刺、守卫边界。
- 暗红血麦、远处风中像人影的稻草。
- 给饥饿稻草人站位留空间。

不要画一个巨大稻草人占满画面。角色会单独叠加。

### 5. `bg_hungry_barn_exterior.png`

第四关前置场景“会咀嚼的谷仓”或谷仓入口。

必须出现：
- 半开谷仓外观。
- 像牙齿或咀嚼痕迹的木板结构，但不要做成夸张怪兽嘴。
- 空粮袋、旧车辙、被拖拽的麦束。
- 给角色和对话站位留空间。

重点：这是进入 Boss 前的压迫感，不是 Boss 房本体。

### 6. `bg_barn_king_chamber.png`

Boss“谷仓王”。半开谷仓内部，既像粮仓也像腹腔。

必须出现：
- 谷仓钥匙或钥匙钩。
- 木梁骨架、空粮仓。
- 巨大胃囊或祭献痕迹。
- 旧名单和救济残留。
- 给谷仓王站位和弱点展示留空间。

方向不是纯怪兽巢穴，而是“救济失败后的王权和饥荒机器”。

## 收藏家角色需求

文件建议：

```text
assets/card_demo/actors/collector/source/collector_fullbody_front.png
assets/card_demo/actors/collector/collector_fullbody_idle_0.png
assets/card_demo/actors/collector/collector_fullbody_idle_1.png
assets/card_demo/actors/collector/collector_fullbody_idle_2.png
assets/card_demo/actors/collector/collector_fullbody_idle_3.png
assets/card_demo/actors/collector/collector_fullbody_speak_0.png
...
assets/card_demo/actors/collector/collector_fullbody_speak_5.png
```

规格：
- 先交一张干净透明全身源图，脚底完整。
- 后续至少需要 `idle` 4 帧、`speak` 6 帧。
- 单帧建议 `768x768`，feet anchor 约 `x=384, y=720`。
- 游戏内显示高度约 320-420px 时仍要能看清轮廓。

气质：
- 像医生、研究者、档案管理员和圣物保管者的混合体。
- 不要画成恶魔、巫师、商人、赛博科学家。
- 银灰长袖或旧医师式外衣。
- 至少有两种记录工具：纸页、金属夹、封蜡、样本标签、细笔、手套。
- 冷白或脏银主色，旧纸黄辅助，暗红只用于封蜡或小样本标记。

## 主角 2026-06-10 版本替换需求

当前游戏里的主角还没替换成我们选定的 6.10 版本方向。请以这个文件为基准：

```text
assets/card_demo/actors/player_echo/source/player_echo_visual_benchmark_20260610.png
```

需要：
- 干净去噪。
- 透明 PNG。
- 可以拆成站立、行走、攻击、防御、受击、胜利动作。
- 不要只给静态一张图。
- 不要变成旧版本主角或普通骑士。

最低动作需求：
- `field_idle` 6 帧。
- `field_walk` 8 帧。
- `card_attack` 8 帧。
- `card_defend` 8 帧。
- `card_hurt` 6 帧。
- `card_win` 8 帧。

如果时间不够，先交透明全身源图和 `field_idle` / `card_attack` / `card_defend`，但必须保持 6.10 视觉方向。

## 当前交付方式

请不要直接改 `main`。

金荣俊交付时使用：

```text
handoff/from-jin-rongjun
```

建议目录：

```text
assets/card_demo/actors/collector/
assets/card_demo/actors/player_echo/
assets/card_demo/backgrounds/
assets/concepts/jin_rongjun_delivery_YYYYMMDD/
```

每次交付请附一个 README，写清楚：
- 哪些图是最终可进 Godot 的 PNG。
- 哪些只是概念参考。
- 每张图的尺寸。
- 角色是否透明。
- 动作帧数量。
- 已知问题，比如噪点、边缘污染、需要继续拆帧。

## 验收红线

以下情况先不要进游戏：
- 收藏家只是半身头像，不是站在场景里的全身角色。
- 开局没有收藏家所在的非战斗场景。
- 场景图只有五张，缺开局圣匣收藏家场景。
- 主角没有按 6.10 版本方向替换。
- 角色没有透明背景。
- 角色只有一张静态图，没有可做动效的帧或源图。
- 背景噪点太高，UI 和角色站位看不清。
- 图里写死大段文字，程序无法替换文本。
