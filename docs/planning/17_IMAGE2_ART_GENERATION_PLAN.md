# 《神烬使徒》Image2 美术生成方案

本文给 image2 / AI 图像生成模型操作者使用，用于批量生成《神烬使徒 / Apostles of God-Ash》第一批视觉资产参考。它不是宣传文案，也不是最终可直接导入的精灵表，而是让不熟悉项目的人也能按统一规则生成可二次整理、可切图、可进入 Godot 2D 房间制 Demo 的美术素材。

本项目不是《以撒》式纯俯视，也不是《空洞骑士》式横版，而是更接近《哈迪斯》的 3/4 斜俯视房间制动作肉鸽。

当前玩法形态已经确定：
- 16:9 横屏。
- 哈迪斯式 3/4 斜俯视房间制动作肉鸽。
- 主要参考《哈迪斯》的 3/4 斜俯视、房间推进、近战动作、Boss 演出、角色和场景体积感。
- 部分参考《以撒的结合》的房间清场、掉落碎片、局内收集、用房间推进叙事。
- 不是《空洞骑士》式横版平台动作，不做侧视平台地形。

当前美术强度修正：
- 可以更卡通化、更亲和，但不是 Q 版幼态。
- 保留暗黑奇幻、宗教仪式、农业异化和圣匣档案感。
- 降低直观恐怖、血腥、露骨器官、惊悚海报感。
- 用枯麦、旧谷仓、封蜡、金属夹、记忆晶片、暗红胃囊符号表达不安，而不是满屏血肉。

## 1. 总体生成原则

### 1.1 玩法视角优先

所有 image2 提示词必须明确：
- 本项目是 16:9 横屏、哈迪斯式 3/4 斜俯视房间制。
- 房间背景必须是哈迪斯式斜俯视房间构图，有清晰地面、边界、障碍、危险区域位置和战斗留白。
- 玩家和敌人在同一地面平面内战斗。
- 不要横版平台侧视，不要跳台结构，不要侧面剖面地形。
- 战斗角色、敌人、Boss 概念都必须是 `3/4 top-down / three-quarter isometric-like view`。
- 不要正面立绘，不要纯俯视圆饼，不要横版侧视。
- 角色精灵要是斜俯视小体型角色，能看到头肩、胸口胃纹、身体前后层次。
- Boss 要是斜俯视大体积 Boss，能在房间内战斗，不要画成横版背景里的巨大侧脸怪。

### 1.2 风格优先级

正式方向：
- 2D 手绘。
- 油画感厚涂，但要服务游戏可读性。
- 暗黑奇幻。
- 宗教仪式感。
- 农业异化 / 农业恐怖的轻量表达。
- 圣匣档案 UI。

禁止方向：
- 像素风。
- 日系二次元描线。
- 3D 写实渲染。
- 科幻赛博 UI。
- 高饱和卡通。
- 正面海报角色合集。
- 横版平台关卡。
- 露骨血腥、器官堆叠、恐怖电影海报。

### 1.3 卡通化边界

本项目允许“卡通一点”，但卡通化的意思是：
- 轮廓更清楚。
- 角色比例更易读。
- 表情和形体不吓人。
- 血肉符号更抽象。
- 颜色更温和、更低饱和。

不是：
- Q 版大头小身。
- 儿童绘本甜美风。
- 明亮糖果色。
- 搞笑怪物。
- 过度可爱宠物化。

推荐关键词：
- 中文：3/4斜俯视、哈迪斯式房间制构图、斜俯视动作肉鸽战斗场景、可用于Godot 2D的斜俯视游戏资产、暗黑童话、手绘厚涂、低饱和、可读剪影、温和怪诞、档案感、枯麦、脏银、封蜡。
- English: three-quarter top-down view, Hades-like isometric action roguelite room, 3/4 overhead perspective, playable game asset, clear combat readability, soft dark fantasy, stylized hand-painted, readable silhouettes, restrained horror, archive UI, withered wheat, dirty silver, wax seal.

### 1.4 Godot 可处理原则

image2 生成图必须能被二次处理成 Godot 资产：
- 背景图要能切成地面、边界、前景遮挡、危险区覆盖层。
- 角色图要能抠出透明背景，并二次整理成 spritesheet。
- UI 图要能拆成九宫格面板、按钮、图标、纸页底图。
- 日志碎片图标要能导出透明 PNG，并在 48x48 或 64x64 下可读。
- 不要把大量文字烘进图里；游戏文本由 Godot 渲染。

## 2. P0 美术生成清单

P0 是第一轮必须生成的图，不追求完整世界观资产库，只服务低语田野 Demo 的最小闭环。

