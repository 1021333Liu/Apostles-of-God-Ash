# Art Atlas Automation Handoff 2026-06-18

本文记录本轮把现有 2D 人物 / 敌人 / Boss / 日志碎片帧整理成 Godot 友好 atlas + manifest 的结果。

本轮使用 `generate2dsprite` 的资产处理原则：按动作分组、固定 cell、保留脚底 / 中心锚点、把宽刀光视为单独 FX 需求、用 manifest 做程序侧自动化入口。

## 1. 文件清单

### 原始概念图

本轮没有新增或修改原始概念图。现有概念参考仍在：

- `assets/concepts/`
- `assets/concepts/art_iteration_round_20260610/`
- `assets/concepts/art_clean_color_round_20260610/`
- `assets/concepts/wyeth_rural_masterset_20260615/`

这些仍是参考图，不应直接作为运行时 PNG。

### 临时运行帧

本轮没有修改原始散帧。atlas 均从现有运行帧生成：

- `assets/sprites/characters/player/*.png`
- `assets/sprites/characters/enemies/*.png`
- `assets/sprites/characters/bosses/*.png`
- `assets/sprites/pickups/*.png`

本地还有未跟踪目录：

- `assets/sprites/runtime_concepts/`

该目录不是本轮 atlas 接入必须内容，当前不应自动提交，除非明确决定把它作为正式运行资产来源。

### Atlas

新增：

- `assets/sprites/atlases/player_echo_atlas.png`
- `assets/sprites/atlases/enemy_empty_atlas.png`
- `assets/sprites/atlases/enemy_farmer_atlas.png`
- `assets/sprites/atlases/enemy_scarecrow_atlas.png`
- `assets/sprites/atlases/boss_barn_king_atlas.png`
- `assets/sprites/atlases/log_fragment_atlas.png`

### Manifest

新增：

- `assets/sprites/atlases/player_echo_atlas.json`
- `assets/sprites/atlases/enemy_empty_atlas.json`
- `assets/sprites/atlases/enemy_farmer_atlas.json`
- `assets/sprites/atlases/enemy_scarecrow_atlas.json`
- `assets/sprites/atlases/boss_barn_king_atlas.json`
- `assets/sprites/atlases/log_fragment_atlas.json`
- `assets/sprites/atlases/sprite_atlas_build_summary.json`

### 工具脚本

新增：

- `tools/build_sprite_atlases.py`

功能：

- 从现有散帧读取 PNG。
- 按角色 / 敌人 / Boss / 拾取物打包 atlas。
- 生成 manifest JSON。
- 记录每帧尺寸、alpha bbox、是否触边、缺帧 / 尺寸错误。

### 文档

新增：

- `docs/planning/ART_ATLAS_AUTOMATION_HANDOFF_20260618.md`

### 程序接入

修改：

- `scripts/systems/art_asset_registry.gd`

作用：

- 优先读取 atlas manifest。
- 从 atlas texture + `region` 构造 `AtlasTexture` 帧。
- manifest / atlas 不存在时回退到旧散帧路径。
- PNG 没有 `.import` sidecar 时，使用 `Image.load()` + `ImageTexture.create_from_image()` 直接加载，保证自动化环境里也能运行。

### 不应提交的本地改动

- `project.godot`

说明：

- 本轮不需要修改 `project.godot`。
- 当前 diff 显示 Godot 版本字段、配置头、stretch/aspect 等被本地 Godot 过程改写，属于编辑器 / headless 噪音或既有本地改动。
- 除非主线程确认项目配置确实要升级，否则不应提交。

## 2. Manifest 数据结构

schema：

```json
{
  "schema": "godash.sprite_atlas.v1",
  "source": "tools/build_sprite_atlases.py",
  "texture": "res://assets/sprites/atlases/player_echo_atlas.png",
  "cell_size": [128, 128],
  "draw_size": [82.0, 82.0],
  "anchor": {
    "mode": "feet",
    "x": 64,
    "y": 104
  },
  "groups": {
    "idle": [
      {
        "source": "assets/sprites/characters/player/player_echo_idle_0.png",
        "region": [0, 0, 128, 128],
        "anchor": {
          "mode": "feet",
          "x": 64,
          "y": 104
        }
      }
    ]
  },
  "qc": {
    "frames": [],
    "edge_touch_frames": [],
    "missing_or_bad_frames": []
  }
}
```

字段说明：

