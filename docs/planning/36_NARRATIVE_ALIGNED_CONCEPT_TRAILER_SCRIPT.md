# 《神烬使徒》概念片叙事对齐版脚本

版本：2026-06-30  
用途：在 34/35 号概念片方案基础上，按正式叙事文本池与世界观规划重排旁白、字幕、镜头功能和 Godot 演出切分。  
叙事优先级：`03_NARRATIVE_COPY.md` > `神烬使徒_项目世界观与垂直切片规划.md` > `low_whispering_field.json` > `34_CONCEPT_TRAILER_STORYBOARD_SEEDANCE.md` > `35_CONCEPT_TRAILER_RUNTIME_CUTS_SEEDANCE.md`。

## 01 已吸收的叙事来源

| 来源 | 已吸收内容 | 用法 |
|---|---|---|
| `docs/planning/03_NARRATIVE_COPY.md` | 收藏家开场、进入田野、死亡回收、房间短句、敌人图鉴、神之胃囊记忆碎片、谷仓王视角、头顶气泡 | 旁白、字幕、镜头结尾台词、Boss 悲剧动机 |
| `docs/神烬使徒_项目世界观与垂直切片规划.md` | 无韵回响、收藏家定位、低语田野暴食规则、神之胃囊作为残骸/人格碎片、死亡回圣匣循环 | 镜头世界观功能标注和演出边界 |
| `data/encounters/low_whispering_field.json` | 当前 Godot 可用的遭遇文本、敌人顺序、对话、奖励名、日志碎片 | 游戏内演出结尾衔接和可直接复用短句 |
| `docs/planning/34_CONCEPT_TRAILER_STORYBOARD_SEEDANCE.md` | 17 镜头结构、Seedance 风格边界、课堂概念片节奏 | 镜头骨架和生成提示词基础 |
| `docs/planning/35_CONCEPT_TRAILER_RUNTIME_CUTS_SEEDANCE.md` | 课堂版/Godot 演出版切分、P0 生成顺序、音效 cue | 执行拆分基础 |

## 02 文案来源标记

下文用以下标记说明旁白和字幕来源：

- `[03直引]`：直接来自 `03_NARRATIVE_COPY.md` 或与其同步的 `low_whispering_field.json`。
- `[03改写]`：基于 `03_NARRATIVE_COPY.md` 压缩、重组或改写。
- `[世界观]`：来自世界观规划，主要服务无韵回响、收藏家、残骸、低语田野规则。
- `[概念片新增]`：为预告片剪辑新增的连接句，保持短句、档案感，不写华丽诗歌。

## 03 最终旁白稿

这一版旁白不再用“宏大解释”，而是像收藏家、档案、死亡回收记录和残骸记忆拼起来的片段。收藏家保持可信，但有不完全安全的记录感；不剧透其最终真实目的。

### 完整版 140-160 秒

```text
你醒了。很好，这具身体还没有拒绝你。 [03直引]
无声圣匣会把你带回来。痛会过去，留下来的东西更有用。 [03直引]

第一站是低语田野。 [03直引]
那里以前是粮仓，现在更像一张没合上的嘴。 [03直引]

低语田野听不懂饱。 [03直引]
它只听得懂再多一点。 [03直引]

最后的人拿不到粮，也轮不到被正式记名。 [03直引]
空腹者不是第一个被吃掉的人。 [03直引]
他只是第一个被名单忘掉的人。 [03直引]

天亮就下田。 [03直引]
名单别乱。 [03直引]
他不觉得自己在杀人。 [03直引]
他只是害怕哪一天没有人继续照常。 [03直引]

第一年绑的是草。 [03直引]
第二年绑的是偷粮者的衣服。 [03直引]
第三年里面开始有骨头。 [03直引]
它不追远，因为它相信逃出去的人迟早会回来。 [03直引]

谷仓王在里面。 [03直引]
他曾经让很多人活过冬天，所以很多人愿意替他闭嘴。 [03直引]

他们说我是王。 [03直引]
那时我只是拿着粮仓钥匙的人。 [03直引]
谷仓王献出自己的胃，是为了让献祭到他为止。 [03直引]
田地接受了他，也学会了通过他继续索要。 [03直引]

把神之胃囊带回来。 [03直引]
它不干净，但很适合活下去。 [03直引]

每一次掷骰，都是一次采样。 [概念片新增]
每一次失败，都会被圣匣保存。 [概念片新增]

胃囊贴着肋骨轻轻收缩，像在学习等待。 [03直引]
胃囊彻底张开。它认出了同类，也认出了饥荒。 [03直引]

这一次，你带回了什么？ [概念片新增]
```

