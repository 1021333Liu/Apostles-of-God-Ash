# Nanobanana Card Combat Art Prompts

本文档用于《神烬使徒 / Apostles of God-Ash》卡牌骰子 Demo 的 nanobanana / image-to-image 美术生成与后处理。目标是生成可进入 Godot 2D 的角色动作、卡牌 UI、骰子 UI 和拆分 FX，不是生成宣传海报或场景大图。

当前战斗机制：

- 玩家行动轮：攻击 / 重击 / 蓄防 / 大招。
- 敌方攻击轮：敌人自动攻击，玩家自动投防御骰。
- 重击：攻击骰必须比敌方防御骰高 5 点，命中后 D3 伤害翻倍。
- 蓄防：本轮不攻击，下次敌方攻击时防御 D20 投两次取最高。
- 大招：攻击 / 重击累计 3 次后可用，D6 直伤，无视防御。

## 00 总体风格与负面提示词

### 总体风格

中文总提示词：

```text
《神烬使徒 / Apostles of God-Ash》Godot 2D 卡牌骰子战斗资产，低饱和乡土暗黑奇幻，干燥、冷清、旧纸、泥土、脏银、暗红血肉点缀，孤独乡村气质，干刷和蛋彩/油画质感，制度化饥饿与圣匣档案感。资产必须干净去噪，减少高频颗粒和 AI 脏边，保留受控手绘笔触。角色必须是全身游戏资产，脚底完整，透明背景，适合 Godot 2D 接入，动作可读，轮廓清楚，不带场景背景和文字。
```

English base prompt:

```text
Apostles of God-Ash Godot 2D card-and-dice combat asset, low-saturation rural dark fantasy, dry and quiet countryside mood, old paper, dirt, tarnished silver, restrained dark red flesh accents, dry-brush tempera-like painterly texture, institutional famine and sacred archive feeling. Clean denoised game asset, reduced high-frequency speckles and AI dirty edges while preserving controlled hand-painted brush texture. Full-body readable game character asset with complete feet, transparent background, Godot 2D ready, clear silhouette and readable action, no scene background, no text.
```

### 全局 negative prompt

中文：

```text
赛博朋克，霓虹，高饱和，二次元，Q版，大头，塑料质感，塑料骰子，亮蓝魔法盾，现代手游按钮，现代实验室，科幻 UI，玻璃拟态 UI，水印，logo，大字，文字，复杂背景，宣传海报构图，半身头像，角色贴满画面，多角色混杂，横版平台视角，正面海报立绘，强发光能量炮，动漫必杀技姿势，夸张刀光，满屏粒子，血腥恐怖片，过度写实 3D 渲染，像素风。
```

English:

```text
cyberpunk, neon, high saturation, anime, chibi, big head, plastic material, plastic dice, bright blue magic shield, mobile game glossy button, modern laboratory, sci-fi UI, glassmorphism UI, watermark, logo, large text, written words, complex background, poster composition, bust portrait, character filling the whole image, multiple characters mixed together, side-scrolling platformer view, front-facing poster portrait, glowing energy cannon, anime ultimate pose, oversized slash beam, full-screen particles, horror gore, realistic 3D render, pixel art.
```

### 通用去噪与清洁要求

- 角色、Boss、16:9 背景：必须模型级/人工级去噪、清边和透明化。
- UI、骰子、卡牌：文字区必须低噪点；边缘 alpha 必须干净；材质纹理只保留在非文字区域。
- 小图标、旧日志碎片、临时骰子/气泡：可轻修，不必模型级重做。
- 保留：干草、旧木板、尘土、粗布、旧纸、脏银、封蜡的方向性纹理。
- 去除：随机白噪点、AI 颗粒、背景污染、压缩块、透明边缘白边/灰边。

## 01 角色动作提示词

### 输入参考图建议

主角：

```text
assets/card_demo/actors/player_echo/source/player_echo_visual_benchmark_20260610_clean.png
assets/card_demo/actors/player_echo/source/player_echo_visual_benchmark_20260610.png
```

收藏家：

```text
assets/concepts/artist_thread_low_whispering_field_20260620/collector_fullbody_front_concept.png
assets/card_demo/actors/collector/source/collector_fullbody_front.png  # 若画师已交正式透明源图，优先用这个
```

