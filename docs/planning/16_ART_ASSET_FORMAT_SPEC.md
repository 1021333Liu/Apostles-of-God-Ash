# 《神烬使徒》Godot 2D 美术资产格式规格

本文用于把“2D 手绘油画感暗黑动作肉鸽”的正式美术方向转成可执行、可验收、可导入 Godot 的资产生产规格。

当前目标不是完整商业版美术量，而是完成“低语田野”垂直切片的最小美术闭环：玩家、两类普通敌人、首版 Boss、日志碎片、圣匣日志 UI、低语田野视觉基准图都能进入 Godot Demo，并能支撑击杀掉落日志、胃囊状态、圣匣归档、Boss 弱点暴露、死亡回收等核心事件。

## 1. 正式资产格式总则

### 1.1 战斗角色精灵

正式接入格式：
- 优先使用透明背景 PNG spritesheet。
- 源文件可为 `.psd`、`.kra`、`.clip` 或分层 `.psd`，但进入 Godot 的最终文件必须是 `.png`。
- 每个角色按“动作 + 方向”拆 sheet，首版不要把所有动作塞进一张超大总表。

推荐命名：
- `player_echo_idle_sheet.png`
- `player_echo_walk_sheet.png`
- `enemy_empty_bite_sheet.png`
- `boss_barn_king_phase1_idle_sheet.png`

透明要求：
- 必须透明背景。
- 角色外轮廓至少保留 4 px 空边，Boss 至少保留 8 px 空边。
- 使用直通 alpha PNG，不要在源图里压黑边。

推荐尺寸：

| 类型 | 单帧画布 | 屏幕呈现目标 | 说明 |
| --- | ---: | ---: | --- |
| 玩家：无韵回响 | `96x96` | 约 48-64 px 高 | 保留胸口胃纹和武器挥击空间 |
| 普通敌人：空腹者 / 饥民农夫 | `96x96` | 约 52-72 px 高 | 和玩家同画布，便于碰撞与排序 |
| 精英：饥饿稻草人 | `128x128` | 约 80-96 px 高 | 需要召唤/麦刺前摇空间 |
| Boss：谷仓王 | `256x256` 或 `320x320` | 约 180-260 px 高 | 首版只做阶段差异和弱点暴露，不做巨量细节 |
| 掉落物 / 小交互物 | `32x32` 或 `48x48` | 约 16-32 px | 日志碎片、胃囊残光等 |

Godot 接入建议：
- 普通角色：`CharacterBody2D` + `AnimatedSprite2D` + `CollisionShape2D`。
- 静态可拾取物：`Area2D` + `Sprite2D` + `CollisionShape2D`。
- Boss：`Node2D` 或 `CharacterBody2D` 根节点，子节点拆 `AnimatedSprite2D`、`WeakPoint`、`AttackTelegraph`。
- 动画资源：用 `SpriteFrames` 管理，不在代码里逐帧硬编码图片路径。

方向数原则：
- P0 先做 1 方向或 2 方向。
- 可移动角色首版用左右镜像解决横向差异。
- 俯视斜角游戏里，首版不做 8 方向，避免动画量失控。

### 1.2 立绘

正式接入格式：
- 需要透明边缘、压在 UI 上的角色立绘：PNG。
- 不需要透明、作为档案背景或整页插图的图：WebP 或 PNG，优先 WebP 减小体积。
- 源文件保留分层 `.psd` / `.kra` / `.clip`。

推荐分辨率：

| 类型 | 导出尺寸 | 背景 | 用途 |
| --- | ---: | --- | --- |
| 半身立绘 | `1200x1600` | 透明 PNG | 收藏家、Boss 档案、圣匣页面 |
| 全身立绘 | `1600x2200` | 透明 PNG | 宣传、图鉴、后续商店/档案 |
| 档案整页插图 | `1920x1080` 或 `1600x1000` | 带背景 WebP/PNG | 圣匣档案大图 |
| 小头像 / 标签头像 | `256x256` | 透明 PNG | UI 列表、日志来源标识 |

立绘不直接等同战斗精灵。立绘承担油画厚涂质感，战斗精灵承担剪影、攻击范围和状态识别。

### 1.3 背景

正式接入格式：
- 分层 PNG。
- 大面积、不需要透明的远景层可用 WebP。
- 需要遮挡、排序、洞口、边缘破损的层必须用透明 PNG。

推荐尺寸：

