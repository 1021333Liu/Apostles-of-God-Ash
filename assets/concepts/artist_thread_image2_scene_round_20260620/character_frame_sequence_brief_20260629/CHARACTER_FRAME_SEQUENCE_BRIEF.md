# 角色帧序列制作需求

## 1. 总目标

请基于本包内已经确认的 5 张角色母图，制作 Godot 2D 战斗用透明 PNG 帧序列。

重点不是重新设计角色，而是把同一个角色扩展成稳定、可播放、可接入 Godot 的动作帧。每个动作可以多帧，但必须保持角色身份、尺寸、脚底锚点、朝向和道具一致。

## 2. 统一技术规格

- 每帧尺寸：`768x768`
- 文件格式：真正透明 PNG，必须有 alpha 通道
- 背景：完全透明，不要白底、棋盘格底、地面、阴影底图或场景背景
- 构图：全身完整，不裁脚，不裁武器，不裁木桩底部
- 锚点：脚底或角色底部锚点尽量接近 `x=384, y=720`
- 朝向：保持母图朝向，不要左右乱翻
- 角色大小：同一角色所有帧大小一致，不能忽大忽小
- 风格：低饱和、乡土、干燥、冷清，高级商业游戏角色原画质感
- 禁止：不要攻击特效、魔法光、烟尘、骰子、卡牌、UI、文字、logo、水印

## 3. 母图路径

主角回声：

```text
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\02_actor_sources\player_echo\player_echo_fullbody_20260610_alpha.png
```

空腹者：

```text
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\02_actor_sources\enemy_empty\fullbody_clean.png
```

农夫登记执行者：

```text
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\02_actor_sources\enemy_farmer\fullbody_clean.png
```

稻草人：

```text
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\02_actor_sources\enemy_scarecrow\fullbody_clean.png
```

谷仓王 Boss：

```text
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\02_actor_sources\boss_barn_king\fullbody_clean.png
```

## 4. 输出目录建议

先交付到输出包，便于检查：

```text
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\frame_sequences\player_echo
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\frame_sequences\enemy_empty
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\frame_sequences\enemy_farmer
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\frame_sequences\enemy_scarecrow
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\frame_sequences\boss_barn_king
```

确认后再复制到 runtime：

```text
assets/sprites/characters/player
assets/sprites/characters/enemies
assets/sprites/characters/bosses
```

## 5. 普通敌人通用帧数

适用于空腹者、农夫登记执行者、稻草人：

```text
idle: 4 帧
walk: 6 帧
attack: 6 帧
hit: 4 帧
death: 6 帧，可选
```

如果工作量要压缩，`death` 可以暂缓，但 `idle / walk / attack / hit` 建议都做。

## 6. 空腹者 enemy_empty

### 文件名

```text
enemy_empty_idle_0.png
enemy_empty_idle_1.png
enemy_empty_idle_2.png
enemy_empty_idle_3.png

enemy_empty_walk_0.png
enemy_empty_walk_1.png
enemy_empty_walk_2.png
enemy_empty_walk_3.png
enemy_empty_walk_4.png
enemy_empty_walk_5.png

enemy_empty_attack_0.png
enemy_empty_attack_1.png
enemy_empty_attack_2.png
enemy_empty_attack_3.png
enemy_empty_attack_4.png
enemy_empty_attack_5.png

enemy_empty_hit_0.png
enemy_empty_hit_1.png
enemy_empty_hit_2.png
enemy_empty_hit_3.png
```

### 角色要点

空腹者是第一怪，抱着空碗，饥饿、虚弱、麻木，被粮食制度掏空。不要画成丧尸、恶魔、怪物或血腥角色。

### idle 逐帧

- `idle_0`：母图近似姿势，双手抱碗，身体轻微佝偻。
- `idle_1`：肩膀下沉 1-2 像素，头略低，像呼吸吐气。
- `idle_2`：身体略回升，碗保持在腹前，脸仍麻木。
- `idle_3`：回到接近 `idle_0`，形成平滑循环。

### walk 逐帧

- `walk_0`：抱碗站立，准备拖步。
- `walk_1`：一只脚轻微向前拖，身体前倾，碗不离手。
- `walk_2`：重心压到前脚，肩膀晃动，破布轻摆。
- `walk_3`：另一只脚拖上来，步幅小，不能奔跑。
- `walk_4`：身体略晃，像饥饿导致不稳。
- `walk_5`：回到可衔接 `walk_0` 的站姿。

### attack 逐帧

