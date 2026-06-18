# 《神烬使徒》低语田野 10 张场景图需求

本文是给画师或 image2 操作者的场景图任务单。

目标不是再随机生成 10 张气氛图，而是沿着当前垂直切片的游戏进程，把“无声圣匣 -> 低语田野 -> 谷仓王 -> 回圣匣归档”的体验拆成 10 张可执行场景图。

这些图有三层用途：

1. 作为画师理解低语田野的环境叙事参考。
2. 作为 Godot 房间背景、前景遮挡、UI 档案插图的生产依据。
3. 作为后续 image2 批量出图时的稳定 prompt 模板。

## 1. 总体规则

### 1.1 玩法视角

所有可落地到战斗房间的场景图必须遵守：

- `16:9` 横屏。
- 哈迪斯式 `3/4 斜俯视`。
- 能看见地面、边界、障碍、危险区和战斗留白。
- 玩家、敌人和 Boss 都应能站在同一地面平面内。
- 不是横版平台侧视。
- 不是纯俯视地图。
- 不是只服务宣传的海报近景。

### 1.2 风格规则

本批场景图延续乡村静默方向：

- 低饱和麦田。
- 灰褐土地。
- 冷白天空。
- 褪色木屋。
- 旧木板、干草、尘土、粗布、油渍纸。
- 暗红只作为胃囊、伤口、危险区、神烬仪式和日志核心点缀。

参考 Andrew Wyeth 绘画中常见的乡村荒凉、静默、干燥、孤独感，但只提取气质和材质规则：

- 不临摹任何具体作品。
- 不复刻任何构图。
- 不写 `in the style of Andrew Wyeth` 作为唯一风格指令。
- 不做成纯写实插画。
- 不让灰度和纹理压掉战斗可读性。

### 1.3 Godot 拆层要求

每张可进入游戏的房间场景图，建议至少拆成：

```text
bg_xxx_floor.png
bg_xxx_boundary.png
bg_xxx_props_mid.png
bg_xxx_foreground.png
bg_xxx_collision_paintover.png
```

说明：

- `floor`：主地面，不透明，低对比。
- `boundary`：墙、麦田边界、谷仓边、围栏。
- `props_mid`：低矮障碍、农具、空碗、谷袋、木桩。
- `foreground`：透明前景遮挡，只放边缘，不压战斗中心。
- `collision_paintover`：给程序看的阻挡区参考，不进游戏。

## 2. 十张场景图总表

| # | 图名 | 对应游戏进程 | 叙事功能 | 资产用途 | 优先级 |
| --- | --- | --- | --- | --- | --- |
| 01 | 无声圣匣安全区 | 开局 / 死亡回收 | 玩家被保存、拆解、归档的安全房 | 圣匣主界面背景、复活房背景 | P0 |
| 02 | 低语田野入口 | 房间 1 | 第一次进入田野，看到丰收牌和名单 | 第一战斗房背景 | P0 |
| 03 | 空碗排队路 | 房间 1 后 / 日志碎片前史 | 展示饥饿如何被登记和排队 | 过场插图、日志档案图 | P1 |
| 04 | 血肉麦田 | 房间 2 | 引入咬人麦穗和献祭成果 | 第二战斗房背景 | P0 |
| 05 | 肠道灌溉渠 | 房间 3 | 献祭被工程化，渠道成为危险区 | 第三战斗房背景 | P0 |
| 06 | 饥饿谷仓外场 | 房间 4 入口 | 谷仓不再储粮，而是在分配饥饿 | 精英房背景 / 关门演出 | P0 |
| 07 | 稻草人仪式麦场 | 房间 4 战斗 | 旧命令自动化，稻草人守着名单 | 精英战场景图 | P1 |
| 08 | 谷仓王胃室 | 房间 5 Boss | 谷仓、王权和胃囊合为 Boss 场 | Boss 房背景 | P0 |
| 09 | 王的开仓记忆 | Boss 后日志 | 谷仓王曾经打开粮仓救人 | 圣匣故事插图 | P1 |
| 10 | 回圣匣归档真相 | 回圣匣 / 第一故事拼接 | 击杀不是刷怪，而是采样和归档 | 结算 / 日志拼图界面背景 | P0 |

P0 先画 7 张：01、02、04、05、06、08、10。  
P1 再补 03、07、09。  
如果工期只能先做 4 张，优先 02、05、08、10。