空腹者：

```text
assets/concepts/artist_thread_low_whispering_field_20260620/enemy_empty_stomach_fullbody_concept.png
assets/concepts/art_iteration_round_20260610/art_iter_enemy_empty_one_readability_20260610.png
```

农夫：

```text
assets/concepts/artist_thread_low_whispering_field_20260620/enemy_famine_farmer_fullbody_concept.png
assets/concepts/art_iteration_round_20260610/art_iter_enemy_famine_farmer_readability_20260610.png
```

稻草人：

```text
assets/concepts/artist_thread_low_whispering_field_20260620/enemy_hungry_scarecrow_fullbody_concept.png
assets/concepts/art_iteration_round_20260610/art_iter_enemy_scarecrow_cast_readability_20260610.png
```

谷仓王：

```text
assets/concepts/artist_thread_low_whispering_field_20260620/boss_barn_king_fullbody_or_keypose_concept.png
assets/concepts/art_clean_color_round_20260610/art_clean_color_barn_king_20260610.png
assets/concepts/art_iteration_round_20260610/art_iter_boss_barn_king_phase_readability_20260610.png
```

### 角色通用规格

- 单帧：`768x768` RGBA PNG。
- 背景：透明 alpha。
- 锚点：feet anchor `x=384, y=720`。
- 脚底：完整可见，不要裁切脚、袍摆、武器尖端。
- 每个动作单独生成/处理，不要混在一张大图里。
- P0 代理每动作 4 帧；最终建议 6-8 帧。
- 命名：

```text
assets/card_demo/actors/{actor_key}/{action}/{action}_0.png
assets/card_demo/actors/{actor_key}/{action}/{action}_1.png
...
```

actor_key：

```text
player_echo
enemy_empty
enemy_farmer
enemy_scarecrow
boss_barn_king
collector
```

action：

```text
idle
attack
heavy_attack
defend
hurt
talk
ultimate_cast
```

### 角色通用中文 prompt

```text
使用输入参考图的同一角色身份、轮廓、服装、材质和配色，生成 Godot 2D 卡牌骰子战斗的全身透明角色动作帧。角色站在透明背景中，脚底完整，feet anchor 适合 x=384 y=720，单帧 768x768 RGBA PNG。低饱和乡土暗黑奇幻，干燥旧纸、泥土、脏银、暗红点缀，清洁去噪，轮廓清楚，动作可读。只生成一个角色，不要场景，不要文字，不要投影，不要 UI。保持 body-only，刀光、尘土、命中特效、骰子效果不要合入角色身体帧。
```

### Character universal English prompt

```text
Use the input reference image as the exact same character identity, silhouette, costume, material language, and palette. Generate full-body transparent Godot 2D card-and-dice combat action frames. The character stands on a transparent background with complete feet, suitable feet anchor x=384 y=720, 768x768 RGBA PNG per frame. Low-saturation rural dark fantasy, dry old paper, dirt, tarnished silver, restrained dark red accents, clean denoised edges, clear silhouette, readable action. One character only, no scene, no text, no baked shadow, no UI. Body-only frames; do not include slash beams, dust, hit sparks, dice effects, or detached VFX in the character body frames.
```

### 动作提示词模板

#### idle

中文：

```text
动作：idle 待机。全身站姿，轻微呼吸、衣摆和肩颈微动，角色保持警觉但克制。动作幅度小，脚底锚点稳定，不位移。输出 4-6 帧透明 PNG 序列。
```

English:

```text
Action: idle. Full-body standing pose with subtle breathing, robe hem movement, and slight shoulder/neck motion. Alert but restrained. Very small motion, stable feet anchor, no body translation. Output 4-6 transparent PNG frames.
```

#### attack

中文：

```text
动作：attack 普通攻击。短促、克制、可读的近身攻击，武器或手臂向前/斜前动作，身体重心轻微前移。不要夸张刀光，不要大范围能量弧，不要尘土和命中特效，body-only。输出 6-8 帧；P0 可 4 帧。
```

English:

```text
Action: attack. Short, restrained, readable melee attack; weapon or arm moves forward / diagonal-forward, body weight shifts slightly forward. No exaggerated slash beam, no large energy arc, no dust or hit effect, body-only. Output 6-8 frames; 4 frames acceptable for P0.
```