| 优先级 | 资产 | 建议文件名 | 推荐尺寸 | 透明背景 | 是否分层 | 用途 |
| --- | --- | --- | ---: | --- | --- | --- |
| P0-1 | 低语田野视觉基准图 | `art_key_low_whispering_field_1920.png` | `1920x1080` | 否 | 不强制 | 确定整体风格 |
| P0-2 | 低语田野房间背景基准 | `bg_field_room_baseline_1920.png` | `1920x1080` | 否 | 后期需要切层 | Godot 房间制背景参考 |
| P0-3 | 无韵回响玩家战斗精灵概念 | `concept_player_echo_turnaround.png` | `1536x1024` | 是，或纯色背景便于抠图 | 不强制 | 后续整理成 spritesheet |
| P0-4 | 空腹者敌人战斗精灵概念 | `concept_enemy_empty_one.png` | `1536x1024` | 是，或纯色背景便于抠图 | 不强制 | 基础敌人精灵参考 |
| P0-5 | 饥民农夫敌人战斗精灵概念 | `concept_enemy_famine_farmer.png` | `1536x1024` | 是，或纯色背景便于抠图 | 不强制 | 中距离敌人参考 |
| P0-6 | 谷仓王 Boss 三阶段概念 | `concept_boss_barn_king_phases.png` | `2048x1152` | 透明或简单灰底 | 不强制 | Boss 主体与弱点设计 |
| P0-7 | 日志碎片 / 记忆晶片图标 | `icon_memory_shard_variants.png` | `1024x1024` | 是，或纯色背景便于抠图 | 不强制 | 掉落物与 UI 图标 |
| P0-8 | 圣匣日志 UI 概念 | `ui_archive_concept_1920.png` | `1920x1080` | 否 | 后期需要切 UI | 日志碎片系统核心界面 |

## 3. 每项资产的 Image2 提示词模板

所有模板都可以直接复制给图像模型。若模型支持透明背景，角色和图标类资产使用透明背景；若不支持，使用纯浅灰或纯绿色背景，后期抠图。

### 3.1 低语田野视觉基准图

用途：
- 确定低语田野的整体风格、色彩、材质和恐怖强度。
- 不是可直接游戏资产，不要求切成房间。

推荐比例与尺寸：
- 16:9。
- `1920x1080`。

透明 / 分层：
- 不透明背景。
- 不强制分层，但画面要能提取配色和材质。

中文正向 prompt：

```text
为 2D 手绘暗黑奇幻动作肉鸽《神烬使徒》生成一张“低语田野”视觉基准图。画面是 16:9 横屏关键视觉，服务哈迪斯式 3/4 斜俯视房间制动作肉鸽，不是海报角色合集。风格为手绘油画厚涂、低饱和暗黑童话、宗教仪式感、农业异化。场景包含枯金麦田、旧谷仓、低矮栅栏、旧农具、脏银色记忆晶片、油渍纸页、封蜡和轻微暗红胃囊符号。整体要有不安和神秘感，但不要露骨恐怖。画面应适合后续拆出可用于Godot 2D的斜俯视游戏资产：房间背景、角色配色和圣匣 UI 材质参考。使用温和怪诞、可读轮廓、清晰明暗层次。
```

English prompt:

```text
Create a 16:9 visual key art reference for the 2D hand-painted dark fantasy action roguelite "Apostles of God-Ash", area: Low Whispering Field. The project is a Hades-like isometric action roguelite room game in a three-quarter top-down view, not a character poster. Use a stylized oil-painting feel, soft dark fantasy, low saturation, ritual atmosphere, and agricultural uncanny mood. Show withered golden wheat, an old barn, low fences, worn farming tools, dirty silver memory shards, oil-stained archive paper, wax seals, and subtle dark red stomach-symbol motifs. The mood should be mysterious and uneasy but not gory or horror-poster-like. The image should provide color, material, and mood references for later Godot 2D three-quarter game assets, room backgrounds, character palettes, and Sacred Casket archive UI. Readable silhouettes, clear value separation, restrained body-horror symbols.
```

Negative prompt：

```text
side-scrolling platformer, side view, Hollow Knight style, front-facing character portrait, front-facing hero poster, pure top-down flat icon view, poster composition, cinematic close-up only, 3D render, photorealistic, pixel art, anime line art, cyberpunk UI, neon sci-fi, high saturation cartoon, cute chibi, exposed organs, gore, blood splatter, horror movie poster, jump scare, text, logo, watermark
```

构图要求：
- 16:9 横屏。
- 可以是环境关键视觉，但不要变成电影海报。
- 要能看出低语田野的农业、档案、神性和胃囊符号。

