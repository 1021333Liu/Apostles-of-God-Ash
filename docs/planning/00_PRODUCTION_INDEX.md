# 《神烬使徒》低语田野垂直切片制作索引

## 制作原则

当前阶段只服务一个目标：做出 5-8 分钟可玩的低语田野垂直切片，证明“用神之残骸拼装自我”的叙事卡牌骰子决斗体验成立。

本阶段不展开十城邦全量内容，不做复杂随机地图，不做大规模装备库，不做完整结局线。所有新增内容都必须能回答：

> 它是否让低语田野这一轮更好玩、更好懂、更像《神烬使徒》？

## 当前困境与转向

旧实时动作原型已经能跑，但试玩后暴露出一个核心问题：它更像“套着低语田野文案的动作 Demo”，还没有让世界观、日志碎片和战斗规则拧成同一个主循环。

主要问题：

- 实时近战和危险区有基础可玩性，但项目辨识度不够强。
- 文案、胃囊、圣匣、日志碎片更像战斗外层反馈，没有真正决定玩家每回合如何选择。
- 击杀敌人后的“采样 / 归档 / 理解故事”还没有成为玩家继续推进的主要动力。

因此从 `28_CARD_DICE_PIVOT_DESIGN.md` 开始，当前主方向转为卡牌骰子决斗：

```text
场景遇见 NPC
-> 对话失败
-> 攻击 / 防御行动选择
-> 骰子对抗
-> 胜利后获得故事与日志碎片
-> 三选一奖励
```

旧动作原型暂时保留，不删除；它继续作为美术、世界观、敌人身份和反馈方式的素材来源。

## 文档入口

| 文档 | 面向对象 | 用途 |
| --- | --- | --- |
| `01_ART_DIRECTION.md` | 美术、UI、特效 | 统一视觉关键词、资产清单和首版占位标准 |
| `02_LEVEL_DESIGN.md` | 关卡、程序、策划 | 固定房间链、每房间目标、敌人配置和节奏 |
| `03_NARRATIVE_COPY.md` | 文案、叙事、策划 | 开场、死亡、Boss、残骸、晶片文本池 |
| `04_ITEMS_RELICS.md` | 系统策划、程序、数值 | 道具、残骸、武器和后续扩展规则 |
| `05_BALANCE_TABLES.md` | 数值、程序、测试 | 玩家、敌人、Boss、房间、奖励首版数值 |
| `06_TASK_BREAKDOWN.md` | 全组 | 按里程碑拆任务、验收标准和优先级 |
| `07_TEAM_GIT_WORKFLOW.md` | 程序、协作负责人 | 三人 Git 分支、文件边界和集成规则 |
| `08_NARRATIVE_HANDOFF_PROMPT.md` | 文案、文案 Codex | 文案同学第一批文本交付说明 |
| `09_LEVEL_HUD_HANDOFF.md` | 关卡/HUD 技术 | 关卡表现同学的占位资产、HUD 和反馈任务 |
| `10_JIN_RONGJUN_LEVEL_HUD_TASK_CARD.md` | 金荣俊 | 拉取 `feature/level-hud` 后优先阅读的个人任务卡 |
| `11_JIN_RONGJUN_PLAYTEST_CHECKLIST.md` | 金荣俊、测试 | 关卡/HUD/表现试玩检查清单 |
| `12_JIN_RONGJUN_PLAYTEST_NOTES.md` | 全组 | 试玩问题记录和后续改动依据 |
| `13_PIXEL_ART_ASSET_REQUEST.md` | 美术、HUD | 像素占位和正式资产需求 |
| `14_THIRD_PARTY_ASSET_SOURCES.md` | 美术、程序 | 第三方素材来源、许可证和接入规则 |
| `15_EXPERT_REVIEW_BRIEF.md` | 业内专家、导师、全组 | 项目介绍、美术方案、日志系统方案和评审问题 |
| `16_ART_ASSET_FORMAT_SPEC.md` | 美术、程序 | Godot 2D 正式美术资产格式、尺寸、帧数和接入规格 |
| `17_IMAGE2_ART_GENERATION_PLAN.md` | 美术、image2 操作者 | 斜俯视房间制美术生成提示词、负面约束和首批生成清单 |
| `18_ART_INTEGRATION_GUIDE.md` | 美术、程序 | 正式 PNG 资产到达后的仓库路径、自动加载和 Godot 接入方式 |
| `19_ART_ITERATION_BRANCH_PLAN.md` | 美术、程序、协作负责人 | 美术轮次分支、修改边界、可读性问题和验收标准 |
| `20_LOG_FRAGMENT_SYSTEM_PLAN.md` | 文案、程序、系统策划 | 日志碎片掉落、归档、圣匣 UI 和第一故事拼接的 MVP 计划 |
| `28_CARD_DICE_PIVOT_DESIGN.md` | 策划、程序、UI、文案 | 从实时动作战斗转向卡牌骰子决斗的核心规则、首关数值、奖励和 Godot MVP 方案 |
| `29_CARD_DEMO_ART_BRIEF.md` | 画师、美术负责人、程序接入 | 卡牌骰子 Demo 的 P0/P1 美术资产清单、格式、交付目录和画师任务单 |
| `32_NANOBANANA_CARD_COMBAT_ART_PROMPTS.md` | 美术处理、生成线程、真人画师、程序接入 | 新版攻击/重击/蓄防/大招战斗所需角色动作、卡牌、骰子、FX 的 nanobanana / image-to-image 提示词、负面提示词和接入规格 |
| `33_CURRENT_ASSET_SORT_AND_I2I_NEXT_STEPS.md` | 美术处理、生成线程、真人画师、程序接入 | 当前确定采用资产分级、收藏家半身像清洁、角色动作、四张行动牌、骰子、FX 的 i2i 执行顺序与验收标准 |

