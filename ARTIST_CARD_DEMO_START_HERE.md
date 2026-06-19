# 画师任务入口：卡牌骰子 Demo

这个分支是给画师看的工作分支：

```text
feature/card-demo-art
```

请不要直接改 `main`。所有卡牌 Demo 美术资产先提交到这个分支，确认后再由项目负责人合并。

## 这次为什么改方向

项目原来做过一版实时动作战斗：玩家进入低语田野、砍怪、躲危险区、打谷仓王。

但试玩后发现，这套玩法虽然能跑，却没有把《神烬使徒》最有辨识度的东西打出来：

- 世界观和战斗结合不够深。
- 日志碎片更像战斗后的附属奖励，不像主循环。
- 玩家没有强烈感觉自己是在“逼对方说出故事，并把这段记忆归档进身体”。

所以当前 Demo 转向为：

```text
进入场景
-> 和 NPC 对话失败
-> 攻击 / 防御二选一
-> 双方掷骰对抗
-> 胜利后敌人讲出故事
-> 获得日志碎片和三选一奖励
```

第一场样板敌人是：**饥民农夫**。

## 你需要先读的文件

按顺序看：

1. `README.md`
   - 看项目整体介绍和玩法转向说明。

2. `docs/planning/28_CARD_DICE_PIVOT_DESIGN.md`
   - 看新玩法的完整规则：攻击、防御、骰子、大成功、完美防御、反弹、胜利故事、三选一奖励。

3. `docs/planning/29_CARD_DEMO_ART_BRIEF.md`
   - 最重要。请直接按这个文件画 P0 资产。

## 第一批 P0 美术资产

请优先交这些，先让 Demo 能跑起来：

1. `bg_card_field_entrance.png`
   - 低语田野入口背景。
   - `1920x1080`。
   - 中央留玩家和农夫对峙空间，下方留卡牌 UI 空间。

2. 玩家“无韵回响”对峙动画组
   - 透明 PNG 序列，单帧建议 `768x768`。
   - 面向右侧敌人。
   - 至少：
     - `idle` 6 帧
     - `attack` 6-8 帧
     - `defend` 4-6 帧
     - `hit` 4 帧
     - `victory` 6 帧

3. 敌人“饥民农夫”对峙动画组
   - 透明 PNG 序列，单帧建议 `768x768`。
   - 面向左侧玩家。
   - 至少：
     - `idle` 6 帧
     - `mutter` 6 帧
     - `attack` 6-8 帧
     - `defend` 4-6 帧
     - `hit` 4 帧
     - `confess` 8 帧

4. 基础攻击牌 / 防御牌
   - 单卡 `512x768`。
   - 不要把效果正文画死，文字留给程序。

5. 骰子 UI
   - 命中骰、防御骰、效果骰。
   - 大成功、大失败、完美防御、反弹标记。

6. 敌人意图图标
   - 攻击意图。
   - 防御意图。
   - 行动序列小点。

7. 日志碎片和胜利归档 UI
   - 日志碎片图标。
   - 样本归档底板。
   - 胜利故事纸页，正文区域留给程序。

8. 首战奖励图标
   - 农夫的镰刀。
   - 农夫的帽子。
   - 农夫种的麦子。
   - 奖励卡底板。

## 推荐放置路径

请把导出的 PNG 放在：

```text
assets/card_demo/backgrounds/
assets/card_demo/actors/player_echo/
assets/card_demo/actors/enemy_farmer/
assets/card_demo/cards/
assets/card_demo/ui/dice/
assets/card_demo/ui/intent/
assets/card_demo/ui/log/
assets/card_demo/ui/rewards/
```

源文件可以先放：

```text
assets/card_demo/source/
```

如果源文件太大，先不要提交，单独发给项目负责人确认。

## 命名示例

玩家：

```text
actor_player_echo_idle_0.png
actor_player_echo_idle_1.png
actor_player_echo_attack_0.png
actor_player_echo_defend_0.png
actor_player_echo_hit_0.png
actor_player_echo_victory_0.png
```

农夫：

```text
actor_enemy_farmer_idle_0.png
actor_enemy_farmer_mutter_0.png
actor_enemy_farmer_attack_0.png
actor_enemy_farmer_defend_0.png
actor_enemy_farmer_hit_0.png
actor_enemy_farmer_confess_0.png
```

UI：

```text
card_basic_attack_art.png
card_basic_defense_art.png
ui_die_hit_d20.png
ui_die_defense_d20.png
ui_die_effect_d3.png
ui_intent_enemy_attack.png
ui_intent_enemy_defend.png
pickup_log_fragment_card_demo.png
reward_farmer_sickle.png
reward_farmer_hat.png
reward_farmer_wheat.png
```

## 风格关键词

- 低饱和。
- 乡村荒凉。
- 干燥、安静。
- 枯麦、灰褐土地、旧纸、脏银、封蜡。
- 暗红只用于胃囊、伤害、日志核心和封蜡。

可以参考 Andrew Wyeth 绘画里的乡村孤独感、干燥材质和大面积留白，但不要临摹具体作品，也不要复刻构图。

## 不要做

- 不要画成静态纸片人。角色需要 `idle / attack / defend / hit` 动画。
- 不要把卡牌效果文字画死在图片里。
- 不要做赛博蓝 UI。
- 不要做普通 RPG 金色装备图标。
- 不要让日志碎片像金币、宝石或经验球。
- 不要把背景画得比角色和 UI 更抢眼。

## 提交流程

```bash
git checkout feature/card-demo-art
git pull origin feature/card-demo-art
```

完成一批资产后：

```bash
git add assets/card_demo ARTIST_CARD_DEMO_START_HERE.md
git commit -m "Add card demo art round 1"
git push origin feature/card-demo-art
```

如果只提交部分资产，也可以提交：

```bash
git commit -m "Add player and farmer duel animation draft"
```

每次提交前，请确认不要误提交巨大临时文件、缓存文件或无关工程配置。