## 3. 单张场景需求

### 01 无声圣匣安全区

**用途**

- 开局安全区。
- 死亡回收点。
- 圣匣日志 UI 的世界内背景。

**画面内容**

- 房间中心是无声圣匣，像旧金属夹、棺匣、档案柜和器官标本箱的混合体。
- 地上有油渍纸页、封蜡碎片、脏银夹、空白标签。
- 墙边或桌边挂着已归档的样本牌，但不要密到像博物馆。
- 可以有收藏家的工作痕迹，但不要直接画成邪恶实验室。

**构图**

- 16:9，3/4 斜俯视。
- 中心留出玩家出生位置。
- 圣匣占画面中后部，前部留 UI / 玩家站位空间。

**色调**

- 冷白、灰褐、脏银、旧纸黄。
- 暗红只在封蜡、胃囊小纹样和归档标记出现。

**必须出现**

- 圣匣。
- 归档纸页。
- 封蜡。
- 金属夹。
- 复活 / 回收感。

**禁止**

- 赛博实验室。
- 高科技蓝光。
- 恐怖手术台。
- 满屏器官血肉。

**image2 中文 prompt**

```text
16:9 横屏，哈迪斯式 3/4 斜俯视室内安全区场景，可用于 Godot 2D 房间制游戏。画面中心是“无声圣匣”，像旧金属档案柜、棺匣、器官标本箱和封蜡圣物的结合。地面和桌面有油渍纸页、脏银金属夹、封蜡碎片、空白样本标签，空间安静、干燥、低饱和、乡村档案感。冷白光、灰褐木板、旧纸黄、脏银，暗红只作为封蜡和胃囊符号点缀。中心留玩家出生和交互空间，边缘可有归档样本牌。不要赛博 UI，不要现代实验室，不要血腥手术台，不要横版侧视，不要纯海报构图。
```

**English prompt**

```text
16:9 landscape, Hades-like three-quarter top-down indoor safe-room scene for a Godot 2D room-based action roguelite. The center contains the Silent Sacred Casket, a hybrid of an old metal archive cabinet, reliquary coffin, organ specimen case, and wax-sealed sacred object. Oil-stained papers, dirty silver clips, wax seal fragments, and blank sample tags lie on old wooden surfaces. Quiet, dry, muted rural archive mood; cold white light, gray-brown wood, aged paper yellow, dirty silver, with dark red only on wax seals and stomach-symbol accents. Keep playable interaction space around the center. No cyber UI, no modern lab, no gore surgery table, no side view, no poster-only composition.
```

### 02 低语田野入口

**用途**

- 第一战斗房。
- 教玩家移动、近战、采样掉落。
- 让玩家第一次看到“丰收”和“名单”并列。

**画面内容**

- 一条干土路通向枯麦田。
- 路边旧木牌正面写“丰收”，背面或边缘刻着名单痕迹。
- 两侧枯麦围出房间边界。
- 少量空碗、谷袋、断农具散在边缘。

**构图**

- 16:9，3/4 斜俯视战斗房。
- 中央 60% 留空，适合玩家和 2 个空腹者战斗。
- 边界必须清楚，不能像开放风景图。

**色调**

- 枯麦黄、灰褐土、冷白天空。
- 暗红极少，只在路牌刻痕或远处仪式点。

**必须出现**

- 丰收牌。
- 名单刻痕。
- 枯麦边界。
- 中央战斗空地。

**禁止**

- 风景明信片感。
- 横版道路。
- 中心满地装饰。
- 过多红色。

**image2 中文 prompt**

```text
低语田野入口战斗房背景，16:9 横屏，哈迪斯式 3/4 斜俯视房间制构图，可用于 Godot 2D。中央是大片清楚可战斗的灰褐干土空地，一条旧土路通向枯麦田深处。两侧枯麦、低矮围栏和旧谷袋形成自然房间边界。路边有褪色木牌，正面写着丰收的痕迹，背面或边缘刻着名单。少量空碗、断农具、干草散在边缘。乡村荒凉、静默、干燥、低饱和，冷白天空，暗红只做极小仪式点。不要横版平台，不要纯俯视地图，不要风景海报，不要把战斗中心画满。
```

**English prompt**