验收标准：
- 2 秒内能看出是“暗黑童话式异化农田”，不是普通农田。
- 恐怖强度可接受，不让玩家产生生理不适。
- 可提取 5 组基准色：枯金、暗褐、骨白、脏银、低饱和暗红。

### 3.2 低语田野房间背景基准

用途：
- 为 Godot 房间制战斗提供背景构图参考。
- 必须服务实际玩法空间。

推荐比例与尺寸：
- 16:9。
- `1920x1080`。

透明 / 分层：
- 不透明背景。
- 后期需要拆成地面、边界、前景遮挡、危险区覆盖层。

中文正向 prompt：

```text
生成一张 Godot 2D 房间制动作肉鸽的低语田野战斗房间背景基准图。必须是 16:9 横屏、3/4斜俯视、哈迪斯式房间制构图、斜俯视动作肉鸽战斗场景，不是横版平台侧视，也不是纯俯视平面图。画面中心留出清晰可走的战斗区域，四周可放麦田、谷仓门、灌溉渠、献祭柱、低矮栅栏、旧农具、破谷袋、轻微暗红异化麦穗和脏银记忆晶片。地面、边界、障碍、危险区位置和战斗留白都要清楚。风格是 2D 手绘油画感、卡通化暗黑奇幻、低饱和、温和怪诞，不要血腥。画面要适合拆成可用于Godot 2D的斜俯视游戏资产：地面、边界道具、前景遮挡、危险覆盖层。
```

English prompt:

```text
Create a practical Godot 2D combat room background reference for a Hades-like isometric action roguelite room, area: Low Whispering Field. 16:9 landscape composition, three-quarter top-down view, 3/4 overhead perspective, not a side-scrolling platformer and not a pure top-down flat map. Leave a clear readable walkable combat area in the center. Around the edges show withered wheat, a barn door boundary, irrigation canal edges, sacrificial posts, low fences, old farming tools, torn grain sacks, subtle dark red corrupted wheat, and dirty silver memory shards. The floor, boundaries, obstacles, danger zones, and empty combat space must be readable. Style: stylized 2D hand-painted oil-painting feel, soft dark fantasy, slightly cartoony, low saturation, restrained uncanny agricultural mood, no gore. The image should be a playable game asset reference with clear combat readability, suitable for later layer extraction in Godot: floor, boundary props, foreground occluders, and danger overlays.
```

Negative prompt：

```text
side-scrolling platformer, side view, platformer level, vertical scrolling, pure top-down flat icon view, poster composition, cinematic close-up only, cinematic landscape only, no walkable space, dense clutter, front-facing character portrait, 3D render, pixel art, anime, cyberpunk, neon, high saturation, gore, exposed organs, horror poster, front-facing characters, text, labels, logo, watermark
```

构图要求：
- 16:9 横屏固定房间。
- 哈迪斯式 3/4 斜俯视房间构图。
- 摄像机在上方偏斜角，能看见地面、边界、障碍、危险区和战斗留白。
- 中央必须空出来给玩家移动。
- 不要画成横向卷轴关卡。

验收标准：
- 程序能一眼判断哪里能走、哪里是边界、哪里可能是危险区。
- 缩小到游戏画面仍可读。
- 恐怖元素只作为符号，不抢战斗可读性。

### 3.3 无韵回响玩家战斗精灵概念

用途：
- 生成玩家角色的哈迪斯式 3/4 斜俯视小体型概念。
- 后续由美术二次整理成 `96x96` spritesheet。

推荐比例与尺寸：
- `1536x1024`。
- 单图放 3-5 个小姿态：idle、walk、attack、hit。

透明 / 分层：
- 优先透明背景。
- 若 image2 不支持透明，用纯浅灰背景，方便抠图。

中文正向 prompt：

```text
生成《神烬使徒》玩家角色“无韵回响”的战斗精灵概念图。角色必须是 3/4斜俯视小体型战斗角色、哈迪斯式动作肉鸽角色视角、可用于Godot 2D的斜俯视游戏资产，不是正面立绘，不是纯俯视圆饼，不是海报人物。银白色身体，能看到头肩、胸口暗红胃纹、身体前后层次，没有明确脸部，轮廓清楚，动作可读。风格为 2D 手绘厚涂、轻微卡通化暗黑奇幻、低饱和。请在同一张图里给出 4 个小姿态参考：待机、移动、横向攻击、受击。背景透明或纯浅灰。角色要适合后续整理成 Godot `96x96` 战斗 spritesheet。
```

English prompt:

