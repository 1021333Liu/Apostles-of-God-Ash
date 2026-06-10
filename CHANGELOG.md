# 更新日志 / Changelog

## 2026-06-10

### Art iteration: add P0 readability concept round

- Owner: Codex
- Changes:
  - Added `assets/concepts/art_iteration_round_20260610/` with six P0 readability concept sheets.
  - Added `docs/planning/ART_ROUND_20260610.md` to record files, addressed issues, concept-vs-runtime scope, and follow-up cleanup work.
- Reason:
  - `feature/art-iteration` needs a focused visual pass for silhouettes, attack anticipation, Boss phase contrast, and log-fragment pickup identity before runtime replacement.
- Impact:
  - Art concept references, future transparent PNG frame cleanup, and log-fragment visual direction.
- Verification:
  - This round only adds concept images and documentation; no Godot runtime code or asset registry changes were made.
- Follow-up:
  - Select usable poses from the sheets, clean them into transparent PNG frames, then replace current runtime assets after 1280x720 readability checks.
这个文件记录项目每次有意义的更新。  
原则：代码可以告诉我们“哪里变了”，但这里要告诉我们“为什么变了”。

## 记录规则

每次提交前，如果改动属于以下任意一种，都要写一条：

- 新功能
- 玩法调整
- 数值调整
- 关卡变化
- 文案更新
- 美术/音效资产接入
- Bug 修复
- 项目结构变化
- 协作文档变化

格式：

```md
## YYYY-MM-DD

### 类型：一句话标题

- 负责人：
- 改动：
- 原因：
- 影响范围：
- 验证：
- 后续：
```

## 2026-06-05

### 世界观文档：补充四层模型拆解

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `docs/planning/21_WORLDVIEW_FOUR_LAYER_MODEL.md`，按物理/自然法则、历史与势力、文化与信仰、日常质感四层拆解《神烬使徒》的底层世界观。
  - 更新 `docs/planning/00_PRODUCTION_INDEX.md`，加入四层世界观模型入口。
- 原因：
  - 需要把“神死后残骸仍在运行”“残骸被制度化”“玩家通过日志碎片向下挖掘真相”的世界观逻辑固定成团队共识。
- 影响范围：
  - 文案、日志碎片系统、美术设计、关卡环境叙事、UI 风格和后续十城邦扩展。
- 验证：
  - 已整理成独立 Markdown 文档，并加入制作索引。
- 后续：
  - 日志碎片文本和美术迭代应优先对照该四层模型，确保玩家看到的日常质感能反推底层规则。

## 2026-06-05

### 协作规划：建立美术迭代分支和日志系统排期

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `docs/planning/19_ART_ITERATION_BRANCH_PLAN.md`，明确 `feature/art-iteration` 的美术轮次边界、可读性问题清单、交付格式和验收标准。
  - 新增 `docs/planning/20_LOG_FRAGMENT_SYSTEM_PLAN.md`，将日志碎片掉落、拾取、归档、圣匣 UI 和第一故事拼接列为下一阶段核心系统。
  - 更新 `docs/planning/00_PRODUCTION_INDEX.md`，加入 19-20 号文档入口，并把日志碎片系统列入第一阶段完成定义。
  - 更新 `docs/planning/07_TEAM_GIT_WORKFLOW.md`，补充 `feature/art-iteration` 和 `feature/log-fragment-system` 的分支规则与文件边界。
- 原因：
  - 试玩反馈显示美术需要多轮调整，不能直接在 `main` 上试错；同时日志系统已经成为连接战斗和世界观的关键模块，需要正式排期。
- 影响范围：
  - 团队分支策略、美术迭代流程、日志系统开发计划、文案交付格式、后续 main 集成规则。
- 验证：
  - 文档已加入制作索引，Git 分支边界已写入团队协作流程。
- 后续：
  - 从当前 `main` 创建 `feature/art-iteration` 给美术轮次使用；日志系统开发时单开 `feature/log-fragment-system`。

## 2026-06-05

### 美术接入：概念图资产进入当前可玩版

