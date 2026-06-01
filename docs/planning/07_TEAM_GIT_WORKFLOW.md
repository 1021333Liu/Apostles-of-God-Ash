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

技术 A 分支：

- `feature/core-combat`
- 用于玩家、敌人、Boss、残骸系统、代码拆分。

技术 B 分支：

- `feature/level-hud`
- 用于房间、HUD、表现反馈、资产接入。

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
- `scripts/systems/relic_system.gd`
- `scenes/characters/`
- `scenes/bosses/`

### 技术 B 优先负责

- `scenes/levels/`
- `scenes/ui/`
- `assets/`
- `scripts/ui/`
- `scripts/levels/`

### 需要先沟通再改

- `project.godot`
- `scenes/main.tscn`
- `scripts/main.gd`
- `docs/planning/05_BALANCE_TABLES.md`

当前原型还集中在 `scripts/main.gd`，所以拆分前两位技术不要同时大改这个文件。先由技术 A 做结构拆分，技术 B 同期做关卡布局文档、HUD 草图和资产准备。

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