#### heavy_attack

中文：

```text
动作：heavy_attack 重击。比普通攻击更沉、更压低重心，身体先蓄力再向前砸/劈/刺，乡土残片武器感，动作厚重但不动漫化。不要大招姿势，不要满屏刀光，特效另出。输出 6-8 帧。
```

English:

```text
Action: heavy_attack. Heavier than normal attack, lower center of gravity, brief wind-up then a weighty chop, stab, or slam with a rural fragment weapon feeling. Heavy but not anime-like. No ultimate pose, no screen-filling slash; FX are separate. Output 6-8 frames.
```

#### defend

中文：

```text
动作：defend 防御/护身。双手、残片武器、衣摆和身体向内收拢，保护胸口或腹部核心标记。不要亮蓝魔法盾，不要大圆罩，不要科幻屏障。输出 4-6 帧。
```

English:

```text
Action: defend. Hands, fragment weapon, robe strips, and body curl inward to protect the chest or stomach core mark. No bright blue magic shield, no large circular dome, no sci-fi barrier. Output 4-6 frames.
```

#### hurt

中文：

```text
动作：hurt 受击。身体后退、蜷缩或失衡，肩膀和头部收缩，脚底锚点尽量稳定。不要血腥爆裂，不要夸张飞出画面。输出 4-6 帧。
```

English:

```text
Action: hurt. The body recoils, curls inward, or loses balance; shoulders and head contract. Keep feet anchor as stable as possible. No gore burst, no exaggerated flying off-frame. Output 4-6 frames.
```

#### talk

中文：

```text
动作：talk 场景对话。轻微嘴部/头部/上身动效，像低声说话、登记、喃喃自语或告解。动作幅度小，不影响对话框布局。输出 4-6 帧代理即可。
```

English:

```text
Action: talk. Subtle mouth, head, and upper-body motion, like quiet speech, registration, muttering, or confession. Small motion only, should not disrupt dialogue UI layout. 4-6 proxy frames are enough.
```

#### ultimate_cast

仅主角 P0 必需；Boss 后续可做专属。

中文：

```text
动作：ultimate_cast 主角大招占位。表现“神之胃囊/圣匣记录被打开”的仪式感，胸口暗红标记与旧纸/封蜡/圣匣记录产生短促回应。角色身体收束后释放，不是赛博能量炮，不是二次元必杀，不要高饱和发光。body-only，吞噬痕迹另做 fx_ultimate_digest。输出 6-8 帧。
```

English:

```text
Action: ultimate_cast for the player. Convey the ritual feeling of a divine stomach sac / sacred casket record opening. The dark red chest mark briefly responds with old paper, sealing wax, and archive-record symbolism. The body gathers inward then releases. Not a cyber energy cannon, not an anime ultimate, no high-saturation glow. Body-only; the digest trace is a separate fx_ultimate_digest. Output 6-8 frames.
```

### 角色差异化补充

player_echo：

```text
银灰盔甲的空壳使徒，封闭头盔/无脸，白发或浅色头部轮廓，破碎黑灰/蓝灰布条，胸口暗红胃囊/圣痕，短刃或长刃。保持 assets/card_demo/actors/player_echo/source/player_echo_visual_benchmark_20260610_clean.png 的身份。
```

enemy_empty：

```text
空腹者，干瘪饥民、空碗、喉咙与腹部失衡，被掏空的记忆感。攻击像饥饿扑咬或抓挠，不像正规战士。
```

enemy_farmer：

```text
饥民农夫，粗布、长柄农具、播种和执行劳动的动作。attack 像挥动农具或撒出危险麦穗，talk 像低声登记/告解。
```

enemy_scarecrow：

```text
饥饿稻草人，木桩、破布、麦浪仪式符号。attack/heavy_attack 像麦秆刺击或木桩压下，defend 像破布和麦秆收拢。
```

boss_barn_king：

```text
谷仓王，谷仓/身体/胃囊/王权/献祭制度融合。体积大但仍必须能站在房间中战斗。动作帧可用 1024x1024 源处理后导出 768x768 或 Boss 专用 1024x1024，manifest 中另写 draw_size。不要画成横版背景里的巨大侧脸怪。
```

collector：