| 背景类型 | 单层尺寸 | 接入方式 | 说明 |
| --- | ---: | --- | --- |
| 房间底图 | `1920x1080` 或 `2048x1152` | `Sprite2D` / `TileMapLayer` | P0 固定房间可先用整张底图 |
| 可重复地表纹理 | `512x512` 或 `1024x1024` | `TileMapLayer` / shader repeat | 麦田、肉泥、泥土 |
| 前景遮挡 | 与房间底图同尺寸 | `Sprite2D`，按 YSort 或 CanvasItem z_index | 麦穗、谷仓梁、吊钩 |
| 远景剪影 | `1920x540` | `ParallaxBackground` 可选 | 谷仓、栅栏、远处麦浪 |

建议切层：
- `bg_field_floor_base.png`：地面主层，不透明。
- `bg_field_meat_wheat_overlay.png`：血肉麦穗、咬痕、胃液边缘，透明。
- `bg_field_props_mid.png`：木桩、农具、谷袋、低矮遮挡，透明。
- `bg_field_foreground.png`：上方压暗麦穗、吊绳、画面前景遮挡，透明。
- `bg_field_collision_ref.png`：只给程序参考，不进最终画面。

P0 不要求完整 TileSet。先用整张房间底图 + 少量透明遮挡层验证气质；后续再拆可复用 TileMap。

### 1.4 UI

UI 正式接入格式：

| UI 类型 | 推荐格式 | 使用场景 |
| --- | --- | --- |
| 可拉伸面板、纸页、档案框 | PNG 九宫格 | 圣匣日志界面、死亡回收界面、提示面板 |
| 固定图标 | 透明 PNG | 胃囊四态、日志碎片、拾取提示 |
| 极简线性标记 | SVG 可选 | 临时调试图标、矢量小箭头、可换色符号 |
| 油画质感按钮 / 封蜡 / 金属夹 | 透明 PNG | 质感依赖笔触，不建议 SVG |
| 文本 | Godot Label + 字体 | 不要把可变文字烘进图片 |

Godot 接入建议：
- 可拉伸底板：`NinePatchRect`。
- 固定图标：`TextureRect`。
- UI 根：`CanvasLayer` + `Control`。
- 列表：`ScrollContainer` + `VBoxContainer`。
- 标签与批注：`Label` / `RichTextLabel`，不要输出成图片。

首版 UI 要像“圣匣档案系统”：油渍纸页、封蜡、金属夹、手写批注、器官标本标签。禁止赛博 UI、霓虹扫描线、科幻 HUD、日系二次元描边按钮。

### 1.5 特效

| 特效类型 | 推荐格式 | 适合内容 | Godot 接入 |
| --- | --- | --- | --- |
| PNG 序列 / spritesheet | 透明 PNG sheet | 手绘刀光、命中爆点、胃囊吞噬、日志归档小演出 | `AnimatedSprite2D` / `SpriteFrames` |
| 粒子贴图 | 小尺寸透明 PNG | 血雾、银白晶屑、灰烬、麦尘 | `GPUParticles2D` |
| Shader 参数图 | 灰度 mask / noise PNG | 胃液蠕动、纸页腐蚀边、Boss 弱点脉冲 | `ShaderMaterial` |
| 普通静态图 | 透明 PNG | 首版预警圈、拾取光圈、交互标记 | `Sprite2D` / `TextureRect` |

P0 特效原则：
- 关键反馈先可读，再追求华丽。
- 攻击命中、日志掉落、胃囊开启/闭合、Boss 弱点暴露必须有明显颜色和轮廓差异。
- 首版不做复杂全屏后处理。

## 2. P0 资产清单：必须能进入 Godot Demo

P0 只做最小闭环，不追求所有敌人和场景都完成。

### 2.1 P0 总表

