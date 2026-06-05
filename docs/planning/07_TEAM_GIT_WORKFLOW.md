# 三人团队 Git 协作流程

## 团队结构

| 成员 | 工作方式 | 主责任 | 主要文件 |
| --- | --- | --- | --- |
| 技术 A | Git | 核心玩法与代码结构 | `scripts/`, 拆分后的 `scenes/characters/`, `scenes/systems/` |
| 技术 B | Git | 关卡、HUD、表现、资产接入 | `scenes/levels/`, `scenes/ui/`, `assets/`, 数值接入 |
| 文案 C | 不直接用 Git | 文案、图鉴、Boss 台词、晶片文本 | 先交 Markdown 给负责人，再由技术或我整理进项目 |

## 分支规则

主分支：

- `main`：永远保持能打开、能运行。
- 只接收已经验证过的稳定集成结果，不直接承接个人分支的大段实验改动。

技术 A 分支：

- `feature/core-combat`
- 用于玩家、敌人、Boss、残骸系统、代码拆分。
- 当前由刘秉昂 / Codex 维护，是核心战斗和系统拆分的主工作分支。

技术 B 分支：

- `feature/level-hud`
- 用于房间、HUD、表现反馈、资产接入。
- 当前由金荣俊 / Codex 维护，是关卡、HUD、美术占位和试玩反馈的主工作分支。

集成分支：

- `feature/integration-vertical-slice`
- 用于把 `feature/core-combat` 和 `feature/level-hud` 的成果手工整合成可进 `main` 的评审版。
- 不建议把 `feature/level-hud` 直接合并进 `feature/core-combat`，也不建议把任意个人分支直接合并进 `main`。

美术迭代分支：

- `feature/art-iteration`
- 用于美术资产替换、比例调整、可读性测试、概念图轮次和 `.import` 导入配置。
- 不用于实现日志系统、战斗数值、敌人 AI 或房间流程。
- 详细规则见 `docs/planning/19_ART_ITERATION_BRANCH_PLAN.md`。

日志系统分支：

- `feature/log-fragment-system`
- 用于日志碎片掉落、拾取、归档、圣匣日志 UI 和第一故事拼接。
- 不和美术轮次混在一起；美术只提前准备日志碎片图标和圣匣 UI 概念图。
- 详细规则见 `docs/planning/20_LOG_FRAGMENT_SYSTEM_PLAN.md`。

临时修复：

- `fix/<short-name>`
- 只用于小 bug，例如 `fix/boss-phase-warning`。

## 每天开始工作

```bash
git checkout main
git pull
git checkout feature/core-combat
git merge main
```

技术 B 把最后一行换成：

```bash
git checkout feature/level-hud
git merge main
```

美术轮次把最后一行换成：

```bash
git checkout feature/art-iteration
git merge main
```

日志系统开发把最后一行换成：

```bash
git checkout feature/log-fragment-system
git merge main
```

## 每次提交前

1. 打开 Godot，确认项目能运行。
2. 如果改了功能、关卡、数值、文案、资产或项目结构，先更新 `CHANGELOG.md`。
3. 看自己改了哪些文件：

```bash
git status
git diff
```

4. 只提交自己负责的文件。
5. 提交信息写清楚做了什么：

```bash
git add <files>
git commit -m "Split player combat controller"
git push
```

## 文件边界

### 技术 A 优先负责

- `scripts/player/`
- `scripts/enemies/`
- `scripts/boss/`
- `scripts/systems/`
- `scenes/characters/`
- `scenes/bosses/`
- `scripts/main.gd` 中的玩家、敌人、Boss、胃囊、伤害、死亡和战斗节奏逻辑

### 技术 B 优先负责

- `scenes/levels/`
- `scenes/ui/`
- `assets/`
- `scripts/ui/`
- `scripts/levels/`
- `Communication.md`
- `docs/planning/11_JIN_RONGJUN_PLAYTEST_CHECKLIST.md`
- `docs/planning/12_JIN_RONGJUN_PLAYTEST_NOTES.md`
- `docs/planning/13_PIXEL_ART_ASSET_REQUEST.md`
- `docs/planning/14_THIRD_PARTY_ASSET_SOURCES.md`
- `scripts/main.gd` 中的 HUD 外观、危险区表现、房间提示和关卡可读性逻辑

### 需要先沟通再改

- `project.godot`
- `scenes/main.tscn`
- `scripts/main.gd`
- `docs/planning/05_BALANCE_TABLES.md`
- `scripts/systems/art_asset_registry.gd`

### 美术迭代优先负责

- `assets/concepts/`
- `assets/backgrounds/rooms/`
- `assets/portraits/`
- `assets/sprites/characters/`
- `assets/sprites/pickups/`
- `assets/sprites/ui/`
- `assets/vfx/`
- 所有对应 `.import` 文件
- `docs/planning/19_ART_ITERATION_BRANCH_PLAN.md`

### 日志系统优先负责

