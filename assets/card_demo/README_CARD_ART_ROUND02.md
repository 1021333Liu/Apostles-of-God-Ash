# Card Demo Art Round 02

本批资产服务当前卡牌骰子 Demo 的完整流程：

1. 田野场景中主角移动。
2. 主角靠近农夫。
3. 农夫喃喃自语并触发对话失败。
4. 进入左右站位的卡牌骰子战斗。
5. 角色头顶显示攻击 / 防御意图气泡，屏幕中央显示骰子判定底座。

这些文件是 P0 可运行代理资产，不是最终美术。它们从现有项目精灵扩展、放大并重新锚定到 Godot 友好的 768x768 透明 PNG 序列，方便程序先把流程跑通。

重要修正：主角最终视觉基准已改为 `assets/card_demo/actors/player_echo/source/player_echo_visual_benchmark_20260610.png`。当前 `player_echo` 动作帧只是可运行占位，后续必须按这张干净彩色主角图重新去噪、拆分、重画动作帧，不再把旧低清占位精灵当作主角标准。

## 输出目录

- `assets/card_demo/actors/player_echo/`：主角探索与卡牌战斗动作帧。
- `assets/card_demo/actors/player_echo/source/`：主角最终视觉基准图与源图处理说明。
- `assets/card_demo/actors/enemy_farmer/`：农夫探索与卡牌战斗动作帧。
- `assets/card_demo/ui/intent/`：攻击 / 防御意图气泡。
- `assets/card_demo/ui/dice/`：骰子滚动底座。
- `assets/card_demo/card_demo_art_manifest.json`：程序接入 manifest。

## 通用规格

- 角色帧：`768x768`，`RGBA`，透明背景。
- 脚底锚点：`x=384, y=720`。
- 推荐 draw size：`256x256`，程序可按场景缩放。
- 方向规则：当前帧统一按右向 / 右前方向制作。角色向左时，程序应围绕脚底锚点做 `mirror_x_by_direction` 镜像，不要读取另一套不同锚点的左向图，避免左右移动瞬移。
- 文件命名：`field_idle_0.png`、`field_walk_0.png`、`card_attack_0.png` 等，数字从 0 连续递增。

## 动作清单

| Actor | Action | Frames | FPS | 用途 | 当前状态 |
| --- | ---: | ---: | ---: | --- | --- |
| `player_echo` | `field_idle` | 6 | 6 | 田野探索待机，呼吸 / 布条轻晃 | P0 代理，需按主角基准图重画 |
| `player_echo` | `field_walk` | 8 | 10 | 田野探索行走循环，脚底稳定 | P0 代理，需按主角基准图重画 |
| `player_echo` | `card_attack` | 8 | 12 | 出牌攻击动作 | 复用旧 `player_echo_attack_*`，需按主角基准图重画 |
| `player_echo` | `card_defend` | 8 | 8 | 防御动作 | 待机代理，需按主角基准图重画举刃 / 护胃动作 |
| `player_echo` | `card_hurt` | 6 | 10 | 受击后仰 | 复用旧 `player_echo_hit_*`，需按主角基准图重画 |
| `player_echo` | `card_win` | 8 | 8 | 胜利回稳 | 待机代理，需按主角基准图重画胜利收刀 |
| `enemy_farmer` | `field_idle` | 6 | 6 | 农夫田路待机，佝偻颤动 | P0 可用 |
| `enemy_farmer` | `field_mutter` | 8 | 8 | 农夫喃喃自语 | 行走 / 待机代理，需最终重画嘴部和肩颈动作 |
| `enemy_farmer` | `card_attack` | 8 | 12 | 农夫出牌攻击 | 复用旧 `enemy_farmer_attack_*` |
| `enemy_farmer` | `card_defend` | 8 | 8 | 农夫防御 | 待机代理，需重画抱碗 / 护身 |
| `enemy_farmer` | `card_hurt` | 6 | 10 | 农夫受击踉跄 | 复用旧 `enemy_farmer_hit_*` |
| `enemy_farmer` | `card_mutter` | 8 | 8 | 回合等待 / 骰子判定前喃喃 | 待机代理，需最终重画 |
| `enemy_farmer` | `card_confess` | 8 | 7 | 战斗后坦白 / 崩溃 | 受击代理，需重画跪低 / 松手 |

