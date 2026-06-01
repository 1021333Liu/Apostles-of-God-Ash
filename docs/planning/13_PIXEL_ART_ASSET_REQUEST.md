# 像素风 HUD 与首版角色资源需求

目标：参考动作肉鸽的紧凑可读性，将当前几何占位原型改为原创像素风版本。
只参考信息层级和操作反馈，不复制其他游戏的美术、图标或界面素材。

## 最小可开工资源

### 参考图

请提供 3-6 张参考图：

1. 喜欢的像素画颗粒大小，例如偏 `16x16`、`24x24` 或 `32x32` 角色。
2. 喜欢的 HUD 布局，例如生命条、状态条、技能图标的位置。
3. 喜欢的暗黑奇幻配色或材质参考。
4. 如果有团队草图，提供玩家、胃囊图标和血肉麦田的草图。

参考图只用于提炼方向，不直接复制。

### HUD 图标

首版至少需要以下透明 PNG：

| 文件 | 建议尺寸 | 用途 |
| --- | --- | --- |
| `ui_hp_frame.png` | `160x24` | 暗红生命条银边框 |
| `ui_relic_stomach_open.png` | `24x24` | 胃囊可吞噬 |
| `ui_relic_stomach_closed.png` | `24x24` | 胃囊闭合 |
| `ui_relic_stomach_overflow.png` | `24x24` | 溢血转刃 |
| `ui_memory_shard.png` | `16x16` | 记忆晶片 |
| `ui_prompt_interact.png` | `16x16` | 交互提示 |

### 玩家占位精灵

首版可先只做单方向俯视角：

| 文件 | 建议尺寸 | 用途 |
| --- | --- | --- |
| `player_unrhymed_idle.png` | `24x24` 或 `32x32` | 待机 |
| `player_unrhymed_attack.png` | 横向 spritesheet | 近战攻击 |
| `player_unrhymed_hit.png` | 横向 spritesheet | 受击 |
| `player_unrhymed_heal.png` | 横向 spritesheet | 胃囊回血 |

识别点：银白身体、胸口暗红胃纹、不要明确脸部。

### 反馈特效

| 文件 | 建议尺寸 | 用途 |
| --- | --- | --- |
| `fx_slash_silver.png` | 横向 spritesheet | 银白攻击弧线 |
| `fx_hit_red.png` | 横向 spritesheet | 命中闪烁 |
| `fx_heal_stomach.png` | 横向 spritesheet | 胃囊回血脉冲 |
| `fx_farmer_warning.png` | 横向 spritesheet | 远程农夫落点预警 |

## 第二批资源

- 空腹者、饥民农夫、饥饿稻草人、谷仓王像素精灵。
- 无声圣匣、血肉麦田和谷仓王胃室 tileset。
- 正式像素字体或允许商业使用的字体文件。
- 攻击、命中、回血、胃囊闭合和危险区预警音效。

## 文件格式

- 使用透明背景 PNG。
- 保持整数像素，不使用模糊缩放。
- 同一类图标保持一致画布尺寸。
- Spritesheet 标明每帧宽高、帧数和播放速度。
- 如有源文件，可提供 `.aseprite` 或分层 `.psd`。

