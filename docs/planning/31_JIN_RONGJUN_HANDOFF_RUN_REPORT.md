# 金荣俊交接：运行与美术资源验收记录

日期：2026-06-21
分支：`handoff/to-jin-rongjun`
基线提交：`b5fbcfad69352afd6c61e1013d53eb37b68eed95`

## 本轮结论

- 旧的实时战斗切片工程结构有效，入口是 `project.godot -> scenes/main.tscn -> scripts/main.gd`。
- 当前本机没有可用 Godot 可执行文件。下载 Godot 4.6.3 运行时的尝试因 GitHub 网络连接超时失败，因此本轮没有伪造“已启动试玩”的结论。
- 卡牌 Demo 美术 manifest 完整，但主场景目前没有引用 `assets/card_demo/`；它是可交接的资源包，不是已经接线完成的卡牌流程。
- 本分支要求的 5 张 Image2 场景背景仍未生成。详见 `assets/concepts/artist_thread_image2_scene_round_20260620/ARTIST_THREAD_IMAGE2_SCENE_DELIVERY.md`。

## 已完成的静态验收

| 项目 | 结果 |
| --- | --- |
| Godot 项目入口 | `project.godot` 指向 `res://scenes/main.tscn` |
| 运行脚本 | 共 7 个 `scripts/**/*.gd` 文件；主场景绑定 `scripts/main.gd` |
| 卡牌 manifest | `godash.card_demo_art.v1` JSON 有效 |
| 动作资源 | 13 组动作，共 96 张角色帧，文件全部存在 |
| UI 资源 | 3 张 UI 图，文件全部存在 |
| 尺寸合同 | 96 张角色帧均为 `768x768`，符合 manifest |
| 运行时接线 | `scripts/`、`scenes/`、`project.godot` 对 `assets/card_demo/` 的引用数为 0 |
| Git 健康检查 | `git diff --check` 与 `git fsck --no-dangling --no-reflogs` 通过 |

## 金荣俊接手顺序

1. 在有 Godot 4.3+ 的机器上运行 `godot --editor --path .`，再按 `docs/planning/11_JIN_RONGJUN_PLAYTEST_CHECKLIST.md` 完成完整试玩。
2. 不要把 `assets/card_demo` 的 P0 动作帧误当最终美术。主角基准图、动作重画缺口和脚底锚点以 `assets/card_demo/README_CARD_ART_ROUND02.md` 为准。
3. 将卡牌 Demo 的 manifest 接入独立 registry 或卡牌专用场景；不要在 `scripts/main.gd` 里散落硬编码 PNG 路径。
4. 在 5 张场景 PNG 生成并验收后，按 `HUMAN_ARTIST_SCENE_BRIEF.md` 的文件名放入 `assets/concepts/artist_thread_image2_scene_round_20260620/`，生成接触表后再接入 Godot。

## 关键风险

- `assets/card_demo/actors/player_echo/source/player_echo_visual_benchmark_20260610.png` 是干净的高对比角色设定图，与当前低饱和乡村场景 brief 不完全一致。接线前应由主美确认以哪一份视觉规范为准，避免把 P0 代理帧锁成最终风格。
- 场景背景缺失时，不应以纯色或旧实时战斗背景冒充卡牌 Demo 的最终场景；这会掩盖 UI 覆盖区、站位留白与可读性问题。