## UI 小图

| ID | Path | Size | 用途 | 当前状态 |
| --- | --- | ---: | --- | --- |
| `intent_attack` | `assets/card_demo/ui/intent/bubble_attack.png` | `320x168` | 角色头顶攻击意图气泡，左侧留文字区 | P0 代理 |
| `intent_defend` | `assets/card_demo/ui/intent/bubble_defend.png` | `320x168` | 角色头顶防御意图气泡，左侧留文字区 | P0 代理 |
| `dice_roll_stage` | `assets/card_demo/ui/dice/dice_roll_stage.png` | `512x256` | 屏幕中央 D20 / D3 骰子滚动底座 | P0 代理 |

现有 `assets/sprites/ui/ui_memory_shard.svg` 可以临时复用为胜利后的记忆样本奖励图标。暴击、大失败、完美防御、反弹 icon 还没有足够贴合卡牌骰子战斗的专用图，建议 P1 重画。

## Manifest 结构

`assets/card_demo/card_demo_art_manifest.json` 使用 `godash.card_demo_art.v1`：

- `coordinate_contract.character_frame_size`：角色 PNG 固定尺寸。
- `coordinate_contract.anchor`：脚底锚点。
- `coordinate_contract.direction_policy`：左向镜像规则。
- `actions[]`：
  - `actor`：`player_echo` 或 `enemy_farmer`。
  - `action`：动作名。
  - `frame_count`：帧数。
  - `fps`：推荐播放帧率。
  - `anchor`：该动作帧的脚底锚点。
  - `draw_size`：程序侧默认绘制尺寸建议。
  - `flip_policy`：方向镜像策略。
  - `description`：1 行动作说明。
  - `paths`：PNG 序列路径。
  - `reuse_from`：如存在，说明该动作复用了旧资产。
  - `status`：`p0_proxy` 表示可运行但非最终美术。
- `ui[]`：意图气泡、骰子底座等 UI 小图。
- `reusable_existing_icons[]`：可临时复用的旧 UI 图标。
- `qc`：本轮尺寸与锚点检查结果。

## 技术接入建议

- 优先在资产注册层接入 manifest，例如集中到 `scripts/systems/art_asset_registry.gd` 或卡牌 Demo 专用 registry。
- 不建议直接在运行脚本里硬编码所有 PNG 路径。
- 加载动作时按 `paths` 顺序生成帧数组，按 `fps` 播放。
- 角色节点建议使用 `Sprite2D` / `AnimatedSprite2D` 加外层 `Node2D`。镜像时翻外层或 sprite 的 `scale.x`，同时保持 feet anchor 对齐。
- 进入战斗后建议复用同一 actor 节点，只切换 action，不要重新创建不同锚点的左右角色图。

## 当前最大问题

1. 主角 `card_attack` 仍复用旧攻击帧，武器/攻击外轮廓有过宽和贴边问题，最终要拆成 body-only 动作 + 独立 slash FX。
2. `card_defend`、`card_win`、`field_mutter`、`card_mutter`、`card_confess` 目前是代理动作，不是专门绘制的表演。
3. UI 气泡和骰子底座是 P0 代理图，能跑流程，但还不够 Andrew Wyeth 式低饱和乡土质感。
4. 角色仍是从 128x128 运行帧放大得到，进入高清卡牌战斗界面时会显得粗糙。
5. 暴击 / 大失败 / 完美防御 / 反弹缺少专用 icon，不应长期借用记忆碎片或胃囊图标。

## 给画师的下一轮重画要求

- 保持主角身份：银灰盔甲的空壳使徒、封闭头盔、无脸、黑灰破布、胸口暗红胃囊 / 圣痕、短刃或长刃。
- 保持农夫身份：低饱和泥土色、干瘦、粗布、农具、空碗 / 饥荒暗示，不要变成卡通二次元。
- 仍按 `768x768` 透明 PNG 输出，脚底锚点保持 `x=384, y≈720`。
- 每个动作单独画，不要把大范围斩击、骰子、文字、尘土 FX 合进角色 body 帧。
- 最先重画：`player_echo/card_attack`、`player_echo/card_defend`、`enemy_farmer/card_confess`、`enemy_farmer/field_mutter`、四个战斗结果 icon。