### 105-120 秒课堂短版

```text
你醒了。很好，这具身体还没有拒绝你。 [03直引]
第一站是低语田野。那里以前是粮仓，现在更像一张没合上的嘴。 [03直引]

低语田野听不懂饱。它只听得懂再多一点。 [03直引]

最后的人拿不到粮，也轮不到被正式记名。 [03直引]
天亮就下田。名单别乱。 [03直引]
第一年绑的是草。第三年里面开始有骨头。 [03直引]

他们说我是王。那时我只是拿着粮仓钥匙的人。 [03直引]
谷仓王献出自己的胃，是为了让献祭到他为止。 [03直引]

把神之胃囊带回来。它不干净，但很适合活下去。 [03直引]
每一次掷骰，都是一次采样。 [概念片新增]
每一次失败，都会被圣匣保存。 [概念片新增]

这一次，你带回了什么？ [概念片新增]
```

### 字幕上屏版

字幕只放短句，不解释百科：

```text
这具身体还没有拒绝你。
那里以前是粮仓，现在更像一张没合上的嘴。
低语田野听不懂饱。
最后的人轮不到被正式记名。
名单别乱。
那时我只是拿着粮仓钥匙的人。
把神之胃囊带回来。
每一次掷骰，都是一次采样。
每一次失败，都会被圣匣保存。
这一次，你带回了什么？
```

## 04 课堂概念片分镜：叙事对齐版

| # | 时长 | 画面 | 旁白/字幕 | 来源 | 服务的世界观 |
|---|---:|---|---|---|---|
| 01 | 6s | 黑场，旧纸纹理，圣匣锁扣被烛光照亮 | 你醒了。很好，这具身体还没有拒绝你。 | [03直引] | 无韵回响是可回收容器；圣匣是复活机制 |
| 02 | 7s | 圣匣打开，主角从匣内醒来，白发、阴影脸、破损白蓝衣 | 无声圣匣会把你带回来。痛会过去，留下来的东西更有用。 | [03直引] | 收藏家是医生/研究者/引导者，不是早期反派 |
| 03 | 7s | 收藏家半身，档案、样本瓶、脏银工具 | 第一站是低语田野。 | [03直引] | 收藏家派遣采样，不剧透真实目的 |
| 04 | 9s | 低语田野远景，田垄像胃壁，远处谷仓像没合上的嘴 | 那里以前是粮仓，现在更像一张没合上的嘴。 | [03直引] | 低语田野从粮仓/丰收反转为胃囊 |
| 05 | 7s | 麦穗、名单、空碗、旧发放纸签、登记牌依次压到旧纸上 | 低语田野听不懂饱。它只听得懂再多一点。 | [03直引] | 暴食回响；社会规则是喂饱土地 |
| 06 | 8s | 空腹者抱碗站在队伍末尾，队伍尽头没有粮 | 最后的人拿不到粮，也轮不到被正式记名。 | [03直引] | 空腹者是等待救济失败，不是丧尸 |
| 07 | 7s | 空碗近景，碗沿有啃痕，队尾碎纸被风吹走 | 空腹者不是第一个被吃掉的人。他只是第一个被名单忘掉的人。 | [03直引] | 名单和登记成为吞噬机制 |
| 08 | 8s | 农夫登记执行者走在田垄，旧镰刀低垂，脏银牌在胸前 | 天亮就下田。名单别乱。 | [03直引] | 农夫是制度执行者，不是纯恶人 |
| 09 | 7s | 农夫把名字刻/划进脏银登记牌，不显示可读文字 | 他不觉得自己在杀人。他只是害怕哪一天没有人继续照常。 | [03直引] | 普通居民参与维持田野规则 |
| 10 | 8s | 稻草人：木桩、草束、破布支架，无人腿，血麦边界 | 第一年绑的是草。第二年绑的是偷粮者的衣服。 | [03直引] | 边界与恐惧自动化 |
| 11 | 6s | 镜头绕稻草人半圈，破布中有骨影但不血腥 | 第三年里面开始有骨头。 | [03直引] | 稻草人不追远，守边界 |
| 12 | 10s | 谷仓外景，仓门半开，里面没有粮声，门缝里有胃囊组织 | 谷仓王在里面。他曾经让很多人活过冬天，所以很多人愿意替他闭嘴。 | [03直引] | 谷仓王“曾经合理，如今怪物” |
| 13 | 8s | 老钥匙、开仓记忆、孩子们围着一个普通男人 | 他们说我是王。那时我只是拿着粮仓钥匙的人。 | [03直引] | Boss 曾是救人者，不是普通恶魔王 |
| 14 | 9s | 谷仓内室，木梁和胃囊融合，钥匙碎片、空碗、旧发放纸签散落 | 谷仓王献出自己的胃，是为了让献祭到他为止。 | [03直引] | 神之胃囊是悲剧残骸 |
| 15 | 6s | 田地肉质纹理沿谷仓梁柱扩散 | 田地接受了他，也学会了通过他继续索要。 | [03直引] | 田野通过王继续索要 |
| 16 | 8s | Godot 插片：骰子、技能、敌人、日志快速切 | 每一次掷骰，都是一次采样。 | [概念片新增] | 骰子不是桌游趣味，而是圣匣取证 |
| 17 | 7s | 神之胃囊意象贯穿：田垄、谷仓、骰子、日志碎片一一闪回 | 把神之胃囊带回来。它不干净，但很适合活下去。 | [03直引] | 胃囊是力量、代价、人格侵蚀 |
| 18 | 8s | 圣匣归档，日志碎片入匣，失败记录盖章 | 每一次失败，都会被圣匣保存。 | [概念片新增] | 死亡回收推进叙事 |
| 19 | 6s | 快切：主角一次次倒在田里、谷仓门口、血麦边界；每次黑场后都在收藏家面前的圣匣中重新睁眼 | 无旁白，只留呼吸、倒地、锁扣和纸页声 | [世界观/概念片新增] | 把“死亡回收”变成画面证据 |
| 20 | 8s | 收藏家近景，平静看向镜头 | 这一次，你带回了什么？ | [概念片新增] | 收藏家不完全安全，但不剧透；循环追问 |
| 21 | 5s | 标题卡 | 无旁白，只留标题 | [概念片新增] | 收束，接 Demo |