```text
Create a combat sprite concept sheet for the player character "Unrhymed Echo" from Apostles of God-Ash. The character must be a small three-quarter top-down view gameplay sprite, a 3/4 overhead perspective Hades-like action roguelite character, not a front-facing character portrait, not a pure top-down flat icon view, and not a poster character. Dirty silver body, visible head and shoulders, visible dark red stomach mark on the chest, clear front/back body layering, no clear face, readable silhouette, clear action poses. Style: stylized 2D hand-painted, slightly cartoony soft dark fantasy, low saturation. Show 4 small pose references on one sheet: idle, movement, side attack, hit reaction. Transparent background if possible, otherwise plain light gray background. The design must be a playable game asset suitable for later cleanup into a Godot `96x96` combat spritesheet.
```

Negative prompt：

```text
front-facing character portrait, front portrait, pure top-down flat icon view, full illustration background, side-scrolling platformer, side view, side-scrolling platformer pose, poster composition, cinematic close-up only, tall realistic human, anime, chibi, pixel art, 3D render, photorealistic, horror monster, gore, exposed organs, high saturation, complex cape covering silhouette, text, labels, logo, watermark
```

构图要求：
- 角色姿态小而清楚。
- 不要有复杂背景。
- 攻击方向要能看懂。

验收标准：
- 缩到 48-64 px 高仍能看出玩家身份。
- 胸口胃纹可见但不恶心。
- 角色不吓人，偏神秘容器感。

### 3.4 空腹者敌人战斗精灵概念

用途：
- 基础近战敌人概念。
- 后续整理成 `96x96` spritesheet。

推荐比例与尺寸：
- `1536x1024`。
- 单图放 3-5 个小姿态。

透明 / 分层：
- 优先透明背景。
- 不支持透明时用纯浅灰。

中文正向 prompt：

```text
生成《神烬使徒》敌人“空腹者”的战斗精灵概念图。角色必须是 3/4斜俯视小体型敌人、哈迪斯式动作肉鸽敌人视角、可用于Godot 2D的斜俯视游戏资产，不是正面怪物立绘，不是纯俯视圆饼。它是被饥荒影响的干瘪饥民，能看到头肩、塌陷腹部、喉咙和空碗意象，身体有前后层次，动作像被饥饿牵引向前，但不要血腥、不要露骨器官、不要惊悚。风格为 2D 手绘厚涂、轻微卡通化暗黑奇幻、低饱和、可读剪影。请给出待机、拖行、扑咬、受击 4 个小姿态。背景透明或纯浅灰，适合后续整理成 Godot `96x96` spritesheet。
```

English prompt:

```text
Create a combat sprite concept sheet for the enemy "Empty One" from Apostles of God-Ash. The enemy must be a small three-quarter top-down view gameplay sprite, a 3/4 overhead perspective Hades-like action roguelite enemy, not a front-facing monster portrait and not a pure top-down flat icon view. It is a famine-touched gaunt villager with visible head and shoulders, collapsed belly, throat and empty-bowl motifs, clear front/back body layering, moving as if pulled forward by hunger. Keep it readable and unsettling but not gory, not exposed-organ horror, not frightening. Style: stylized 2D hand-painted, slightly cartoony soft dark fantasy, low saturation, strong silhouette. Show 4 small pose references: idle, dragging walk, bite/lunge, hit reaction. Transparent background if possible, otherwise plain light gray. Suitable as a playable game asset for cleanup into a Godot `96x96` spritesheet.
```

Negative prompt：

```text
front-facing character portrait, front-facing horror creature, pure top-down flat icon view, side-scrolling platformer, side view, side-view platformer, poster composition, cinematic close-up only, gore, blood, exposed organs, zombie horror, realistic corpse, jump scare, anime, chibi, pixel art, 3D render, high saturation cartoon, complex background, text, labels, logo, watermark
```

构图要求：
- 3/4 斜俯视小角色。
- 能看到头肩、胸腹和身体前后层次。
- 喉咙 / 空碗 / 塌陷腹部是符号化表达，不要生理恐怖。

验收标准：
- 和玩家剪影明显不同。
- bite 前摇能读。
- 怪异但不恶心。

### 3.5 饥民农夫敌人战斗精灵概念

用途：
- 中距离敌人概念。
- 体现“劳动动作被制度化成攻击”。

推荐比例与尺寸：
- `1536x1024`。
- 单图放 4 个小姿态。

透明 / 分层：
- 优先透明背景。
- 不支持透明时用纯浅灰。

中文正向 prompt：

```text
生成《神烬使徒》敌人“饥民农夫”的战斗精灵概念图。角色必须是 3/4斜俯视小体型敌人、哈迪斯式动作肉鸽敌人视角、可用于Godot 2D的斜俯视游戏资产，不是正面立绘，不是纯俯视圆饼。它是被献祭制度训练成劳动执行者的农夫，能看到头肩、胸腹、身体前后层次，穿破旧农衣，拿播种袋、镰刀或草叉，动作像播种、记录产量、执行劳作，而不是普通战士挥刀。风格为 2D 手绘厚涂、卡通化暗黑奇幻、低饱和、可读剪影。不要血腥，不要恐怖脸。请给出待机、播种投掷、挥农具、受击 4 个小姿态。背景透明或纯浅灰，适合后续整理成 Godot `96x96` spritesheet。
```