```text
收藏家，医生、研究者、档案管理员、圣物保管者混合体。全身站在无声圣匣场景中，不是半身像。银灰长袍、记录器具、样本标签、封蜡、脏银金属夹。
```

## 02 卡牌 UI 提示词

### 输入参考图建议

```text
assets/concepts/art_clean_color_round_20260610/art_clean_color_sacred_casket_ui_simple_20260610.png
assets/concepts/wyeth_rural_masterset_20260615/wyeth_rural_08_sacred_casket_log_ui_20260615.png
assets/card_demo/ui/intent/bubble_attack.png
assets/card_demo/ui/intent/bubble_defend.png
```

### 卡牌通用规格

- 单张：`512x768` RGBA PNG。
- 背景：透明或干净 alpha 边缘。
- 顶部：行动图标区域。
- 中央/下半：干净文字区，低噪点，高可读。
- 不要把具体中文/英文规则文字写死在图上，文字由 Godot 渲染。
- 卡面可以有小图标，不要满屏插画。
- 命名：

```text
assets/card_demo/ui/cards/card_attack_base.png
assets/card_demo/ui/cards/card_heavy_base.png
assets/card_demo/ui/cards/card_guard_base.png
assets/card_demo/ui/cards/card_ultimate_base.png
assets/card_demo/ui/cards/card_hover_frame.png
assets/card_demo/ui/cards/card_selected_frame.png
assets/card_demo/ui/cards/card_disabled_overlay.png
```

### 卡牌通用 prompt

中文：

```text
Godot 2D 卡牌 UI 资产，512x768 透明 PNG，旧纸卡面，脏银边框，封蜡、档案标签、医学样本标签、低饱和暗红点缀。顶部留行动图标区域，中央和下半留干净文字区，低噪点，高可读，不写任何文字。边缘 alpha 干净，可用于 Godot 叠加。不是现代手游按钮，不是赛博 UI，不是二次元卡面，不是满屏插画。
```

English:

```text
Godot 2D card UI asset, 512x768 transparent PNG, old paper card face, tarnished silver frame, sealing wax, archive label, medical sample tag, restrained dark red accents. Top area reserved for a small action icon; center and lower half reserved as a clean readable text area with low noise. No written text. Clean alpha edges for Godot overlay. Not a modern mobile game button, not cyber UI, not anime card art, not full-card illustration.
```

### 四张基础行动牌

card_attack_base：

```text
攻击牌。顶部小图标为克制短刃/残片划痕，表达 D20 对抗防御与 D3 伤害，但不要写文字或数字。旧纸、脏银边框、少量暗红封蜡。
```

```text
Attack card. The top icon is a restrained short blade / fragment scratch, implying D20 versus defense and D3 damage without written text or numbers. Old paper, tarnished silver border, small dark red sealing wax accent.
```

card_heavy_base：

```text
重击牌。顶部小图标为更重的压痕、断裂麦秆或沉重残片武器，表达高出 5 点触发和 D3 x2，但不要写文字或数字。整体比攻击牌更沉、更暗。
```

```text
Heavy attack card. The top icon shows a heavier dent, broken wheat stalk, or weighty fragment weapon, implying a 5-point advantage trigger and D3 x2 without text or numbers. Heavier and darker than the attack card.
```

card_guard_base：

```text
蓄防牌。顶部小图标为身体收拢、残片护身、双骰取高的档案标记感。不要画蓝色魔法盾，不要大圆罩。
```

```text
Guard charge card. The top icon suggests a body curling inward, fragment protection, and a two-roll take-high archive mark. No blue magic shield, no large dome barrier.
```

card_ultimate_base：

```text
大招牌。顶部小图标为圣匣记录/神之胃囊/暗红封蜡被打开，表达 3 次攻击后可用、D6 直伤无视防御，但不要写文字或数字。克制仪式感，不要能量炮。
```

```text
Ultimate card. The top icon shows a sacred casket record / divine stomach sac / dark red sealing wax opening, implying availability after three attacks and D6 direct damage ignoring defense, without written text or numbers. Restrained ritual feeling, no energy cannon.
```

### 状态框与禁用层

card_hover_frame：

```text
透明 hover 边框，脏银细边，旧纸轻微提亮，少量暗红角标，不遮挡文字区。
```

card_selected_frame：

