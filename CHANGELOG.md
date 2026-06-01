# 更新日志 / Changelog

这个文件记录项目每次有意义的更新。  
原则：代码可以告诉我们“哪里变了”，但这里要告诉我们“为什么变了”。

## 记录规则

每次提交前，如果改动属于以下任意一种，都要写一条：

- 新功能
- 玩法调整
- 数值调整
- 关卡变化
- 文案更新
- 美术/音效资产接入
- Bug 修复
- 项目结构变化
- 协作文档变化

格式：

```md
## YYYY-MM-DD

### 类型：一句话标题

- 负责人：
- 改动：
- 原因：
- 影响范围：
- 验证：
- 后续：
```

## 2026-06-01

### 核心战斗：抽出胃囊系统和战斗数据工厂

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `scripts/systems/god_stomach_relic.gd`，集中管理神之胃囊的击杀回血、受击闭合、溢血加伤和记忆晶片。
  - 新增 `scripts/systems/combat_data_factory.gd`，集中生成敌人与危险区数据。
  - 更新 `scripts/main.gd`，让主脚本只调度核心流程，不再直接维护胃囊计时和战斗数据模板。
- 原因：
  - 我们的 `feature/core-combat` 分支要先把战斗核心从单文件原型里拆出来，后续才能继续拆 `Player`、敌人、Boss 和房间控制器。
- 影响范围：
  - 核心战斗、神之胃囊残骸奖励、敌人/危险区生成入口。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 继续拆分 `Player`、`Enemy`、`BarnKing`、`RoomController`，但每次只拆一个可验证边界。

### 协作交接：新增文案与关卡 HUD 任务说明

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `docs/planning/08_NARRATIVE_HANDOFF_PROMPT.md`，用于交给文案同学或她的 Codex。
  - 新增 `docs/planning/09_LEVEL_HUD_HANDOFF.md`，明确关卡/HUD/表现同学先用占位资产推进，不等待正式美术。
  - 新增 `docs/planning/10_JIN_RONGJUN_LEVEL_HUD_TASK_CARD.md`，作为金荣俊拉取 `feature/level-hud` 后的个人开工任务卡。
  - 更新 `docs/planning/00_PRODUCTION_INDEX.md` 的文档入口。
- 原因：
  - 三人协作需要更具体的个人任务说明，避免“等资产”“等文案”“不知道先做什么”。
- 影响范围：
  - 团队任务分配、文案交付、关卡/HUD 工作流。
- 验证：
  - 新文档已加入制作索引。
- 后续：
  - 文案同学交付第一版 Markdown 后，整理进 `docs/planning/03_NARRATIVE_COPY.md`。
  - 关卡/HUD 同学在 `feature/level-hud` 分支推进占位布局和反馈。

### 项目初始化：低语田野垂直切片骨架

- 负责人：刘秉昂 / Codex
- 改动：
  - 创建 Godot 工程配置 `project.godot`。
  - 创建主场景 `scenes/main.tscn`。
  - 创建首版原型脚本 `scripts/main.gd`。
  - 实现无声圣匣、低语田野固定房间链、近战、敌人、危险区、谷仓王 Boss、神之胃囊反馈。
- 原因：
  - 先验证 5-8 分钟垂直切片能否成立，不提前展开十城邦全量。
- 影响范围：
  - 工程骨架、玩法原型、Demo 执行规格。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误、无警告。
- 后续：
  - 拆分 `Player`、敌人、Boss、HUD、残骸系统。
  - 调整近战手感和 Boss 阶段节奏。

### 策划拆分：建立分项制作文档

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `docs/planning/00_PRODUCTION_INDEX.md`。
  - 新增美术、关卡、文案、道具、数值、任务拆分文档。
  - 新增 `docs/planning/07_TEAM_GIT_WORKFLOW.md`，明确三人团队分支和文件边界。
- 原因：
  - 三人协作需要明确分工，避免所有内容堆在一个 README 或一个脚本里。
- 影响范围：
  - 制作流程、任务分配、Git 协作。
- 验证：
  - README 已能指向分项策划入口。
- 后续：
  - 每次功能、文案、数值、关卡更新都同步记录到本文件。

### README 改写：项目首页与开发者介绍

- 负责人：刘秉昂 / Codex
- 改动：
  - 将 README 改成更幽默的 GitHub 项目首页。
  - 增加世界观介绍、低语田野介绍、当前可玩内容、开发状态和开发者分工。
  - 增加 `Coding：Codex` 署名。
- 原因：
  - GitHub 首页需要让外部读者快速理解“这是什么游戏”和“谁在做”。
- 影响范围：
  - `README.md`。
- 验证：
  - 已检查 Markdown 排版。
- 后续：
  - 后续每次可玩版本变化时，同步更新 README 的当前状态。