```text
Low Whispering Field entrance combat-room background, 16:9 landscape, Hades-like three-quarter top-down room composition for Godot 2D. A large readable gray-brown dry-soil combat area sits in the center, with an old dirt path leading into withered wheat. Withered wheat, low fences, old grain sacks, and dry grass form natural room boundaries. A faded wooden sign suggests "harvest" on the front, with scratched name-list marks on the back or edge. A few empty bowls and broken tools sit near the borders. Rural desolation, quiet, dry, low saturation, cold white sky, dark red only as tiny ritual marks. No side-scrolling platformer, no pure top-down map, no scenic poster, no cluttered combat center.
```

### 03 空碗排队路

**用途**

- 解释空腹者的来源。
- 用于日志碎片、圣匣故事页或房间间隙插图。
- 不一定直接做战斗背景。

**画面内容**

- 一排空碗沿着谷仓外的土路摆放。
- 地上有排队划线、登记木牌、被擦掉的名字。
- 远处可见谷仓门，但门是关着的。
- 没有人群挤满画面，重点是“排过队的痕迹”。

**构图**

- 16:9，低角度 3/4 斜俯视或轻微叙事插图视角。
- 空碗形成引导线，指向远处谷仓。
- 大量负空间，压出等待感。

**色调**

- 旧白碗、灰褐泥地、枯麦黄。
- 暗红只在少量登记印章或划痕。

**必须出现**

- 空碗队列。
- 登记牌。
- 被划掉的名字。
- 远处谷仓。

**禁止**

- 直接画血腥献祭现场。
- 画成人山人海。
- 让碗像装饰花纹。

**image2 中文 prompt**

```text
低语田野叙事场景图，16:9 横屏，乡村荒凉、静默、干燥、低饱和。一排旧白空碗沿着灰褐土路排向远处褪色谷仓，地面有排队划线、登记木牌、被擦掉或划掉的名字。画面保留大量空地和冷白天空，表现等待、饥饿和制度化登记。气质安静孤独，不血腥，不恐怖。可作为圣匣日志故事插图，不是战斗海报。不要人群挤满画面，不要横版侧视，不要复制任何具体画作构图。
```

**English prompt**

```text
Low Whispering Field narrative scene, 16:9 landscape, rural desolation, quiet, dry, low saturation. A line of old white empty bowls follows a gray-brown dirt road toward a faded barn in the distance. The ground has queue marks, registry boards, and erased or crossed-out names. Keep large empty ground and cold white sky, expressing waiting, hunger, and institutional registration. Quiet and lonely, not gory, not horror. Suitable as a Sacred Casket log story illustration, not a combat poster. No crowded mob, no side view, no copied painting composition.
```

### 04 血肉麦田

**用途**

- 第二战斗房。
- 引入咬人麦穗和地面危险。
- 表达“丰收是献祭成果”。

**画面内容**

- 麦田更密，但中心必须留战斗空白。
- 地面有暗红根脉，从边缘渗入中心。
- 两到三个危险区预留位置，和装饰红痕区分明显。
- 边缘有低矮献祭柱、旧布条、谷袋。

**构图**

- 16:9，3/4 斜俯视战斗房。
- 中心至少 `900x420` 清楚可战斗区域。
- 危险区位置要能直接给程序参考。

**色调**

- 枯麦黄 + 灰褐土为主。
- 暗红危险区要比背景装饰更亮、更规整。

**必须出现**

- 血麦边缘。
- 咬人麦穗危险区预留。
- 中央空地。
- 献祭柱或旧布条。

**禁止**

- 满屏血肉。
- 背景红斑和危险区混淆。
- 麦田纹理吞掉角色。

**image2 中文 prompt**

```text
血肉麦田战斗房背景，16:9 横屏，哈迪斯式 3/4 斜俯视，可用于 Godot 2D。中心保留大面积清楚战斗空地，四周是更密的枯麦和低矮献祭柱，灰褐土地上有少量暗红根脉从边缘渗入。预留 2 到 3 个咬人麦穗危险区位置，危险区外圈应比装饰红痕更清楚。低饱和、干燥、乡村荒凉、冷白天空，暗红只作为危险和神烬点缀。不要满屏血肉，不要恐怖片，不要让麦田纹理吞掉角色，不要横版侧视。
```

**English prompt**