- `texture`：Godot `res://` atlas PNG 路径。
- `cell_size`：源帧固定 cell 尺寸。
- `draw_size`：当前 demo 中推荐绘制尺寸，和 `art_asset_registry.gd` 的 draw size 保持一致。
- `anchor`：默认锚点。
  - 玩家 / 普通敌人：`feet`，`x=64`，`y=104`。
  - Boss：`feet`，`x=192`，`y=315`。
  - 日志碎片：`center`，`x=48`，`y=48`。
- `groups`：动作名到帧数组。
- 每帧 `region`：`[x, y, width, height]`，用于创建 `AtlasTexture.region`。
- 每帧 `source`：原始散帧路径，便于追溯。
- `qc.frames[].alpha_bbox`：非透明区域 bbox。
- `qc.edge_touch_frames`：触碰 cell 边缘的帧。
- `qc.missing_or_bad_frames`：缺失或尺寸不符合的帧。

当前动作组：

- 玩家 `player_echo`：`idle:4`、`walk:4`、`attack:4`、`hit:3`。
- 空腹者 `enemy_empty`：`idle:4`、`walk:4`、`attack:4`、`hit:3`。
- 饥民农夫 `enemy_farmer`：`idle:4`、`walk:4`、`attack:4`、`hit:3`。
- 稻草人 `enemy_scarecrow`：`idle:4`、`walk:4`、`attack:4`、`hit:3`。
- 谷仓王 `boss_barn_king`：
  - `phase1:4`、`phase2:4`、`phase3:4`
  - `phase1_attack:3`、`phase2_attack:3`、`phase3_attack:3`
  - `phase1_hit:2`、`phase2_hit:2`、`phase3_hit:2`
- 日志碎片 `log_fragment`：`pulse:5`、`idle:5`。

## 3. 程序侧接入说明

推荐接入集中在：

- `scripts/systems/art_asset_registry.gd`

本轮已经修改该文件，不需要直接改 `scripts/main.gd`。

加载流程：

1. `load_all()` 先尝试 `_load_atlas_frame_groups(manifest_path)`。
2. manifest 可解析且 atlas texture 可加载时，返回 `AtlasTexture` 帧数组。
3. 如果 atlas 或 manifest 不存在、JSON 解析失败、texture 加载失败，则回退 `_load_frame_groups(...)` 的旧散帧路径。
4. `player_frame()`、`enemy_frame()`、`log_fragment_frame()` 的外部接口保持不变。

对 `scripts/main.gd` 的影响：

- 当前无需改。
- `_draw_player()`、`_draw_enemy()`、`_draw_active_log_fragment()` 仍从 registry 拿 `Texture2D`。
- atlas 帧是 `AtlasTexture`，仍是 `Texture2D`，因此调用侧兼容。

后续如果要彻底解决“单侧脸 / 镜像”问题，才需要进一步扩展：

- registry 增加 `state + direction` 维度。
- `player_frame(state, direction, frame_index)`。
- `enemy_frame(kind, state, direction, frame_index)`。
- `main.gd` 的 flip 逻辑改为方向选择，不再只 `flip_h`。

## 4. P0 运行资产判断

可以作为 P0 运行资产：

- `assets/sprites/atlases/player_echo_atlas.png` + `.json`
- `assets/sprites/atlases/enemy_empty_atlas.png` + `.json`
- `assets/sprites/atlases/enemy_farmer_atlas.png` + `.json`
- `assets/sprites/atlases/enemy_scarecrow_atlas.png` + `.json`
- `assets/sprites/atlases/boss_barn_king_atlas.png` + `.json`
- `assets/sprites/atlases/log_fragment_atlas.png` + `.json`

原因：

- 尺寸统一。
- 动作组可解析。
- Godot headless 启动通过。
- registry 有旧路径回退。

只能作为概念参考：

- `assets/concepts/**`
- `assets/concepts/wyeth_rural_masterset_20260615/**`

原因：

- 未切成透明运行帧。
- 不能直接保证锚点、hitbox、动画节奏。

当前不建议进游戏 / 需要重做：

- 玩家 attack 部分帧。

QC 发现：

- `assets/sprites/characters/player/player_echo_attack_0.png`
- `assets/sprites/characters/player/player_echo_attack_1.png`
- `assets/sprites/characters/player/player_echo_attack_2.png`

这些帧 alpha bbox 触碰 cell 边缘，说明攻击身体帧包含过宽武器 / 刀光。根据 `generate2dsprite` 原则，玩家身体 attack 应保持 body-only，宽刀光应拆成单独 `vfx_slash_*` atlas。