- 负责人：美术 Agent / 刘秉昂 / Codex
- 改动：
  - 新增 5 张房间背景、9 张概念参考图、玩家/敌人/Boss 多帧 PNG、日志碎片脉冲帧，并保留对应 Godot `.import` 导入配置。
  - 扩展 `scripts/systems/art_asset_registry.gd`，支持玩家、敌人、Boss、日志碎片按 `idle`、`walk`、`attack`、`hit`、Boss 阶段状态切换帧。
  - 更新 `scripts/main.gd`，接入状态驱动绘制、受击短动画、日志碎片脉冲显示、Boss 分阶段显示，并移除常驻白色武器方向线。
  - 调整第三关固定 hazard 的范围、位置和伤害，并限制临时 hazard 堆积，降低试玩压迫感。
  - 修正 `.gitignore`，允许提交 Godot `.import` 文件；将旧 SVG UI 图标改为资源加载，避免导出时文件依赖不被识别。
- 原因：
  - 当前 Demo 需要从几何占位进入“可看见世界观”的阶段，让低语田野、空腹者、饥民农夫、稻草人、谷仓王和日志碎片具备初步视觉身份。
- 影响范围：
  - 美术资产管线、主场景绘制、角色/敌人/Boss 表现、日志碎片反馈、第三关 hazard 难度、Godot 导入配置。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，headless 检查通过。
- 后续：
  - 下一步应补真正的朝向/持武器帧，替代程序化挥砍线作为主要攻击表现。

## 2026-06-04

### 美术接入：建立正式资产目录和自动加载准备

- 负责人：刘秉昂 / Codex
- 改动：
  - 纳入美术师 Agent 产出的 `docs/planning/16_ART_ASSET_FORMAT_SPEC.md` 和 `docs/planning/17_IMAGE2_ART_GENERATION_PLAN.md`。
  - 新增 `docs/planning/18_ART_INTEGRATION_GUIDE.md`，明确正式 PNG 资产的放置路径、命名和 Godot 接入方式。
  - 新增美术资产目录：`assets/concepts/`、`assets/backgrounds/rooms/`、`assets/portraits/`、`assets/sprites/characters/`、`assets/sprites/pickups/`、`assets/vfx/`。
  - 新增 `scripts/systems/art_asset_registry.gd`，用于可选加载玩家、敌人、Boss、房间背景和日志碎片 PNG。
  - 更新 `scripts/main.gd`，让房间、玩家、敌人和 Boss 在指定 PNG 存在时优先显示正式美术，否则继续使用几何占位。
  - 更新 `docs/planning/00_PRODUCTION_INDEX.md`，加入 16-18 号美术文档入口。
- 原因：
  - 后续 image2 或真人画师会陆续交付资产，项目需要先准备路径、格式和代码钩子，避免每来一张图都临时改结构。
- 影响范围：
  - 美术资产管线、Godot 绘制 fallback、低语田野房间背景、玩家/敌人/Boss 占位替换流程。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 第一批美术图到位后，按 `18_ART_INTEGRATION_GUIDE.md` 放入指定路径并做比例、可读性和碰撞范围检查。

## 2026-06-03

### 文案更新：整合低语田野第 2 版文本

- 负责人：孙慧 / 刘秉昂 / Codex
- 改动：
  - 用文案同学交付的 `低语田野文案 第 2 版` 更新 `docs/planning/03_NARRATIVE_COPY.md`。
  - 新增头顶气泡文字池，覆盖跑图、小怪、空腹者、饥民农夫、饥饿稻草人、精英怪、谷仓王和 Boss 阶段气泡。
  - 更新 `scripts/main.gd` 中的收藏家开场、回圣匣台词、房间短句、击杀采样记忆碎片、谷仓王记忆和死亡回收台词。
- 原因：
  - 第 2 版文本强化了谷仓王悲剧动机、普通居民参与献祭的复杂性，并为后续头顶气泡系统提供了正式文案池。
- 影响范围：
  - 文案池、房间进入提示、死亡回收反馈、击杀采样反馈、Boss 通关记忆、后续气泡系统。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 下一步将第 8 节头顶气泡文字接入低概率气泡系统，并把神之胃囊记忆碎片接入日志系统 MVP。