```text
Blood Wheat Field combat-room background, 16:9 landscape, Hades-like three-quarter top-down view for Godot 2D. Keep a large readable combat space in the center. Around the borders are denser withered wheat and low sacrificial posts. Gray-brown soil has a few dark red root veins leaking in from the edges. Reserve two or three readable biting-wheat hazard positions, with hazard rims clearer than decorative red stains. Muted, dry, rural desolation, cold white sky, dark red only for danger and god-ash accents. No full-screen flesh, no horror movie, no wheat texture swallowing characters, no side view.
```

### 05 肠道灌溉渠

**用途**

- 第三战斗房。
- 当前试玩容易卡住和误判的房间，需要最强可读性。
- 展示献祭被工程化：胃液像灌溉系统一样流动。

**画面内容**

- 三条清楚的灌溉渠穿过房间。
- 渠线之间留战斗通道。
- 渠边有木板桥、破桶、旧水闸、登记钉牌。
- 渠水是暗红偏棕或污浊胃液，不要鲜红。

**构图**

- 16:9，3/4 斜俯视。
- 渠线方向要让玩家一眼看出可走路线。
- 危险 / 减速区边界必须非常明确。

**色调**

- 灰褐泥地、污红褐渠水、枯草边。
- 可用淡橙红边光表示危险，但不要霓虹。

**必须出现**

- 三条渠线。
- 可走通道。
- 木板桥或水闸。
- 渠边登记牌。

**禁止**

- 渠线像装饰花纹。
- 中心全是障碍。
- 红色过亮像科幻熔岩。

**image2 中文 prompt**

```text
肠道灌溉渠战斗房背景，16:9 横屏，哈迪斯式 3/4 斜俯视，用于 Godot 2D 动作肉鸽。房间中有三条非常清楚的灌溉渠，渠水像污浊暗红褐色胃液，边缘有可读的危险 / 减速区轮廓。渠线之间留出玩家和敌人战斗通道。边缘有旧木板桥、破桶、小水闸、登记钉牌、干草和灰褐泥地。低饱和、干燥、乡村工程化恐惧，但不血腥。必须让玩家一眼看出哪里能走、哪里不能走。不要让渠线像装饰花纹，不要横版侧视，不要霓虹熔岩，不要中心过度拥挤。
```

**English prompt**

```text
Intestinal Irrigation Canal combat-room background, 16:9 landscape, Hades-like three-quarter top-down view for a Godot 2D action roguelite. The room contains three very readable irrigation channels filled with dirty dark red-brown stomach-fluid water, with clear hazard / slow-zone outlines. Leave walkable combat lanes between the channels. Edges include old plank bridges, broken barrels, small sluice gates, registry tags, dry grass, and gray-brown mud. Muted, dry, rural engineered horror without gore. The player must immediately read where to walk and where not to walk. No decorative canal pattern, no side view, no neon lava, no cluttered center.
```

### 06 饥饿谷仓外场

**用途**

- 第四房入口或精英房背景。
- 从田野过渡到谷仓。
- 显示“仓里没有粮声”。

**画面内容**

- 谷仓门在画面上侧或远侧，半开或沉默关闭。
- 门前有空碗、谷袋、登记桌、旧秤。
- 边缘有枯麦和木围栏形成战斗房边界。
- 场地中心留给空腹者和稻草人精英活动。

**构图**

- 16:9，3/4 斜俯视。
- 谷仓是远侧边界，不是横版立面主角。
- 中心空旷但有压迫感。

**色调**

- 褪色木褐、枯麦黄、灰土、冷白光。
- 暗红只在门缝和登记印章。

**必须出现**

- 谷仓门。
- 空碗。
- 登记桌或旧秤。
- 战斗空地。

**禁止**

- 纯横版谷仓立面。
- 谷仓遮住战斗中心。
- 过度鬼屋化。

**image2 中文 prompt**

```text
饥饿谷仓外场战斗房背景，16:9 横屏，哈迪斯式 3/4 斜俯视。谷仓门位于画面远侧或上侧，半开或沉默关闭，门前有空碗、旧谷袋、登记桌、旧秤和被划掉的名字。四周枯麦、木围栏和褪色木板形成房间边界，中心留出清楚战斗空地。气质是乡村荒凉、静默、干燥、孤独，不是鬼屋。低饱和木褐、灰土、冷白光，暗红只在门缝、封蜡和登记印章。不要横版谷仓立面，不要让谷仓占满中心，不要恐怖片海报。
```

