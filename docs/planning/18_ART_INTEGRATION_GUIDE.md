# 美术资产接入指南

本文档说明正式美术资产到达后如何放入仓库，并如何被当前 Godot Demo 自动读取。

当前接入策略：

- 美术资产未到位时，游戏继续使用几何占位绘制。
- 美术资产放入指定路径后，`scripts/systems/art_asset_registry.gd` 会优先加载这些 PNG。
- 不需要为了测试一张图改 `scripts/main.gd`，除非新增了全新的资产类型。

## 1. 目录结构

| 目录 | 用途 |
| --- | --- |
| `assets/concepts/` | 视觉基准图、image2 生成参考图、不可直接进游戏的概念图 |
| `assets/backgrounds/rooms/` | 低语田野房间背景底图 |
| `assets/portraits/` | 收藏家、Boss、档案立绘 |
| `assets/sprites/characters/player/` | 玩家战斗精灵 |
| `assets/sprites/characters/enemies/` | 普通敌人和精英敌人战斗精灵 |
| `assets/sprites/characters/bosses/` | Boss 战斗精灵 |
| `assets/sprites/pickups/` | 日志碎片、记忆晶片、掉落物 |
| `assets/sprites/ui/` | HUD、胃囊、生命、晶片等 UI 图标 |
| `assets/vfx/` | 攻击、命中、胃囊吞噬、日志归档等特效贴图 |

## 2. 当前可自动加载的文件名

把图片放到以下路径后，当前 Demo 会自动优先显示图片；如果图片不存在，则继续显示几何占位。

### 玩家

| 文件 | 用途 |
| --- | --- |
| `assets/sprites/characters/player/player_echo_idle.png` | 无韵回响当前占位精灵 |

### 敌人

| 文件 | 用途 |
| --- | --- |
| `assets/sprites/characters/enemies/enemy_empty_idle.png` | 空腹者 |
| `assets/sprites/characters/enemies/enemy_farmer_idle.png` | 饥民农夫 |
| `assets/sprites/characters/enemies/enemy_scarecrow_idle.png` | 饥饿稻草人 |
| `assets/sprites/characters/bosses/boss_barn_king_phase1_idle.png` | 谷仓王首版 |

### 房间背景

| 文件 | 用途 |
| --- | --- |
| `assets/backgrounds/rooms/bg_field_gate_base.png` | 低语田野入口 |
| `assets/backgrounds/rooms/bg_blood_wheat_base.png` | 血肉麦田 |
| `assets/backgrounds/rooms/bg_gut_canal_base.png` | 肠道灌溉渠 |
| `assets/backgrounds/rooms/bg_hungry_barn_base.png` | 饥饿谷仓 |
| `assets/backgrounds/rooms/bg_barn_king_base.png` | 谷仓王胃室 |

### 掉落物

| 文件 | 用途 |
| --- | --- |
| `assets/sprites/pickups/log_fragment.png` | 日志碎片 / 记忆晶片 |

## 3. 图片规格

首批可直接测试的规格：

| 类型 | 推荐尺寸 | 透明背景 | 备注 |
| --- | ---: | --- | --- |
| 玩家单张占位 | `96x96` | 是 | 斜俯视，能看见胸口胃纹 |
| 普通敌人单张占位 | `96x96` | 是 | 空腹者、农夫 |
| 稻草人单张占位 | `128x128` | 是 | 需要更高剪影 |
| Boss 单张占位 | `256x256` 或 `320x320` | 是 | 谷仓王首版 |
| 房间背景 | `1920x1080` | 否 | 3/4 斜俯视房间，中心留战斗区域 |
| 日志碎片 | `48x48` 或 `64x64` | 是 | 小尺寸下仍可读 |

## 4. 接入流程

1. 把 image2 或画师输出的图片整理成 PNG。
2. 按本文件第 2 节放入指定路径。
3. 打开 Godot 或运行主场景。
4. 如果图片能正常加载，游戏会自动显示该资产。
5. 如果图片没显示，先检查文件名、路径和 PNG 是否可被 Godot 导入。

## 5. 当前代码接入点

- `scripts/systems/art_asset_registry.gd`：管理可选美术资源路径。
- `scripts/main.gd`：
  - `_draw_field_room()` 优先显示房间背景图。
  - `_draw_player()` 优先显示玩家 PNG。
  - `_draw_enemy()` 优先显示敌人 / Boss PNG。

## 6. 后续扩展

当前只是“单张 PNG 接入准备”。拿到正式 spritesheet 后，下一步应拆成：

1. `Player` 独立场景。
2. `EnemyBase` 与各敌人独立场景。
3. `BarnKing` Boss 独立场景。
4. `SpriteFrames` 动画资源。
5. 日志碎片 `Area2D` 拾取物。
6. 圣匣日志 UI 独立 `CanvasLayer`。

在正式拆场景前，不要为了每张新图改主脚本。先按当前路径验证风格、比例和可读性。
