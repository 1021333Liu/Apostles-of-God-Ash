# 金荣俊任务卡：关卡 / HUD / 表现

这份是给金荣俊的开工文件。  
拉到 `feature/level-hud` 分支后，先读这份，再读 `09_LEVEL_HUD_HANDOFF.md`。

## 你现在负责什么

你负责让当前原型从“能跑”变成“玩家看得懂、队友测得出、项目能交付”。

你不负责重写核心战斗。  
你不需要等正式美术。  
你先用占位图形和简单 UI 把关卡、HUD、反馈跑通。

## 先执行这些 Git 命令

第一次拉项目：

```bash
git clone git@github.com:1021333Liu/Apostles-of-God-Ash.git
cd Apostles-of-God-Ash
git checkout feature/level-hud
```

每天开工前：

```bash
git checkout main
git pull
git checkout feature/level-hud
git merge main
```

每天收工前：

```bash
git status
git add <你改过的文件>
git commit -m "Update level HUD feedback"
git push
```

如果你改了关卡、HUD、表现、资产目录，提交前必须更新 `CHANGELOG.md`。

## 第一周不要碰这些

除非先和刘秉昂确认，否则不要大改：

- `scripts/main.gd`
- `project.godot`
- `scenes/main.tscn`

原因：当前核心玩法还集中在 `scripts/main.gd`，刘秉昂会先拆核心战斗结构。你现在直接大改这个文件，很容易冲突。

## 你第一阶段要做的 4 件事

### 1. 建占位资产目录

先建立这些目录：

```text
assets/
  sprites/
    characters/
    enemies/
    bosses/
    environment/
    ui/
  audio/
    sfx/
    music/
```

目录里可以先放 `.gitkeep`，不用等正式图片。

完成标准：

- 美术以后知道文件该放哪里。
- 程序以后接资源不用重新猜路径。

### 2. 做 HUD 草图或占位实现

HUD 至少要有：

- 当前房间名。
- 玩家 HP。
- 神之胃囊状态：可吞噬 / 闭合中 / 溢血刃。
- 当前目标：清怪 / 进入下一房间 / 击败 Boss。
- 交互提示：E / Enter。

完成标准：

- 玩家一眼知道自己现在要做什么。
- 胃囊能不能回血必须清楚。
- HUD 不挡玩家和敌人。

如果现在不方便直接改 Godot 场景，就先在 `docs/planning/` 下写 HUD 草图说明，或者提交截图/草图。

### 3. 做房间布局占位

先做这三个重点房间：

1. 低语田野入口。
2. 血肉麦田。
3. 谷仓王胃室。

占位规则：

- 玩家：银白。
- 普通敌人：棕红。
- 远程敌人：黄褐。
- Boss：大块暗红。
- Boss 胃囊弱点：亮红。
- 危险区：半透明红色，并加边缘提示。
- 出口/下一房间提示：金色或银色。

完成标准：

- 不看说明也知道哪里危险。
- 不会把装饰误认为伤害区。
- Boss 阶段变化要比普通敌人更显眼。

### 4. 强化战斗反馈

优先做这些反馈：

- 攻击弧线。
- 受击闪烁。
- 伤害数字或短文本。
- 击杀回血提示。
- 胃囊闭合提示。
- Boss 阶段变化提示。

完成标准：

- 玩家知道自己有没有打中。
- 玩家知道自己为什么掉血。
- 玩家知道 Boss 进入了新阶段。

## 本周交付标准

本周你交付这些就算完成：

- `feature/level-hud` 分支能正常打开 Godot 项目。
- 至少建好资产目录。
- 至少完成 HUD 信息层级设计或占位实现。
- 至少完成 3 个重点房间的布局占位方案。
- 至少有 2 种战斗反馈比当前版本更清楚。
- `CHANGELOG.md` 有你的更新记录。

## 你可以先不做

- 正式美术。
- 完整音效。
- 完整 UI 皮肤。
- 十城邦地图。
- 随机地图。
- Boss 复杂新技能。

先把“玩家看得懂”做好。

## 相关文档

- `docs/planning/09_LEVEL_HUD_HANDOFF.md`
- `docs/planning/02_LEVEL_DESIGN.md`
- `docs/planning/01_ART_DIRECTION.md`
- `docs/planning/05_BALANCE_TABLES.md`
- `CHANGELOG.md`