| 资产 | 用途 | 尺寸 / 帧数 | 导出格式 | 透明要求 | Godot 接入节点建议 |
| --- | --- | --- | --- | --- | --- |
| 低语田野视觉基准图 | 定义正式画面气质、配色、材质、UI 参考 | `1920x1080`，静态 1 张 | PNG 或 WebP；源文件分层 | 带背景，不要求透明 | 不直接进战斗；可放 `docs` 或作为 `TextureRect` 测试 |
| 无韵回响战斗精灵 | 玩家首版替换几何占位 | `96x96` 单帧画布；4 组动作 | 透明 PNG spritesheet | 必须透明 | `CharacterBody2D` + `AnimatedSprite2D` |
| 空腹者战斗精灵 | 基础近战敌人 | `96x96`；3 组动作 | 透明 PNG spritesheet | 必须透明 | `CharacterBody2D` + `AnimatedSprite2D` |
| 谷仓王首版 Boss 精灵 | Boss 战视觉核心 | `256x256` 或 `320x320`；4 组动作 | 透明 PNG spritesheet | 必须透明 | `Node2D`/`CharacterBody2D` + `AnimatedSprite2D` + 弱点子节点 |
| 日志碎片掉落视觉 | 击杀后记忆采样反馈 | `48x48`；静态 1 张 + 可选 4 帧闪烁 | 透明 PNG | 必须透明 | `Area2D` + `Sprite2D`；可加 `GPUParticles2D` |
| 圣匣日志 UI 首版 | 展示已收集日志和第一段故事 | `1920x1080` 设计稿；面板九宫格按实际切片 | PNG 九宫格 + 固定 PNG 图标 | 面板边缘透明 | `CanvasLayer` + `Control` + `NinePatchRect` |

### 2.2 P0 细化规格

#### 低语田野视觉基准图

用途：
- 定义“农业恐怖 + 宗教仪式 + 油画厚涂”的基准。
- 作为所有后续角色、背景、UI 的色彩和材质锚点。

内容必须出现：
- 枯金麦田、腐红地表、谷仓剪影。
- 银白神血或记忆晶片。
- 胃囊 / 嘴 / 牙齿 / 祭祀制度的暗示。
- 画面不能只是普通农田或纯血腥场景。

导出：
- `art_key_low_whispering_field_1920.png` 或 `.webp`。
- 源文件：`art_key_low_whispering_field_source.psd`。

验收：
- 截图 2 秒内能分辨这里是“吃人的活体农田”。
- 颜色不高饱和卡通，不赛博，不像像素游戏标题图。

#### 无韵回响战斗精灵

用途：
- 玩家角色首版正式替换。
- 支撑移动、三段近战攻击、受击、死亡/回收。

首版动作：

| 动作 | 方向 | 帧数 | 备注 |
| --- | --- | ---: | --- |
| idle | 1 方向 | 4 | 轻微胃纹呼吸 |
| walk | 2 方向，左右镜像 | 6 | 身体漂移，不做复杂脚步 |
| attack | 2 方向，左右镜像 | 6 | 银白刀弧可单独做 FX |
| hit | 1 方向 | 3 | 胸口胃纹收缩 |
| death_recover | 1 方向 | 6 | 可做成回收溶解首版 |

文件：
- `player_echo_idle_sheet.png`
- `player_echo_walk_side_sheet.png`
- `player_echo_attack_side_sheet.png`
- `player_echo_hit_sheet.png`
- `player_echo_death_recover_sheet.png`

Godot：
- `AnimatedSprite2D`，动画名：`idle`、`walk_side`、`attack_side`、`hit`、`death_recover`。
- 碰撞不用逐帧变化，首版保持胶囊或圆形碰撞。

#### 空腹者战斗精灵

用途：
- 首个基础敌人。
- 视觉上承担“饥荒感染者”的识别。

首版动作：

| 动作 | 方向 | 帧数 | 备注 |
| --- | --- | ---: | --- |
| idle | 1 方向 | 4 | 喉咙扩张、腹部塌陷 |
| walk | 2 方向，左右镜像 | 6 | 拖拽感强 |
| bite | 2 方向，左右镜像 | 5 | 大嘴前探，攻击前摇清楚 |
| hit | 1 方向 | 3 | 身体被银白冲击撕开 |
| death_drop | 1 方向 | 6 | 死亡后吐出日志碎片 |

文件：
- `enemy_empty_idle_sheet.png`
- `enemy_empty_walk_side_sheet.png`
- `enemy_empty_bite_side_sheet.png`
- `enemy_empty_hit_sheet.png`
- `enemy_empty_death_drop_sheet.png`

Godot：
- `CharacterBody2D` + `AnimatedSprite2D`。
- 日志掉落从死亡动画最后 1-2 帧触发。

#### 谷仓王首版 Boss 精灵

用途：
- 垂直切片终局视觉核心。
- 必须体现“谷仓、胃、王权、献祭制度”的集合体。

首版动作：

| 动作 | 方向 | 帧数 | 备注 |
| --- | --- | ---: | --- |
| idle_phase1 | 1 方向 | 6 | 巨腹呼吸，谷仓门脸轻微开合 |
| summon | 1 方向 | 8 | 招来麦浪/小怪的前摇 |
| devour | 1 方向 | 8 | 吞噬或胃液喷口动作 |
| weak_expose | 1 方向 | 6 | 腹部画布撕开，露出红核 |
| death | 1 方向 | 10 | 首版可以短，不做长过场 |