## 05 游戏内演出版切分：叙事对齐版

### intro_opening.mp4

建议时长：24-30 秒。  
接入位置：游戏启动/章节开始后，接收藏家 intro 对话。  
包含镜头：01-04。  
世界观功能：建立无韵回响的“身体/容器”状态，收藏家作为可信引导者，圣匣作为回收机制。

旁白/字幕：

```text
你醒了。很好，这具身体还没有拒绝你。 [03直引]
无声圣匣会把你带回来。痛会过去，留下来的东西更有用。 [03直引]
第一站是低语田野。那里以前是粮仓，现在更像一张没合上的嘴。 [03直引]
```

Seedance prompt：

```text
16:9 cinematic opening for a dark rural fantasy game, inside a sacred casket and archive room, old paper texture, dirty silver lock, pale white-haired protagonist wakes in cold light, shadowed face, damaged white and blue robe, the Collector appears as a calm doctor archivist with old documents and a glass sample bottle, then a dead rural field appears like a granary transformed into an unclosed mouth, restrained slow push, dusty air, low saturation, no readable generated text, no anime, no cyberpunk, no high saturation, no modern laboratory, no villain expression
```

结尾接 Godot：停在收藏家半身正面，硬切 `bg_silent_casket_collector_intro.png`，继续显示同源台词：“先别急着要名字。低语田野会给所有东西登记，名字在那里可能会被吃掉哦。”

### field_reveal.mp4

建议时长：14-18 秒。  
接入位置：收藏家 intro 后、玩家进入田野前；课堂片可接在开场后。  
包含镜头：04-05。  
世界观功能：把低语田野从“粮仓/丰收”反转成“没合上的嘴/胃囊”。

旁白/字幕：

```text
低语田野听不懂饱。它只听得懂再多一点。 [03直引]
别被庄稼骗了。长得越好，下面埋的东西越多。 [03直引]
```

Seedance prompt：

```text
wide cinematic reveal of Low Whispering Field, once a granary and farmland but now shaped like an unclosed mouth and stomach folds, dry wheat rows bend like intestinal paths, old harvest signs with hidden registry marks but no readable text, empty bowls and old supply paper slips half buried in mud, gray sky, cold rural silence, low saturation, restrained lateral tracking, old paper and dirty silver accents, subtle dark red flesh only, no gore, no fantasy magic glow
```

结尾接 Godot：停在田野入口远景，接 `bg_card_field_entrance.png` 或首个探索背景。

### encounter_empty_pre.mp4