**English prompt**

```text
Hungry Barn exterior combat-room background, 16:9 landscape, Hades-like three-quarter top-down. The barn door sits on the far or upper side of the room, half-open or silently closed. In front are empty bowls, old grain sacks, a registry table, an old scale, and crossed-out names. Withered wheat, wooden fences, and faded boards form the room boundary, while the center remains clear for combat. Rural desolation, quiet, dry, lonely, not a haunted house. Muted wood brown, gray soil, cold white light, dark red only in door cracks, wax seals, and registry stamps. No side-view barn facade, no barn filling the combat center, no horror poster.
```

### 07 稻草人仪式麦场

**用途**

- 精英战关键场景。
- 支撑饥饿稻草人的麦浪法术和封路机制。

**画面内容**

- 中心或远侧有高瘦稻草人木架的位置。
- 地面有麦浪施法轨迹和旧符号，但不能像危险区常亮。
- 边缘有偷粮者破衣、挂签、登记木条。
- 房间中心留给麦浪危险线展开。

**构图**

- 16:9，3/4 斜俯视。
- 地面可预留 3 条麦浪方向线。
- 高瘦竖向元素放边缘，不遮角色。

**色调**

- 灰布、枯草黄、木褐。
- 暗红极少，用于挂签和旧符号。

**必须出现**

- 稻草人木架位置。
- 麦浪施法轨迹。
- 挂签 / 破衣。
- 战斗留白。

**禁止**

- 万圣节稻草人摆件。
- 满地符文发光。
- 纯恐怖祭坛。

**image2 中文 prompt**

```text
稻草人仪式麦场，16:9 横屏，哈迪斯式 3/4 斜俯视精英战房间，用于 Godot 2D。场地边缘有高瘦稻草人木架、破旧衣服、挂签、登记木条和枯草，中心留出战斗空间，并预留 3 条麦浪法术展开方向。地面有很淡的旧仪式痕迹，但不要像常亮危险区。乡村荒凉、静默、干燥、低饱和，灰布、木褐、枯草黄，暗红只做小符号点缀。不要万圣节摆件感，不要满地发光符文，不要纯恐怖祭坛，不要横版侧视。
```

**English prompt**

```text
Scarecrow ritual wheat-yard, 16:9 landscape, Hades-like three-quarter top-down elite combat room for Godot 2D. The borders contain a tall scarecrow wooden frame, torn clothes, hanging tags, registry sticks, and dry straw. Keep the center open for combat, with three reserved directions for wheat-wave spell lanes. The floor has very faint old ritual traces, but not constant glowing hazard marks. Rural desolation, quiet, dry, muted palette: gray cloth, wood brown, withered straw yellow, dark red only as small symbolic accents. No Halloween prop feel, no full glowing rune floor, no pure horror altar, no side view.
```

### 08 谷仓王胃室

**用途**

- Boss 战背景。
- 前面所有机制的汇总场。
- 让玩家看到谷仓、王权、胃囊和献祭制度合一。

**画面内容**

- 场地像谷仓内部和胃室的混合。
- 地面有环形仪式痕，但不能抢 Boss 弱点。
- 边缘有木梁、谷仓门板、名单、谷袋、胃液渠出口。
- 中心必须足够空，Boss 和玩家能绕行。

**构图**

- 16:9，3/4 斜俯视。
- 中心空地可容纳 260px 高 Boss。
- 背景红光低于 Boss 红核亮度。

**色调**

- 褪色木板、灰土、旧纸、暗红内光。
- 暗红按层级使用：Boss 弱点最高，危险区次之，背景最低。

**必须出现**

- 谷仓结构。
- 胃室暗示。
- 王权 / 登记符号。
- 可绕行的 Boss 场。

**禁止**

- 背景比 Boss 更亮。
- 横版大怪脸舞台。
- 胃室画成满屏血肉洞穴。

**image2 中文 prompt**

```text
谷仓王胃室 Boss 战背景，16:9 横屏，哈迪斯式 3/4 斜俯视，可用于 Godot 2D。场地是旧谷仓内部与神之胃室的混合：褪色木梁、谷仓门板、名单纸、谷袋、胃液渠出口、低亮度环形仪式痕。中心必须留出足够空地，能容纳大体积 Boss 和玩家绕行。背景暗红内光必须低于 Boss 红核弱点亮度，不能抢焦点。乡村荒凉、干燥、低饱和、压迫但不血腥。不要横版大怪脸舞台，不要满屏血肉洞穴，不要让背景危险红和 Boss 弱点混淆。
```