- `data/log_fragments/`
- `scripts/systems/log_fragment_database.gd`
- `scripts/systems/log_archive_runtime.gd`
- `scripts/ui/log_archive_panel.gd`
- `docs/planning/20_LOG_FRAGMENT_SYSTEM_PLAN.md`

当前原型还集中在 `scripts/main.gd`，所以两位技术如果都改了这个文件，最后必须手工集成。不能用“谁的版本覆盖谁的版本”的方式解决冲突。

## 当前集成策略

截至 2026-06-02，两个功能分支已经同时修改了 `scripts/main.gd`：

- `feature/core-combat` 已经把胃囊、玩家运行时、敌人运行时、攻击运行时和战斗数据拆到 `scripts/systems/`。
- `feature/level-hud` 已经推进 HUD 像素化、原创 SVG 图标、动态危险区前摇、房间清空喘息和试玩记录。

因此当前策略是：

1. `feature/core-combat` 可以先吸收 `feature/level-hud` 中低冲突的资料：`Communication.md`、`assets/sprites/ui/`、试玩文档、素材许可证文档。
2. `feature/core-combat` 暂不直接吸收 `feature/level-hud` 的 `scripts/main.gd`，因为这会覆盖核心系统拆分。
3. 后续创建 `feature/integration-vertical-slice`，以 `feature/core-combat` 为底，再手工移植金荣俊分支里 HUD、危险区预警、房间清空喘息和移动手感的有效逻辑。
4. 移植完成后必须运行 Godot 主场景，并更新 `CHANGELOG.md`。
5. 只有集成分支可稳定运行后，才合并进 `main`。

## 金荣俊分支内容处理规则

可以直接带入 core 或 main 的内容：

- `Communication.md`
- `assets/sprites/ui/*.svg`
- `docs/planning/11_JIN_RONGJUN_PLAYTEST_CHECKLIST.md`
- `docs/planning/12_JIN_RONGJUN_PLAYTEST_NOTES.md`
- `docs/planning/13_PIXEL_ART_ASSET_REQUEST.md`
- `docs/planning/14_THIRD_PARTY_ASSET_SOURCES.md`

需要手工移植的内容：

- `scripts/main.gd` 里的 HUD 像素化实现。
- `scripts/main.gd` 里的类摇杆移动。
- `scripts/main.gd` 里的农夫危险区前摇和清房喘息。

移植原则：

- 保留 `feature/core-combat` 的系统拆分。
- 将金荣俊分支的表现逻辑拆进更明确的 HUD、关卡或危险区模块。
- 不删除 `scripts/systems/` 下的核心运行时脚本。

## 文案交付方式

文案 C 不需要直接碰 Git。她可以交一个 Markdown 文件，格式如下：

```md
# 低语田野文案 第 1 版

## 收藏家开场

1. ...
2. ...

## 死亡回收

1. ...
2. ...

## 谷仓王

### 开场

1. ...

### 阶段二

1. ...

### 死亡

1. ...

## 神之胃囊记忆

1. ...

## 静默者晶片

1. ...
```

收到后，由技术负责人或我整理进：

- `docs/planning/03_NARRATIVE_COPY.md`
- 后续可转成 `resources/narrative/*.json`

## 合并规则

每次合并进 `main` 前必须满足：

- Godot 能打开主场景。
- 没有明显脚本报错。
- README 或对应策划文档已更新。
- `CHANGELOG.md` 已记录这次改动。
- 不包含无关大文件。
- 不覆盖别人正在做的文件。

当前推荐合并路径：

```bash
git checkout feature/core-combat
git pull
git checkout -b feature/integration-vertical-slice
git merge feature/core-combat
git checkout origin/feature/level-hud -- Communication.md assets docs/planning/11_JIN_RONGJUN_PLAYTEST_CHECKLIST.md docs/planning/12_JIN_RONGJUN_PLAYTEST_NOTES.md docs/planning/13_PIXEL_ART_ASSET_REQUEST.md docs/planning/14_THIRD_PARTY_ASSET_SOURCES.md
```

然后手工移植 `feature/level-hud` 的 `scripts/main.gd` 有效逻辑。确认 Godot 主场景可运行后，再进入：

```bash
git checkout main
git merge feature/integration-vertical-slice
git push
```

## 第一周建议节奏

| 天 | 技术 A | 技术 B | 文案 C |
| --- | --- | --- | --- |
| 1 | 拆分计划，创建 `Player` 结构 | 画房间布局草图 | 改收藏家和 Boss 台词 |
| 2 | 拆玩家移动/攻击 | HUD 草图和危险区表现 | 写死亡回收文本 |
| 3 | 拆敌人基类和空腹者 | 搭入口房和麦田占位 | 写敌人图鉴 |
| 4 | 拆饥民农夫/稻草人 | 搭灌溉渠和谷仓占位 | 写胃囊记忆 |
| 5 | 拆 Boss 阶段 | 接入文本和反馈 | 统一润色 |
| 6 | 联调 | 联调 | 试玩记录 |
| 7 | 合并评审版 | 合并评审版 | 文案二修 |
