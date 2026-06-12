# 24 商业化优化自动巡检

## 目标

本文件记录《神烬使徒》后续商业化优化的固定工作法：先由主线程维护可运行版本，再让子 Agent 做只读审查，最后用本地巡检脚本验证 UI、美术资源和 Godot 启动状态。

## 自动化脚本

脚本路径：

`tools/commercial_slice_audit.ps1`

默认检查：

- Godot headless 是否能启动 `res://scenes/main.tscn`
- `assets/concepts/` 下 PNG 是否具备 `.import` 侧车文件
- 系统 UI 的概念图预览是否具备裁切、等比居中和安全矩形约束
- 攻击反馈是否保留命中爆点和挥空反馈入口
- 连击配置是否仍有三段攻击分支

运行方式：

```powershell
.\tools\commercial_slice_audit.ps1
```

如果只想检查文件规则，不启动 Godot：

```powershell
.\tools\commercial_slice_audit.ps1 -SkipGodot
```

## 子 Agent 分工

### 动作 / 攻击审查 Agent

只读检查范围：

- `scripts/main.gd`
- `scripts/systems/attack_runtime.gd`
- `scripts/systems/player_runtime.gd`
- `scripts/systems/enemy_runtime.gd`

输出要求：

- 当前攻击手感最弱的 5 个问题
- 精确到函数名的改法
- 低风险高收益修改优先

### UI / 系统界面审查 Agent

只读检查范围：

- `scripts/main.gd`
- `scripts/systems/art_asset_registry.gd`
- `assets/concepts/`
- `assets/sprites/ui/`

输出要求：

- 图片越界、比例失控、层级混乱问题
- 日志页和圣匣页的布局建议
- TextureRect 的尺寸、stretch、modulate 建议

## 主线程合并规则

- 子 Agent 不直接改 `scripts/main.gd`。
- 主线程负责落地代码、跑巡检、更新 CHANGELOG、提交和推送。
- 若巡检失败，不进入下一轮试玩。
