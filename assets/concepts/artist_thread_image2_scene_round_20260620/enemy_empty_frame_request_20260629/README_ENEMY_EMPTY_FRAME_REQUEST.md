# 2026-06-29 空腹者 enemy_empty 帧序列制作需求

给金荣俊 / 美术处理线程：

请基于本目录里的母图制作空腹者 `enemy_empty` 第一版动作帧序列。

## 母图

只使用这个文件作为帧序列母图：

```text
assets/concepts/artist_thread_image2_scene_round_20260620/enemy_empty_frame_request_20260629/enemy_empty_fullbody_clean_reference.png
```

这张图来自主线程本地：

```text
D:\Desktop\DeskHub\神烬使徒 Godot\art_edit_outputs_20260628\02_actor_sources\enemy_empty\fullbody_clean.png
```

注意：不要使用这些文件：

```text
fullbody_clean_source_alpha.png
fullbody_clean_checker_preview.png
```

原因：`fullbody_clean.png` 已经是正式规格：`768x768`、真透明 PNG、脚底锚点接近 `x=384, y=720`，适合作为动作帧基准。

## 统一规格

- 每张都是 `768x768`。
- 真透明 PNG。
- 全身完整，不裁脚。
- 脚底锚点保持接近 `x=384, y=720`。
- 角色大小、脸、发型、体型、破布服装、空碗、旧纸标签要和母图一致。
- 不要背景、地面、阴影底图、攻击特效、尘土、骰子、卡牌、UI、文字、logo、水印。
- 风格保持低饱和、乡土、干燥、冷清、高级商业游戏角色原画质感。
- 不要恶魔化、丧尸化、怪物化、血腥化、内脏化、二次元脸、赛博、现代实验室、高饱和魔法光。

## 第一版帧序列

请优先制作这些文件：

```text
enemy_empty_idle_0.png
enemy_empty_idle_1.png
enemy_empty_idle_2.png
enemy_empty_idle_3.png

enemy_empty_walk_0.png
enemy_empty_walk_1.png
enemy_empty_walk_2.png
enemy_empty_walk_3.png

enemy_empty_attack_0.png
enemy_empty_attack_1.png
enemy_empty_attack_2.png
enemy_empty_attack_3.png

enemy_empty_hit_0.png
enemy_empty_hit_1.png
enemy_empty_hit_2.png
```

动作说明：

- `idle`：抱着空碗，轻微佝偻呼吸，肩膀下沉，麻木疲惫。
- `walk`：拖步向前，身体虚弱，空碗仍在手中，不能变成奔跑。
- `attack`：向前伸碗 / 抓取 / 夺取粮食，虚弱但突然有攻击性。
- `hit`：上半身后仰或侧偏，空碗倾斜但不要飞走，不要画血。

## 目标 runtime 路径

最终交付给主线程时，请放到或命名为这些路径：

```text
assets/sprites/characters/enemies/enemy_empty_idle_0.png
assets/sprites/characters/enemies/enemy_empty_idle_1.png
assets/sprites/characters/enemies/enemy_empty_idle_2.png
assets/sprites/characters/enemies/enemy_empty_idle_3.png

assets/sprites/characters/enemies/enemy_empty_walk_0.png
assets/sprites/characters/enemies/enemy_empty_walk_1.png
assets/sprites/characters/enemies/enemy_empty_walk_2.png
assets/sprites/characters/enemies/enemy_empty_walk_3.png

assets/sprites/characters/enemies/enemy_empty_attack_0.png
assets/sprites/characters/enemies/enemy_empty_attack_1.png
assets/sprites/characters/enemies/enemy_empty_attack_2.png
assets/sprites/characters/enemies/enemy_empty_attack_3.png

assets/sprites/characters/enemies/enemy_empty_hit_0.png
assets/sprites/characters/enemies/enemy_empty_hit_1.png
assets/sprites/characters/enemies/enemy_empty_hit_2.png
```

这些路径应匹配当前 Godot registry 已使用的敌人运行帧命名。

## 交付建议

请交付：

```text
assets/sprites/characters/enemies/enemy_empty_*.png
assets/concepts/jin_rongjun_delivery_YYYYMMDD_enemy_empty_frames/preview_contact_sheet.png
assets/concepts/jin_rongjun_delivery_YYYYMMDD_enemy_empty_frames/README.md
```

README 里请说明：

- 是否完全基于 `enemy_empty_fullbody_clean_reference.png`。
- 是否保持 `768x768` 和透明通道。
- 是否保持脚底锚点接近 `x=384, y=720`。
- 是否存在需要主线程后续修边 / 去噪 / 对齐的问题。

