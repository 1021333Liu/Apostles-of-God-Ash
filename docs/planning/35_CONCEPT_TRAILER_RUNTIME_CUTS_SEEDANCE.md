# 《神烬使徒 / Apostles of God-Ash》概念片叙事强化与 Godot 演出切分

版本：2026-06-30  
用途：接续 `34_CONCEPT_TRAILER_STORYBOARD_SEEDANCE.md`，整理课堂概念片与游戏内过场视频的最终执行方案。  
目标：先完成 2:20-2:50 的 vertical slice concept trailer，再把其中关键镜头拆成 Godot 可接入短视频段。  
边界：本文件只做制作方案与 Seedance / 即梦提示词整理，不代表视频资产已经生成，不改 Godot runtime。

补充说明：叙事源对齐后的最终脚本已整理到 `36_NARRATIVE_ALIGNED_CONCEPT_TRAILER_SCRIPT.md`。后续旁白、字幕、镜头结尾台词和 Godot 演出切分优先以 36 号文档为准；本文件保留为初版执行拆分参考。

## 01 核心叙事判断

这支片子不能只展示“好看的乡土暗黑美术”。观众必须在 2 分半内理解三件事：

1. 低语田野不是普通地图，而是神留下的胃囊。田垄、谷仓、发放名单和旧纸签都是胃囊的消化器官。
2. 饥饿不是自然灾害，而是被登记、分配、执行和归档的制度。四个敌人是四份证据，不是普通怪物。
3. 主角不是自由冒险者，而是圣匣中的可回收样本。收藏家反复记录、回收、派回田野，失败也会成为资料。

最终情绪曲线：

```text
不是田野 -> 胃囊真相 -> 圣匣醒来 -> 收藏家派遣 -> 四份饥饿证据 -> 骰子/技能作为取证机制 -> 谷仓王压迫 -> 失败归档 -> 再次追问
```

## 02 课堂概念片最终分镜调整版

建议成片 150-165 秒。课堂时间紧时剪 105-120 秒版本，保留标记为 P0 的镜头。

| # | 优先级 | 时长 | 画面 | 叙事功能 | 结尾画面 |
|---|---|---:|---|---|---|
| 01 | P0 | 6s | 旧纸黑场，圣匣锁扣在烛光里浮现 | 建立“档案/回收”母题 | 圣匣锁扣居中，可黑场转场 |
| 02 | P0 | 9s | 低语田野远景，田垄像胃壁褶皱延伸 | 明确田野是胃囊 | 远景静止，接档案桌 |
| 03 | P1 | 7s | 空碗、旧发放纸签、脏银登记牌被放上档案桌 | 饥饿被制度化 | 登记牌压住空碗 |
| 04 | P0 | 9s | 圣匣打开，主角在冷光里醒来 | 主角是被回收样本 | 主角坐起，接 Godot 对话 |
| 05 | P0 | 8s | 收藏家半身，手持档案和样本瓶 | 派遣者、记录者登场 | 收藏家看向镜头 |
| 06 | P1 | 4s | Godot 收藏家对话插片 | 证明游戏项目，并接叙事 | 对话停在“低语田野” |
| 07 | P0 | 9s | 空腹者抱空碗，站在救济队尾 | 第一证据：等待失败 | 空碗近景停住 |
| 08 | P0 | 9s | 农夫登记执行者站在田垄，旧镰刀与登记牌 | 第二证据：执行秩序 | 脏银牌反光，接遭遇 |
| 09 | P0 | 8s | 稻草人立在血麦边界，无人腿，木桩/草束/破布支架 | 第三证据：边界守卫 | 破布被风吹平，接遭遇 |
| 10 | P0 | 11s | 谷仓外景推进胃囊内室，木梁、钥匙碎片、救济残物 | 第四证据：救济失败的王 | 内室黑暗里出现巨大轮廓 |
| 11 | P1 | 7s | 技能图标蒙太奇，银刃、落刃、旧册、灰烛 | 机制不是热血战斗，而是证词采样 | 灰烛熄灭切骰子 |
| 12 | P0 | 9s | 骨白/脏银 D20 在画面中央缓慢旋转 | 骰子等于向圣匣交证词 | 骰子停点，接 Godot 骰子 UI |
| 13 | P1 | 7s | Godot 战斗/UI 插片：技能、骰子、角色受击、归档按钮 | 把概念片拉回可玩性 | UI 退为旧纸纹理 |
| 14 | P0 | 9s | 日志碎片被放回圣匣，失败记录被盖章 | 失败被保存 | 匣盖合上 |
| 15 | P1 | 8s | 主角再次站到田野，收藏家在远处阴影 | 循环未结束 | 主角背影停住 |
| 16 | P0 | 8s | 收藏家近景追问 | 悬念与主题句 | 黑场 |
| 17 | P0 | 5s | 标题卡 | 收束 | 纸页合上 |