## 2026-06-02

### 策划文档：新增专家评审简报

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `docs/planning/15_EXPERT_REVIEW_BRIEF.md`，整理项目介绍、美术方向、日志碎片系统、圣匣日志 UI、团队制作方式和专家评审问题。
  - 更新 `docs/planning/00_PRODUCTION_INDEX.md`，加入专家评审简报入口。
- 原因：
  - 下一阶段需要请业内专家判断美术方向和系统方向是否成立，需要一份可直接阅读的项目简报，而不是零散聊天记录。
- 影响范围：
  - 项目对外说明、专家评审、下一阶段美术和日志系统决策。
- 验证：
  - 已检查文档结构，覆盖项目定位、美术方案、系统方案和待评审问题。
- 后续：
  - 根据专家反馈决定优先做油画风视觉基准、日志系统 MVP 或战斗反馈补强。

### 集成：手工移植金荣俊分支的 HUD 与关卡可读性改动

- 负责人：金荣俊 / 刘秉昂 / Codex
- 改动：
  - 在 `feature/integration-vertical-slice` 中以当前 core 架构为底，手工移植金荣俊分支的 HUD 像素面板、原创 SVG 图标、HP 条、胃囊闭合条和记忆晶片图标。
  - 补充手柄左摇杆轴输入，保留键盘八方向输入。
  - 将饥民农夫动态危险区改为 `0.85` 秒高亮落点预警，预警阶段不造成伤害。
  - 房间清空时立即移除残留危险区，并显示“危险消退”反馈。
- 原因：
  - `feature/level-hud` 的 `scripts/main.gd` 与 core 分支系统拆分冲突，不能直接覆盖合并；需要把有效表现和可玩性改动移植进现有结构。
- 影响范围：
  - HUD 表现、手柄移动输入、农夫危险区预警、清房后的喘息时间。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 继续试玩确认胃囊闭合、击杀回血和近战命中反馈是否足够清楚。

### 文案交付：孙慧完成低语田野第一版文本池

- 负责人：孙慧 / 刘秉昂 / Codex
- 改动：
  - 将孙慧交付的低语田野世界观、收藏家开场、死亡回收、敌人图鉴、Boss 台词、神之胃囊记忆和静默者晶片文本整理进 `docs/planning/03_NARRATIVE_COPY.md`。
  - 在 core 分支中将其中一部分短文本接入 Demo 的开场、房间档案、死亡回收和 Boss 阶段反馈。
- 原因：
  - 文案不应只停留在外部聊天或临时文件里，需要进入仓库成为后续 HUD、图鉴和战斗反馈的正式依据。
- 影响范围：
  - 文案池、房间进入提示、死亡反馈、Boss 阶段提示和后续 UI 文案接入。
- 验证：
  - 文案已进入仓库文档，并已在 core 分支通过 Godot 主场景启动检查。
- 后续：
  - 后续把敌人图鉴、静默者晶片和胃囊记忆进一步做成正式档案 UI。

### 协作集成：吸收金荣俊分支的安全资料和 HUD 占位资产

- 负责人：金荣俊 / 刘秉昂 / Codex
- 改动：
  - 从 `feature/level-hud` 带入 `Communication.md`，记录金荣俊的试玩结论、P0-P2 优先级、待验证事项和素材许可证规则。
  - 带入 `assets/sprites/ui/` 下 5 个原创 SVG 像素占位图标：生命、胃囊开启、胃囊闭合、溢血、记忆晶片。
  - 带入 `docs/planning/11_JIN_RONGJUN_PLAYTEST_CHECKLIST.md`、`12_JIN_RONGJUN_PLAYTEST_NOTES.md`、`13_PIXEL_ART_ASSET_REQUEST.md`、`14_THIRD_PARTY_ASSET_SOURCES.md`。
  - 更新 `docs/planning/00_PRODUCTION_INDEX.md`，让新增协作文档有统一入口。