建议时长：16-20 秒。  
接入位置：空腹者首次遭遇前。  
包含镜头：06-07。  
世界观功能：空腹者是等待救济失败与被名单忘掉的结果，不是普通丧尸。

旁白/字幕：

```text
最后的人拿不到粮，也轮不到被正式记名。 [03直引]
空腹者不是第一个被吃掉的人。他只是第一个被名单忘掉的人。 [03直引]
```

Seedance prompt：

```text
cinematic pre-encounter scene for the Empty One, a relief line in a dead rural field with no food at the end, thin starving rural figure holding an empty bowl at the very last place in line, tired and numb rather than zombie, old rag clothing, gnawed bowl rim, queue scrap paper and old supply paper slip in the mud, slow pull back from empty bowl to full body, low saturation, no demon features, no blood, no horror exaggeration, no readable text
```

结尾接 Godot：停在空腹者抱碗 3/4 全身，接 `bg_empty_stomach_first_enemy.png` 或 `bg_empty_stomach_queue.png`。可直接接 JSON 短句：“一点就好。”、“碗呢？谁偷了我的碗。”

### encounter_farmer_pre.mp4

建议时长：14-18 秒。  
接入位置：农夫登记执行者首次遭遇前。  
包含镜头：08-09。  
世界观功能：农夫是稳定、重复、公文化的执行者；他害怕没有人继续照常，不是邪恶表情。

旁白/字幕：

```text
天亮就下田。名单别乱。 [03直引]
他不觉得自己在杀人。他只是害怕哪一天没有人继续照常。 [03直引]
```

Seedance prompt：

```text
cinematic pre-encounter shot of the Famine Farmer Registrar, dry field rows, worn rural work clothes, old practical sickle held low, dirty silver registry tag, he repeats field work like an official routine, sowing, patrolling, harvesting, registering, calm tired expression, not evil grin, not grim reaper, not magical, no glowing scythe, low angle slow push in, mud and dry wheat, old paper and dirty silver, no readable text
```

结尾接 Godot：旧镰刀和脏银登记牌靠近镜头，接 `bg_farmer_field_register.png`。可直接接 JSON 短句：“名单别乱。孩子还在田边等我。”、“规矩在这。”

### encounter_scarecrow_pre.mp4

建议时长：14-18 秒。  
接入位置：饥饿稻草人首次遭遇前。  
包含镜头：10-11。  
世界观功能：稻草人是边界和恐惧自动化；必须无腿，避免血腥恐怖片化。

旁白/字幕：

```text
第一年绑的是草。第二年绑的是偷粮者的衣服。第三年里面开始有骨头。 [03直引]
它不追远，因为它相信逃出去的人迟早会回来。 [03直引]
```

Seedance prompt：

```text
cinematic pre-encounter shot of the Hungry Scarecrow at the blood-wheat boundary, no human legs, lower body is wooden stake, straw bundle and torn cloth support, first-year straw, second-year stolen clothing, faint bone shapes inside by the third year but restrained and not bloody, it stands as an automated border command rather than a monster, wind moves torn cloth, slow half-circle camera movement, low saturation rural dread, no gore, no screaming face, no human legs
```

结尾接 Godot：停在无腿支架和血麦边界，接 `bg_scarecrow_blood_wheat.png`。可直接接 JSON 短句：“名字留下。”、“站好。”

### boss_barn_king_pre.mp4

建议时长：24-32 秒。  
接入位置：谷仓王战前。  
包含镜头：12-15。  
世界观功能：谷仓王是“曾经合理，如今怪物”的悲剧核心；必须保留救济失败、钥匙、胃囊、木梁证据。

旁白/字幕：

```text
谷仓王在里面。他曾经让很多人活过冬天，所以很多人愿意替他闭嘴。 [03直引]
他们说我是王。那时我只是拿着粮仓钥匙的人。 [03直引]
谷仓王献出自己的胃，是为了让献祭到他为止。 [03直引]
田地接受了他，也学会了通过他继续索要。 [03直引]
```

Seedance prompt：

```text
cinematic boss prelude from hungry barn exterior into the Barn King chamber, old rural barn once used as a relief granary, no crown at first, memory of a man holding a barn key while children call him uncle, then transition to failed relief evidence: empty bowls, old supply paper slips, dirty registry book, broken barn key fragments, wooden beams fused with restrained stomach-like sacs, the Barn King silhouette sits inside as a warehouse that learned to eat, tragic not purely evil, slow camera through door crack into darkness, low saturation, old paper and dirty silver, no demon throne, no excessive gore, no readable generated text
```