105-120 秒课堂短版：01、02、04、05、07、08、09、10、12、14、16、17。  
90 秒极限版：01、02、04、05、07、10、12、14、16、17。

## 03 Godot 内演出版切分

视频段落建议放置路径：

```text
res://assets/videos/cutscenes/intro_opening.mp4
res://assets/videos/cutscenes/encounter_empty_pre.mp4
res://assets/videos/cutscenes/encounter_farmer_pre.mp4
res://assets/videos/cutscenes/encounter_scarecrow_pre.mp4
res://assets/videos/cutscenes/boss_barn_king_pre.mp4
res://assets/videos/cutscenes/ending_archive.mp4
```

当前 `res://scenes/card_duel_demo.tscn` 已有收藏家对话、骰子面板、奖励面板和归档面板，可先用录屏作为课堂概念片插片；真正接入短视频需后续单独实现 VideoStreamPlayer 或场景过场控制。

| 视频文件 | 建议时长 | 包含课堂镜头 | Godot 接入点 | 结尾接法 |
|---|---:|---|---|---|
| `intro_opening.mp4` | 24-30s | 01、02、04、05 | 游戏启动/章节开始后，接收藏家 intro 对话 | 停在收藏家半身正面，硬切 `bg_silent_casket_collector_intro.png` 和收藏家对话框 |
| `encounter_empty_pre.mp4` | 16-20s | 03、07 | 空腹者首次遭遇前 | 停在空碗近景或队尾全身，接空腹者对话/战斗背景 `bg_empty_stomach_first_enemy.png` 或 `bg_empty_stomach_queue.png` |
| `encounter_farmer_pre.mp4` | 14-18s | 03、08 | 农夫首次遭遇前 | 停在旧镰刀低垂和脏银登记牌，接 `bg_farmer_field_register.png` |
| `encounter_scarecrow_pre.mp4` | 14-18s | 09 | 稻草人首次遭遇前 | 停在血麦边界的无腿支架，接 `bg_scarecrow_blood_wheat.png` |
| `boss_barn_king_pre.mp4` | 22-28s | 10、12 的短回声 | Boss 战前 | 从谷仓门缝推进到胃囊内室，停在巨大暗影，接 `bg_barn_king_chamber.png` |
| `ending_archive.mp4` | 24-32s | 12、14、15、16、17 | 章节完成、失败回收或结尾 | 圣匣合上后转收藏家追问，再转标题卡或章节完成 UI |

## 04 每段视频 Seedance / 即梦 Prompt

### 通用前缀

```text
16:9 cinematic concept trailer shot for a dark rural fantasy card dice game, low saturation, dry rural atmosphere, old paper texture, dirty silver metal, mud, small dark red flesh accents only, painterly but realistic, premium console game trailer mood, restrained camera movement, dusty air, cold lonely farmland, sacred casket and archive imagery, no anime, no cyberpunk, no neon, no high saturation, no plastic board game dice, no mobile game UI, no modern laboratory, no glossy fantasy magic, no excessive gore, no readable generated text
```

中文控制词：

```text
低饱和，乡土，干燥，冷清，旧纸，泥土，脏银，少量暗红血肉点缀。不要赛博，不要二次元，不要高饱和，不要塑料骰子，不要手游按钮式 UI，不要现代实验室，不要发光魔法，不要过度血腥，不要让模型生成可读文字。
```

### intro_opening.mp4

时长：24-30 秒。  
用途：游戏开场与课堂概念片前 0:00-0:45。  
结构：圣匣锁扣 -> 低语田野远景 -> 圣匣内主角醒来 -> 收藏家第一次出现。

Prompt A：圣匣与田野

```text
16:9 cinematic opening for a dark rural fantasy game, almost black frame, old parchment texture slowly lit by a weak candle, a sacred archive casket with dirty silver lock appears, dust in the air, then dissolve to a dead rural field under gray sky, dry wheat rows bending like stomach folds and intestinal paths, distant broken fences, cold lonely farmland, restrained slow push in and slow lateral drift, no readable text, no characters in foreground
```