根目录的 `Communication.md` 用于记录尚未完成的试玩意见、待确认事项和团队沟通。已经落地的修改必须写入 `CHANGELOG.md`。

## 当前版本形态

当前 Godot 原型在 `res://scripts/main.gd` 中以单脚本方式实现，记录了实时动作垂直切片的第一阶段尝试。自 `28_CARD_DICE_PIVOT_DESIGN.md` 建立后，低语田野首版可玩目标转向卡牌骰子决斗；旧动作原型暂时保留为美术、文本、反馈和系统素材来源，不再作为主玩法方向。

卡牌骰子版本进入实现前，建议优先新增独立演示场景与数据文件：

1. `CardDuelDemo` 独立场景。
2. `CardDuelController` 决斗流程控制器。
3. `DiceResolver` 骰子和攻防结算。
4. `CardDatabase` 基础卡牌数据。
5. `EnemyIntentRuntime` 敌人行动序列。
6. `CardHandPanel`、`DiceResultPanel`、`RewardPanel` 等 UI 组件。

旧动作原型如果继续维护，建议逐步拆分为：

1. `Player` 独立场景。
2. `EnemyBase` 与三类敌人场景。
3. `BarnKing` Boss 独立场景。
4. `RoomController` 固定房间控制器。
5. `RelicSystem` 残骸系统。
6. `HUD` 独立 CanvasLayer。

## 第一阶段完成定义

- 玩家能从无声圣匣进入低语田野。
- 至少 4 个战斗房 + 1 个精英房 + 1 个 Boss 房。
- 至少 3 种普通/精英敌人。
- 谷仓王有 3 个可感知阶段。
- 神之胃囊同时提供收益和代价。
- 死亡后回圣匣并触发不同文本。
- 击败 Boss 后获得记忆文本。
- 玩家能明确理解：自己在吸收别人的执念来构筑自己。
- 击杀敌人能获得日志碎片，并在圣匣中查看和拼出低语田野第一段故事。