- 原因：
  - 金荣俊分支的关卡/HUD资料和素材是有效成果，但其 `scripts/main.gd` 与 core 分支的系统拆分冲突，必须先吸收低冲突资料，避免直接覆盖核心战斗结构。
- 影响范围：
  - 团队沟通、HUD 占位资产、试玩记录、美术资产需求、素材来源管理。
- 验证：
  - 已检查 `Communication.md` 内容，确认其记录了 HUD、移动、危险区前摇、清房喘息和素材规则。
- 后续：
  - 在 `feature/integration-vertical-slice` 中手工移植金荣俊分支的 HUD 像素化、危险区前摇和清房喘息逻辑。

### 协作流程：明确 core、level-hud 与 main 的集成边界

- 负责人：刘秉昂 / Codex
- 改动：
  - 更新 `docs/planning/07_TEAM_GIT_WORKFLOW.md`，明确 `main` 只接收稳定集成结果。
  - 明确 `feature/core-combat` 由刘秉昂 / Codex 维护核心战斗和系统拆分。
  - 明确 `feature/level-hud` 由金荣俊 / Codex 维护关卡、HUD、美术占位和试玩反馈。
  - 新增推荐集成分支 `feature/integration-vertical-slice`，用于手工整合两个功能分支。
  - 明确 `scripts/main.gd` 不能用覆盖方式解决冲突，必须保留 core 系统拆分并手工移植 level-hud 的表现逻辑。
- 原因：
  - 两个技术分支都改动了 `scripts/main.gd`，直接合并会产生冲突并可能删除 `scripts/systems/` 下的核心运行时脚本。
- 影响范围：
  - Git 分支策略、团队协作规则、后续 main 集成流程。
- 验证：
  - 已对比 `feature/core-combat` 与 `origin/feature/level-hud` 的差异，确认冲突集中在 `scripts/main.gd` 和 `CHANGELOG.md`。
- 后续：
  - 下一次进入 main 前，先创建 `feature/integration-vertical-slice` 做可运行集成版。

## 2026-06-01

### 文案更新：整合低语田野第 1 版文本

- 负责人：孙慧 / 刘秉昂 / Codex
- 改动：
  - 用文案同学交付的 `低语田野文案 第 1 版` 更新 `docs/planning/03_NARRATIVE_COPY.md`。
  - 保留收藏家、死亡回收、房间短句、敌人图鉴、谷仓王台词、神之胃囊记忆碎片、静默者晶片文本。
  - 新增“可直接进 Demo 的短文本”索引，便于后续程序和 HUD 接入。
  - 更新 `scripts/main.gd` 中的开场、房间短句、死亡回收和 Boss 阶段文本。
- 原因：
  - 当前世界观反馈 UI 已经上线，需要更强的正式文本支撑，而不是继续使用临时占位句。
- 影响范围：
  - 文案池、房间进入提示、死亡回收反馈、Boss 阶段反馈。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 继续把敌人图鉴、静默者晶片和神之胃囊记忆碎片接入正式档案 UI。

### 核心战斗：加入世界观反馈 UI

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增胃囊器官状态 UI，区分饥饿、闭合、溢血、归档四种状态。
  - 新增击杀后的采样记录，显示敌人身份、记忆碎片、胃囊反应、回血和末击伤害。
  - 新增死亡回圣匣的失败样本档案，记录死因和土地学习反馈。
  - 新增房间进入任务档案，让每个房间的异常机制和建议打法进入 UI。
  - 新增 Boss 胃囊暴露仪式提示和红色画面反馈，强化弱点窗口。
- 原因：
  - 试玩反馈显示世界观还停留在文案层，缺少和战斗行为绑定的反馈。
- 影响范围：
  - HUD 文本、战斗反馈、房间进入提示、死亡回收反馈、Boss 弱点表现。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 后续可交给 `feature/level-hud` 将这些反馈重做成正式 HUD 组件和美术资产。

### 平衡调整：麦穗危险区从必中改为可躲