## 5. 当前视觉最大 5 个问题

1. 玩家和敌人仍然缺方向维度。
   当前 atlas 只是按动作整理，仍没有 `down / up / left / right` 四方向正式帧。`main.gd` 仍依赖水平翻转解决朝向。

2. 玩家攻击帧过宽并触边。
   攻击帧把武器 / 刀光塞进 128x128 body cell，导致 body bbox 变宽、缩放和锚点风险变高。应拆身体攻击和 slash FX。

3. 稻草人和农夫共享相近动作结构。
   两者运行帧目前可用，但精英稻草人的施法身份不够独立，后续需要更明显的 `cast_wave`。

4. Boss 阶段可用但仍像概念结构。
   三阶段 atlas 已可接入，但 phase change 和 death 缺失，Boss 仍需要更明确的红核弱点、开仓召唤、胃室收缩动作。

5. UI 仍是程序面板 + SVG 占位。
   圣匣日志 UI 和胃囊四态还没有正式 atlas / NinePatch / UI 切图；日志碎片已有 atlas，但归档状态和 UI 内同源图标还没完整拆分。

## 6. 自动化巡检验收条件

建议主线程或 CI 增加以下检查：

### 文件存在

- `assets/sprites/atlases/player_echo_atlas.png`
- `assets/sprites/atlases/player_echo_atlas.json`
- `assets/sprites/atlases/enemy_empty_atlas.png`
- `assets/sprites/atlases/enemy_empty_atlas.json`
- `assets/sprites/atlases/enemy_farmer_atlas.png`
- `assets/sprites/atlases/enemy_farmer_atlas.json`
- `assets/sprites/atlases/enemy_scarecrow_atlas.png`
- `assets/sprites/atlases/enemy_scarecrow_atlas.json`
- `assets/sprites/atlases/boss_barn_king_atlas.png`
- `assets/sprites/atlases/boss_barn_king_atlas.json`
- `assets/sprites/atlases/log_fragment_atlas.png`
- `assets/sprites/atlases/log_fragment_atlas.json`

### Manifest parse

每个 manifest 必须：

- JSON 可解析。
- `schema == "godash.sprite_atlas.v1"`。
- `texture` 指向存在的 PNG。
- `cell_size` 为 2 个正整数。
- `draw_size` 为 2 个正数。
- `groups` 非空。
- 每帧 `region` 长度为 4。
- `qc.missing_or_bad_frames` 为空。

### QC 阈值

P0 可运行：

- `missing_or_bad_frames` 必须为空。

P0 生产级：

- `edge_touch_frames` 应为空。

当前结果：

- 可运行级通过。
- 生产级未完全通过，玩家 attack 有 3 帧触边。

### Godot headless

通过命令：

```powershell
& 'E:\Godot\Godot_v4.6.3-stable_win64.exe\Godot_v4.6.3-stable_win64_console.exe' --headless --path 'D:\Desktop\DeskHub\神烬使徒 Godot' 'res://scenes/main.tscn' --quit-after 2
```

本轮结果：

- 通过。

### Registry 接入

巡检应确认：

- `scripts/systems/art_asset_registry.gd` 包含 `_load_atlas_frame_groups()`。
- `load_all()` 优先读取 atlas manifest。
- 旧散帧路径仍存在作为 fallback。
- `_try_load_texture()` 支持 `.png` 直读 fallback，避免新 PNG 没有 `.import` 时无法启动。

### 旧路径读取检查

建议在 Godot 内增加临时 debug 或单元检查：

- atlas manifest 存在时，`player_frame("idle", 0)` 返回 `AtlasTexture`。
- 删除 / 改名 manifest 后，`player_frame("idle", 0)` 回退为普通 `Texture2D`。

### UI 图片越界

本轮没有改 UI 图片。下一轮巡检应加入：

- UI 图标尺寸是否符合目标 rect。
- `TextureRect.STRETCH_KEEP_ASPECT_CENTERED` 是否仍在使用。
- 圣匣日志概念图是否没有被 `KEEP_ASPECT_COVERED` 裁切关键信息。

## 7. 本轮验证记录

已执行：

- `python tools/build_sprite_atlases.py`
- `python -m json.tool assets/sprites/atlases/player_echo_atlas.json`
- Godot 4.6.3 headless 启动 `res://scenes/main.tscn`

结果：

- Atlas 和 manifest 已生成。
- JSON 可解析。
- Godot headless 启动通过。
- `project.godot` 有本地改动，但不是本轮必要改动，不应提交。