```text
透明 selected 边框，比 hover 更明确，封蜡角标或档案夹锁定感，低饱和暗红点缀，不发光成霓虹。
```

card_disabled_overlay：

```text
透明禁用遮罩，灰褐旧纸阴影，像档案被暂时封存；不写文字，不大面积纯黑，不影响规则文字可读性。
```

## 03 骰子与投掷舞台提示词

### 输入参考图建议

```text
assets/card_demo/ui/dice/dice_roll_stage.png
assets/concepts/art_clean_color_round_20260610/art_clean_color_sacred_casket_ui_simple_20260610.png
assets/concepts/wyeth_rural_masterset_20260615/wyeth_rural_09_log_fragment_memory_samples_20260615.png
```

### 骰子规格

- 单骰：`512x512` RGBA PNG，透明背景。
- 投掷舞台：`768x384` 或 `640x320` RGBA PNG。
- 不要文字，不要数字可读要求过强，点数/刻痕可以作为材质符号。
- alpha 边缘干净，无白边/灰边。
- 命名：

```text
assets/card_demo/ui/dice/d20_attack_die.png
assets/card_demo/ui/dice/d20_defense_die.png
assets/card_demo/ui/dice/d3_effect_die.png
assets/card_demo/ui/dice/d6_ultimate_die.png
assets/card_demo/ui/dice/dice_roll_stage.png
```

### 骰子通用 prompt

中文：

```text
Godot 2D 骰子 UI 单体，512x512 透明 PNG，低饱和暗黑乡土奇幻，不是塑料游戏骰子。材质为旧骨、旧象牙、脏银、旧铁、封蜡或麦粒感，边缘手工磨损，刻痕暗红或冷灰，干净去噪，透明 alpha 边缘清楚。不要文字，不要 logo，不要高饱和发光，不要现代桌游塑料质感。
```

English:

```text
Godot 2D single dice UI asset, 512x512 transparent PNG, low-saturation rural dark fantasy, not a plastic game die. Material feels like old bone, aged ivory, tarnished silver, old iron, sealing wax, or rough grain. Worn handmade edges, dark red or cold gray engraved marks, clean denoised alpha edges. No text, no logo, no high-saturation glow, no modern plastic tabletop dice look.
```

d20_attack_die：

```text
攻击 D20，骨白/旧象牙材质，暗红刻痕，像被饥荒制度登记过的攻击骰。克制、干燥、旧物感。
```

d20_defense_die：

```text
防御 D20，脏银/旧铁/冷灰刻痕，像圣匣档案中的防御判定器物。更冷、更硬。
```

d3_effect_die：

```text
效果 D3，小而粗粝，旧骨或麦粒感，三面形态清楚，适合表示 D3 伤害，不要可爱玩具感。
```

d6_ultimate_die：

```text
大招 D6，圣匣、胃纹、暗红封蜡感，像被打开的仪式骰。不要塑料方块，不要霓虹发光，不要能量水晶。
```

### 投掷舞台 prompt

中文：

```text
Godot 2D 投掷舞台 UI，768x384 或 640x320 透明 PNG，旧木盘、档案托盘、圣匣托盘的混合体，中心留骰子位置，边缘有脏银夹、旧纸标签、少量封蜡。低噪点，不遮挡整屏，适合放在画面中央短暂显示。不要文字，不要现代按钮，不要高饱和发光。
```

English:

```text
Godot 2D dice roll stage UI, 768x384 or 640x320 transparent PNG, a hybrid of old wooden tray, archive tray, and sacred casket tray. Center area reserved for dice. Edges include tarnished silver clips, old paper labels, and small sealing wax accents. Low noise, does not cover the whole screen, suitable for a short centered display. No text, no modern buttons, no high-saturation glow.
```

## 04 FX 提示词

### FX 通用规格

- `512x512` 或 `768x768` RGBA PNG 序列帧。
- 透明背景。
- 与角色 body-only 动作拆分。
- 命名：

```text
assets/card_demo/fx/{fx_name}/{fx_name}_0.png
assets/card_demo/fx/{fx_name}/{fx_name}_1.png
...
```

### FX 通用 prompt

中文：