English prompt:

```text
Create a combat sprite concept sheet for the enemy "Famine Farmer" from Apostles of God-Ash. The character must be a small three-quarter top-down view gameplay sprite, a 3/4 overhead perspective Hades-like action roguelite enemy, not a front portrait and not a pure top-down flat icon view. This farmer is an agricultural labor enforcer shaped by a ritual famine system: visible head and shoulders, clear chest/body layering, worn farm clothes, seed bag, sickle or pitchfork, poses that feel like sowing, recording harvest, and executing labor, not like a normal warrior. Style: stylized 2D hand-painted, slightly cartoony soft dark fantasy, low saturation, readable silhouette. No gore, no scary horror face. Show 4 small pose references: idle, seed throw/sowing, tool swing, hit reaction. Transparent background if possible, otherwise plain light gray. Suitable as a playable game asset for cleanup into a Godot `96x96` spritesheet.
```

Negative prompt：

```text
generic knight, front-facing character portrait, front portrait, pure top-down flat icon view, side-scrolling platformer, side view, poster composition, cinematic close-up only, horror gore, zombie, exposed organs, anime, chibi, pixel art, 3D render, photorealistic, high saturation cartoon, cyberpunk, complex background, text, labels, logo, watermark
```

构图要求：
- 姿态像劳动，不像格斗游戏角色。
- 农具要读得清楚。

验收标准：
- 玩家能从动作看出“播种 / 投掷 / 劳作攻击”。
- 不像普通强盗或士兵。
- 可缩小到战斗画面使用。

### 3.6 谷仓王 Boss 概念

用途：
- Boss 主体、三阶段和弱点设计。
- 后续整理成 Boss 精灵、弱点子节点和阶段视觉反馈。

推荐比例与尺寸：
- `2048x1152`。
- 横向排三阶段：仓门紧闭、仓门裂开、红核暴露。

透明 / 分层：
- 透明背景或简单中性灰底。
- 不要复杂场景背景。

中文正向 prompt：

```text
生成《神烬使徒》Boss“谷仓王”的三阶段概念图。必须是 3/4斜俯视大体积 Boss、哈迪斯式房间制 Boss 战素材参考、可用于Godot 2D的斜俯视游戏资产，不是正面海报，不是纯俯视图标，不是横版背景里的巨大侧脸怪。请横向展示三个阶段：1 仓门紧闭，像旧谷仓和王权祭坛结合；2 仓门裂开，露出暗红胃囊符号和脏银神性裂光；3 红核暴露，弱点清楚可读。Boss 要有清楚体积，能在 16:9 斜俯视房间内与玩家战斗。整体风格为 2D 手绘厚涂、卡通化暗黑奇幻、宗教仪式感、农业异化。Boss 要有谷仓、胃、王权、献祭制度的融合感，但不要露骨器官，不要血腥，不要恐怖电影怪物。背景透明或纯灰，轮廓清楚，适合后续整理成 Godot Boss 精灵。
```

English prompt:

```text
Create a three-phase boss concept sheet for "Barn King" from Apostles of God-Ash. It must be a large-volume three-quarter top-down view boss gameplay asset, a 3/4 overhead perspective Hades-like isometric action roguelite room boss, not a front-facing poster, not a pure top-down flat icon view, and not a giant side-face monster in a side-scrolling background. Show three phases horizontally: 1 closed barn door, combining an old barn with a royal ritual altar; 2 cracked barn door, revealing subtle dark red stomach-symbol motifs and dirty silver divine cracks; 3 exposed red core, with a very clear readable weak point. The boss must feel like it can fight inside a 16:9 three-quarter room. Style: stylized 2D hand-painted, slightly cartoony soft dark fantasy, ritual atmosphere, agricultural uncanny mood. The boss should fuse barn, stomach, kingship, and sacrifice-system imagery, but no exposed organs, no gore, no horror movie monster. Transparent background or plain gray, clear silhouette, suitable as a playable game asset for later cleanup into a Godot boss sprite.
```

Negative prompt：

```text
front-facing character portrait, front horror poster, pure top-down flat icon view, side-scrolling platformer, side view, side-view platformer boss, giant side-face monster, poster composition, cinematic close-up only, gore, exposed intestines, blood, realistic monster, 3D render, photorealistic, anime, pixel art, chibi, sci-fi machine, neon cyber UI, high saturation, dense background, text, labels, logo, watermark
```