Prompt B：主角醒来

```text
inside a sacred casket looking upward, a pale white-haired protagonist wakes in cold light, shadowed black face, damaged white and blue sacred robe, short blade beside the body, old paper sample tag attached, dust floating, the casket lid opens like an archive drawer, slow handheld push, solemn and vulnerable, not heroic, no gore, no readable text
```

Prompt C：收藏家出现

```text
half-body cinematic portrait of the Collector, pale silver-haired archivist with calm expression, holding old documents and a small glass sample bottle, dirty silver tools, wax seals and paper tags on clothing, looks like a doctor, clerk and undertaker at once, dark sacred archive background, slow push in, quiet judgement, no modern lab, no readable text
```

结尾接 Godot：最后 1 秒让收藏家正面居中、背景变暗，剪到 `CardDuelDemo` 的收藏家 intro 对话。对话可用现有句子：“你醒了。很好，这具身体还没有拒绝你。”

### encounter_empty_pre.mp4

时长：16-20 秒。  
用途：空腹者首次遭遇前；课堂片中作为第一份证据。

Prompt：

```text
cinematic pre-encounter scene for the Empty One, top-down archive desk with an empty bowl shard, old supply paper slip and dirty silver registry tag placed on old paper, cut to a dead field relief line with no food at the end, the Empty One is a thin starving rural figure holding an empty bowl, tired and numb rather than zombie, old rag clothing, paper sample tag, slow pull back from the bowl to full body, low saturation, no blood, no demon features, no horror exaggeration, no readable text
```

结尾接 Godot：停在空腹者抱碗的 3/4 全身，背景可硬切 `bg_empty_stomach_first_enemy.png` 或 `bg_empty_stomach_queue.png`。接遭遇对话时第一句建议：“它还在排队。只是队伍早就没有尽头。”

### encounter_farmer_pre.mp4

时长：14-18 秒。  
用途：农夫登记执行者首次遭遇前；课堂片中作为第二份证据。

Prompt：

```text
cinematic pre-encounter shot of the Farmer Registrar in dry field rows, a practical rural executioner holding an old sickle and a dirty silver registry tag, worn work clothes, cold bureaucratic expression, he stamps or scratches names into the metal tag without readable letters, low angle slow push in, dry wheat and mud background, not a grim reaper, not magical, no glowing weapon, no oversized fantasy scythe, low saturation, old paper and dirty silver accents
```

结尾接 Godot：旧镰刀垂在画面下方，脏银登记牌靠近镜头。剪到 `bg_farmer_field_register.png`，接现有农夫对话氛围：“名单别乱。”

### encounter_scarecrow_pre.mp4

时长：14-18 秒。  
用途：稻草人首次遭遇前；课堂片中作为第三份证据。

Prompt：

```text
cinematic pre-encounter shot of the Hungry Scarecrow at the blood-wheat boundary, no human legs, lower body is wooden stake, straw bundle and torn cloth support, it stands as a border marker rather than a monster, wind moves the torn cloth, dry wheat with subtle dark red stains, unsettling but not too scary, no gore, no screaming face, slow half-circle camera movement, low saturation rural horror, old paper dust in the air
```

结尾接 Godot：镜头绕半圈后停在无腿支架和血麦边界，硬切 `bg_scarecrow_blood_wheat.png`。遭遇文本建议：“它不追你。它只是不让边界后退。”

### boss_barn_king_pre.mp4

时长：22-28 秒。  
用途：谷仓王战前；课堂片的压迫峰值。

Prompt：

```text
cinematic boss prelude from hungry barn exterior into the Barn King chamber, old rural barn built like a failed relief granary, wooden beams, hanging old supply sacks, broken bowls, old supply paper slips, fragments of barn key on the floor, stomach-like organic sacs integrated into the walls but restrained and not gory, the Barn King silhouette sits inside the failed relief system like a warehouse that learned to eat, slow camera move through a door crack into darkness, oppressive low frequency mood, dirty silver and old paper details, no demon throne, no excessive gore, no readable text
```

可选补帧 Prompt：钥匙碎片/救济失败特写

```text
macro insert shot, broken barn key fragments lying among old supply paper slips and empty bowl shards on muddy wooden floor, dirty silver glints, a shadow of a huge barn-like body breathes in the background, candle flicker, shallow depth of field, no readable text
```