```text
Godot 2D 透明战斗 FX 序列帧，低饱和乡土暗黑奇幻，干燥、旧纸、尘土、脏银、暗红裂纹。效果短促、克制、可读，透明背景，干净 alpha，不能遮挡角色主体。不要高饱和魔法，不要赛博能量波，不要动漫大刀光，不要满屏粒子。
```

English:

```text
Godot 2D transparent combat FX sequence, low-saturation rural dark fantasy, dry old paper, dust, tarnished silver, restrained dark red cracks. Short, restrained, readable effect, transparent background, clean alpha, does not cover the character body. No high-saturation magic, no cyber energy wave, no anime slash beam, no full-screen particles.
```

fx_attack_slash：

```text
普通攻击短刀痕/残片划痕，1-3 帧，克制，贴近武器轨迹，像旧金属划过旧纸或干土，不要大刀光。
```

```text
Normal attack short blade trace / fragment scratch, 1-3 frames, restrained, close to the weapon path, like old metal scratching old paper or dry soil, no large slash beam.
```

fx_heavy_impact：

```text
重击压痕/尘土/暗红裂纹，2-4 帧，地面或空气中短促破裂，沉重但不满屏。
```

```text
Heavy impact dent / dust / restrained dark red crack, 2-4 frames, a brief fracture in ground or air, weighty but not screen-filling.
```

fx_guard_ready：

```text
蓄防提示，身体前方一层低调残片、衣摆收拢、旧纸标签被压住的感觉，2-4 帧。不能是蓝色大盾或圆罩。
```

```text
Guard ready cue, 2-4 frames, a low-key layer of fragments in front of the body, robe strips curling inward, old paper labels pressed together. Not a blue shield or circular dome.
```

fx_reflect：

```text
防御反弹，短促反咬/碎片回弹，2-4 帧，暗红和脏银小范围闪回，不要大爆炸。
```

```text
Defense reflect, 2-4 frames, a short biting recoil / fragments snapping back, restrained dark red and tarnished silver flicker, no large explosion.
```

fx_ultimate_digest：

```text
大招占位，“圣匣记录/神之胃囊”式暗红吞噬痕迹，4-6 帧。像旧纸档案被打开、胃纹收束、封蜡裂开后留下的吞食印记。不要赛博能量波，不要激光，不要二次元魔法阵。
```

```text
Ultimate placeholder FX, 4-6 frames, a dark red digest trace inspired by sacred casket records / divine stomach sac. Like old paper archives opening, stomach marks tightening, sealing wax cracking and leaving a devouring mark. No cyber energy wave, no laser, no anime magic circle.
```

## 05 文件命名与 Godot 接入规格

### 角色

```text
assets/card_demo/actors/{actor_key}/{action}/{action}_0.png
assets/card_demo/actors/{actor_key}/{action}/{action}_1.png
...
```

建议 manifest action 字段：

```json
{
  "actor": "player_echo",
  "action": "heavy_attack",
  "frame_count": 6,
  "fps": 10,
  "anchor": {"mode": "feet", "x": 384, "y": 720},
  "draw_size": [256, 256],
  "paths": [
    "assets/card_demo/actors/player_echo/heavy_attack/heavy_attack_0.png"
  ],
  "status": "p0_i2i_processed",
  "fx_policy": "body_only; detached FX loaded separately"
}
```

Boss 可使用：

```json
"draw_size": [420, 420]
```

或独立 Boss frame size，但必须在 manifest 写明。

### 卡牌

```text
assets/card_demo/ui/cards/card_attack_base.png
assets/card_demo/ui/cards/card_heavy_base.png
assets/card_demo/ui/cards/card_guard_base.png
assets/card_demo/ui/cards/card_ultimate_base.png
assets/card_demo/ui/cards/card_hover_frame.png
assets/card_demo/ui/cards/card_selected_frame.png
assets/card_demo/ui/cards/card_disabled_overlay.png
```

建议 UI manifest：

```json
{
  "id": "card_attack_base",
  "path": "assets/card_demo/ui/cards/card_attack_base.png",
  "size": [512, 768],
  "status": "p0_i2i_processed",
  "text_policy": "no baked text; Godot renders all labels and rules"
}
```

### 骰子

```text
assets/card_demo/ui/dice/d20_attack_die.png
assets/card_demo/ui/dice/d20_defense_die.png
assets/card_demo/ui/dice/d3_effect_die.png
assets/card_demo/ui/dice/d6_ultimate_die.png
assets/card_demo/ui/dice/dice_roll_stage.png
```