构图要求：
- 三阶段横向排列。
- 弱点必须清楚。
- 视角必须能用于哈迪斯式 3/4 斜俯视 Boss 战。
- Boss 是可放进房间内战斗的大体积单位，不是背景侧脸。

验收标准：
- 缩小后仍能看出三阶段差异。
- 红核暴露一眼能读。
- 恐怖强度被控制在暗黑童话范围内。

### 3.7 日志碎片 / 记忆晶片图标

用途：
- 击杀掉落物。
- 圣匣日志 UI 列表图标。
- 日志碎片系统是下一阶段核心系统，图标必须有记忆采样感。

推荐比例与尺寸：
- `1024x1024` 概念板。
- 生成 3-5 个变体。
- 后续导出为 `48x48`、`64x64`、`128x128` PNG。

透明 / 分层：
- 优先透明背景。
- 不支持透明时用纯色背景。

中文正向 prompt：

```text
生成《神烬使徒》“日志碎片 / 记忆晶片”图标变体，一张图里放 5 个不同小图标。它们是敌人死亡后掉落的记忆样本，可进入圣匣日志 UI。视觉应结合半透明脏银晶片、油渍纸页残片、封蜡小印、冷青裂纹和轻微神性光。风格为 2D 手绘图标、低饱和、卡通化暗黑奇幻、清晰剪影。不要像金币、宝石货币或普通经验球。背景透明或纯浅灰，图标要适合缩小到 48x48 仍可读。
```

English prompt:

```text
Create an icon variant sheet for "log fragments / memory shards" from Apostles of God-Ash. Place 5 different small icons on one image. These are memory samples dropped by enemies and archived into the Sacred Casket log UI. Combine translucent dirty-silver crystal shards, oil-stained paper scraps, tiny wax seals, cold cyan cracks, and subtle divine glow. Style: 2D hand-painted game icons, low saturation, slightly cartoony soft dark fantasy, clear silhouettes. Do not make them look like coins, gem currency, or generic XP orbs. Transparent background if possible, otherwise plain light gray. The icons must remain readable at 48x48.
```

Negative prompt：

```text
gold coin, normal gem, generic loot orb, sci-fi hologram, cyber UI, pixel art, anime, 3D render, photorealistic, side-scrolling platformer, side view, front-facing character portrait, pure top-down flat icon view as a scene, poster composition, cinematic close-up only, gore, blood, exposed organs, high saturation cartoon, text, labels, logo, watermark
```

构图要求：
- 5 个变体分开摆放。
- 每个图标留出边距，方便抠图。

验收标准：
- 缩到 48x48 仍能识别。
- 看起来是“可归档的记忆”，不是货币。
- 与圣匣 UI 气质一致。

### 3.8 圣匣日志 UI 概念

用途：
- 生成核心日志系统界面概念。
- 作为后续 Godot UI 拆图依据。

推荐比例与尺寸：
- 16:9。
- `1920x1080`。

透明 / 分层：
- 不透明概念图。
- 后续拆成面板、纸页、标签、封蜡、金属夹、图标。

中文正向 prompt：

```text
生成《神烬使徒》圣匣日志 UI 概念图，16:9 横屏界面。它是游戏内“日志碎片系统”的核心界面，不是科幻菜单。布局：左侧是日志碎片列表，右侧是油渍纸页文本区域，底部是真相拼合进度，顶部有低语田野区域标签。视觉元素包括旧医学档案、油渍纸页、封蜡、脏银金属夹、手写批注、器官标本标签和半透明记忆晶片。风格为 2D 手绘、卡通化暗黑奇幻、低饱和、圣匣档案感。不要生成大段可读文字，文字位置用空白线或模糊占位即可。不要赛博 UI，不要霓虹，不要高饱和。
```

English prompt:

```text
Create a 16:9 Sacred Casket log UI concept for Apostles of God-Ash. This is the core interface for the log fragment / memory shard system, not a sci-fi menu. Layout: fragment list on the left, oil-stained paper text page on the right, truth assembly progress at the bottom, Low Whispering Field area tab at the top. Visual elements: old medical archive, oil-stained paper, wax seal, dirty silver metal clips, handwritten annotation marks, specimen labels, translucent memory shards. Style: 2D hand-painted, slightly cartoony soft dark fantasy, low saturation, archive-system mood. Do not generate long readable text; use blank lines or soft placeholder marks only. No cyber UI, no neon, no high saturation.
```

Negative prompt：

```text
cyberpunk UI, sci-fi hologram, neon interface, RPG inventory grid, modern phone app, side-scrolling platformer, side view, front-facing character portrait, pure top-down flat icon view, poster composition, cinematic close-up only, readable paragraphs, English labels, logo, watermark, 3D render, anime, pixel art, high saturation cartoon, gore, exposed organs, horror poster
```