**English prompt**

```text
Barn King stomach chamber boss-room background, 16:9 landscape, Hades-like three-quarter top-down for Godot 2D. The arena mixes an old barn interior with a divine stomach chamber: faded wooden beams, barn door boards, name-list papers, grain sacks, stomach-fluid canal outlets, and low-brightness circular ritual marks. Keep enough open center space for a large boss and player movement. Background dark red inner glow must stay dimmer than the boss red-core weak point. Rural desolation, dry, muted, oppressive but not gory. No side-view giant monster stage, no full-screen flesh cave, no confusing background red with boss weak point.
```

### 09 王的开仓记忆

**用途**

- Boss 后故事插图。
- 展示谷仓王最初不是怪物，而是曾经开仓救人。
- 可用于圣匣日志第一故事的前半段。

**画面内容**

- 谷仓门被打开，里面的粮袋很少。
- 门外是空碗和等待痕迹，不画密集人群。
- 谷仓王可以只作为远处背影或手持钥匙的剪影。
- 画面要有“救人”和“不够”的双重感。

**构图**

- 16:9 叙事插图。
- 谷仓门作为视觉中心，但不要像英雄海报。
- 空碗和粮袋数量对比形成叙事。

**色调**

- 冷白冬光、灰褐木板、旧粮袋黄。
- 暗红不出现或极少，只埋在后续不祥细节。

**必须出现**

- 开仓门。
- 钥匙或开锁痕迹。
- 少量粮袋。
- 大量空碗。

**禁止**

- 把谷仓王画成纯反派。
- 强英雄光环。
- 直接血腥献祭。

**image2 中文 prompt**

```text
谷仓王开仓记忆场景，16:9 横屏叙事插图，乡村荒凉、静默、干燥、低饱和。褪色谷仓门被打开，里面粮袋很少，门外地上有很多旧白空碗、排队痕迹和冷白冬光。谷仓王只作为远处背影或手持钥匙的剪影出现，表现他曾经开仓救人，但粮食明显不够。画面有悲剧起点，不是反派登场。灰褐木板、旧粮袋黄、冷白光，暗红极少或不出现。不要英雄海报，不要血腥献祭，不要人群挤满画面，不要临摹具体画作构图。
```

**English prompt**

```text
Barn King opening the granary memory scene, 16:9 narrative illustration, rural desolation, quiet, dry, muted. A faded barn door is opened; inside are only a few grain sacks, while many old white empty bowls and queue traces sit outside under cold white winter light. Barn King appears only as a distant back silhouette or a hand holding a key, showing that he once opened the granary to save people, but the food was clearly not enough. A tragic beginning, not a villain reveal. Gray-brown wood, old sack yellow, cold white light, dark red almost absent. No hero poster, no bloody sacrifice, no crowded mob, no copied painting composition.
```

### 10 回圣匣归档真相

**用途**

- 死亡回收。
- Boss 后结算。
- 日志碎片拼出“谷仓王为什么献出胃”的核心图。

**画面内容**

- 圣匣打开，纸页、日志碎片、封蜡、金属夹围绕中央故事页。
- 左侧像本轮采样列表，右侧像胃囊反应记录。
- 中央故事页上可以留空给 Godot 文本，不要把字画死。
- 背景隐约有田野、谷仓、空碗和胃囊纹的淡影。

**构图**

- 16:9 UI / 场景混合图。
- 可以作为圣匣日志界面的背景升级版。
- 中央必须留可读文本区。

**色调**

- 旧纸黄、脏银、灰褐、冷白。
- 暗红只在封蜡、主线碎片核心和胃囊反应。

**必须出现**

- 圣匣打开。
- 日志碎片归档。
- 第一故事中央页。
- 真相进度 / 采样列表区域。

**禁止**

- 科幻 UI。
- 现代 App 卡片。
- 把正文烘进图里。
- 太多装饰遮挡文本。

**image2 中文 prompt**