- `attack_0`：抱碗前倾蓄势，肩膀下沉。
- `attack_1`：上身向前探，双手把空碗推出。
- `attack_2`：手臂继续伸出，碗最靠前，像讨要又像抢夺。
- `attack_3`：攻击最高点，脸仍饥饿麻木，不要怪物化。
- `attack_4`：开始收回碗，身体后缩。
- `attack_5`：回到半佝偻站姿，可衔接 idle。

### hit 逐帧

- `hit_0`：正常站姿刚被击中，肩膀僵住。
- `hit_1`：上半身后仰或侧偏，碗倾斜但不飞出。
- `hit_2`：身体最失衡，手指仍抓住碗，不画血。
- `hit_3`：恢复到虚弱站姿。

## 7. 农夫登记执行者 enemy_farmer

### 文件名

```text
enemy_farmer_idle_0.png
enemy_farmer_idle_1.png
enemy_farmer_idle_2.png
enemy_farmer_idle_3.png

enemy_farmer_walk_0.png
enemy_farmer_walk_1.png
enemy_farmer_walk_2.png
enemy_farmer_walk_3.png
enemy_farmer_walk_4.png
enemy_farmer_walk_5.png

enemy_farmer_attack_0.png
enemy_farmer_attack_1.png
enemy_farmer_attack_2.png
enemy_farmer_attack_3.png
enemy_farmer_attack_4.png
enemy_farmer_attack_5.png

enemy_farmer_hit_0.png
enemy_farmer_hit_1.png
enemy_farmer_hit_2.png
enemy_farmer_hit_3.png
```

### 角色要点

农夫登记执行者不是普通农民，不是商人。他是执行田地登记、粮食配给和驱逐制度的人。必须保留镰刀、登记板、档案纸、封蜡标签或量粮工具。

镰刀要求：旧镰刀、农具感、锈蚀、泥土痕迹。不要巨大死神镰刀，不要魔法镰刀。

### idle 逐帧

- `idle_0`：母图近似姿势，镰刀立在一侧，登记板或档案挂在身上。
- `idle_1`：头略低，像冷漠核对登记。
- `idle_2`：镰刀轻微偏移，衣摆和纸条轻摆。
- `idle_3`：回到稳定站姿，可循环。

### walk 逐帧

- `walk_0`：稳定站姿，镰刀贴身。
- `walk_1`：前脚迈出，镰刀保持竖向或斜向。
- `walk_2`：重心前移，登记板轻晃。
- `walk_3`：后脚跟上，衣摆摆动。
- `walk_4`：镰刀随身体轻摆，但不要挥击。
- `walk_5`：回到可衔接第一帧的步态。

### attack 逐帧

- `attack_0`：抬起镰刀，身体略侧转，准备执行收割。
- `attack_1`：镰刀向后或侧方蓄力，登记板和纸条轻摆。
- `attack_2`：镰刀斜向挥出，动作冷漠克制。
- `attack_3`：攻击最高点，镰刀到达前方或斜下方，不加刀光。
- `attack_4`：镰刀收回，身体回正。
- `attack_5`：回到待机姿态。

### hit 逐帧

- `hit_0`：正常站姿刚被击中。
- `hit_1`：身体后退，登记板歪斜，镰刀仍握住。
- `hit_2`：最失衡，纸条和衣摆甩动。
- `hit_3`：恢复站稳，不掉武器。

## 8. 稻草人 enemy_scarecrow

### 文件名

```text
enemy_scarecrow_idle_0.png
enemy_scarecrow_idle_1.png
enemy_scarecrow_idle_2.png
enemy_scarecrow_idle_3.png

enemy_scarecrow_walk_0.png
enemy_scarecrow_walk_1.png
enemy_scarecrow_walk_2.png
enemy_scarecrow_walk_3.png
enemy_scarecrow_walk_4.png
enemy_scarecrow_walk_5.png

enemy_scarecrow_attack_0.png
enemy_scarecrow_attack_1.png
enemy_scarecrow_attack_2.png
enemy_scarecrow_attack_3.png
enemy_scarecrow_attack_4.png
enemy_scarecrow_attack_5.png

enemy_scarecrow_hit_0.png
enemy_scarecrow_hit_1.png
enemy_scarecrow_hit_2.png
enemy_scarecrow_hit_3.png
```

### 角色要点

稻草人不要太恐怖，不要血腥，不要人腿。底部应是木桩、草束、破布支架或插地结构。它是血麦田守卫，不是长腿行走怪物。

### idle 逐帧