构图要求：
- 16:9 UI 概念。
- 功能区必须清楚：左列表、右文本、底部进度。
- 留白足够，便于后续 Godot Label / RichTextLabel 放文本。

验收标准：
- 一眼能看出是“圣匣档案”，不是普通菜单。
- 日志碎片系统的收集、查看、拼合进度都能从布局读出来。
- UI 可拆成 `NinePatchRect` 面板和 `TextureRect` 图标。

## 4. 房间制视角规范

### 4.1 正确视角

我们的视角是：
- 16:9 横屏。
- 哈迪斯式 3/4 斜俯视房间制。
- 摄像机在房间上方偏前，能看到地面、角色头肩、胸口、身体前后层次和场景体积。
- 不接受纯俯视圆饼化视角作为战斗资产主方向。
- 玩家、敌人、掉落物、危险区都位于同一战斗平面。
- 房间边界围绕战斗区，而不是横向平台。

可以参考的空间组织：
- 《哈迪斯》：主要参考，3/4 斜俯视动作感、房间推进、近战节奏、Boss 体积感和神性反馈。
- 《以撒的结合》：只参考房间清场、掉落碎片、局内收集、推进叙事。
- 《挺进地牢》：地面危险、弹幕、掩体和敌人的可读性。

### 4.2 错误视角

image2 生成时最容易犯的错误：
- 把背景做成横版平台侧视。
- 画出跳台、悬崖、平台边缘、横向通道。
- 把角色画成正面海报立绘。
- 把角色画成纯俯视圆饼或平面图标，完全看不到头肩和胸口层次。
- 只画氛围风景，没有可玩空间。
- 中央区域塞满道具，玩家无法移动。
- Boss 只像正面怪物肖像或横版背景巨大侧脸怪，不能放进房间战斗。
- UI 变成赛博界面或普通 RPG 背包。

### 4.3 房间背景必须包含

每张房间背景都要检查：
- 16:9 横屏。
- 3/4 斜俯视。
- 清晰地面。
- 清晰边界。
- 中央可走战斗空白。
- 四周可放麦田、谷仓门、灌溉渠、献祭柱等边界装饰。
- 2-4 个可读地标道具。
- 危险区域位置或可放危险区的空位。
- 前景遮挡不能盖住核心战斗区域。
- 色彩不要把玩家、敌人、掉落物淹没。

### 4.4 角色战斗素材必须包含

每个角色概念都要检查：
- 3/4 斜俯视小体型。
- 能看到头肩、胸口关键符号和身体前后层次。
- 清楚轮廓。
- 少量动作姿态。
- 不依赖脸部细节识别。
- 缩小后仍能区分玩家、普通敌人、Boss。
- 不把立绘当战斗精灵。
- 不把纯俯视圆饼当战斗精灵。

## 5. 生成后的 Godot 资产处理流程

### 5.1 视觉基准图怎么用

视觉基准图不直接进游戏。它用于：
- 确定低语田野色彩。
- 提取材质样本。
- 给房间背景、角色、UI 统一风格。
- 判断恐怖强度是否过高。

处理步骤：
1. 选出 1 张最适配项目的基准图。
2. 提取 5 组主色：枯金、暗褐、骨白、脏银、低饱和暗红。
3. 裁出材质参考：纸页、封蜡、金属、麦田、记忆晶片。
4. 写入后续资产提示词和画师任务单。

### 5.2 背景怎么切层

从房间背景基准图拆：
- `bg_field_floor_base.png`：地面主层，不透明。
- `bg_field_boundary_props.png`：栅栏、农具、谷袋、边界道具，透明。
- `bg_field_foreground_wheat.png`：前景麦穗和轻遮挡，透明。
- `bg_field_danger_overlay.png`：危险区、异化麦穗、胃囊痕迹，透明。
- `bg_field_collision_ref.png`：碰撞参考，不进最终画面。

Godot 接入：
- P0 可先用 `Sprite2D` 整张底图。
- 透明覆盖层用多个 `Sprite2D` 叠加。
- 后续再拆 `TileMapLayer`。

### 5.3 角色概念怎么整理成 spritesheet

image2 输出通常不是最终 spritesheet，需要二次整理：
1. 选定最清楚的姿态。
2. 抠出透明背景。
3. 统一画布尺寸：普通角色 `96x96`，精英 `128x128`，Boss `256x256` 或 `320x320`。
4. 重画或补间出动作帧。
5. 按动作导出 sheet。
6. 写明单帧尺寸、帧数、FPS、是否循环、是否可镜像。