结尾接 Godot：停在谷仓王内室大暗影，下一帧切 `bg_barn_king_chamber.png` 和 Boss 战 UI。若要接战前台词，可用：“他不是守着谷仓。他就是谷仓。”

### ending_archive.mp4

时长：24-32 秒。  
用途：失败回收、章节完成或课堂片收束。

Prompt A：骰子证词

```text
close-up of an old bone and dirty silver D20 die slowly rotating in the center of frame, not plastic, engraved dark red marks but no readable exact text, candle edge light, dust in the air, slow motion spin, the die stops with heavy physical weight, premium cinematic macro shot, old paper and sacred casket atmosphere nearby, no tray required
```

Prompt B：归档

```text
top-down archive ritual, a hand places a torn log fragment and a failed recovery note into a sacred casket, old paper, wax seal, dirty silver lock, the casket closes slowly, dust rises, quiet solemn mood, failure preserved as evidence, no readable text, low warm candle against cold darkness
```

Prompt C：追问

```text
close-up half-body shot of the Collector, calm pale face, silver hair, archive tools and glass sample bottle, old documents in hand, looking directly toward camera with quiet judgement, dark archive background, slow push in, final trailer mood, no readable text
```

结尾接 Godot：归档镜头可接 `ArchivePanel`、奖励面板或章节完成画面；收藏家追问后可回到圣匣安全场景，或进入标题卡。

## 05 旁白与字幕版本

### 完整旁白

```text
这里不是田野。
这里是神留下的胃囊。

饥饿被写进名单，粮食被做成秩序。
没有人真正死去。他们只是被登记、分配、再次吞咽。

我在圣匣中醒来。
收藏家说，我不是第一个样本，也不会是最后一个。

空腹者还抱着碗，等一口永远不会来的救济。
农夫守着田垄，把名字刻进脏银登记牌。
稻草人站在血麦边界，没有腿，也从不离开。
谷仓王坐在失败的救济里，像一座学会进食的仓库。

在这里，攻击不是勇气。
防御不是退缩。
每一次掷骰，都是向圣匣交出一份证词。

失败会被保存。
记忆会被归档。
下一次醒来时，收藏家会问：

这一次，你带回了什么？
```

### 110 秒短版旁白

```text
这里不是田野。这里是神留下的胃囊。
饥饿被写进名单，粮食被做成秩序。

我在圣匣中醒来。
收藏家说，我不是第一个样本。

空腹者等救济，农夫登记名字，稻草人守住血麦边界。
谷仓王坐在失败的救济里，像一座学会进食的仓库。

每一次掷骰，都是向圣匣交出一份证词。
失败会被保存。记忆会被归档。

这一次，你带回了什么？
```

### 字幕上屏规则

不要每句都上屏。字幕只放主题锚点：

```text
这里不是田野。
这里是神留下的胃囊。
饥饿被写进名单。
每一次掷骰，都是一份证词。
失败会被保存。
这一次，你带回了什么？
```

字幕风格：小字号、旧纸白或脏银灰、左下或居中下方；不要做发光字，不要做手游提示条。所有文字后期添加，不让视频模型生成。

## 06 BGM / 音效 Cue 表

| 时间段 | 画面 | BGM | 音效 |
|---|---|---|---|
| 0:00-0:15 | 圣匣、旧纸、黑场 | 低频 Drone 极弱进入 | 纸页摩擦、锁扣轻响、烛火 |
| 0:15-0:28 | 低语田野远景 | 加一层擦弦或旧风琴低音 | 干草风、远处木板、低频空气 |
| 0:28-0:50 | 主角醒来、收藏家 | Drone 稍微靠前，节奏仍慢 | 木匣开启、玻璃瓶轻碰、钢笔划纸 |
| 0:50-1:30 | 四个证据登场 | 稀疏鼓点开始，每个敌人一记低鼓 | 空碗回声、印章、镰刀刮木、破布风声、谷仓门轴 |
| 1:30-1:55 | 技能/骰子/战斗符号 | 鼓点加密但不热血 | 骨骰滚动、脏银碰撞、厚书合上、蜡烛燃烧 |
| 1:55-2:20 | 谷仓王 | 低频增强，加入不稳定胃鸣式纹理 | 木梁响、粮袋摩擦、钥匙碎片落地 |
| 2:20-2:40 | 归档、追问 | 音乐抽空，只留低频尾音 | 纸片入匣、蜡封、锁扣合上、钢笔停下 |
| 2:40-2:50 | 标题卡 | 单音尾奏或低频收束 | 纸页合上、圣匣锁死 |