### FX

```text
assets/card_demo/fx/fx_attack_slash/fx_attack_slash_0.png
assets/card_demo/fx/fx_heavy_impact/fx_heavy_impact_0.png
assets/card_demo/fx/fx_guard_ready/fx_guard_ready_0.png
assets/card_demo/fx/fx_reflect/fx_reflect_0.png
assets/card_demo/fx/fx_ultimate_digest/fx_ultimate_digest_0.png
```

### Godot 导入与 QC

- PNG 必须保持 alpha。
- 关闭会损坏边缘的强压缩；UI 文本区不可被 mipmap/过滤弄糊。
- 批量检查：
  - 图片尺寸符合规格。
  - `RGBA` 或带 alpha。
  - 角色 alpha bbox 不触边。
  - feet anchor 附近脚底完整。
  - 卡牌文字区无烘焙文字。
  - 骰子和 FX 无复杂背景。
  - `.import` 文件不作为美术源提交依据，由主线程统一处理。

## 06 P0 / P1 优先级清单

### P0 必做

1. player_echo
   - `idle` 清洁/透明化统一。
   - `attack`
   - `heavy_attack`
   - `defend`
   - `hurt`
   - `ultimate_cast`

2. enemy_empty
   - `idle`
   - `attack`
   - `heavy_attack`
   - `defend`
   - `hurt`
   - `talk`

3. 四张基础行动牌
   - `card_attack_base`
   - `card_heavy_base`
   - `card_guard_base`
   - `card_ultimate_base`

4. 骰子与舞台
   - `d20_attack_die`
   - `d20_defense_die`
   - `d3_effect_die`
   - `d6_ultimate_die`
   - `dice_roll_stage`

5. 核心 FX
   - `fx_attack_slash`
   - `fx_heavy_impact`
   - `fx_guard_ready`
   - `fx_ultimate_digest`

### P0.5 第二批

1. enemy_farmer
   - `idle`
   - `attack`
   - `heavy_attack`
   - `defend`
   - `hurt`
   - `talk`

2. enemy_scarecrow
   - `idle`
   - `attack`
   - `heavy_attack`
   - `defend`
   - `hurt`
   - `talk`

3. 卡牌状态
   - `card_hover_frame`
   - `card_selected_frame`
   - `card_disabled_overlay`

4. `fx_reflect`

### P1

1. boss_barn_king
   - `idle`
   - `attack`
   - `heavy_attack`
   - `defend`
   - `hurt`
   - Boss 专属阶段动作。

2. collector
   - `idle`
   - `talk`
   - `gesture`

3. 更完整的逐帧最终动画
   - 主角 walk/attack/heavy/ultimate 6-8 帧重画。
   - 敌人 talk 与 defeat/confess 动作。

### 给真人画师 / 生成线程的直接任务单

```text
请按 docs/planning/32_NANOBANANA_CARD_COMBAT_ART_PROMPTS.md 生成卡牌骰子新版战斗资产。

第一批只做 P0：
1. player_echo：idle、attack、heavy_attack、defend、hurt、ultimate_cast，每帧 768x768 RGBA 透明，feet anchor x=384 y=720，body-only。
2. enemy_empty：idle、attack、heavy_attack、defend、hurt、talk，每帧 768x768 RGBA 透明。
3. 卡牌 UI：card_attack_base、card_heavy_base、card_guard_base、card_ultimate_base，512x768 RGBA，不写文字。
4. 骰子 UI：d20_attack_die、d20_defense_die、d3_effect_die、d6_ultimate_die，512x512 RGBA；dice_roll_stage 768x384 或 640x320。
5. FX：fx_attack_slash、fx_heavy_impact、fx_guard_ready、fx_ultimate_digest，透明 PNG 序列帧。

统一要求：
- 使用对应 fullbody_clean / concept reference 做 image-to-image。
- 低饱和、乡土、干燥、旧纸、泥土、脏银、暗红点缀。
- 角色全身、脚底完整、透明背景、不要场景、不要文字。
- 攻击 body-only；宽刀光、尘土、命中特效和骰子效果拆成 FX。
- 输出前必须去噪、清 alpha 边缘、检查缩小后可读性。
```
