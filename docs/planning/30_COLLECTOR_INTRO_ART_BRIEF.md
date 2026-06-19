# 收藏家开场美术需求

本文件补齐卡牌骰子 Demo 的开场缺口：玩家不应该直接出现在低语田野里，而应先在“无声圣匣”中醒来，由收藏家完成第一轮引导，再进入田野。

当前程序侧已可用占位 UI 表现这段流程，但缺少收藏家正式美术。注意：收藏家不是 UI 半身像，而是站在无声圣匣场景里的全身角色。画师优先交全身站姿原画或透明立绘，美术线程再用 `generate2dsprite` workflow 做动作帧、锚点和 manifest。

## 叙事定位

收藏家早期不能明显邪恶。他更像医生、研究者、档案管理员和圣物保管者的混合体。

玩家第一次见到他时，应该感到：

- 他掌握复活和归档流程。
- 他在“照料”主角，但照料方式冷静、器械化。
- 他对低语田野很熟，但不会立刻解释全部真相。
- 他不是普通老人、法师、恶魔或商人。

开场台词基调来自 `docs/planning/03_NARRATIVE_COPY.md`：

```text
你醒了。很好，这具身体还没有拒绝你。
无声圣匣会把你带回来。痛会过去，留下来的东西更有用。
第一站是低语田野。那里以前是粮仓，现在更像一张没合上的嘴。
先别急着要名字。低语田野会给所有东西登记，名字在那里可能会被吃掉哦。
记住，饿久了的人不一定盼着公道。他们先盼着下一顿。
```

## P0 资产

### 1. 收藏家场景内全身像

路径建议：

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

- 画师优先交一张全身站姿原画：`collector_fullbody_front.png`，透明 PNG，建议长边不低于 `1400px`。
- 程序运行帧由美术线程处理成 `768x768` 透明 PNG，脚底锚点 `x=384, y≈720`。
- 构图为全身站立，适合放在无声圣匣场景右侧或后侧，不是头像框。
- `idle` 4 帧，6 FPS：衣袍、记录纸、肩颈极轻微动。
- `speak` 6 帧，8 FPS：低头记录、抬眼、手指轻点纸页，不需要夸张张嘴。
- 可选 `gesture` 6 帧：伸手指向圣匣或递出样本标签。

必须出现：

- 银灰长袍或旧医师式外衣。
- 记录器具：纸页、金属夹、封蜡、样本标签、细笔、手套，至少两种。
- 冷白或脏银主色，旧纸黄辅助，暗红只作为封蜡或小样本标记。
- 轮廓清楚，缩到场景中 280-420px 高时仍能识别。

禁止：

- 不要画成恶魔、巫师、商店老板、赛博科学家。
- 不要有现代实验室电脑、霓虹、玻璃拟态 UI。
- 不要高饱和紫蓝魔法光。
- 不要临摹 Andrew Wyeth 的任何具体作品，只取乡村孤独、干燥材质和低饱和气质。

### 2. 无声圣匣开场背景

如果时间只够做一张背景，优先给这个。

路径建议：

```text
assets/card_demo/backgrounds/bg_silent_casket_intro.png
```

规格：

- `1920x1080` PNG。
- 16:9 横屏，适合 Godot 2D UI 叠加。
- 中央或偏后方是无声圣匣，像档案柜、棺匣、圣物盒、器官标本箱的混合体。
- 右侧或中后景留收藏家全身站位空间。
- 下方留对话框和继续按钮空间。

必须出现：

- 圣匣。
- 油渍纸页、脏银金属夹、封蜡、空白样本标签。
- 收藏家的工作痕迹，但不要像现代实验室。
- 和低语田野形成色彩区分：冷白、灰褐、脏银、旧纸黄。

### 3. 收藏家对话 UI 底板

路径建议：

```text
assets/card_demo/ui/dialogue/ui_collector_dialogue_panel.png
assets/card_demo/ui/dialogue/ui_speaker_nameplate_collector.png
```

规格：

- `ui_collector_dialogue_panel.png`：建议 `1200x220`，透明 PNG，可九宫格裁切更好。
- `ui_speaker_nameplate_collector.png`：建议 `360x80`，透明 PNG。
- 文本区必须留白，不要把具体台词写死在图上。

视觉关键词：

- 圣匣档案。
- 医学样本标签。
- 旧纸页。
- 封蜡和脏银金属夹。

## P1 资产

### 1. 收藏家手部特写

路径建议：

```text
assets/card_demo/cutins/collector_hand_recording.png
```

用途：

- 开场或死亡回收时短暂闪现。
- 表现“你不是英雄，你是样本”。

规格：

- `1024x512` 透明 PNG 或带背景 PNG。
- 手套、细笔、样本标签、少量暗红封蜡。

### 2. 死亡回圣匣姿态变化

路径建议：

```text
assets/card_demo/actors/collector/collector_fullbody_death_comment_0.png
...
```

用途：

- 玩家死亡回收后，收藏家评论死因。
- 姿态不应幸灾乐祸，而是记录实验误差。

## Manifest 要求

请更新或新增：

```text
assets/card_demo/card_demo_art_manifest.json
```

建议新增：

```json
{
  "actor": "collector",
  "action": "fullbody_idle",
  "frame_count": 4,
  "fps": 6,
  "anchor": {"mode": "feet", "x": 384, "y": 720},
  "draw_size": [320, 420],
  "paths": [
    "assets/card_demo/actors/collector/collector_fullbody_idle_0.png"
  ],
  "status": "p0_proxy_or_final"
}
```

UI 资产也要进 manifest 的 `ui[]`，至少写 `id`、`path`、`size`、`description`。

## 接入验收

程序侧能通过以下方式使用：

1. 开局进入 `SANCTUM_INTRO`，先显示无声圣匣和收藏家。
2. 按空格、回车或继续按钮推进 5 句开场台词。
3. 台词结束后进入低语田野探索。
4. 收藏家全身像站在场景里，不会遮挡台词、按钮、玩家 HP 和状态栏。
5. 1920x1080 下能读，1366x768 下不能越界。

## 给画师的短版任务

```text
这轮请补《神烬使徒》卡牌 Demo 开场的“收藏家 + 无声圣匣”资产。玩家开局应先在圣匣醒来，由收藏家对话后才进入低语田野。

P0：
1. 收藏家全身站姿原画 / 透明立绘：不是半身像，站在无声圣匣场景里。画师交源图，美术线程用 sprite skill 做 idle 4 帧、speak 6 帧、必要锚点和 manifest。
2. 无声圣匣开场背景：1920x1080，给收藏家全身站位留空间。
3. 收藏家对话 UI 底板：1200x220，透明 PNG，文本留白。

收藏家像医生、研究者、档案管理员，不像恶魔、巫师、商人。银灰长袍、记录器具、样本标签、封蜡、脏银金属夹是关键识别点。风格保持低饱和、乡村荒凉、干燥、旧纸、脏银。不要赛博 UI，不要高饱和魔法，不要临摹任何具体画作。
```