- `idle_0`：木桩支撑站立，双臂横展或略垂。
- `idle_1`：上半身轻微摇摆，干草和破布轻动。
- `idle_2`：头部略偏，木杆身体轻微倾斜。
- `idle_3`：回到接近 `idle_0`，形成风吹般循环。

### walk 逐帧

稻草人没有腿，walk 应表现为拖拽、倾斜、木桩挪动，而不是迈步。

- `walk_0`：木桩底部稳定，身体准备倾斜。
- `walk_1`：身体向前倾，底部木桩轻微拖动。
- `walk_2`：一侧草束和破布被拖起，像被风或绳索牵引。
- `walk_3`：身体回正一点，木桩底部换到新位置。
- `walk_4`：另一侧轻微摆动，横杆手臂晃动。
- `walk_5`：回到可循环的插地姿势。

### attack 逐帧

- `attack_0`：身体后仰蓄力，横杆手臂展开。
- `attack_1`：一侧手臂或木杆向前压出，干草张开。
- `attack_2`：上半身猛然前倾，像稻草和木桩扑压。
- `attack_3`：攻击最高点，木杆手臂最靠前，不加血和魔法。
- `attack_4`：身体回弹，破布和绳索甩动。
- `attack_5`：回到插地待机姿态。

### hit 逐帧

- `hit_0`：正常待机。
- `hit_1`：身体被打偏，横杆手臂歪斜。
- `hit_2`：干草飞散感可以通过姿态表现，但不要画碎屑特效。
- `hit_3`：木桩重新稳住，恢复待机。

## 9. 主角回声 player_echo

### 文件名

```text
player_echo_idle_0.png
player_echo_idle_1.png
player_echo_idle_2.png
player_echo_idle_3.png

player_echo_walk_0.png
player_echo_walk_1.png
player_echo_walk_2.png
player_echo_walk_3.png
player_echo_walk_4.png
player_echo_walk_5.png

player_echo_attack_0.png
player_echo_attack_1.png
player_echo_attack_2.png
player_echo_attack_3.png
player_echo_attack_4.png
player_echo_attack_5.png

player_echo_heavy_attack_0.png
player_echo_heavy_attack_1.png
player_echo_heavy_attack_2.png
player_echo_heavy_attack_3.png
player_echo_heavy_attack_4.png
player_echo_heavy_attack_5.png
player_echo_heavy_attack_6.png
player_echo_heavy_attack_7.png

player_echo_defend_0.png
player_echo_defend_1.png
player_echo_defend_2.png
player_echo_defend_3.png

player_echo_hit_0.png
player_echo_hit_1.png
player_echo_hit_2.png
player_echo_hit_3.png

player_echo_ultimate_cast_0.png
player_echo_ultimate_cast_1.png
player_echo_ultimate_cast_2.png
player_echo_ultimate_cast_3.png
player_echo_ultimate_cast_4.png
player_echo_ultimate_cast_5.png
player_echo_ultimate_cast_6.png
player_echo_ultimate_cast_7.png
```

### 角色要点

主角回声必须保持母图身份：白发、黑脸/阴影脸、白蓝破损圣衣、短剑、旧纸标签。不要改成二次元新角色，不要加高饱和魔法光。

### idle

- `idle_0`：母图近似姿势，短剑下垂。
- `idle_1`：肩膀轻微起伏，衣摆轻动。
- `idle_2`：头部微低，短剑轻微偏移。
- `idle_3`：回到 `idle_0`。

### walk

- `walk_0`：准备迈步，短剑低垂。
- `walk_1`：前脚迈出，衣摆向后。
- `walk_2`：重心前移，剑和披带轻摆。
- `walk_3`：后脚跟上。
- `walk_4`：身体回正。
- `walk_5`：衔接循环。

### attack

- `attack_0`：短剑收向侧后方蓄力。
- `attack_1`：身体前压，剑开始斜向挥出。
- `attack_2`：挥砍中段，剑最清晰，不加刀光。
- `attack_3`：攻击最高点，身体前倾。
- `attack_4`：收剑，衣摆回弹。
- `attack_5`：回到待机。

### heavy_attack

- `heavy_attack_0`：压低身体，剑收得更深。
- `heavy_attack_1`：蓄力，肩膀和披带下沉。
- `heavy_attack_2`：开始大幅挥出。
- `heavy_attack_3`：挥砍中段，身体转动更明显。
- `heavy_attack_4`：攻击最高点，剑到达最远处。
- `heavy_attack_5`：动作停顿一瞬，表现重量。
- `heavy_attack_6`：开始回收。
- `heavy_attack_7`：回到待机。

### defend