推荐首版：
- 玩家：idle、walk、attack、hit。
- 空腹者：idle、walk、bite、hit。
- 饥民农夫：idle、walk、throw_seed、hit。
- Boss：phase1、phase2、weak_expose。

### 5.4 日志碎片图标如何导出

处理步骤：
1. 从变体图中选 3-5 个图标。
2. 抠出透明背景。
3. 分别导出：
   - `pickup_memory_shard_01.png`
   - `pickup_memory_shard_02.png`
   - `pickup_memory_shard_03.png`
   - `ui_memory_shard_archive.png`
4. 尺寸导出：
   - `48x48` 世界掉落。
   - `64x64` HUD 提示。
   - `128x128` 圣匣 UI 大图。
5. 在暗背景、枯金背景、纸页背景上分别测试可读性。

### 5.5 UI 概念如何拆成 Godot UI

从圣匣日志 UI 概念拆：
- `ui_archive_panel_9slice.png`：主纸页面板。
- `ui_archive_fragment_slot_9slice.png`：碎片列表条目。
- `ui_archive_fragment_slot_selected_9slice.png`：选中态。
- `ui_archive_wax_seal.png`：封蜡。
- `ui_archive_metal_clip.png`：金属夹。
- `ui_archive_organ_label.png`：标本标签。
- `ui_archive_progress_marker.png`：真相进度点。
- `ui_archive_memory_shard_icon.png`：碎片图标。

Godot 接入：
- 主界面：`CanvasLayer` + `Control`。
- 可拉伸面板：`NinePatchRect`。
- 固定图标：`TextureRect`。
- 列表：`ScrollContainer` + `VBoxContainer`。
- 文本：`RichTextLabel`。

文本处理原则：
- 不把正文烘进图。
- image2 生成的文字全部视为占位。
- 正式中文由 Godot 字体渲染。

## 6. 第一轮交付包

第一轮建议生成 8 组图，共 14-18 张候选：

| 序号 | 文件名建议 | 数量 | 分辨率 | 透明 | 验收重点 |
| --- | --- | ---: | ---: | --- | --- |
| 1 | `art_key_low_whispering_field_1920_v01-v03.png` | 3 | `1920x1080` | 否 | 风格、恐怖强度、色彩基准 |
| 2 | `bg_field_room_baseline_1920_v01-v03.png` | 3 | `1920x1080` | 否 | 哈迪斯式 3/4 斜俯视房间、中心可走、边界清楚 |
| 3 | `concept_player_echo_turnaround_v01-v02.png` | 2 | `1536x1024` | 是或纯浅灰 | 小体型、银白身体、暗红胃纹 |
| 4 | `concept_enemy_empty_one_v01-v02.png` | 2 | `1536x1024` | 是或纯浅灰 | 饥饿符号、非血腥、动作可读 |
| 5 | `concept_enemy_famine_farmer_v01-v02.png` | 2 | `1536x1024` | 是或纯浅灰 | 播种/劳作攻击，不像普通战士 |
| 6 | `concept_boss_barn_king_phases_v01-v02.png` | 2 | `2048x1152` | 是或纯灰 | 三阶段、红核弱点、3/4 斜俯视房间战可用 |
| 7 | `icon_memory_shard_variants_v01-v02.png` | 2 | `1024x1024` | 是或纯浅灰 | 3-5 个变体，48x48 可读 |
| 8 | `ui_archive_concept_1920_v01-v02.png` | 2 | `1920x1080` | 否 | 左列表、右纸页、底部进度、圣匣档案感 |

### 6.1 第一轮总验收标准

必须全部满足：
- 没有横版平台视角。
- 没有正面海报角色冒充战斗素材。
- 没有纯俯视圆饼角色冒充战斗素材。
- 角色能看到头肩、胸口关键符号和身体前后层次。
- Boss 是可放进 16:9 房间战斗的大体积斜俯视单位，不是横版背景侧脸怪。
- 没有像素风、二次元、3D 写实、赛博 UI。
- 恐怖强度适中，不露骨血腥，不堆器官。
- 所有战斗相关图都能服务 16:9 哈迪斯式 3/4 斜俯视房间制。
- 日志碎片系统有明确视觉目标：掉落、拾取、归档、进度拼合。
- 背景、角色、图标、UI 都能被二次处理成 Godot PNG / spritesheet / NinePatchRect 资产。

### 6.2 推荐交付目录

```text
image2_round_01/
  art_key/
  backgrounds/
  characters/
  boss/
  icons/
  ui/
  selected/
  notes.md
```

`notes.md` 记录：
- 每张图使用的 prompt。
- 生成模型和参数。
- 是否透明背景。
- 哪些图通过验收。
- 哪些图因为视角、恐怖强度、可读性或风格偏差被淘汰。