结尾接 Godot：停在巨大谷仓暗影和钥匙碎片，接 `bg_barn_king_chamber.png`。可直接接 JSON 短句：“轻一点。田刚睡下，别又把饥荒吵醒。”、“他们说我是王。那时我只是拿着粮仓钥匙的人。”

### god_stomach_mechanic.mp4

建议时长：12-18 秒。  
接入位置：Boss 前后、残骸获得前、课堂片机制段。  
包含镜头：16-17。  
世界观功能：神之胃囊不是技能图标，而是人格碎片/残骸；力量伴随代价和侵蚀。

旁白/字幕：

```text
把神之胃囊带回来。它不干净，但很适合活下去。 [03直引]
胃囊贴着肋骨轻轻收缩，像在学习等待。 [03直引]
胃囊彻底张开。它认出了同类，也认出了饥荒。 [03直引]
```

Seedance prompt：

```text
cinematic montage showing the God Stomach relic as a personality shard, not a simple skill icon: subtle dark red stomach mark under the protagonist ribs, sacred casket log fragment reacting, old bone and dirty silver D20 slowly rotating in the center of frame, barn stomach chamber echo, the same stomach motif links field rows, barn beams, rotating die and archive casket, restrained body-horror, low saturation, old paper, dirty silver, no glowing fantasy magic, no mobile UI, no excessive gore
```

结尾接 Godot：接骰子 UI、奖励面板或残骸获取提示；文本应短，不超过两行。

### ending_archive.mp4

建议时长：26-34 秒。  
接入位置：死亡回收、章节完成、课堂片结尾。  
包含镜头：18-21。  
世界观功能：死亡回收不是失败惩罚，而是采样、归档、人格侵蚀推进。

旁白/字幕：

```text
每一次失败，都会被圣匣保存。 [概念片新增]
这一次，你带回了什么？ [概念片新增]
```

Seedance prompt：

```text
top-down archive ritual, a torn log fragment and failed recovery record placed into a sacred casket, dirty silver lock, wax seal, old paper, then rapid montage of the protagonist falling again and again: collapsing in a dead field, falling near a barn door, dropping at the blood-wheat boundary, each fall cuts to black and reopens inside the sacred casket before the calm Collector, recovered sample loop, breathing, paper dust, lock sounds, quiet unease but not villain reveal, final close-up of the Collector looking calmly into camera and asking silently, low saturation, restrained camera, no readable generated text, no gore
```

结尾接 Godot：课堂概念片用收藏家近景追问作为最终情绪点；游戏内失败回收时，可在视频结束后接 `03_NARRATIVE_COPY.md` 死亡回收句：“回来了。第一次死在田里的人，通常还会相信自己只是运气不好。”

## 06 P0 生成顺序：叙事对齐版

1. `intro_opening.mp4`：必须先有“这具身体/无声圣匣/没合上的嘴”，否则主角和地图关系不成立。
2. `boss_barn_king_pre.mp4`：必须建立谷仓王曾经救人、持钥匙、献胃、失败变怪物。
3. `encounter_empty_pre.mp4`：最短路径解释“怪物不是丧尸，是救济失败后的队尾”。
4. `encounter_farmer_pre.mp4`：解释普通居民也维持制度，“照常下田”比邪恶表情更可怕。
5. `ending_archive.mp4`：让课堂片有完整死亡回收、倒地快切、圣匣重生和收藏家追问。
6. `god_stomach_mechanic.mp4`：把神之胃囊从战斗机制提升为人格碎片。
7. `encounter_scarecrow_pre.mp4`：补齐边界和恐惧自动化。
8. Godot 插片：收藏家对话、骰子、奖励、归档，作为可玩性证明。

## 07 不能越界的点

- 收藏家不能早早写成反派。他可以冷静、记录、过分专业，但不能露出“幕后黑手”姿态。
- 不要说主角是“新神容器”的真相，只用“这具身体”“样本”“圣匣会带你回来”暗示。
- 谷仓王不能是纯坏 Boss。必须保留“开仓、救人、持钥匙、献胃、失败”的因果。
- 空腹者不要丧尸化。核心是队尾、空碗、没有正式记名。
- 农夫不要死神化。核心是照常、登记、规矩、公文化执行。
- 稻草人不要血腥化。核心是无腿支架、边界、偷粮恐惧。
- 神之胃囊不要只做技能图标。它要在田垄、谷仓、骰子、日志、主角肋骨纹理之间反复出现。
