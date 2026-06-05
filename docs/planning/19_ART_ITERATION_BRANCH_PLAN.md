# 美术迭代分支计划

## 目标

当前美术资产已经进入可玩版，但试玩反馈显示风格、比例、可读性和动作表现还需要多轮调整。

从现在开始，美术资产修改不直接在 `main` 上试错。美术轮次统一放到：

```text
feature/art-iteration
```

这个分支只承担“美术验证”和“资产替换”任务。确认效果稳定后，再通过一次集成提交进入 `main`。

## 分支边界

### 可以修改

- `assets/concepts/`
- `assets/backgrounds/rooms/`
- `assets/portraits/`
- `assets/sprites/characters/`
- `assets/sprites/pickups/`
- `assets/sprites/ui/`
- `assets/vfx/`
- 对应的 `.import` 文件
- `docs/planning/16_ART_ASSET_FORMAT_SPEC.md`
- `docs/planning/17_IMAGE2_ART_GENERATION_PLAN.md`
- `docs/planning/18_ART_INTEGRATION_GUIDE.md`
- `docs/planning/19_ART_ITERATION_BRANCH_PLAN.md`

### 谨慎修改

- `scripts/systems/art_asset_registry.gd`

只有新增资产类型、改命名规则、改帧表结构时才改。

### 不在本分支修改

- 战斗数值
- 敌人 AI
- 日志系统逻辑
- 房间流程
- `scripts/main.gd` 中非美术显示相关逻辑

## 本轮美术问题清单

### P0：先解决可读性

- 玩家、敌人、Boss 在 1280x720 下的轮廓必须一眼能分开。
- 玩家不能被房间背景吞掉。
- 敌人受击和攻击前摇要有明显姿态差异。
- Boss 阶段变化要比普通动画更强。
- 日志碎片要在战斗画面里能被识别为“可收集叙事物”，而不是普通光点。

### P1：再解决风格统一

- 房间背景不要比角色更抢眼。
- 所有角色保持同一视角和同一光源。
- 不走恐怖海报方向，保持“卡通化暗黑奇幻”。
- 减少过多碎纹理，让移动目标更清晰。

### P2：最后解决精修

- 玩家朝向帧。
- 持武器/挥砍帧。
- 敌人死亡帧。
- 胃囊吞噬特效。
- 圣匣日志 UI 的专门美术。

## 交付格式

每一轮美术迭代至少包含：

```text
ART_ROUND_YYYYMMDD.md
```

内容包括：

- 本轮替换了哪些文件。
- 解决了哪个试玩问题。
- 哪些资产只是概念参考，哪些已经进游戏。
- 还需要程序配合的点。
- 截图或录屏结论。

图片文件仍按 `18_ART_INTEGRATION_GUIDE.md` 的路径和命名放置。

## 验收标准

一次美术迭代可以合回 `main`，必须满足：

- Godot 主场景能启动。
- 没有缺失资源报错。
- `.import` 文件一起提交。
- 玩家、敌人、Boss 在战斗中可读。
- 至少经过一次实际试玩反馈。
- `CHANGELOG.md` 有记录。

## 和日志系统的关系

日志系统是下一阶段核心系统，不放在 `feature/art-iteration` 中实现。

但美术分支需要提前准备以下资产：

- 日志碎片普通状态。
- 日志碎片可拾取高亮状态。
- 日志碎片归档/吸收特效。
- 圣匣日志面板概念图。

这些资产会服务后续的 `feature/log-fragment-system`。