文件：
- `boss_barn_king_idle_phase1_sheet.png`
- `boss_barn_king_summon_sheet.png`
- `boss_barn_king_devour_sheet.png`
- `boss_barn_king_weak_expose_sheet.png`
- `boss_barn_king_death_sheet.png`
- `boss_barn_king_weak_core.png`

Godot：
- 根节点 `BarnKing`。
- 主体 `AnimatedSprite2D`。
- 弱点 `Area2D` + `Sprite2D`，平时隐藏，`weak_expose` 时显示。
- 攻击预警可用独立 `Sprite2D` 或 `Line2D`，不要烘进 Boss 主体图。

#### 日志碎片掉落视觉

用途：
- 敌人死亡后掉落记忆样本。
- 让玩家理解“击杀不是刷怪，而是在采样记忆”。

规格：
- `48x48` 透明 PNG。
- 首版静态 1 张即可，可加 4 帧闪烁 sheet。
- 颜色：半透明银白、冷青边缘，内部有油渍纸页或晶片裂纹。

文件：
- `pickup_memory_shard.png`
- 可选：`pickup_memory_shard_glint_sheet.png`

Godot：
- `Area2D` + `Sprite2D`。
- 拾取时可播放 `GPUParticles2D`：小银屑被吸入玩家胸口。

#### 圣匣日志 UI 首版

用途：
- 玩家在圣匣查看“低语田野日志”。
- 支撑日志碎片列表、当前碎片文本、故事拼合进度。

首版资产：

| 文件 | 尺寸 | 格式 | 用途 |
| --- | ---: | --- | --- |
| `ui_archive_panel_9slice.png` | `512x512` | PNG 九宫格 | 主纸页面板 |
| `ui_archive_tab_field.png` | `256x64` | PNG | 低语田野标签页 |
| `ui_archive_wax_seal.png` | `128x128` | 透明 PNG | 封蜡印 |
| `ui_archive_metal_clip.png` | `128x256` | 透明 PNG | 金属夹 |
| `ui_archive_fragment_slot_9slice.png` | `256x96` | PNG 九宫格 | 左侧碎片条目 |
| `ui_archive_progress_marker.png` | `32x32` | 透明 PNG | 故事进度点 |

Godot：
- `CanvasLayer` 根。
- `Control` 自适应全屏。
- 背板用 `NinePatchRect`。
- 文本用 `RichTextLabel`。
- 列表用 `ScrollContainer`。

## 3. P1 / P2 资产清单

### 3.1 P1：Demo 表达增强

| 资产 | 优先级 | 用途 | 尺寸 / 帧数 | 导出格式 | 透明要求 | Godot 接入 |
| --- | --- | --- | --- | --- | --- | --- |
| 饥民农夫战斗精灵 | P1 | 中距离敌人，播种/投掷/拖尸 | `96x96`；idle 4、walk 6、throw 6、hit 3、death 6 | 透明 PNG spritesheet | 必须透明 | `CharacterBody2D` + `AnimatedSprite2D` |
| 饥饿稻草人战斗精灵 | P1 | 精英敌人，恐惧尖鸣和麦刺封路 | `128x128`；idle 4、chant 8、spike 6、hit 3、death 6 | 透明 PNG spritesheet | 必须透明 | `CharacterBody2D` 或 `StaticBody2D` + `AnimatedSprite2D` |
| 收藏家半身立绘 | P1 | 圣匣引导、档案 UI 气质锚点 | `1200x1600` | 透明 PNG | 必须透明 | `TextureRect` |
| 死亡回收界面首版 | P1 | 死亡后样本档案，而非 Game Over | `1920x1080` 设计稿；面板九宫格 | PNG 九宫格 + 固定 PNG | 按面板需要透明 | `CanvasLayer` + `Control` |
| 血肉麦田背景 | P1 | 关键战斗房底图 | `1920x1080` 分层 | PNG / WebP | 覆盖层透明 | `Sprite2D` / `TileMapLayer` |
| 谷仓背景 | P1 | 精英房或 Boss 前置房 | `1920x1080` 分层 | PNG / WebP | 覆盖层透明 | `Sprite2D` / `ParallaxBackground` |
| 胃囊吞噬 FX | P1 | 击杀回血、碎片吸入 | `96x96`，8 帧 | 透明 PNG sheet | 必须透明 | `AnimatedSprite2D` / `GPUParticles2D` |
| Boss 弱点脉冲 FX | P1 | Boss 进攻窗口 | `128x128`，6 帧或 mask | PNG sheet / mask | 必须透明 | `Sprite2D` + `ShaderMaterial` |