- 负责人：刘秉昂 / Codex
- 改动：
  - 危险区新增 `arm_time` 预警时间，生成后先显示再开始造成伤害。
  - 饥民农夫的“牙齿作物”从玩家脚下生成改为沿玩家移动方向前方生成，并延长冷却。
  - 降低早期麦穗危险区的半径和伤害。
- 原因：
  - 试玩反馈“麦穗奔着我就来了，必定扣血”，原设计缺少反应窗口。
- 影响范围：
  - 血肉麦田、肠道灌溉渠、饥饿谷仓的危险区压力和移动容错。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 继续根据试玩反馈微调农夫施法频率、危险区预警时间和伤害。

### Bug 修复：战斗伤害中途回圣匣导致越界

- 负责人：刘秉昂 / Codex
- 改动：
  - 修复 `_update_enemies()` 在敌人接触伤害导致玩家死亡、立即回到圣匣并清空敌人数组后，仍继续访问旧索引的问题。
  - 修复 `_update_hazards()` 在危险区伤害导致玩家死亡、立即回到圣匣并清空危险区数组后，仍继续访问旧索引的问题。
  - 增加敌人循环、危险区循环中的数组长度保护和战斗模式退出保护。
  - 防止玩家因接触伤害死亡回圣匣后，继续套用敌人击退位移。
- 原因：
  - 玩家试玩第三关和危险区时触发 `Out of bounds get index`，造成运行中断。
- 影响范围：
  - 敌人接触伤害、危险区伤害、玩家死亡回圣匣、战斗更新循环。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 后续把伤害/死亡流程抽出时，应避免在实体迭代中直接清空当前数组。

### 核心战斗：优化攻击动作模块

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `scripts/systems/attack_runtime.gd`，集中管理近战冷却、连段窗口、斩击参数和前冲动作。
  - 更新 `scripts/main.gd`，攻击判定改为读取 `attack_runtime` 返回的出招数据。
  - 优化三段连击手感：前两段更快，第三段范围、击退、斩击宽度和伤害加成更强。
- 原因：
  - 近战攻击是玩家主操作，需要独立动作模块，后续才能继续接 AnimationPlayer、音效、手柄震动和真实 hitbox。
- 影响范围：
  - 玩家近战冷却、连段节奏、斩击视觉、攻击距离、击退和轻微前冲。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 下一步可把斩击 hitbox 从字典判定迁移成 Player 节点下的 Area2D/CollisionShape2D。

### 核心战斗：抽出敌人运行时系统

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `scripts/systems/enemy_runtime.gd`，集中处理敌人计时、移动、Boss 阶段解析、技能触发和接触判定。
  - 更新 `scripts/main.gd`，将空腹者、饥民农夫、饥饿稻草人与谷仓王的运行时更新转交给 `enemy_runtime`。
  - 保留危险区生成、文字特效、击杀奖励和流程推进在 `scripts/main.gd`，避免一次性重构过大。
- 原因：
  - 继续压缩 `main.gd` 的战斗职责，让后续 Enemy/Boss 场景化时有稳定的运行时接口。
- 影响范围：
  - 敌人移动、敌人技能触发、Boss 阶段技能、敌人接触伤害。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 下一步可把伤害结算与击杀事件继续抽出，或把 Boss 运行时独立成专门系统。

### 核心战斗：抽出玩家运行时状态

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `scripts/systems/player_runtime.gd`，集中管理玩家位置、速度、朝向、HP。
  - 在 `scripts/main.gd` 接入 `player_runtime`，移动更新、受伤扣血、跑局/圣匣重置改为通过该系统调用。
- 原因：
  - 继续 `feature/core-combat` 的战斗分层，先拆运行时状态层，为后续 Player 场景化迁移提供稳定接口。
- 影响范围：
  - 玩家移动、受击、回城重置、击杀回血写入路径。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 下一步可把玩家攻击/受击反馈继续下沉到该系统或 Player 节点脚本，保持主脚本只做流程调度。

