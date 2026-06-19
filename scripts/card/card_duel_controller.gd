extends Control

const Dice := preload("res://scripts/card/dice_resolver.gd")
const PLAYER_MAX_HP_START: int = 12
const FARMER_MAX_HP: int = 9
const FARMER_PATTERN: Array[int] = [
	Dice.Action.DEFEND,
	Dice.Action.ATTACK,
	Dice.Action.DEFEND,
	Dice.Action.ATTACK
]
const CARD_ART_ROOT: String = "res://assets/card_demo"
const BACKGROUND_ART_PATH: String = CARD_ART_ROOT + "/backgrounds/bg_card_field_entrance.png"
const PLAYER_ART_ROOT: String = CARD_ART_ROOT + "/actors/player_echo"
const FARMER_ART_ROOT: String = CARD_ART_ROOT + "/actors/enemy_farmer"
const REWARD_ICON_PATHS: Dictionary = {
	"sickle": CARD_ART_ROOT + "/ui/rewards/reward_farmer_sickle.png",
	"hat": CARD_ART_ROOT + "/ui/rewards/reward_farmer_hat.png",
	"wheat": CARD_ART_ROOT + "/ui/rewards/reward_farmer_wheat.png"
}
const PLAYER_POSES: Array[String] = ["idle", "attack", "defend", "hit", "victory"]
const FARMER_POSES: Array[String] = ["idle", "mutter", "attack", "defend", "hit", "confess"]

enum DuelState { PRE_DIALOGUE, PLAYER_CHOICE, RESOLVING, VICTORY_STORY, REWARD_CHOICE, COMPLETE, DEFEAT }

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var state: DuelState = DuelState.PRE_DIALOGUE
var player_max_hp: int = PLAYER_MAX_HP_START
var player_hp: int = PLAYER_MAX_HP_START
var farmer_hp: int = FARMER_MAX_HP
var turn_index: int = 0
var selected_reward: String = ""
var archived_log: bool = false
var bonuses: Dictionary = {
	"sickle": false,
	"hat": false
}
var actor_frames: Dictionary = {
	"player": {},
	"farmer": {}
}
var actor_sprites: Dictionary = {}
var actor_pose: Dictionary = {
	"player": "idle",
	"farmer": "idle"
}
var actor_frame_index: Dictionary = {
	"player": 0,
	"farmer": 0
}
var actor_frame_time: Dictionary = {
	"player": 0.0,
	"farmer": 0.0
}
var actor_one_shot_time: Dictionary = {
	"player": 0.0,
	"farmer": 0.0
}
var actor_return_pose: Dictionary = {
	"player": "idle",
	"farmer": "idle"
}

var pre_dialogue: Array[String] = [
	"天亮就下田。",
	"名单别乱。",
	"先收这片。",
	"哭完再干活。",
	"我好饿。",
	"我的孩子还在等。"
]

var victory_story: Array[String] = [
	"我不是第一个把人带去田里的。",
	"我只是记得路。",
	"那年冬天，碗从门口摆到井边。",
	"有人说，只要名单干净，粮就会回来。",
	"我信了。",
	"第二天我照常下田。后来每天都是第二天。"
]

var log_fragment: Dictionary = {
	"title": "照常下田",
	"text": "他不觉得自己在杀人。他只是害怕哪一天没有人继续照常。",
	"reaction": "胃囊收缩了一下，像在模仿劳动。"
}

@onready var background: ColorRect = %Background
@onready var title_label: Label = %TitleLabel
@onready var state_label: Label = %StateLabel
@onready var player_hp_label: Label = %PlayerHpLabel
@onready var farmer_hp_label: Label = %FarmerHpLabel
@onready var intent_label: Label = %IntentLabel
@onready var player_actor: PanelContainer = %PlayerActor
@onready var farmer_actor: PanelContainer = %FarmerActor
@onready var player_actor_label: Label = %PlayerActorLabel
@onready var farmer_actor_label: Label = %FarmerActorLabel
@onready var dialogue_panel: PanelContainer = %DialoguePanel
@onready var dialogue_label: RichTextLabel = %DialogueLabel
@onready var dice_panel: PanelContainer = %DicePanel
@onready var dice_label: RichTextLabel = %DiceLabel
@onready var attack_button: Button = %AttackButton
@onready var defend_button: Button = %DefendButton
@onready var continue_button: Button = %ContinueButton
@onready var reward_panel: PanelContainer = %RewardPanel
@onready var reward_sickle_button: Button = %RewardSickleButton
@onready var reward_hat_button: Button = %RewardHatButton
@onready var reward_wheat_button: Button = %RewardWheatButton
@onready var archive_panel: PanelContainer = %ArchivePanel
@onready var archive_label: RichTextLabel = %ArchiveLabel