```text
回圣匣归档真相场景，16:9 横屏，圣匣日志 UI 与场景结合，用于 Godot 2D。圣匣打开，旧纸页、日志碎片、封蜡、脏银金属夹围绕中央故事页。左侧是本轮采样列表区域，右侧是胃囊反应记录区域，底部有真相进度条位置。中央纸页必须留出清楚可读文本区，不要把正文画死。背景淡淡叠入低语田野、谷仓、空碗和胃囊纹影子。低饱和、安静、干燥、乡村档案感，暗红只在封蜡、主线碎片核心和胃囊反应处。不要科幻 UI，不要现代 App 卡片，不要玻璃拟态，不要满屏装饰。
```

**English prompt**

```text
Return-to-Sacred-Casket truth archive scene, 16:9 landscape, combining Sacred Casket log UI and in-world scene for Godot 2D. The Sacred Casket is open; aged papers, log fragments, wax seals, and dirty silver clips surround a central story page. Left side has a current-run sample list area, right side has stomach reaction record area, bottom has a truth progress bar space. The central paper must leave a clear readable text area; do not bake body text into the image. Subtle background echoes of Low Whispering Field, barn, empty bowls, and stomach-symbol shadows. Muted, quiet, dry rural archive mood; dark red only on wax seals, main-story fragment cores, and stomach reactions. No sci-fi UI, no modern app cards, no glassmorphism, no full-screen decoration.
```

## 4. 生成后如何变成 Godot 资产

### 4.1 P0 房间背景

02、04、05、06、08 应优先处理成可进 Godot 的房间背景：

1. 保留原始概念图作为 `assets/concepts/scene_key_art_round_01/`。
2. 按房间拆 `floor / boundary / props_mid / foreground / collision_paintover`。
3. 导出 `1920x1080` PNG。
4. 用 1280x720 截图叠玩家、敌人、危险区检查可读性。
5. 中心战斗区如果太花，先降对比再进游戏。

### 4.2 圣匣与日志场景

01、10 应拆成 UI 和场景两套用途：

- 场景版：作为玩家回收 / 复活背景。
- UI 版：拆成纸页、封蜡、金属夹、列表底板、进度条底板。
- 正文区域必须留给 Godot 文本渲染。

### 4.3 叙事插图

03、09 可以先不切层：

- 用作圣匣故事插图。
- 推荐输出 `1920x1080` JPG / PNG。
- 需要时再拆出空碗、钥匙、谷仓门等可复用小物件。

## 5. 第一轮交付包

建议第一轮交付 10 张场景图概念 + 其中 7 张 P0 拆层。

```text
GodAsh_Scene_Key_Art_Round01/
  README_SCENE_ROUND01.md
  concept_png/
    scene_01_silent_casket_safe_room.png
    scene_02_field_entrance.png
    scene_03_empty_bowl_queue.png
    scene_04_blood_wheat_field.png
    scene_05_gut_irrigation_canal.png
    scene_06_hungry_barn_exterior.png
    scene_07_scarecrow_ritual_yard.png
    scene_08_barn_king_stomach_chamber.png
    scene_09_barn_king_open_granary_memory.png
    scene_10_casket_truth_archive.png
  godot_layers_p0/
    field_entrance/
    blood_wheat_field/
    gut_irrigation_canal/
    hungry_barn_exterior/
    barn_king_stomach_chamber/
    casket_truth_archive/
  paintover/
    readability_1280x720_checks.png
    collision_paintover_notes.png
```

`README_SCENE_ROUND01.md` 必须说明：

- 哪些是概念图。
- 哪些已拆层可进 Godot。
- 哪些区域是可走地面。
- 哪些区域是阻挡。
- 哪些红色是危险区，哪些只是装饰。
- 哪些文本区必须留给程序。

## 6. 验收标准

每张场景图验收时只问这些问题：

1. 这张图对应哪个房间或哪个故事节点？
2. 能不能一眼看出这是低语田野，而不是普通农场？
3. 16:9 截图里中心是否留出战斗空间？
4. 角色放上去会不会被地表纹理吞掉？
5. 危险区和装饰红色是否能区分？
6. 场景里是否有世界观证据：空碗、名单、谷仓、胃液渠、封蜡、日志碎片？
7. 是否避免了横版、纯俯视、海报化、血腥恐怖和赛博 UI？
8. 是否能拆成 Godot 可用背景层？

不满足 1、3、4、5 的图，不能进游戏背景，只能作为概念参考。