### 3.2 P2：后续扩展

| 资产 | 优先级 | 用途 | 尺寸 / 帧数 | 导出格式 | 透明要求 | Godot 接入 |
| --- | --- | --- | --- | --- | --- | --- |
| 无声圣匣背景 | P2 | 起点、复活、归档空间 | `1920x1080` 分层 | PNG / WebP | 遮挡层透明 | `Sprite2D` |
| 低语田野入口背景 | P2 | 进入田野的主题建立 | `1920x1080` 分层 | PNG / WebP | 遮挡层透明 | `Sprite2D` |
| 肠道灌溉渠背景 | P2 | 危险地面房间 | `1920x1080` 分层 | PNG / WebP | 覆盖层透明 | `Sprite2D` |
| 谷仓王完整立绘 | P2 | 档案、结算、宣传 | `1600x2200` | 透明 PNG | 必须透明 | `TextureRect` |
| 敌人图鉴小头像 | P2 | 圣匣日志来源标识 | `256x256` | 透明 PNG | 必须透明 | `TextureRect` |
| UI 手写批注贴纸包 | P2 | 档案页面装饰 | `64x64` 到 `512x256` | 透明 PNG | 必须透明 | `TextureRect` |
| 房间标题牌 | P2 | 短句 + 地名展示 | `512x128` 九宫格 | PNG 九宫格 | 边缘透明 | `NinePatchRect` |
| 完整拾取/归档演出 | P2 | 碎片飞入圣匣页面 | `128x128`，12 帧 | 透明 PNG sheet | 必须透明 | `AnimatedSprite2D` |

## 4. 角色动作规格

### 4.1 成本控制原则

- P0/P1 不做 8 方向。
- 普通敌人最多 5 个动作组。
- Boss 首版只做 1 个朝向，靠体型、阶段色和弱点状态表达变化。
- 玩家攻击可用角色动作 + 独立刀光 FX 组合，避免每次重画大面积笔触。
- 需要镜像的动作，源图只画一侧，Godot 中用 `flip_h`。

### 4.2 动作表

| 角色 | 动作 | 帧数 | 方向数 | 备注 |
| --- | --- | ---: | ---: | --- |
| 无韵回响 | idle | 4 | 1 | 胸口胃纹呼吸，银白身体微微漂浮 |
| 无韵回响 | walk | 6 | 2 | 左右镜像，移动轮廓清楚 |
| 无韵回响 | attack | 6 | 2 | 三段攻击可先复用同一动作，通过刀光 FX 区分段数 |
| 无韵回响 | hit | 3 | 1 | 被击中时胃囊短暂闭合 |
| 无韵回响 | death_recover | 6 | 1 | 失败样本被圣匣回收 |
| 空腹者 | idle | 4 | 1 | 喉咙扩张、腹部塌陷 |
| 空腹者 | walk | 6 | 2 | 拖拽、扑近 |
| 空腹者 | bite | 5 | 2 | 攻击前摇必须明显 |
| 空腹者 | hit | 3 | 1 | 身体被银白打散 |
| 空腹者 | death_drop | 6 | 1 | 吐出日志碎片 |
| 饥民农夫 | idle | 4 | 1 | 农具下垂、肩背紧绷 |
| 饥民农夫 | walk | 6 | 2 | 机械劳作感 |
| 饥民农夫 | throw_seed | 6 | 2 | 中距离播种/投掷前摇 |
| 饥民农夫 | melee_tool | 5 | 2 | P1 可选，近身挥农具 |
| 饥民农夫 | hit | 3 | 1 | 农具震落产量牌 |
| 饥民农夫 | death_drop | 6 | 1 | 掉落制度记录碎片 |
| 饥饿稻草人 | idle | 4 | 1 | 木杆、稻草和胃腔空洞摇摆 |
| 饥饿稻草人 | chant | 8 | 1 | 恐惧尖鸣 / 旧命令启动 |
| 饥饿稻草人 | wheat_spike | 6 | 1 | 麦刺封路前摇 |
| 饥饿稻草人 | hit | 3 | 1 | 稻草散落，晶片震动 |
| 饥饿稻草人 | death | 6 | 1 | 骨架塌落 |
| 谷仓王 | idle_phase1 | 6 | 1 | 巨腹与谷仓门脸呼吸 |
| 谷仓王 | summon | 8 | 1 | 招唤麦浪或小怪 |
| 谷仓王 | devour | 8 | 1 | 胃液喷口/吞噬 |
| 谷仓王 | weak_expose | 6 | 1 | 腹部撕开红核 |
| 谷仓王 | death | 10 | 1 | 首版短死亡演出 |