func _ready() -> void:
	rng.randomize()
	_connect_signals()
	_build_theme()
	_setup_art_assets()
	_enter_pre_dialogue()


func _process(delta: float) -> void:
	_update_actor_animation("player", delta)
	_update_actor_animation("farmer", delta)


func _connect_signals() -> void:
	attack_button.pressed.connect(func() -> void: _choose_action(Dice.Action.ATTACK))
	defend_button.pressed.connect(func() -> void: _choose_action(Dice.Action.DEFEND))
	continue_button.pressed.connect(_on_continue_pressed)
	reward_sickle_button.pressed.connect(func() -> void: _choose_reward("sickle"))
	reward_hat_button.pressed.connect(func() -> void: _choose_reward("hat"))
	reward_wheat_button.pressed.connect(func() -> void: _choose_reward("wheat"))


func _build_theme() -> void:
	var root_style := StyleBoxFlat.new()
	root_style.bg_color = Color(0.09, 0.075, 0.055, 0.95)
	root_style.border_color = Color(0.55, 0.48, 0.36, 0.9)
	root_style.set_border_width_all(2)
	root_style.set_corner_radius_all(4)

	for panel: PanelContainer in [dialogue_panel, dice_panel, reward_panel, archive_panel, player_actor, farmer_actor]:
		panel.add_theme_stylebox_override("panel", root_style)

	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.19, 0.145, 0.095, 1.0)
	button_style.border_color = Color(0.72, 0.62, 0.42, 1.0)
	button_style.set_border_width_all(2)
	button_style.set_corner_radius_all(4)

	for button: Button in [attack_button, defend_button, continue_button, reward_sickle_button, reward_hat_button, reward_wheat_button]:
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_color_override("font_color", Color(0.93, 0.86, 0.72, 1.0))
		button.focus_mode = Control.FOCUS_ALL

	background.color = Color(0.13, 0.115, 0.075, 1.0)


func _setup_art_assets() -> void:
	_setup_background_art()
	_load_actor_frames("player", PLAYER_ART_ROOT, "actor_player_echo", PLAYER_POSES)
	_load_actor_frames("farmer", FARMER_ART_ROOT, "actor_enemy_farmer", FARMER_POSES)
	_setup_actor_sprite("player", player_actor, player_actor_label)
	_setup_actor_sprite("farmer", farmer_actor, farmer_actor_label)
	_setup_reward_icons()


func _setup_background_art() -> void:
	var texture := _load_texture(BACKGROUND_ART_PATH)
	if texture == null:
		return

	var background_art := TextureRect.new()
	background_art.name = "BackgroundArt"
	background_art.texture = texture
	background_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_art.modulate = Color(0.78, 0.72, 0.64, 1.0)
	background_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background_art)
	move_child(background_art, background.get_index() + 1)


func _load_actor_frames(actor_key: String, root_path: String, file_prefix: String, poses: Array[String]) -> void:
	for pose: String in poses:
		var frames: Array[Texture2D] = []
		for frame_index: int in range(16):
			var path := "%s/%s_%s_%d.png" % [root_path, file_prefix, pose, frame_index]
			var texture := _load_texture(path)
			if texture == null:
				if frame_index == 0:
					var single_path := "%s/%s_%s.png" % [root_path, file_prefix, pose]
					texture = _load_texture(single_path)
				if texture == null:
					break
			frames.append(texture)
		if not frames.is_empty():
			actor_frames[actor_key][pose] = frames


func _setup_actor_sprite(actor_key: String, actor_panel: PanelContainer, fallback_label: Label) -> void:
	var frames: Array = _get_actor_frames(actor_key, "idle")
	if frames.is_empty():
		return

	var sprite := TextureRect.new()
	sprite.name = "%sArt" % actor_key.capitalize()
	sprite.texture = frames[0]
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sprite.offset_top = -10.0
	sprite.offset_bottom = 10.0
	actor_panel.add_child(sprite)
	actor_panel.move_child(sprite, 0)
	actor_sprites[actor_key] = sprite
	fallback_label.visible = false