音效边界：

- 骰子声必须是骨、石、脏银，不要塑料桌游声。
- 攻击声短、钝、脏，不要动漫刀光音。
- 谷仓王不要怪兽咆哮，优先木梁、胃鸣、粮袋和门轴。
- 稻草人不要尖叫恐怖片化，优先风、干草、破布。

## 07 Godot 画面插入建议

可直接使用或录屏的现有画面/资产：

| 插片 | 建议位置 | 当前可用资产/界面 | 剪辑处理 |
|---|---|---|---|
| 收藏家对话 | Shot 06 或 `intro_opening.mp4` 结尾 | `res://assets/card_demo/backgrounds/bg_silent_casket_collector_intro.png`、`portrait_collector_halfbody.png`、收藏家 intro 对话 | 2-4 秒，轻微缩放，叠纸纹暗角 |
| 骰子 UI | Shot 12 后 | `DiceRollStage`、`assets/card_demo/ui/dice/` | 1-2 秒，半透明叠到 Seedance 骰子镜头后 |
| 技能/卡牌 | Shot 11-13 | `assets/card_demo/ui/skills/`、攻击/防御牌 | 快切，不长停 UI |
| 奖励/归档 | Shot 14 前后 | `RewardPanel`、`ArchivePanel`、`assets/card_demo/ui/log/` | 1-3 秒，用印章声转场 |
| Boss 背景 | `boss_barn_king_pre.mp4` 结尾 | `bg_barn_king_chamber.png` | 从视频暗影硬切到战斗背景 |

如果后续要真正接入 Godot，建议新增一个轻量过场层，而不是把视频播放逻辑塞进战斗控制器：

```text
CutscenePlayer.tscn
- Control
  - VideoStreamPlayer
  - SkipHintLabel
  - FadeColorRect

职责：
- 播放指定 mp4。
- 完成后 emit cutscene_finished(cutscene_id)。
- 战斗/章节控制器只监听完成信号，再进入对话或遭遇。
```

这个实现不属于本轮任务；这里只记录接入边界。

## 08 P0 生成顺序

如果马上开始生成视频，优先级如下：

1. `intro_opening` 的收藏家 + 主角醒来。没有这段，循环和圣匣设定立不住。
2. `boss_barn_king_pre`。谷仓王负责影片压迫峰值，也最能体现“救济失败/胃囊/钥匙碎片”。
3. `encounter_empty_pre`。空腹者是观众理解“饥饿不是怪物皮肤”的第一证据。
4. `encounter_farmer_pre`。农夫把制度化饥饿落到执行者身上。
5. `ending_archive` 的圣匣归档 + 收藏家追问。给课堂展示一个完整闭环。
6. `encounter_scarecrow_pre`。重要，但在 90 秒极限版可缩短。
7. 骰子宏观镜头。若 Godot 骰子 UI 录屏稳定，可用 UI 插片先顶上。
8. 技能蒙太奇。优先用现有静态技能图标后期剪，不急着生成。

最小 90-120 秒成片包：

```text
intro_opening.mp4
encounter_empty_pre.mp4
encounter_farmer_pre.mp4
boss_barn_king_pre.mp4
ending_archive.mp4
Godot 收藏家对话/骰子/归档插片 6-10 秒
标题卡
```

## 09 制作检查清单

- 每个视频段都要有“最后 1 秒稳定构图”，方便硬切 Godot。
- 所有字幕、标题、UI 文案后期添加，不让 Seedance 生成文字。
- 空腹者：疲惫、麻木、等待救济；不要丧尸、恶魔、血口。
- 农夫：旧镰刀、登记牌、劳动执行者；不要死神镰刀、魔法镰刀。
- 稻草人：无腿，木桩/草束/破布支架；不要人腿，不要血腥恐怖片。
- 谷仓王：必须出现救济失败、谷仓胃囊、木梁、钥匙碎片；不要普通大怪。
- 画面整体低饱和，暗红只做点缀，不把血肉做成主视觉。
- Godot 插片只证明“这是可玩项目”，不要暴露长时间未完成动作帧。