- `defend_0`：待机转入防御。
- `defend_1`：短剑和手臂抬起护身。
- `defend_2`：身体后缩，衣摆收拢。
- `defend_3`：保持防御姿态。

### hit

- `hit_0`：正常站姿被击中。
- `hit_1`：上身后仰或侧偏。
- `hit_2`：最失衡，剑不脱手。
- `hit_3`：恢复站姿。

### ultimate_cast

不要画大范围特效，只做角色施放姿态，特效后续可单独做 FX。

- `ultimate_cast_0`：站稳，剑收近身体。
- `ultimate_cast_1`：抬头或低头蓄势，衣摆下沉。
- `ultimate_cast_2`：手臂展开，胸前符号更明显。
- `ultimate_cast_3`：剑抬起或指向前方。
- `ultimate_cast_4`：施放最高点，姿态最强。
- `ultimate_cast_5`：短暂停顿。
- `ultimate_cast_6`：动作回收。
- `ultimate_cast_7`：回到可衔接待机。

## 10. 谷仓王 Boss

### 文件名

第一版先做基础 Boss 动作，不做三阶段拆分：

```text
boss_barn_king_idle_0.png
boss_barn_king_idle_1.png
boss_barn_king_idle_2.png
boss_barn_king_idle_3.png
boss_barn_king_idle_4.png
boss_barn_king_idle_5.png

boss_barn_king_advance_0.png
boss_barn_king_advance_1.png
boss_barn_king_advance_2.png
boss_barn_king_advance_3.png
boss_barn_king_advance_4.png
boss_barn_king_advance_5.png

boss_barn_king_attack_0.png
boss_barn_king_attack_1.png
boss_barn_king_attack_2.png
boss_barn_king_attack_3.png
boss_barn_king_attack_4.png
boss_barn_king_attack_5.png
boss_barn_king_attack_6.png
boss_barn_king_attack_7.png

boss_barn_king_hit_0.png
boss_barn_king_hit_1.png
boss_barn_king_hit_2.png
boss_barn_king_hit_3.png
```

### 角色要点

谷仓王是 Boss，是粮仓制度和献祭秩序的统治者。要压迫、厚重、旧木、粮袋、锁链、档案标签、钥匙和封蜡感。不要恶魔化、巫师化、商人化。

### idle

- `idle_0`：母图近似姿态，权杖/钥匙稳定。
- `idle_1`：肩部和布料轻微下沉。
- `idle_2`：头部或胸前笼架轻微起伏。
- `idle_3`：锁链和标签轻摆。
- `idle_4`：身体恢复。
- `idle_5`：回到可循环站姿。

### advance

- `advance_0`：稳定站姿。
- `advance_1`：身体前压，权杖略前移。
- `advance_2`：一侧沉重迈进或整体压迫前移。
- `advance_3`：重心落下，布料和锁链摆动。
- `advance_4`：另一侧跟上。
- `advance_5`：回到稳定姿态。

### attack

- `attack_0`：抬起权杖或钥钩蓄力。
- `attack_1`：身体后压，胸前笼架和锁链绷紧。
- `attack_2`：开始挥击或压砸。
- `attack_3`：动作中段，武器最清晰。
- `attack_4`：攻击最高点，重量感最强。
- `attack_5`：短暂停顿，表现 Boss 重击。
- `attack_6`：收回武器。
- `attack_7`：回到待机。

### hit

- `hit_0`：正常站姿刚被击中。
- `hit_1`：上身后顿，锁链和标签甩动。
- `hit_2`：最失衡但仍压迫，不倒地。
- `hit_3`：恢复站稳。

## 11. 验收标准

逐张检查：

- 尺寸必须是 `768x768`
- 必须是真透明 PNG
- 不能有白底、棋盘格底、背景或地面
- 同一角色每帧大小一致
- 同一角色每帧脚底锚点一致
- 脸、道具、服装、武器不能漂移
- 动作要能连续播放
- 不要加特效，特效后续单独做 FX
- 不能出现文字、logo、水印
- 风格必须和母图一致

## 12. 第一批优先级

如果不能一次做完，按这个顺序交付：

1. `enemy_empty`：`idle / walk / attack / hit`
2. `enemy_farmer`：`idle / walk / attack / hit`
3. `enemy_scarecrow`：`idle / walk / attack / hit`
4. `player_echo`：`idle / walk / attack / hit / defend`
5. `boss_barn_king`：`idle / attack / hit`

先保证每个角色能在 Godot 里动起来，再补 `heavy_attack / ultimate_cast / death / phase_change`。