## 5. UI 资产规格

### 5.1 生命条

首版：
- 静态 UI。
- 暗红生命液体 + 脏银边框。
- 不做科幻血条，不做高饱和卡通渐变。

资产：
- `ui_hp_frame_9slice.png`：`256x48`，PNG 九宫格。
- `ui_hp_fill.png`：`256x32`，普通 PNG，可横向裁切。
- `ui_hp_damage_flash.png`：`256x32`，可选红银闪光层。

Godot：
- `TextureProgressBar` 或 `Control` + `TextureRect` 裁切。
- 首版不做逐帧动画，受击时用代码 Tween 改颜色/透明度。

### 5.2 胃囊四态

四态：
- 开启：可通过击杀回血，胸口胃纹张开。
- 闭合：受击后暂时失效，图标合拢变暗。
- 溢血：满血击杀触发转刃反馈，红银刀锋。
- 归档：日志碎片被圣匣收纳，图标像器官标签被夹起。

资产：
- `ui_stomach_open.png`：`64x64`，透明 PNG。
- `ui_stomach_closed.png`：`64x64`，透明 PNG。
- `ui_stomach_overflow.png`：`64x64`，透明 PNG。
- `ui_stomach_archive.png`：`64x64`，透明 PNG。

首版：
- 静态图标 + Godot Tween 缩放/闪烁。

后续：
- 每态 4-6 帧小动画。
- 胃囊吞噬时用 `GPUParticles2D` 吸入银白碎片。

### 5.3 日志碎片拾取提示

首版：
- 静态拾取图标 + 1 行短提示。
- 文本由 Godot 渲染，不烘进图片。

资产：
- `pickup_memory_shard.png`：`48x48`。
- `ui_prompt_archive_tag_9slice.png`：`384x96` 九宫格。
- `ui_prompt_interact_key.png`：`64x64`，固定图标，可后续替换键鼠/手柄。

Godot：
- 世界内拾取物：`Area2D`。
- HUD 提示：`CanvasLayer` + `Control`。
- 首版提示文字例：`采样记录`、`归档至圣匣`。

### 5.4 圣匣日志界面

首版布局：
- 左侧：日志碎片列表。
- 右侧：当前碎片文本。
- 底部：故事拼合进度，例如 `低语田野真相 3/5`。
- 顶部：区域标签 `低语田野`。

资产：
- `ui_archive_panel_9slice.png`
- `ui_archive_fragment_slot_9slice.png`
- `ui_archive_fragment_slot_selected_9slice.png`
- `ui_archive_wax_seal.png`
- `ui_archive_metal_clip.png`
- `ui_archive_organ_label.png`
- `ui_archive_progress_marker.png`

首版：
- 静态界面。
- 切页和选中态用 Godot UI 状态控制。

后续：
- 碎片归档飞入页面动画。
- 纸页轻微抖动、油渍扩散 shader。
- 完整故事拼合后出现封蜡盖章动画。

### 5.5 死亡回收界面

首版定位：
- 不是 `Game Over`。
- 是“失败样本档案 / 圣匣回收报告”。

资产：
- `ui_recovery_panel_9slice.png`：主纸页。
- `ui_recovery_sample_frame.png`：样本框。
- `ui_recovery_stamp_failed.png`：失败样本章。
- `ui_recovery_return_button_9slice.png`：返回圣匣按钮。

首版：
- 静态界面 + 少量透明度 Tween。
- 文本由 Godot 渲染。

后续：
- 玩家残影被夹入档案。
- 死因标签自动贴到纸页上。

## 6. 美术制作流程建议

### 6.1 第一轮先画什么

第一轮只画 6 项：
1. 低语田野视觉基准图。
2. 无韵回响 P0 战斗精灵。
3. 空腹者 P0 战斗精灵。
4. 谷仓王 P0 首版 Boss 精灵。
5. 日志碎片掉落物。
6. 圣匣日志 UI 首版。

不要第一轮就画完整世界地图、十城邦、全 Boss 图鉴、大量装备图标或完整动画过场。