func _setup_reward_icons() -> void:
	_apply_button_icon(reward_sickle_button, REWARD_ICON_PATHS["sickle"])
	_apply_button_icon(reward_hat_button, REWARD_ICON_PATHS["hat"])
	_apply_button_icon(reward_wheat_button, REWARD_ICON_PATHS["wheat"])


func _apply_button_icon(button: Button, path: String) -> void:
	var texture := _load_texture(path)
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 46)


func _load_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	if path.begins_with(CARD_ART_ROOT):
		var direct_image := Image.load_from_file(ProjectSettings.globalize_path(path))
		if direct_image != null and not direct_image.is_empty():
			return ImageTexture.create_from_image(direct_image)
	var resource := ResourceLoader.load(path)
	if resource is Texture2D:
		return resource
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		return null
	return ImageTexture.create_from_image(image)
	return null


func _enter_pre_dialogue() -> void:
	state = DuelState.PRE_DIALOGUE
	_set_action_buttons_enabled(false)
	reward_panel.visible = false
	archive_panel.visible = false
	continue_button.visible = true
	dice_label.text = "[center]农夫站在田路中央，像一条还没执行完的命令。[/center]"
	dialogue_label.text = _format_lines(pre_dialogue, "农夫")
	_update_actor_pose("idle", "mutter")
	_update_ui()


func _enter_player_choice() -> void:
	state = DuelState.PLAYER_CHOICE
	_set_action_buttons_enabled(true)
	continue_button.visible = false
	reward_panel.visible = false
	archive_panel.visible = false
	dialogue_label.text = "[center]对话失败。只能用行动让他停下来。[/center]"
	dice_label.text = "[center]选择本回合行动。[/center]"
	_update_actor_pose("idle", "idle")
	_update_ui()
	attack_button.grab_focus()


func _choose_action(player_action: int) -> void:
	if state != DuelState.PLAYER_CHOICE:
		return

	state = DuelState.RESOLVING
	_set_action_buttons_enabled(false)
	var enemy_action: int = _current_enemy_action()
	var result: Dictionary = Dice.resolve_exchange(player_action, enemy_action, rng, bonuses)
	_apply_result(result)
	_show_result(result)
	turn_index += 1

	if farmer_hp <= 0:
		_enter_victory_story()
	elif player_hp <= 0:
		_enter_defeat()
	else:
		state = DuelState.PLAYER_CHOICE
		_set_action_buttons_enabled(true)
		_update_ui()


func _apply_result(result: Dictionary) -> void:
	player_hp = clampi(player_hp + int(result["player_hp_delta"]), 0, player_max_hp)
	farmer_hp = clampi(farmer_hp + int(result["enemy_hp_delta"]), 0, FARMER_MAX_HP)


func _show_result(result: Dictionary) -> void:
	var player_action_name: String = _action_name(result["player_action"])
	var enemy_action_name: String = _action_name(result["enemy_action"])
	var lines: Array[String] = []
	lines.append("[b]本回合[/b] 你：%s / 农夫：%s" % [player_action_name, enemy_action_name])
	lines.append("[b]%s[/b]：%s" % [result["event"], result["summary"]])
	_append_roll(lines, "你的攻击骰", result["player_hit_roll"])
	_append_roll(lines, "你的防御骰", result["player_defense_roll"])
	_append_roll(lines, "你的效果骰/伤害", result["player_effect_roll"])
	_append_roll(lines, "你的奖励骰", result["player_bonus_roll"])
	_append_roll(lines, "农夫攻击骰", result["enemy_hit_roll"])
	_append_roll(lines, "农夫防御骰", result["enemy_defense_roll"])
	_append_roll(lines, "农夫效果骰/伤害", result["enemy_effect_roll"])
	lines.append("HP 变化：你 %s，农夫 %s" % [_format_delta(result["player_hp_delta"]), _format_delta(result["enemy_hp_delta"])])
	dice_label.text = "\n".join(lines)

	var farmer_bark: String = "规矩在这。" if result["enemy_action"] == Dice.Action.DEFEND else "误了时辰，田会醒。"
	dialogue_label.text = "[b]农夫[/b]\n%s" % farmer_bark

	var player_pose: String = "attack" if result["player_action"] == Dice.Action.ATTACK else "defend"
	var farmer_pose: String = "attack" if result["enemy_action"] == Dice.Action.ATTACK else "defend"
	if int(result["enemy_hp_delta"]) < 0:
		farmer_pose = "hit"
	if int(result["player_hp_delta"]) < 0:
		player_pose = "hit"
	_update_actor_pose(player_pose, farmer_pose)