### 核心战斗：抽出胃囊系统和战斗数据工厂

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `scripts/systems/god_stomach_relic.gd`，集中管理神之胃囊的击杀回血、受击闭合、溢血加伤和记忆晶片。
  - 新增 `scripts/systems/combat_data_factory.gd`，集中生成敌人与危险区数据。
  - 更新 `scripts/main.gd`，让主脚本只调度核心流程，不再直接维护胃囊计时和战斗数据模板。
- 原因：
  - 我们的 `feature/core-combat` 分支要先把战斗核心从单文件原型里拆出来，后续才能继续拆 `Player`、敌人、Boss 和房间控制器。
- 影响范围：
  - 核心战斗、神之胃囊残骸奖励、敌人/危险区生成入口。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误输出。
- 后续：
  - 继续拆分 `Player`、`Enemy`、`BarnKing`、`RoomController`，但每次只拆一个可验证边界。

### 协作交接：新增文案与关卡 HUD 任务说明

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `docs/planning/08_NARRATIVE_HANDOFF_PROMPT.md`，用于交给文案同学或她的 Codex。
  - 新增 `docs/planning/09_LEVEL_HUD_HANDOFF.md`，明确关卡/HUD/表现同学先用占位资产推进，不等待正式美术。
  - 新增 `docs/planning/10_JIN_RONGJUN_LEVEL_HUD_TASK_CARD.md`，作为金荣俊拉取 `feature/level-hud` 后的个人开工任务卡。
  - 更新 `docs/planning/00_PRODUCTION_INDEX.md` 的文档入口。
- 原因：
  - 三人协作需要更具体的个人任务说明，避免“等资产”“等文案”“不知道先做什么”。
- 影响范围：
  - 团队任务分配、文案交付、关卡/HUD 工作流。
- 验证：
  - 新文档已加入制作索引。
- 后续：
  - 文案同学交付第一版 Markdown 后，整理进 `docs/planning/03_NARRATIVE_COPY.md`。
  - 关卡/HUD 同学在 `feature/level-hud` 分支推进占位布局和反馈。

### 项目初始化：低语田野垂直切片骨架

- 负责人：刘秉昂 / Codex
- 改动：
  - 创建 Godot 工程配置 `project.godot`。
  - 创建主场景 `scenes/main.tscn`。
  - 创建首版原型脚本 `scripts/main.gd`。
  - 实现无声圣匣、低语田野固定房间链、近战、敌人、危险区、谷仓王 Boss、神之胃囊反馈。
- 原因：
  - 先验证 5-8 分钟垂直切片能否成立，不提前展开十城邦全量。
- 影响范围：
  - 工程骨架、玩法原型、Demo 执行规格。
- 验证：
  - 已用 Godot 4.6.3 启动 `res://scenes/main.tscn`，无错误、无警告。
- 后续：
  - 拆分 `Player`、敌人、Boss、HUD、残骸系统。
  - 调整近战手感和 Boss 阶段节奏。

### 策划拆分：建立分项制作文档

- 负责人：刘秉昂 / Codex
- 改动：
  - 新增 `docs/planning/00_PRODUCTION_INDEX.md`。
  - 新增美术、关卡、文案、道具、数值、任务拆分文档。
  - 新增 `docs/planning/07_TEAM_GIT_WORKFLOW.md`，明确三人团队分支和文件边界。
- 原因：
  - 三人协作需要明确分工，避免所有内容堆在一个 README 或一个脚本里。
- 影响范围：
  - 制作流程、任务分配、Git 协作。
- 验证：
  - README 已能指向分项策划入口。
- 后续：
  - 每次功能、文案、数值、关卡更新都同步记录到本文件。

### README 改写：项目首页与开发者介绍

- 负责人：刘秉昂 / Codex
- 改动：
  - 将 README 改成更幽默的 GitHub 项目首页。
  - 增加世界观介绍、低语田野介绍、当前可玩内容、开发状态和开发者分工。
  - 增加 `Coding：Codex` 署名。
- 原因：
  - GitHub 首页需要让外部读者快速理解“这是什么游戏”和“谁在做”。
- 影响范围：
  - `README.md`。
- 验证：
  - 已检查 Markdown 排版。
- 后续：
  - 后续每次可玩版本变化时，同步更新 README 的当前状态。