### 6.2 从视觉基准图拆出 Godot 可用资产

拆分步骤：
1. 在视觉基准图里确定 5 个固定色彩角色：枯金麦田、腐红血肉、骨白残骸、脏银神血、黑绿腐败。
2. 从图里裁出 3-5 个可复用材质样本：纸页油渍、银白晶片、肉质麦穗、谷仓木纹、金属夹。
3. 把大图拆成战斗需要的层：地面、危险覆盖、前景遮挡、远景剪影、UI 纹理。
4. 用 `1920x1080` 背景层做首版房间。
5. 后续再把可重复地面拆成 TileMap，不在 P0 强行做完整 TileSet。

### 6.3 保证油画感不影响战斗可读性

硬性规则：
- 战斗精灵用厚涂色块和清晰剪影，不追求立绘级细碎笔触。
- 玩家、敌人、Boss 弱点必须有稳定识别色：玩家银白，胃囊暗红，日志碎片冷银，Boss 弱点高饱和红。
- 攻击前摇、可受击窗口、危险地面用形状表达，不只靠细节纹理。
- 同屏战斗时，角色边缘必须从背景中跳出来。可用暗描边、冷银边光或底部投影，但不要二次元黑线描。
- UI 不遮挡战斗空间，首版优先贴边和角落。

### 6.4 命名文件规范

命名格式：

```text
<category>_<subject>_<action>[_direction|state][_sheet].png
```

分类建议：
- `player_`
- `enemy_`
- `boss_`
- `pickup_`
- `fx_`
- `ui_`
- `bg_`
- `portrait_`
- `art_key_`

示例：

```text
player_echo_idle_sheet.png
player_echo_attack_side_sheet.png
enemy_empty_walk_side_sheet.png
enemy_farmer_throw_seed_side_sheet.png
enemy_scarecrow_chant_sheet.png
boss_barn_king_weak_expose_sheet.png
pickup_memory_shard.png
fx_slash_silver_side_sheet.png
ui_archive_panel_9slice.png
bg_field_floor_base.png
portrait_collector_halfbody.png
art_key_low_whispering_field_1920.png
```

目录建议：

```text
assets/art/key/
assets/sprites/player/
assets/sprites/enemies/
assets/sprites/bosses/
assets/sprites/pickups/
assets/sprites/fx/
assets/sprites/ui/
assets/backgrounds/field/
assets/portraits/
assets/source/
```

导出附带说明：
- 每个 spritesheet 需要一行说明：单帧尺寸、帧数、播放 FPS、是否循环、是否可镜像。
- 例：`player_echo_attack_side_sheet.png: frame 96x96, frames 6, fps 12, loop false, flip_h allowed`。

### 6.5 Godot 导入设置建议

通用：
- PNG 原图放入 `res://assets/...`。
- `.import` 文件需要提交版本管理。
- `.godot/imported/` 不提交。

角色与 UI：
- 压缩：Lossless。
- Filter：Linear 或项目统一默认。若笔触糊成一团，可单独关闭过滤测试。
- Mipmaps：关闭。
- Fix Alpha Border：开启。

大背景：
- 可用 VRAM Compressed 或 Lossy，根据画质测试决定。
- 如果 Camera2D 会缩放，背景可开启 mipmaps。
- 透明前景层优先 Lossless。

粒子贴图：
- 小尺寸 PNG，Lossless。
- 用 Godot 粒子系统调数量、颜色和速度，不要为每种方向输出大量大图。

## 7. 给绘制者的第一批任务单

下面内容可以直接发给画师执行。

### 任务 A：低语田野视觉基准图

输入：
- 游戏名：《神烬使徒 / Apostles of God-Ash》。
- 区域：低语田野。
- 关键词：古典油画厚涂、宗教仪式、农业恐怖、活体农田、饥荒制度、银白神血、暗红胃囊。
- 禁止：像素风、赛博 UI、二次元描线、高饱和卡通、3D 写实概念图。

输出：
- `art_key_low_whispering_field_1920.png`，`1920x1080`。
- 分层源文件：`art_key_low_whispering_field_source.psd`。
- 附 5 个取色块：枯金、腐红、骨白、脏银、黑绿。

验收标准：
- 一眼能看出不是普通农田，而是被饥荒和献祭制度改造的活体农田。
- 画面里同时有农业、宗教仪式、血肉/胃囊、银白记忆碎片元素。
- 后续能从图中拆出背景层、UI 材质和敌人色彩。