func _enter_victory_story() -> void:
	state = DuelState.VICTORY_STORY
	_set_action_buttons_enabled(false)
	continue_button.visible = true
	continue_button.text = "归档日志"
	dialogue_label.text = _format_lines(victory_story, "农夫")
	dice_label.text = "[center][b]胜利[/b]\n农夫终于停下了。他开始说完整的话。[/center]"
	_update_actor_pose("victory", "confess")
	_update_ui()


func _enter_reward_choice() -> void:
	state = DuelState.REWARD_CHOICE
	continue_button.visible = false
	reward_panel.visible = true
	archive_panel.visible = true
	archive_label.text = "[b]样本归档：%s[/b]\n%s\n\n[i]%s[/i]" % [log_fragment["title"], log_fragment["text"], log_fragment["reaction"]]
	archived_log = true
	dice_label.text = "[center]选择一项从农夫身上留下来的东西。[/center]"
	dialogue_label.text = "[center]日志碎片已进入圣匣索引。[/center]"
	_update_ui()
	reward_sickle_button.grab_focus()


func _choose_reward(reward_id: String) -> void:
	if state != DuelState.REWARD_CHOICE:
		return

	selected_reward = reward_id
	if reward_id == "sickle":
		bonuses["sickle"] = true
		dice_label.text = "[center][b]获得：农夫的镰刀[/b]\n攻击牌额外掷 0-3 追加伤害。[/center]"
	elif reward_id == "hat":
		bonuses["hat"] = true
		dice_label.text = "[center][b]获得：农夫的帽子[/b]\n防御牌额外掷 0-3 加到防御骰。[/center]"
	else:
		var heal: int = Dice.roll_heal(rng)
		player_max_hp += heal
		player_hp = min(player_hp + heal, player_max_hp)
		dice_label.text = "[center][b]食用：农夫种的麦子[/b]\n最大 HP 和当前 HP 增加 %d。[/center]" % heal

	state = DuelState.COMPLETE
	reward_panel.visible = false
	continue_button.visible = true
	continue_button.text = "重新开始"
	dialogue_label.text = "[center]第一场样本结束。下一步可以接入更多敌人、卡牌和圣匣日志界面。[/center]"
	_update_ui()


func _enter_defeat() -> void:
	state = DuelState.DEFEAT
	_set_action_buttons_enabled(false)
	reward_panel.visible = false
	archive_panel.visible = false
	continue_button.visible = true
	continue_button.text = "回圣匣重试"
	dialogue_label.text = "[center]农夫仍在照常下田。你被这套流程回收。[/center]"
	dice_label.text = "[center][b]回收失败样本[/b]\n死因：没有在攻防骰里活下来。[/center]"
	_update_actor_pose("hit", "idle")
	_update_ui()


func _on_continue_pressed() -> void:
	match state:
		DuelState.PRE_DIALOGUE:
			_enter_player_choice()
		DuelState.VICTORY_STORY:
			_enter_reward_choice()
		DuelState.COMPLETE, DuelState.DEFEAT:
			_reset_run()
		_:
			pass


func _reset_run() -> void:
	player_max_hp = PLAYER_MAX_HP_START
	player_hp = PLAYER_MAX_HP_START
	farmer_hp = FARMER_MAX_HP
	turn_index = 0
	selected_reward = ""
	archived_log = false
	bonuses = {
		"sickle": false,
		"hat": false
	}
	continue_button.text = "开始决斗"
	_enter_pre_dialogue()


func _current_enemy_action() -> int:
	return FARMER_PATTERN[turn_index % FARMER_PATTERN.size()]


func _update_ui() -> void:
	player_hp_label.text = "无韵回响 HP %d / %d" % [player_hp, player_max_hp]
	farmer_hp_label.text = "饥民农夫 HP %d / %d" % [farmer_hp, FARMER_MAX_HP]
	intent_label.text = "农夫下一步：%s  |  序列：防御 -> 攻击 -> 防御 -> 攻击" % _action_name(_current_enemy_action())
	state_label.text = _state_name()
	title_label.text = "神烬使徒：低语田野卡牌骰子 Demo"


func _set_action_buttons_enabled(enabled: bool) -> void:
	attack_button.disabled = not enabled
	defend_button.disabled = not enabled


