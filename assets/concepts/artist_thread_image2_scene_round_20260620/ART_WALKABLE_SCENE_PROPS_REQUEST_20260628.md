# 2026-06-28 可走场景与 Walkable Props 美术需求

给金荣俊 / 美术处理线程：

用户参考了“用 AI 地图变成可用游戏场景”的方向，希望后续场景不是只有一张背景，而是能让小比例角色在里面走一小段，有树、篱笆、田埂、血麦等空间层次，接近“固定章节小场景”的可走体验。

注意：这不是要改成《星露谷物语》式开放地图，也不是重做玩法。当前游戏仍是固定章节推进的叙事卡牌骰子 RPG。场景扩展只服务：

- 角色在战斗 / 对话前能走入场景。
- 场景显得更大，人物相对缩小。
- 前景物件能遮挡脚边，增加空间感。
- 遇见敌人后仍切回对话 / 卡牌骰子战斗。

## 目标结构

请按三层来准备美术：

```text
background：现有 16:9 场景底图
walkable_props：树、篱笆、田垄、木牌、粮袋、血麦，可放在角色同层做 y-sort
foreground_occluders：前景枯枝、麦穗、门框、木梁，用来遮挡人物脚边或画面边缘
```

技术侧后续会在 Godot 里加：

- 可走区域 polygon。
- 碰撞障碍。
- y-sort。
- 前景遮挡层。
- 角色缩小后的探索镜头。

## 不要做的方向

明确不要：

- 不要改成开放大地图。
- 不要做可爱农场。
- 不要做像素素材包风格。
- 不要饱和绿色草地。
- 不要赛博、二次元、Q 版、塑料感。
- 不要继续堆新的 16:9 大场景数量。
- 不要把所有树和道具烘在一张图里，至少要有可拆的透明 PNG props。

## 优先生成的 walkable_props

先做 10-15 个透明 PNG 小物件即可，不要一次铺太多。

建议路径：

```text
assets/card_demo/props/dead_tree_01.png
assets/card_demo/props/dead_tree_02.png
assets/card_demo/props/dry_bush_01.png
assets/card_demo/props/dry_bush_02.png
assets/card_demo/props/broken_fence_01.png
assets/card_demo/props/broken_fence_02.png
assets/card_demo/props/field_ridge_01.png
assets/card_demo/props/empty_bowl_pile_01.png
assets/card_demo/props/register_sign_01.png
assets/card_demo/props/blood_wheat_clump_01.png
assets/card_demo/props/blood_wheat_clump_02.png
assets/card_demo/props/barn_post_01.png
assets/card_demo/props/hanging_cloth_01.png
assets/card_demo/props/grain_sack_rotten_01.png
assets/card_demo/props/wooden_stake_01.png
```

## 透明 PNG 规格

```text
transparent PNG
RGBA
no text
no UI
no character
clean silhouette
low saturation
readable when scaled down
no hard baked ground shadow
```

尺寸建议：

- 小物件：`512x512 RGBA PNG`
- 长条篱笆 / 田埂：`768x384 RGBA PNG`
- 前景遮挡枝条 / 麦穗：`1024x512 RGBA PNG`

## 总 prompt

```text
Create a transparent PNG game prop for a 2D narrative card-dice RPG. Low-saturation rural famine horror, dry old-paper texture, mud, tarnished wood, muted gray-brown palette with sparse dark red organic accents. The prop must be isolated on transparent background, clean silhouette, no character, no UI, no text, no card frame, no cyberpunk, no anime, no cute farm style, no plastic look. It should fit a bleak field scene where the player walks through a cursed agricultural village.
```

## 单物件补充 prompts

枯树：

```text
dead leafless tree, twisted dry branches, rural famine field, sparse exposed roots, clean readable silhouette, old bark texture, no leaves
```

干灌木：

```text
dry thorn bush, dead rural shrub, brittle branches, gray brown color, sparse dark red stains, clean transparent silhouette
```

破篱笆：

```text
broken wooden fence, crooked posts, old rope, dry mud stains, abandoned field boundary, low saturation, readable side silhouette
```

田埂：

```text
dry cracked field ridge, raised mud path edge, old farmland boundary, muted gray brown, suitable as walkable ground prop, transparent background
```

空碗堆：

```text
empty bowl pile, cracked ceramic bowls, famine relief queue evidence, old mud and dust, no text, no character, quiet tragic mood
```

登记牌：

```text
wooden registration sign, blank old board, no readable writing, tied cloth strips, field checkpoint feeling, rural famine bureaucracy
```

血麦：

```text
blood wheat clump, dry wheat stalks mixed with subtle dark red fleshy growth, rural horror but not too gory, clean silhouette, transparent PNG
```

谷仓木桩：

```text
barn wooden post, old beam fragment, scratches, rope marks, dark red stains, for foreground occlusion, tarnished rural wood
```

旧布条：

```text
hanging cloth strip, dirty gray linen, tied to a branch or stake, wind worn, famine village marker, no text, transparent background
```

腐烂粮袋：

```text
rotting grain sack, old burlap, small spilled grain, mud stains, famine storage evidence, muted color, transparent background
```

## 前景遮挡件

请额外准备 3-5 个 foreground occluders，用于压在角色前面：

```text
assets/card_demo/props/fg_wheat_blades_01.png
assets/card_demo/props/fg_dead_branch_01.png
assets/card_demo/props/fg_barn_door_frame_01.png
assets/card_demo/props/fg_hanging_cloth_strip_01.png
assets/card_demo/props/fg_blood_wheat_edge_01.png
```

要求：

- 透明 PNG。
- 左右边缘可以有裁切感，用于贴屏幕边缘。
- 中间不要遮太满，不能挡住主角脸和卡牌 UI。
- 可以遮脚边和下半身一点点。

## 可走场景底图补充要求

当前场景底图暂时够用。若顺手做 paintover，请只做这些轻修：

- 底部 UI 区域降低噪点。
- 中央角色行走路径更清楚。
- 避免高频麦穗把角色轮廓吃掉。
- 保持左右能放玩家和敌人的站位。
- 给可走路径留出 1-2 条明显地面通道。

不要重新生成大量新场景。

## Godot 接入备注

后续技术侧会按类似结构接入：

```text
SceneRoot
  Background
  WalkablePropsYSort
    Prop_dead_tree_01
    Prop_broken_fence_01
    Player
    Enemy
  ForegroundOccluders
  DialogueOrBattleUI
```

所以 props 最好是独立透明 PNG，不要和背景合死。