### 任务 B：无韵回响 P0 战斗精灵

输入：
- 角色定位：没有固定人格的容器，银白身体，胸口有暗红胃纹，无明确脸。
- 战斗视角：俯视斜角 2D。
- 风格：简化手绘油画感，剪影清楚。

输出：
- `player_echo_idle_sheet.png`：`96x96`，4 帧。
- `player_echo_walk_side_sheet.png`：`96x96`，6 帧，可左右镜像。
- `player_echo_attack_side_sheet.png`：`96x96`，6 帧，可左右镜像。
- `player_echo_hit_sheet.png`：`96x96`，3 帧。
- `player_echo_death_recover_sheet.png`：`96x96`，6 帧。

验收标准：
- 透明背景，无脏边。
- 缩小到屏幕 48-64 px 高仍能认出玩家。
- 攻击方向和受击状态清楚。
- 胸口胃纹在 idle、hit、death_recover 中可见。

### 任务 C：空腹者 P0 战斗精灵

输入：
- 敌人定位：早期饥荒感染者，干瘪腹部，大嘴/喉咙扩张，像空袋子拖着人形骨架。
- 机制：短距离扑咬，低血量更急躁。

输出：
- `enemy_empty_idle_sheet.png`：`96x96`，4 帧。
- `enemy_empty_walk_side_sheet.png`：`96x96`，6 帧，可左右镜像。
- `enemy_empty_bite_side_sheet.png`：`96x96`，5 帧，可左右镜像。
- `enemy_empty_hit_sheet.png`：`96x96`，3 帧。
- `enemy_empty_death_drop_sheet.png`：`96x96`，6 帧，最后表现吐出/掉落日志碎片。

验收标准：
- 与玩家剪影明显不同。
- bite 前摇清楚，玩家能读出攻击将发生。
- 死亡动画能自然衔接日志碎片掉落。

### 任务 D：谷仓王 P0 Boss 精灵

输入：
- Boss 定位：谷仓、胃、王权和献祭制度的集合体。
- 关键故事：他曾经想吃掉饥荒，后来饥荒学会了用他的嘴说话。
- 战斗需要：召唤、吞噬、弱点暴露、死亡。

输出：
- `boss_barn_king_idle_phase1_sheet.png`：`256x256` 或 `320x320`，6 帧。
- `boss_barn_king_summon_sheet.png`：8 帧。
- `boss_barn_king_devour_sheet.png`：8 帧。
- `boss_barn_king_weak_expose_sheet.png`：6 帧。
- `boss_barn_king_death_sheet.png`：10 帧。
- `boss_barn_king_weak_core.png`：透明 PNG，红色弱点核心。

验收标准：
- 缩小到战斗画面仍能看出 Boss 是“谷仓王”，不是普通大怪。
- 弱点暴露必须高可读，红核和主体分离明显。
- 动作量控制在首版可完成范围，不做复杂过场。

### 任务 E：日志碎片掉落物

输入：
- 物件定位：击杀后掉落的记忆样本，不是金币，不是普通经验球。
- 视觉：银白晶片 / 油渍纸页残片 / 冷青裂纹。

输出：
- `pickup_memory_shard.png`：`48x48`，透明 PNG。
- 可选 `pickup_memory_shard_glint_sheet.png`：`48x48`，4 帧闪烁。

验收标准：
- 在暗红和枯金背景上都能看清。
- 看起来像“可归档的记忆碎片”，不是宝石货币。

### 任务 F：圣匣日志 UI 首版

输入：
- UI 定位：圣匣档案系统，旧医学记录、油渍纸页、封蜡、金属夹、手写批注、器官标本标签。
- 功能：左侧碎片列表，右侧文本，底部进度。
- 禁止：赛博、霓虹、科幻扫描、普通 RPG 背包皮肤。

输出：
- 一张 `1920x1080` UI 设计稿。
- 切图：
  - `ui_archive_panel_9slice.png`
  - `ui_archive_fragment_slot_9slice.png`
  - `ui_archive_fragment_slot_selected_9slice.png`
  - `ui_archive_wax_seal.png`
  - `ui_archive_metal_clip.png`
  - `ui_archive_organ_label.png`
  - `ui_archive_progress_marker.png`

验收标准：
- 能直接在 Godot 用 `NinePatchRect` 和 `TextureRect` 拼出界面。
- 文本区域留白足够，不把正文烘进图片。
- 圣匣日志界面看起来像世界观的一部分，而不是外置菜单。