func _update_actor_pose(player_pose: String, farmer_pose: String) -> void:
	_set_actor_pose("player", player_pose, player_pose in ["attack", "defend", "hit"])
	_set_actor_pose("farmer", farmer_pose, farmer_pose in ["attack", "defend", "hit"])
	player_actor_label.text = "无韵回响\n[%s]\n\n脏银残片 / 胃纹微亮" % player_pose
	farmer_actor_label.text = "饥民农夫\n[%s]\n\n旧帽 / 种袋 / 名单" % farmer_pose


func _set_actor_pose(actor_key: String, pose: String, one_shot: bool) -> void:
	if _get_actor_frames(actor_key, pose).is_empty():
		pose = "idle"
	actor_pose[actor_key] = pose
	actor_frame_index[actor_key] = 0
	actor_frame_time[actor_key] = 0.0
	actor_one_shot_time[actor_key] = _pose_duration(actor_key, pose) if one_shot else 0.0
	actor_return_pose[actor_key] = "idle"
	_apply_actor_frame(actor_key)


func _update_actor_animation(actor_key: String, delta: float) -> void:
	var pose: String = actor_pose.get(actor_key, "idle")
	var frames: Array = _get_actor_frames(actor_key, pose)
	if frames.is_empty():
		return

	if float(actor_one_shot_time.get(actor_key, 0.0)) > 0.0:
		actor_one_shot_time[actor_key] = float(actor_one_shot_time[actor_key]) - delta
		if float(actor_one_shot_time[actor_key]) <= 0.0:
			_set_actor_pose(actor_key, String(actor_return_pose.get(actor_key, "idle")), false)
			return

	var frame_interval := 1.0 / _pose_fps(pose)
	actor_frame_time[actor_key] = float(actor_frame_time[actor_key]) + delta
	if float(actor_frame_time[actor_key]) < frame_interval:
		return

	actor_frame_time[actor_key] = 0.0
	actor_frame_index[actor_key] = (int(actor_frame_index[actor_key]) + 1) % frames.size()
	_apply_actor_frame(actor_key)


func _apply_actor_frame(actor_key: String) -> void:
	if not actor_sprites.has(actor_key):
		return
	var sprite: TextureRect = actor_sprites[actor_key]
	var pose: String = actor_pose.get(actor_key, "idle")
	var frames: Array = _get_actor_frames(actor_key, pose)
	if frames.is_empty():
		return
	var index: int = clampi(int(actor_frame_index.get(actor_key, 0)), 0, frames.size() - 1)
	sprite.texture = frames[index]


func _get_actor_frames(actor_key: String, pose: String) -> Array:
	if not actor_frames.has(actor_key):
		return []
	var pose_map: Dictionary = actor_frames[actor_key]
	if not pose_map.has(pose):
		return []
	return pose_map[pose]


func _pose_duration(actor_key: String, pose: String) -> float:
	var frames: Array = _get_actor_frames(actor_key, pose)
	if frames.is_empty():
		return 0.0
	return float(frames.size()) / _pose_fps(pose)


func _pose_fps(pose: String) -> float:
	match pose:
		"attack", "hit":
			return 12.0
		"defend":
			return 9.0
		"victory", "confess":
			return 7.0
		_:
			return 6.0


func _format_lines(lines: Array[String], speaker: String) -> String:
	var formatted: Array[String] = ["[b]%s[/b]" % speaker]
	for line: String in lines:
		formatted.append("“%s”" % line)
	return "\n".join(formatted)


func _append_roll(lines: Array[String], label: String, value: int) -> void:
	if value >= 0:
		lines.append("%s：%d" % [label, value])


func _format_delta(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return str(value)


func _action_name(action: int) -> String:
	match action:
		Dice.Action.ATTACK:
			return "攻击"
		Dice.Action.DEFEND:
			return "防御"
		_:
			return "未知"


func _state_name() -> String:
	match state:
		DuelState.PRE_DIALOGUE:
			return "战前对话"
		DuelState.PLAYER_CHOICE:
			return "选择行动"
		DuelState.RESOLVING:
			return "结算"
		DuelState.VICTORY_STORY:
			return "胜利故事"
		DuelState.REWARD_CHOICE:
			return "三选一奖励"
		DuelState.COMPLETE:
			return "样本完成"
		DuelState.DEFEAT:
			return "回收失败"
		_:
			return "未知"
