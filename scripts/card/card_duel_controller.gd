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
const ENCOUNTER_DATA_PATH: String = "res://data/encounters/low_whispering_field.json"
const CARD_ART_ROOT: String = "res://assets/card_demo"
const BACKGROUND_ART_PATH: String = CARD_ART_ROOT + "/backgrounds/bg_card_field_entrance.png"
const SANCTUM_BACKGROUND_ART_PATH: String = CARD_ART_ROOT + "/backgrounds/bg_silent_casket_collector_intro.png"
const COLLECTOR_PORTRAIT_PATH: String = CARD_ART_ROOT + "/actors/collector/source/collector_fullbody_front_20260625_alpha.png"
const ENCOUNTER_BACKGROUND_ART_PATHS: Dictionary = {
	"empty_stomach": CARD_ART_ROOT + "/backgrounds/bg_empty_stomach_queue.png",
	"famine_farmer": CARD_ART_ROOT + "/backgrounds/bg_farmer_field_register.png",
	"hungry_scarecrow": CARD_ART_ROOT + "/backgrounds/bg_scarecrow_blood_wheat.png",
	"barn_king": CARD_ART_ROOT + "/backgrounds/bg_barn_king_chamber.png"
}
const PLAYER_ART_ROOT: String = CARD_ART_ROOT + "/actors/player_echo"
const FARMER_ART_ROOT: String = CARD_ART_ROOT + "/actors/enemy_farmer"
const ENEMY_ACTOR_SOURCES: Dictionary = {
	"empty": {"root": CARD_ART_ROOT + "/actors/enemy_empty", "prefix": "enemy_empty"},
	"farmer": {"root": FARMER_ART_ROOT, "prefix": "actor_enemy_farmer"},
	"scarecrow": {"root": CARD_ART_ROOT + "/actors/enemy_scarecrow", "prefix": "enemy_scarecrow"},
	"barn_king": {"root": CARD_ART_ROOT + "/actors/boss_barn_king", "prefix": "boss_barn_king"}
}
const REWARD_ICON_PATHS: Dictionary = {
	"sickle": CARD_ART_ROOT + "/ui/rewards/reward_farmer_sickle.png",
	"hat": CARD_ART_ROOT + "/ui/rewards/reward_farmer_hat.png",
	"wheat": CARD_ART_ROOT + "/ui/rewards/reward_farmer_wheat.png"
}
const INTENT_ICON_PATHS: Dictionary = {
	"attack": CARD_ART_ROOT + "/ui/intent/bubble_attack.png",
	"defend": CARD_ART_ROOT + "/ui/intent/bubble_defend.png"
}
const DICE_ICON_PATHS: Dictionary = {
	"hit": CARD_ART_ROOT + "/ui/dice/d20_attack_die.png",
	"defense": CARD_ART_ROOT + "/ui/dice/d20_defense_die.png",
	"effect": CARD_ART_ROOT + "/ui/dice/d3_effect_die.png"
}
const DICE_ROLL_STAGE_PATH: String = CARD_ART_ROOT + "/ui/dice/dice_roll_stage.png"
const CARD_UI_PATHS: Dictionary = {
	"attack": CARD_ART_ROOT + "/ui/cards/card_attack_base.png",
	"heavy": CARD_ART_ROOT + "/ui/cards/card_attack_base.png",
	"defend": CARD_ART_ROOT + "/ui/cards/card_defend_base.png",
	"ultimate": CARD_ART_ROOT + "/ui/cards/card_attack_base.png",
	"selected": CARD_ART_ROOT + "/ui/cards/card_selected_frame.png",
	"hover": CARD_ART_ROOT + "/ui/cards/card_hover_frame.png"
}
const PLAYER_POSES: Array[String] = ["idle", "attack", "defend", "hit", "victory"]
const FARMER_POSES: Array[String] = ["idle", "mutter", "attack", "defend", "hit", "confess"]
const ACTOR_ACTION_ALIASES: Dictionary = {
	"player": {
		"idle": ["field_idle", "idle"],
		"attack": ["card_attack", "attack"],
		"defend": ["card_defend", "defend"],
		"hit": ["card_hurt", "hit"],
		"victory": ["card_win", "victory"]
	},
	"farmer": {
		"idle": ["idle", "field_idle"],
		"mutter": ["idle"],
		"attack": ["idle"],
		"defend": ["idle"],
		"hit": ["idle"],
		"confess": ["idle"]
	}
}
const FIELD_PLAYER_START: Vector2 = Vector2(300.0, 540.0)
const FIELD_FARMER_POS: Vector2 = Vector2(640.0, 360.0)
const FIELD_INTERACT_DISTANCE: float = 135.0
const FIELD_PLAYER_SPEED: float = 260.0

enum DuelState { SANCTUM_INTRO, FIELD_EXPLORATION, FIELD_DIALOGUE, PRE_DIALOGUE, PLAYER_CHOICE, RESOLVING, VICTORY_STORY, REWARD_CHOICE, COMPLETE, DEFEAT }

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var state: DuelState = DuelState.SANCTUM_INTRO
var player_max_hp: int = PLAYER_MAX_HP_START
var player_hp: int = PLAYER_MAX_HP_START
var enemy_hp: int = FARMER_MAX_HP
var enemy_max_hp: int = FARMER_MAX_HP
var turn_index: int = 0
var player_attack_count: int = 0
var player_guard_charged: bool = false
var selected_reward: String = ""
var action_selection_index: int = 0
var reward_selection_index: int = 0
var archived_log: bool = false
var restore_story_threshold: int = 3
var encounter_data: Dictionary = {}
var encounters: Array = []
var current_encounter_index: int = 0
var current_encounter: Dictionary = {}
var current_rewards: Array = []
var current_log_fragment: Dictionary = {}
var bonuses: Dictionary = {
	"sickle": 0,
	"hat": 0
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
var background_art: TextureRect
var collector_portrait: TextureRect
var field_layer: Control
var field_player_sprite: TextureRect
var field_farmer_sprite: TextureRect
var field_interact_hint_label: Label
var field_prompt_label: Label
var field_dialogue_panel: PanelContainer
var field_dialogue_label: RichTextLabel
var dice_roll_stage: PanelContainer
var dice_roll_icon: TextureRect
var dice_roll_label: Label
var dice_roll_icon_tween: Tween
var heavy_button: Button
var ultimate_button: Button
var result_banner: PanelContainer
var result_banner_label: Label
var action_card_overlays: Dictionary = {}
var player_bubble: PanelContainer
var farmer_bubble: PanelContainer
var field_player_position: Vector2 = FIELD_PLAYER_START
var collector_intro_index: int = 0
var collector_intro_lines: Array[String] = [
	"你醒了。很好，这具身体还没有拒绝你。",
	"无声圣匣会把你带回来。痛会过去，留下来的东西更有用。",
	"第一站是低语田野。那里以前是粮仓，现在更像一张没合上的嘴。",
	"先别急着要名字。低语田野会给所有东西登记，名字在那里可能会被吃掉哦。",
	"记住，饿久了的人不一定盼着公道。他们先盼着下一顿。"
]
var field_dialogue_index: int = 0
var field_player_facing: float = 1.0
var field_dialogue_lines: Array[String] = [
	"咕噜……饿了。",
	"名单别乱。孩子还在田边等我。",
	"不是我不讲理，是田先听不懂人话。",
	"你也饿吗？那就照规矩来。"
]

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
var archived_fragments: Array[Dictionary] = []
var archive_fragment_index: int = 0
var failed_recoveries: int = 0
var last_failure_record: String = ""

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
	_ensure_gameplay_input_actions()
	rng.randomize()
	_load_encounter_data()
	_connect_signals()
	_build_theme()
	_setup_art_assets()
	_enter_sanctum_intro()


func _process(delta: float) -> void:
	_update_actor_animation("player", delta)
	var enemy_actor_key := _current_enemy_actor_key()
	_update_actor_animation(enemy_actor_key, delta)
	if state == DuelState.FIELD_EXPLORATION and not _archive_has_input_focus():
		_update_field_exploration(delta)


func _connect_signals() -> void:
	attack_button.pressed.connect(func() -> void: _choose_action(Dice.Action.ATTACK))
	defend_button.pressed.connect(func() -> void: _choose_action(Dice.Action.DEFEND))
	continue_button.pressed.connect(_on_continue_pressed)
	reward_sickle_button.pressed.connect(func() -> void: _choose_reward_by_index(0))
	reward_hat_button.pressed.connect(func() -> void: _choose_reward_by_index(1))
	reward_wheat_button.pressed.connect(func() -> void: _choose_reward_by_index(2))


func _load_encounter_data() -> void:
	encounter_data = _fallback_encounter_data()
	var file := FileAccess.open(ENCOUNTER_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("CardDuelController._load_encounter_data: cannot open %s" % ENCOUNTER_DATA_PATH)
	else:
		var parsed: Variant = JSON.parse_string(file.get_as_text())
		if parsed is Dictionary:
			encounter_data = parsed
		else:
			push_error("CardDuelController._load_encounter_data: invalid JSON in %s" % ENCOUNTER_DATA_PATH)
	restore_story_threshold = maxi(int(encounter_data.get("restore_story_threshold", 3)), 1)
	encounters = encounter_data.get("encounters", [])
	if encounters.is_empty():
		encounter_data = _fallback_encounter_data()
		encounters = encounter_data.get("encounters", [])
		restore_story_threshold = int(encounter_data.get("restore_story_threshold", 3))
	current_encounter_index = 0
	_set_current_encounter(0)


func _fallback_encounter_data() -> Dictionary:
	return {
		"chapter_title": "低语田野",
		"restore_story_threshold": 1,
		"collector_intro": collector_intro_lines,
		"collector_departure": [],
		"encounters": [
			{
				"id": "famine_farmer",
				"order": 1,
				"display_name": "饥民农夫",
				"room_name": "登记田路",
				"field_target": "田路中央的农夫",
				"actor_key": "farmer",
				"max_hp": FARMER_MAX_HP,
				"intent_pattern": ["defend", "attack", "defend", "attack"],
				"exploration_prompt": "WASD / 方向键移动，靠近田路中央的农夫",
				"field_dialogue": field_dialogue_lines,
				"pre_dialogue": pre_dialogue,
				"combat_barks": {"attack": "误了时辰，田会醒。", "defend": "规矩在这。"},
				"victory_story": victory_story,
				"log_fragment": log_fragment,
				"rewards": [
					{"id": "farmer_sickle", "title": "农夫的镰刀", "kind": "attack_bonus", "description": "攻击牌额外掷 0-3 追加伤害。", "button_text": "农夫的镰刀\n攻击追加 0-3"},
					{"id": "farmer_hat", "title": "农夫的帽子", "kind": "defense_bonus", "description": "防御牌额外掷 0-3 加到防御骰。", "button_text": "农夫的帽子\n防御追加 0-3"},
					{"id": "farmer_wheat", "title": "农夫种的麦子", "kind": "heal", "description": "最大 HP 和当前 HP 增加 1-3。", "button_text": "农夫种的麦子\n最大 HP + 1-3"}
				]
			}
		]
	}


func _set_current_encounter(index: int) -> void:
	if encounters.is_empty():
		return
	current_encounter_index = clampi(index, 0, encounters.size() - 1)
	current_encounter = encounters[current_encounter_index]
	enemy_max_hp = maxi(int(current_encounter.get("max_hp", FARMER_MAX_HP)), 1)
	enemy_hp = enemy_max_hp
	turn_index = 0
	action_selection_index = 0
	reward_selection_index = 0
	archived_log = false
	current_rewards = current_encounter.get("rewards", [])
	current_log_fragment = current_encounter.get("log_fragment", log_fragment)
	_apply_enemy_actor_layout()


func _current_encounter_name() -> String:
	return String(current_encounter.get("display_name", "未知样本"))


func _current_enemy_actor_key() -> String:
	var actor_key := String(current_encounter.get("actor_key", "farmer"))
	if actor_frames.has(actor_key):
		return actor_key
	return "farmer"


func _current_field_target() -> String:
	return String(current_encounter.get("field_target", _current_encounter_name()))


func _current_room_name() -> String:
	return String(current_encounter.get("room_name", "低语田野"))


func _apply_enemy_actor_layout() -> void:
	if not actor_sprites.has("farmer"):
		return
	var sprite: TextureRect = actor_sprites["farmer"]
	sprite.scale = Vector2.ONE
	sprite.modulate = Color.WHITE
	sprite.offset_left = 18.0
	sprite.offset_top = 16.0
	sprite.offset_right = -18.0
	sprite.offset_bottom = -16.0
	match String(current_encounter.get("actor_key", "farmer")):
		"scarecrow":
			sprite.scale = Vector2(0.92, 0.92)
			sprite.modulate = Color(0.90, 0.84, 0.70, 1.0)
			sprite.offset_left = 30.0
			sprite.offset_top = 10.0
			sprite.offset_right = -30.0
			sprite.offset_bottom = -10.0
		"barn_king":
			sprite.scale = Vector2(1.05, 1.05)
			sprite.modulate = Color(0.92, 0.86, 0.76, 1.0)
			sprite.offset_left = -8.0
			sprite.offset_top = 0.0
			sprite.offset_right = 8.0
			sprite.offset_bottom = 0.0


func _encounter_progress_text() -> String:
	if encounters.is_empty():
		return "样本 0/0"
	return "样本 %d/%d" % [current_encounter_index + 1, encounters.size()]


func _current_lines(key: String, fallback: Array[String]) -> Array[String]:
	var raw: Array = current_encounter.get(key, fallback)
	var lines: Array[String] = []
	for line: Variant in raw:
		lines.append(String(line))
	return lines


func _chapter_title() -> String:
	return String(encounter_data.get("chapter_title", "低语田野"))


func _pattern_text() -> String:
	var names: Array[String] = []
	for action: int in _current_enemy_pattern():
		names.append(_action_name(action))
	return " - ".join(names)


func _upcoming_pattern_text(count: int = 4) -> String:
	var pattern := _current_enemy_pattern()
	var names: Array[String] = []
	for i in count:
		var action: int = pattern[(turn_index + i) % pattern.size()]
		var prefix := "> " if i == 0 else ""
		names.append("%s%s" % [prefix, _action_name(action)])
	return " / ".join(names)


func _current_enemy_pattern() -> Array[int]:
	var raw_pattern: Array = current_encounter.get("intent_pattern", [])
	var pattern: Array[int] = []
	for raw_action: Variant in raw_pattern:
		pattern.append(_action_from_key(String(raw_action)))
	if pattern.is_empty():
		return FARMER_PATTERN.duplicate()
	return pattern


func _action_from_key(action_key: String) -> int:
	match action_key:
		"attack":
			return Dice.Action.ATTACK
		"defend":
			return Dice.Action.DEFEND
		_:
			return Dice.Action.DEFEND


func _reward_at(index: int) -> Dictionary:
	if index >= 0 and index < current_rewards.size() and current_rewards[index] is Dictionary:
		return current_rewards[index]
	return {}


func _has_next_encounter() -> bool:
	return current_encounter_index + 1 < encounters.size()


func _build_theme() -> void:
	var root_style := StyleBoxFlat.new()
	root_style.bg_color = Color(0.055, 0.047, 0.036, 0.94)
	root_style.border_color = Color(0.60, 0.52, 0.38, 0.95)
	root_style.set_border_width_all(2)
	root_style.set_corner_radius_all(3)

	var actor_style := StyleBoxFlat.new()
	actor_style.bg_color = Color(0.035, 0.032, 0.028, 0.72)
	actor_style.border_color = Color(0.50, 0.43, 0.32, 0.88)
	actor_style.set_border_width_all(1)
	actor_style.set_corner_radius_all(2)

	for panel: PanelContainer in [dialogue_panel, dice_panel, reward_panel, archive_panel]:
		panel.add_theme_stylebox_override("panel", root_style)
	for panel: PanelContainer in [player_actor, farmer_actor]:
		panel.add_theme_stylebox_override("panel", actor_style)

	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.17, 0.125, 0.080, 1.0)
	button_style.border_color = Color(0.74, 0.62, 0.38, 1.0)
	button_style.set_border_width_all(2)
	button_style.set_corner_radius_all(3)

	var button_hover_style := button_style.duplicate() as StyleBoxFlat
	button_hover_style.bg_color = Color(0.24, 0.18, 0.105, 1.0)
	button_hover_style.border_color = Color(0.92, 0.76, 0.45, 1.0)

	var button_pressed_style := button_style.duplicate() as StyleBoxFlat
	button_pressed_style.bg_color = Color(0.10, 0.075, 0.055, 1.0)
	button_pressed_style.border_color = Color(0.92, 0.43, 0.28, 1.0)

	for button: Button in [attack_button, defend_button, continue_button, reward_sickle_button, reward_hat_button, reward_wheat_button]:
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_stylebox_override("hover", button_hover_style)
		button.add_theme_stylebox_override("pressed", button_pressed_style)
		button.add_theme_stylebox_override("focus", button_hover_style)
		button.add_theme_color_override("font_color", Color(0.93, 0.86, 0.72, 1.0))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.70, 1.0))
		button.add_theme_color_override("font_pressed_color", Color(1.0, 0.88, 0.64, 1.0))
		button.add_theme_font_size_override("font_size", 17)
		button.focus_mode = Control.FOCUS_ALL
	for button: Button in [attack_button, defend_button, reward_sickle_button, reward_hat_button, reward_wheat_button]:
		button.toggle_mode = true
	_setup_action_card_buttons()
	for button: Button in [heavy_button, ultimate_button]:
		button.add_theme_stylebox_override("normal", button_style)
		button.add_theme_stylebox_override("hover", button_hover_style)
		button.add_theme_stylebox_override("pressed", button_pressed_style)
		button.add_theme_stylebox_override("focus", button_hover_style)
		button.focus_mode = Control.FOCUS_ALL
		button.toggle_mode = true

	for label: Label in [title_label, state_label, player_hp_label, farmer_hp_label, intent_label, player_actor_label, farmer_actor_label]:
		label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.73, 1.0))
		label.add_theme_color_override("font_shadow_color", Color(0.02, 0.015, 0.012, 0.90))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
	title_label.add_theme_font_size_override("font_size", 20)
	state_label.add_theme_font_size_override("font_size", 15)
	intent_label.add_theme_font_size_override("font_size", 15)

	for rich_label: RichTextLabel in [dialogue_label, dice_label, archive_label]:
		rich_label.add_theme_color_override("default_color", Color(0.86, 0.78, 0.62, 1.0))
		rich_label.add_theme_color_override("font_selected_color", Color(0.95, 0.86, 0.66, 1.0))
		rich_label.add_theme_font_size_override("normal_font_size", 16)
		rich_label.add_theme_font_size_override("bold_font_size", 18)

	background.color = Color(0.13, 0.115, 0.075, 1.0)


func _ensure_gameplay_input_actions() -> void:
	_ensure_key_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_key_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_key_action("move_up", [KEY_W, KEY_UP])
	_ensure_key_action("move_down", [KEY_S, KEY_DOWN])
	_ensure_key_action("menu_left", [KEY_A, KEY_LEFT])
	_ensure_key_action("menu_right", [KEY_D, KEY_RIGHT])
	_ensure_key_action("toggle_archive", [KEY_P])
	_ensure_key_action("ui_accept", [KEY_SPACE, KEY_ENTER, KEY_KP_ENTER])


func _ensure_key_action(action_name: String, physical_keycodes: Array[int]) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for keycode: int in physical_keycodes:
		if _action_has_physical_key(action_name, keycode):
			continue
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action_name, event)


func _action_has_physical_key(action_name: String, physical_keycode: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var key_event := event as InputEventKey
		if key_event != null and key_event.physical_keycode == physical_keycode:
			return true
	return false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu_left"):
		if _archive_has_input_focus():
			_step_archive_fragment(-1)
			get_viewport().set_input_as_handled()
		elif state == DuelState.PLAYER_CHOICE:
			_set_action_selection(action_selection_index - 1)
			get_viewport().set_input_as_handled()
		elif state == DuelState.REWARD_CHOICE:
			_set_reward_selection(reward_selection_index - 1)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("menu_right"):
		if _archive_has_input_focus():
			_step_archive_fragment(1)
			get_viewport().set_input_as_handled()
		elif state == DuelState.PLAYER_CHOICE:
			_set_action_selection(action_selection_index + 1)
			get_viewport().set_input_as_handled()
		elif state == DuelState.REWARD_CHOICE:
			_set_reward_selection(reward_selection_index + 1)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("toggle_archive"):
		_toggle_archive_panel()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		if state == DuelState.SANCTUM_INTRO:
			_advance_sanctum_intro()
			get_viewport().set_input_as_handled()
		elif state == DuelState.FIELD_EXPLORATION and _is_near_farmer():
			_enter_field_dialogue()
			get_viewport().set_input_as_handled()
		elif state == DuelState.FIELD_DIALOGUE:
			_advance_field_dialogue()
			get_viewport().set_input_as_handled()
		elif state == DuelState.PLAYER_CHOICE:
			_confirm_action_selection()
			get_viewport().set_input_as_handled()
		elif state == DuelState.REWARD_CHOICE:
			_confirm_reward_selection()
			get_viewport().set_input_as_handled()
		elif state in [DuelState.PRE_DIALOGUE, DuelState.VICTORY_STORY, DuelState.COMPLETE, DuelState.DEFEAT]:
			_on_continue_pressed()
			get_viewport().set_input_as_handled()


func _toggle_archive_panel() -> void:
	if archive_panel.visible:
		archive_panel.visible = false
		_set_archive_expanded(false)
		_restore_ui_after_archive()
		_update_ui()
		return
	_set_archive_expanded(true)
	archive_label.text = _archive_panel_text()
	archive_panel.visible = true
	_enter_archive_overlay()
	_update_ui()


func _set_archive_expanded(expanded: bool) -> void:
	if archive_panel == null or archive_label == null:
		return
	if expanded:
		archive_panel.custom_minimum_size = Vector2(0.0, 560.0)
		archive_label.custom_minimum_size = Vector2(0.0, 510.0)
		archive_label.fit_content = false
		archive_label.scroll_active = true
	else:
		archive_panel.custom_minimum_size = Vector2(0.0, 150.0)
		archive_label.custom_minimum_size = Vector2.ZERO
		archive_label.fit_content = true
		archive_label.scroll_active = false


func _enter_archive_overlay() -> void:
	for node: Control in [player_actor, farmer_actor, dice_panel, dialogue_panel, attack_button, defend_button, continue_button, reward_panel]:
		node.visible = false
	for node: Control in [heavy_button, ultimate_button]:
		if node != null:
			node.visible = false
	if field_layer != null:
		field_layer.visible = false


func _restore_ui_after_archive() -> void:
	match state:
		DuelState.FIELD_EXPLORATION:
			_set_duel_ui_visible(false)
			if field_layer != null:
				field_layer.visible = true
				_set_field_layer_intro_mode(false)
			continue_button.visible = false
		DuelState.FIELD_DIALOGUE, DuelState.PRE_DIALOGUE:
			_set_duel_ui_visible(false)
			if field_layer != null:
				field_layer.visible = true
			if field_dialogue_panel != null:
				field_dialogue_panel.visible = true
			continue_button.visible = false
		DuelState.REWARD_CHOICE:
			_set_duel_ui_visible(true)
			continue_button.visible = false
			reward_panel.visible = true
			archive_panel.visible = false
			_set_action_buttons_enabled(false)
		DuelState.PLAYER_CHOICE:
			_enter_player_choice()
		_:
			pass


func _setup_art_assets() -> void:
	_setup_background_art()
	_setup_collector_intro_art()
	_load_actor_frames("player", PLAYER_ART_ROOT, "actor_player_echo", PLAYER_POSES)
	_load_enemy_actor_frames()
	_setup_actor_sprite("player", player_actor, player_actor_label)
	_setup_actor_sprite("farmer", farmer_actor, farmer_actor_label)
	_setup_reward_icons()
	_setup_field_layer()
	_setup_combat_presentation_layer()


func _load_enemy_actor_frames() -> void:
	for actor_key: String in ENEMY_ACTOR_SOURCES.keys():
		_ensure_actor_state(actor_key)
		actor_frames[actor_key] = {}
		var source: Dictionary = ENEMY_ACTOR_SOURCES[actor_key]
		_load_actor_frames(actor_key, String(source["root"]), String(source["prefix"]), FARMER_POSES)


func _setup_combat_presentation_layer() -> void:
	dice_roll_stage = PanelContainer.new()
	dice_roll_stage.name = "DiceRollStage"
	dice_roll_stage.visible = false
	dice_roll_stage.custom_minimum_size = Vector2(320.0, 150.0)
	dice_roll_stage.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	dice_roll_stage.offset_left = -160.0
	dice_roll_stage.offset_top = -76.0
	dice_roll_stage.offset_right = 160.0
	dice_roll_stage.offset_bottom = 74.0
	var stage_style := StyleBoxFlat.new()
	stage_style.bg_color = Color(0.07, 0.055, 0.04, 0.94)
	stage_style.border_color = Color(0.78, 0.68, 0.43, 1.0)
	stage_style.set_border_width_all(3)
	stage_style.set_corner_radius_all(5)
	dice_roll_stage.add_theme_stylebox_override("panel", stage_style)
	add_child(dice_roll_stage)

	var stage_art := TextureRect.new()
	stage_art.texture = _load_texture(DICE_ROLL_STAGE_PATH)
	stage_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stage_art.stretch_mode = TextureRect.STRETCH_SCALE
	stage_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dice_roll_stage.add_child(stage_art)

	var dice_margin := MarginContainer.new()
	dice_margin.add_theme_constant_override("margin_left", 18)
	dice_margin.add_theme_constant_override("margin_top", 14)
	dice_margin.add_theme_constant_override("margin_right", 18)
	dice_margin.add_theme_constant_override("margin_bottom", 14)
	dice_roll_stage.add_child(dice_margin)

	var dice_box := VBoxContainer.new()
	dice_box.alignment = BoxContainer.ALIGNMENT_CENTER
	dice_box.add_theme_constant_override("separation", 8)
	dice_margin.add_child(dice_box)

	dice_roll_icon = TextureRect.new()
	dice_roll_icon.custom_minimum_size = Vector2(70.0, 70.0)
	dice_roll_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dice_roll_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dice_roll_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dice_box.add_child(dice_roll_icon)

	dice_roll_label = Label.new()
	dice_roll_label.text = "D20"
	dice_roll_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dice_roll_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dice_roll_label.add_theme_font_size_override("font_size", 28)
	dice_roll_label.add_theme_color_override("font_color", Color(0.96, 0.87, 0.62, 1.0))
	dice_box.add_child(dice_roll_label)

	player_bubble = _make_action_bubble("PlayerActionBubble", Vector2(136.0, 214.0))
	farmer_bubble = _make_action_bubble("FarmerActionBubble", Vector2(-136.0, 214.0))
	add_child(player_bubble)
	add_child(farmer_bubble)
	_setup_result_banner()


func _setup_result_banner() -> void:
	result_banner = PanelContainer.new()
	result_banner.name = "CombatResultBanner"
	result_banner.visible = false
	result_banner.custom_minimum_size = Vector2(520.0, 78.0)
	result_banner.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	result_banner.offset_left = -260.0
	result_banner.offset_top = 124.0
	result_banner.offset_right = 260.0
	result_banner.offset_bottom = 202.0
	add_child(result_banner)

	result_banner_label = Label.new()
	result_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_banner_label.add_theme_font_size_override("font_size", 28)
	result_banner_label.add_theme_color_override("font_color", Color(0.98, 0.90, 0.66, 1.0))
	result_banner_label.add_theme_color_override("font_shadow_color", Color(0.03, 0.02, 0.015, 1.0))
	result_banner_label.add_theme_constant_override("shadow_offset_x", 2)
	result_banner_label.add_theme_constant_override("shadow_offset_y", 2)
	result_banner_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_banner.add_child(result_banner_label)


func _make_action_bubble(bubble_name: String, center_offset: Vector2) -> PanelContainer:
	var bubble := PanelContainer.new()
	bubble.name = bubble_name
	bubble.visible = false
	bubble.custom_minimum_size = Vector2(162.0, 70.0)
	bubble.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	bubble.offset_left = center_offset.x - 81.0
	bubble.offset_top = -center_offset.y - 35.0
	bubble.offset_right = center_offset.x + 81.0
	bubble.offset_bottom = -center_offset.y + 35.0
	var bg := TextureRect.new()
	bg.name = "BubbleArt"
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bubble.add_child(bg)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	bubble.add_child(margin)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 7)
	margin.add_child(row)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.custom_minimum_size = Vector2(42.0, 42.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)

	var label := Label.new()
	label.name = "Label"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.10, 0.065, 0.04, 1.0))
	row.add_child(label)
	return bubble


func _setup_background_art() -> void:
	var texture := _load_texture(_background_path_for_state())
	if texture == null:
		return

	background_art = TextureRect.new()
	background_art.name = "BackgroundArt"
	background_art.texture = texture
	background_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_art.modulate = Color(0.78, 0.72, 0.64, 1.0)
	background_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background_art)
	move_child(background_art, background.get_index() + 1)


func _refresh_background_art() -> void:
	if background_art == null:
		return
	var texture := _load_texture(_background_path_for_state())
	if texture != null:
		background_art.texture = texture


func _background_path_for_state() -> String:
	if state == DuelState.SANCTUM_INTRO:
		return SANCTUM_BACKGROUND_ART_PATH
	return _background_path_for_current_encounter()


func _background_path_for_current_encounter() -> String:
	var encounter_id := String(current_encounter.get("id", ""))
	return String(ENCOUNTER_BACKGROUND_ART_PATHS.get(encounter_id, BACKGROUND_ART_PATH))


func _setup_collector_intro_art() -> void:
	var texture := _load_texture(COLLECTOR_PORTRAIT_PATH)
	if texture == null:
		return

	collector_portrait = TextureRect.new()
	collector_portrait.name = "CollectorPortrait"
	collector_portrait.texture = texture
	collector_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	collector_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	collector_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	collector_portrait.modulate = Color(0.92, 0.88, 0.80, 1.0)
	collector_portrait.z_index = 2
	collector_portrait.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	collector_portrait.offset_left = -170.0
	collector_portrait.offset_top = -322.0
	collector_portrait.offset_right = 170.0
	collector_portrait.offset_bottom = 182.0
	add_child(collector_portrait)
	move_child(collector_portrait, background.get_index() + 2)


func _set_collector_intro_art_visible(visible: bool) -> void:
	if collector_portrait != null:
		collector_portrait.visible = visible


func _setup_field_layer() -> void:
	field_layer = Control.new()
	field_layer.name = "FieldExplorationLayer"
	field_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	field_layer.z_index = 3
	field_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(field_layer)
	move_child(field_layer, background.get_index() + 2)

	field_farmer_sprite = _make_field_sprite("FieldFarmer", _current_enemy_actor_key(), "mutter", Vector2(220.0, 220.0))
	field_farmer_sprite.position = FIELD_FARMER_POS - field_farmer_sprite.custom_minimum_size * 0.5
	field_layer.add_child(field_farmer_sprite)

	field_interact_hint_label = Label.new()
	field_interact_hint_label.name = "FieldInteractHint"
	field_interact_hint_label.text = "对话"
	field_interact_hint_label.visible = false
	field_interact_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	field_interact_hint_label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.62, 1.0))
	field_interact_hint_label.add_theme_color_override("font_shadow_color", Color(0.05, 0.03, 0.02, 1.0))
	field_interact_hint_label.add_theme_constant_override("shadow_offset_x", 2)
	field_interact_hint_label.add_theme_constant_override("shadow_offset_y", 2)
	field_interact_hint_label.size = Vector2(120.0, 32.0)
	field_layer.add_child(field_interact_hint_label)

	field_player_sprite = _make_field_sprite("FieldPlayer", "player", "idle", Vector2(190.0, 190.0))
	field_layer.add_child(field_player_sprite)

	field_prompt_label = Label.new()
	field_prompt_label.name = "FieldPrompt"
	field_prompt_label.text = "WASD / 方向键移动，靠近农夫后按 空格 / 回车 对话"
	field_prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	field_prompt_label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.68, 1.0))
	field_prompt_label.add_theme_color_override("font_shadow_color", Color(0.05, 0.03, 0.02, 1.0))
	field_prompt_label.add_theme_constant_override("shadow_offset_x", 2)
	field_prompt_label.add_theme_constant_override("shadow_offset_y", 2)
	field_prompt_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	field_prompt_label.offset_top = 22.0
	field_prompt_label.offset_bottom = 58.0
	field_layer.add_child(field_prompt_label)

	field_dialogue_panel = PanelContainer.new()
	field_dialogue_panel.name = "FieldDialoguePanel"
	field_dialogue_panel.visible = false
	field_dialogue_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	field_dialogue_panel.offset_left = 44.0
	field_dialogue_panel.offset_right = -44.0
	field_dialogue_panel.offset_top = -176.0
	field_dialogue_panel.offset_bottom = -34.0
	var dialogue_style := StyleBoxFlat.new()
	dialogue_style.bg_color = Color(0.065, 0.052, 0.04, 0.92)
	dialogue_style.border_color = Color(0.72, 0.61, 0.42, 0.92)
	dialogue_style.set_border_width_all(2)
	dialogue_style.set_corner_radius_all(4)
	field_dialogue_panel.add_theme_stylebox_override("panel", dialogue_style)
	field_layer.add_child(field_dialogue_panel)

	var dialogue_margin := MarginContainer.new()
	dialogue_margin.add_theme_constant_override("margin_left", 18)
	dialogue_margin.add_theme_constant_override("margin_top", 14)
	dialogue_margin.add_theme_constant_override("margin_right", 18)
	dialogue_margin.add_theme_constant_override("margin_bottom", 14)
	field_dialogue_panel.add_child(dialogue_margin)

	field_dialogue_label = RichTextLabel.new()
	field_dialogue_label.bbcode_enabled = true
	field_dialogue_label.fit_content = true
	field_dialogue_label.scroll_active = false
	field_dialogue_label.text = ""
	field_dialogue_label.add_theme_color_override("default_color", Color(0.86, 0.78, 0.62, 1.0))
	field_dialogue_label.add_theme_font_size_override("normal_font_size", 19)
	field_dialogue_label.add_theme_font_size_override("bold_font_size", 22)
	dialogue_margin.add_child(field_dialogue_label)
	_update_field_positions()


func _set_field_layer_intro_mode(enabled: bool) -> void:
	if field_player_sprite != null:
		field_player_sprite.visible = not enabled
	if field_farmer_sprite != null:
		field_farmer_sprite.visible = not enabled
	if field_interact_hint_label != null:
		field_interact_hint_label.visible = false
	if field_prompt_label != null:
		field_prompt_label.visible = not enabled
	if field_dialogue_panel != null:
		field_dialogue_panel.visible = enabled
		if enabled:
			field_dialogue_panel.offset_left = 78.0
			field_dialogue_panel.offset_right = -78.0
			field_dialogue_panel.offset_top = -178.0
			field_dialogue_panel.offset_bottom = -40.0


func _make_field_sprite(sprite_name: String, actor_key: String, pose: String, size: Vector2) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.name = sprite_name
	sprite.custom_minimum_size = size
	sprite.size = size
	sprite.pivot_offset = size * 0.5
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frames := _get_actor_frames(actor_key, pose)
	if not frames.is_empty():
		sprite.texture = frames[0]
	return sprite


func _load_actor_frames(actor_key: String, root_path: String, file_prefix: String, poses: Array[String]) -> void:
	for pose: String in poses:
		var frames: Array[Texture2D] = []
		for action_name: String in _actor_action_names(actor_key, pose):
			frames = _load_actor_frame_sequence(root_path, file_prefix, action_name)
			if not frames.is_empty():
				break
		if not frames.is_empty():
			actor_frames[actor_key][pose] = frames


func _actor_action_names(actor_key: String, pose: String) -> Array[String]:
	var action_map: Dictionary = ACTOR_ACTION_ALIASES.get(actor_key, {})
	if action_map.has(pose):
		var aliases: Array[String] = []
		for alias: String in action_map[pose]:
			aliases.append(alias)
		return aliases
	return [pose]


func _load_actor_frame_sequence(root_path: String, file_prefix: String, action_name: String) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for frame_index: int in range(16):
		var path := "%s/%s_%d.png" % [root_path, action_name, frame_index]
		var texture := _load_texture(path)
		if texture == null:
			path = "%s/%s/%s_%d.png" % [root_path, action_name, action_name, frame_index]
			texture = _load_texture(path)
		if texture == null:
			path = "%s/%s_%s_%d.png" % [root_path, file_prefix, action_name, frame_index]
			texture = _load_texture(path)
		if texture == null:
			if frame_index == 0:
				var single_path := "%s/%s_%s.png" % [root_path, file_prefix, action_name]
				texture = _load_texture(single_path)
			if texture == null:
				break
		frames.append(texture)
	return frames


func _setup_actor_sprite(actor_key: String, actor_panel: PanelContainer, fallback_label: Label) -> void:
	var frames: Array = _get_actor_frames(actor_key, "idle")
	if frames.is_empty():
		return

	var sprite := TextureRect.new()
	sprite.name = "%sArt" % actor_key.capitalize()
	sprite.texture = frames[0]
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sprite.offset_left = 18.0
	sprite.offset_top = 16.0
	sprite.offset_right = -18.0
	sprite.offset_bottom = -16.0
	actor_panel.add_child(sprite)
	actor_panel.move_child(sprite, 0)
	actor_sprites[actor_key] = sprite
	fallback_label.visible = false
	if actor_key == "farmer":
		_apply_enemy_actor_layout()


func _setup_reward_icons() -> void:
	for button: Button in [reward_sickle_button, reward_hat_button, reward_wheat_button]:
		button.custom_minimum_size = Vector2(190.0, 72.0)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.add_theme_font_size_override("font_size", 20)
	_apply_button_icon(reward_sickle_button, REWARD_ICON_PATHS["sickle"])
	_apply_button_icon(reward_hat_button, REWARD_ICON_PATHS["hat"])
	_apply_button_icon(reward_wheat_button, REWARD_ICON_PATHS["wheat"])


func _setup_action_card_buttons() -> void:
	var bottom_row := attack_button.get_parent()
	heavy_button = Button.new()
	heavy_button.name = "HeavyButton"
	heavy_button.text = ""
	heavy_button.pressed.connect(func() -> void: _choose_action(Dice.Action.HEAVY))
	bottom_row.add_child(heavy_button)
	bottom_row.move_child(heavy_button, attack_button.get_index() + 1)
	ultimate_button = Button.new()
	ultimate_button.name = "UltimateButton"
	ultimate_button.text = ""
	ultimate_button.pressed.connect(func() -> void: _choose_action(Dice.Action.ULTIMATE))
	bottom_row.add_child(ultimate_button)
	bottom_row.move_child(ultimate_button, defend_button.get_index() + 1)
	_configure_action_card_button(attack_button, "attack")
	_configure_action_card_button(heavy_button, "heavy")
	_configure_action_card_button(defend_button, "defend")
	_configure_action_card_button(ultimate_button, "ultimate")


func _configure_action_card_button(button: Button, card_key: String) -> void:
	var base_texture := _load_texture(String(CARD_UI_PATHS.get(card_key, "")))
	if base_texture == null:
		return
	button.custom_minimum_size = Vector2(172.0, 214.0)
	button.clip_contents = true
	button.icon = null
	button.expand_icon = false
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", Color(0.16, 0.10, 0.055, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.09, 0.055, 0.032, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.08, 0.04, 0.025, 1.0))

	var base := TextureRect.new()
	base.name = "CardBaseArt"
	base.texture = base_texture
	base.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	base.stretch_mode = TextureRect.STRETCH_SCALE
	base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(base)
	button.move_child(base, 0)

	var hover := TextureRect.new()
	hover.name = "CardHoverArt"
	hover.texture = _load_texture(String(CARD_UI_PATHS.get("hover", "")))
	hover.visible = false
	hover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	hover.stretch_mode = TextureRect.STRETCH_SCALE
	hover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(hover)

	var selected := TextureRect.new()
	selected.name = "CardSelectedArt"
	selected.texture = _load_texture(String(CARD_UI_PATHS.get("selected", "")))
	selected.visible = false
	selected.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	selected.stretch_mode = TextureRect.STRETCH_SCALE
	selected.mouse_filter = Control.MOUSE_FILTER_IGNORE
	selected.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	button.add_child(selected)
	action_card_overlays[card_key] = {"hover": hover, "selected": selected}

	var card_text := Label.new()
	card_text.name = "CardText"
	card_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_text.add_theme_font_size_override("font_size", 15)
	card_text.add_theme_color_override("font_color", Color(0.12, 0.075, 0.04, 1.0))
	card_text.add_theme_color_override("font_shadow_color", Color(0.92, 0.82, 0.62, 0.35))
	card_text.add_theme_constant_override("shadow_offset_x", 1)
	card_text.add_theme_constant_override("shadow_offset_y", 1)
	card_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_text.offset_left = 20.0
	card_text.offset_top = 70.0
	card_text.offset_right = -20.0
	card_text.offset_bottom = -46.0
	button.add_child(card_text)

	button.mouse_entered.connect(func() -> void:
		_set_action_card_hover(card_key, true)
	)
	button.mouse_exited.connect(func() -> void:
		_set_action_card_hover(card_key, false)
	)


func _set_action_card_hover(card_key: String, hovered: bool) -> void:
	var overlays: Dictionary = action_card_overlays.get(card_key, {})
	var hover := overlays.get("hover", null) as TextureRect
	var selected := overlays.get("selected", null) as TextureRect
	if hover != null:
		hover.visible = hovered and not (selected != null and selected.visible)


func _set_action_card_selected(card_key: String, selected_state: bool) -> void:
	var overlays: Dictionary = action_card_overlays.get(card_key, {})
	var selected := overlays.get("selected", null) as TextureRect
	var hover := overlays.get("hover", null) as TextureRect
	if selected != null:
		selected.visible = selected_state
	if hover != null and selected_state:
		hover.visible = false


func _set_action_card_text(button: Button, text: String) -> void:
	button.text = text
	var card_text := button.find_child("CardText", false, false) as Label
	if card_text != null:
		card_text.text = text


func _apply_button_icon(button: Button, path: String) -> void:
	var texture := _load_texture(path)
	if texture == null:
		return
	button.icon = texture
	button.expand_icon = true
	button.add_theme_constant_override("icon_max_width", 34)


func _load_texture(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	if path.begins_with(CARD_ART_ROOT) or not FileAccess.file_exists("%s.import" % path):
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


func _enter_sanctum_intro() -> void:
	state = DuelState.SANCTUM_INTRO
	collector_intro_index = 0
	_set_current_encounter(0)
	_refresh_background_art()
	_set_collector_intro_art_visible(true)
	if field_layer != null:
		field_layer.visible = true
		_set_field_layer_intro_mode(true)
	_set_sanctum_intro_ui_visible(true)
	_set_action_buttons_enabled(false)
	continue_button.text = "继续"
	_update_actor_pose("idle", "confess")
	_show_collector_intro_line()
	_update_ui()


func _advance_sanctum_intro() -> void:
	collector_intro_index += 1
	if collector_intro_index >= _collector_intro().size():
		_enter_field_exploration()
		return
	_show_collector_intro_line()


func _show_collector_intro_line() -> void:
	var lines := _collector_intro()
	var line := lines[clampi(collector_intro_index, 0, lines.size() - 1)]
	if field_dialogue_panel != null:
		field_dialogue_panel.visible = true
	if field_dialogue_label != null:
		field_dialogue_label.text = "[b]收藏家[/b]\n%s\n\n[color=#c7b277]Enter / Space 继续[/color]" % line
	dialogue_label.text = "[b]收藏家[/b]\n%s" % line
	dice_label.text = "[center][b]无声圣匣[/b]\n一具银白空壳在档案匣中醒来。收藏家的正式立绘尚未接入。[/center]"
	intent_label.text = "开场：收藏家记录样本 | 按 空格 / 回车 或继续"
	player_actor_label.text = "无韵回响\n[刚醒来]\n\n脏银残片 / 胃纹未稳定"
	farmer_actor_label.text = "收藏家\n[占位剪影]\n\n银灰长袍 / 记录器具 / 像医生不像恶魔"


func _collector_intro() -> Array[String]:
	if failed_recoveries > 0:
		return [
			"你又醒了。很好，圣匣至少把失败也带回来了。",
			"第 %d 次回收：%s。别急着解释，田野不会听解释。" % [failed_recoveries, last_failure_record],
			"这一次记住：不要只看骰子，也要看对方下一步想做什么。",
			"再进去。饥饿学得很快，你也必须学得更快。"
		]
	var raw: Array = encounter_data.get("collector_intro", collector_intro_lines)
	var lines: Array[String] = []
	for line: Variant in raw:
		lines.append(String(line))
	if lines.is_empty():
		return collector_intro_lines.duplicate()
	return lines


func _enter_field_exploration() -> void:
	state = DuelState.FIELD_EXPLORATION
	_refresh_background_art()
	_set_collector_intro_art_visible(false)
	field_player_position = FIELD_PLAYER_START
	field_player_facing = 1.0
	field_dialogue_index = 0
	get_viewport().gui_release_focus()
	_set_duel_ui_visible(false)
	if field_layer != null:
		field_layer.visible = true
		_set_field_layer_intro_mode(false)
	if field_dialogue_panel != null:
		field_dialogue_panel.visible = false
	_set_action_buttons_enabled(false)
	reward_panel.visible = false
	archive_panel.visible = false
	continue_button.visible = false
	_update_field_positions()
	_update_field_prompt()
	_show_room_entry_banner()


func _update_field_exploration(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		if not is_zero_approx(input_dir.x):
			field_player_facing = signf(input_dir.x)
		field_player_position += input_dir * FIELD_PLAYER_SPEED * delta
		field_player_position.x = clampf(field_player_position.x, 150.0, 1130.0)
		field_player_position.y = clampf(field_player_position.y, 250.0, 620.0)
	_update_field_positions()
	_update_field_prompt()


func _update_field_positions() -> void:
	if field_player_sprite == null:
		return
	field_player_sprite.position = field_player_position - field_player_sprite.custom_minimum_size * 0.5
	field_player_sprite.scale.x = field_player_facing
	if field_interact_hint_label != null:
		field_interact_hint_label.position = FIELD_FARMER_POS + Vector2(-60.0, -152.0)
	if field_farmer_sprite != null:
		var frames := _get_actor_frames(_current_enemy_actor_key(), "mutter")
		if frames.is_empty():
			frames = _get_actor_frames(_current_enemy_actor_key(), "idle")
		if not frames.is_empty():
			field_farmer_sprite.texture = frames[0]


func _update_field_prompt() -> void:
	if field_prompt_label == null:
		return
	var near_target := _is_near_farmer()
	field_prompt_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.58, 1.0) if near_target else Color(0.96, 0.88, 0.68, 1.0))
	if field_farmer_sprite != null:
		field_farmer_sprite.modulate = Color(1.0, 0.90, 0.62, 1.0) if near_target else Color.WHITE
	if field_interact_hint_label != null:
		field_interact_hint_label.visible = near_target
	if near_target:
		field_prompt_label.text = "按 空格 / 回车 与%s对话" % _current_encounter_name()
	else:
		var remaining_distance := maxi(int(ceil(field_player_position.distance_to(FIELD_FARMER_POS) - FIELD_INTERACT_DISTANCE)), 0)
		field_prompt_label.text = "%s | 还差 %d" % [String(current_encounter.get("exploration_prompt", "WASD / 方向键移动，靠近%s" % _current_field_target())), remaining_distance]


func _is_near_farmer() -> bool:
	return field_player_position.distance_to(FIELD_FARMER_POS) <= FIELD_INTERACT_DISTANCE


func _enter_field_dialogue() -> void:
	state = DuelState.FIELD_DIALOGUE
	field_dialogue_index = 0
	continue_button.visible = false
	if field_dialogue_panel != null:
		field_dialogue_panel.visible = true
	if field_prompt_label != null:
		field_prompt_label.text = "空格 / 回车 继续"
	_show_field_dialogue_line()


func _advance_field_dialogue() -> void:
	field_dialogue_index += 1
	if field_dialogue_index >= _current_lines("field_dialogue", field_dialogue_lines).size():
		_enter_pre_dialogue()
		return
	_show_field_dialogue_line()


func _show_field_dialogue_line() -> void:
	if field_dialogue_label == null:
		return
	var lines := _current_lines("field_dialogue", field_dialogue_lines)
	field_dialogue_label.text = "[b]%s[/b]\n%s" % [_current_encounter_name(), lines[clampi(field_dialogue_index, 0, lines.size() - 1)]]


func _set_duel_ui_visible(visible: bool) -> void:
	for node: Control in [title_label, state_label, player_hp_label, farmer_hp_label, intent_label, player_actor, farmer_actor, dialogue_panel, dice_panel, attack_button, defend_button, continue_button, reward_panel, archive_panel]:
		node.visible = visible
	for node: Control in [heavy_button, ultimate_button]:
		if node != null:
			node.visible = visible


func _set_sanctum_intro_ui_visible(visible: bool) -> void:
	for node: Control in [title_label]:
		node.visible = visible
	for node: Control in [state_label, player_hp_label, farmer_hp_label, intent_label, player_actor, farmer_actor, dice_panel, dialogue_panel, attack_button, defend_button, continue_button, reward_panel, archive_panel]:
		node.visible = false
	for node: Control in [heavy_button, ultimate_button]:
		if node != null:
			node.visible = false


func _enter_pre_dialogue() -> void:
	state = DuelState.PRE_DIALOGUE
	continue_button.visible = false
	if field_layer != null:
		field_layer.visible = true
	if field_dialogue_panel != null:
		field_dialogue_panel.visible = true
	if field_prompt_label != null:
		field_prompt_label.text = "?? / ?? ??"
	_set_collector_intro_art_visible(false)
	_set_duel_ui_visible(false)
	_set_action_buttons_enabled(false)
	reward_panel.visible = false
	archive_panel.visible = false
	continue_button.visible = false
	if field_dialogue_label != null:
		field_dialogue_label.text = _format_lines(_current_lines("pre_dialogue", pre_dialogue), _current_encounter_name())
	_update_actor_pose("idle", "mutter")
	_update_ui()

func _enter_player_choice() -> void:
	state = DuelState.PLAYER_CHOICE
	if field_layer != null:
		field_layer.visible = false
	if field_dialogue_panel != null:
		field_dialogue_panel.visible = false
	_set_duel_ui_visible(true)
	_set_action_buttons_enabled(true)
	continue_button.visible = false
	reward_panel.visible = false
	archive_panel.visible = false
	dialogue_label.text = "[center]对话失败。只能用行动让他停下来。[/center]"
	dice_label.text = "[center]选择本回合行动。[/center]"
	_update_actor_pose("idle", "idle")
	_update_ui()
	_refresh_card_button_texts()
	_set_action_selection(action_selection_index)
	_hide_action_bubbles()


func _refresh_card_button_texts() -> void:
	var attack_bonus := int(bonuses.get("sickle", 0))
	var defend_bonus := int(bonuses.get("hat", 0))
	var attack_text := "攻击\nD20 > 防御\n命中掷 D3"
	var heavy_text := "重击\n高出5点\nD3 x2"
	var defend_text := "蓄防\n下次受击\n防御投2取高"
	var ultimate_text := "大招\n%s\nD6直伤" % ("可用" if _ultimate_ready() else "%d/3" % player_attack_count)
	if attack_bonus > 0:
		attack_text += "\n奖励D3 x%d" % attack_bonus
		heavy_text += "\n奖励D3 x%d" % attack_bonus
	if defend_bonus > 0:
		defend_text += "\n奖励D3 x%d" % defend_bonus
	_set_action_card_text(attack_button, attack_text)
	_set_action_card_text(heavy_button, heavy_text)
	_set_action_card_text(defend_button, defend_text)
	_set_action_card_text(ultimate_button, ultimate_text)


func _choose_action(player_action: int) -> void:
	if state != DuelState.PLAYER_CHOICE:
		return

	state = DuelState.RESOLVING
	_set_action_buttons_enabled(false)
	attack_button.button_pressed = false
	defend_button.button_pressed = false
	var result: Dictionary
	if _is_enemy_turn():
		result = Dice.resolve_enemy_attack(rng, bonuses, player_guard_charged)
		player_guard_charged = false
	else:
		result = Dice.resolve_player_action(player_action, rng, bonuses, _ultimate_ready())
		if player_action in [Dice.Action.ATTACK, Dice.Action.HEAVY]:
			player_attack_count += 1
		elif player_action == Dice.Action.DEFEND:
			player_guard_charged = true
		elif player_action == Dice.Action.ULTIMATE and int(result.get("enemy_hp_delta", 0)) < 0:
			player_attack_count = 0
	await _play_combat_presentation(result)
	_finish_resolved_action(result)


func _set_action_selection(index: int) -> void:
	action_selection_index = wrapi(index, 0, 4)
	if _is_enemy_turn():
		action_selection_index = 2
	var buttons: Array[Button] = [attack_button, heavy_button, defend_button, ultimate_button]
	var keys: Array[String] = ["attack", "heavy", "defend", "ultimate"]
	for i: int in range(buttons.size()):
		buttons[i].button_pressed = action_selection_index == i
		_set_action_card_selected(keys[i], action_selection_index == i)
	buttons[action_selection_index].grab_focus()
	if _is_enemy_turn():
		dice_label.text = "[center][b]敌方攻击轮[/b]\nEnter / Space 结算自动防御。\n%s[/center]" % ("蓄防已就绪：防御骰投两次取最高。" if player_guard_charged else "未蓄防：防御骰投一次。")
		return
	match action_selection_index:
		0:
			dice_label.text = "[center][b]攻击[/b]\nD20 对抗敌方防御，成功后掷 D3 伤害。[/center]"
		1:
			dice_label.text = "[center][b]重击[/b]\nD20 必须比敌方防御高 5 点，命中后 D3 伤害翻倍。[/center]"
		2:
			dice_label.text = "[center][b]蓄防[/b]\n本轮不攻击。下一次敌方攻击时，防御 D20 投两次取最高。[/center]"
		_:
			dice_label.text = "[center][b]大招[/b]\n攻击累计 3 次后可用。无视防御，造成 D6 直伤。当前 %d/3。[/center]" % player_attack_count


func _confirm_action_selection() -> void:
	if _is_enemy_turn():
		_choose_action(Dice.Action.DEFEND)
		return
	if action_selection_index == 3 and not _ultimate_ready():
		_set_action_selection(action_selection_index)
		return
	var actions: Array[int] = [Dice.Action.ATTACK, Dice.Action.HEAVY, Dice.Action.DEFEND, Dice.Action.ULTIMATE]
	_choose_action(actions[action_selection_index])


func _finish_resolved_action(result: Dictionary) -> void:
	_apply_result(result)
	_show_result(result)
	turn_index += 1

	if enemy_hp <= 0:
		_enter_victory_story()
	elif player_hp <= 0:
		_enter_defeat()
	else:
		state = DuelState.PLAYER_CHOICE
		_set_action_buttons_enabled(true)
		_refresh_card_button_texts()
		_set_action_selection(action_selection_index)
		_update_ui()


func _play_combat_presentation(result: Dictionary) -> void:
	var player_action: int = result["player_action"]
	var enemy_action: int = result["enemy_action"]
	dialogue_label.text = "[center]%s[/center]" % _turn_phase_text()
	dice_label.text = "[center]骰子正在落下。[/center]"
	_show_action_bubbles(player_action, enemy_action)
	_update_actor_pose("idle", "mutter")
	await get_tree().create_timer(0.55).timeout
	await _roll_relevant_dice(result)
	_hide_action_bubbles()
	await _play_result_banner(result)
	_play_result_motion(result)
	await get_tree().create_timer(0.65).timeout


func _show_action_bubbles(player_action: int, enemy_action: int) -> void:
	if player_bubble != null:
		_configure_action_bubble(player_bubble, player_action)
		player_bubble.visible = true
		_pop_node(player_bubble)
	if farmer_bubble != null:
		_configure_action_bubble(farmer_bubble, enemy_action)
		farmer_bubble.visible = true
		_pop_node(farmer_bubble)


func _show_enemy_intent_preview() -> void:
	if farmer_bubble == null:
		return
	_configure_action_bubble(farmer_bubble, _current_enemy_action())
	farmer_bubble.visible = true
	_pop_node(farmer_bubble)


func _configure_action_bubble(bubble: PanelContainer, action: int) -> void:
	var action_key := "defend" if action == Dice.Action.DEFEND else "attack"
	var bg := bubble.find_child("BubbleArt", true, false) as TextureRect
	if bg != null:
		bg.texture = _load_texture(INTENT_ICON_PATHS[action_key])
	var icon := bubble.find_child("Icon", true, false) as TextureRect
	if icon != null:
		icon.texture = _load_texture(DICE_ICON_PATHS["defense" if action == Dice.Action.DEFEND else "hit"])
	var label := bubble.find_child("Label", true, false) as Label
	if label != null:
		match action:
			Dice.Action.HEAVY:
				label.text = "HEAVY"
			Dice.Action.ULTIMATE:
				label.text = "BURST"
			Dice.Action.DEFEND:
				label.text = "GUARD"
			_:
				label.text = "ATTACK"


func _hide_action_bubbles() -> void:
	if player_bubble != null:
		player_bubble.visible = false
	if farmer_bubble != null:
		farmer_bubble.visible = false


func _roll_relevant_dice(result: Dictionary) -> void:
	var roll_steps: Array[Dictionary] = []
	var player_action: int = result["player_action"]
	var enemy_action: int = result["enemy_action"]
	if player_action in [Dice.Action.ATTACK, Dice.Action.HEAVY]:
		_add_roll_step(roll_steps, "我方命中 D20", result["player_hit_roll"], "hit", 20, player_actor)
	elif player_action == Dice.Action.DEFEND:
		_add_roll_step(roll_steps, "我方防御 D20", result["player_defense_roll"], "defense", 20, player_actor)
		_add_roll_step(roll_steps, "我方蓄防 D20", result["player_defense_roll_2"], "defense", 20, player_actor)
	if enemy_action == Dice.Action.ATTACK:
		_add_roll_step(roll_steps, "%s命中 D20" % _current_encounter_name(), result["enemy_hit_roll"], "hit", 20, farmer_actor)
	elif enemy_action == Dice.Action.DEFEND:
		_add_roll_step(roll_steps, "%s防御 D20" % _current_encounter_name(), result["enemy_defense_roll"], "defense", 20, farmer_actor)
	if int(result["player_effect_roll"]) >= 0:
		_add_roll_step(roll_steps, "我方效果 D%d" % int(result.get("player_effect_sides", 3)), result["player_effect_roll"], "effect", int(result.get("player_effect_sides", 3)))
	elif int(result["enemy_effect_roll"]) >= 0:
		_add_roll_step(roll_steps, "%s效果 D%d" % [_current_encounter_name(), int(result.get("enemy_effect_sides", 3))], result["enemy_effect_roll"], "effect", int(result.get("enemy_effect_sides", 3)))
	var bonus_rolls: Array = result.get("player_bonus_rolls", [])
	for i: int in range(bonus_rolls.size()):
		_add_roll_step(roll_steps, "Bonus D3 #%d" % [i + 1], int(bonus_rolls[i]), "effect", 3)
	for step: Dictionary in roll_steps:
		await _roll_single_die(step["label"], int(step["value"]), step["kind"], int(step["sides"]), step.get("owner", null))


func _add_roll_step(roll_steps: Array[Dictionary], label: String, value: int, kind: String, sides: int, owner: Control = null) -> void:
	if value >= 0:
		roll_steps.append({"label": label, "value": value, "kind": kind, "sides": sides, "owner": owner})


func _roll_single_die(label: String, final_value: int, kind: String, sides: int, owner: Control = null) -> void:
	if dice_roll_stage == null or dice_roll_label == null:
		return
	if dice_roll_icon != null:
		dice_roll_icon.texture = _load_texture(DICE_ICON_PATHS.get(kind, DICE_ICON_PATHS["hit"]))
	dice_roll_stage.visible = true
	dice_roll_stage.scale = Vector2(0.88, 0.88)
	if dice_roll_icon != null:
		dice_roll_icon.rotation = 0.0
		dice_roll_icon.scale = Vector2.ONE
		dice_roll_icon.pivot_offset = dice_roll_icon.custom_minimum_size * 0.5
	_pop_node(dice_roll_stage)
	for i: int in range(8):
		var face := _roll_tick_face(sides, final_value, i)
		dice_roll_label.text = "%s\n%d" % [label, face]
		if dice_roll_icon != null:
			_tumble_die_icon(i)
		await get_tree().create_timer(0.055 + float(i) * 0.012).timeout
	dice_roll_label.text = _roll_result_label(label, final_value, sides)
	if dice_roll_icon != null:
		if dice_roll_icon_tween != null:
			dice_roll_icon_tween.kill()
		dice_roll_icon.rotation = 0.0
		dice_roll_icon.scale = Vector2.ONE
	_flash_node(dice_roll_stage, _roll_result_flash_color(final_value, sides))
	if owner != null and sides == 20 and (final_value == 20 or final_value == 0):
		_flash_actor_panel(owner, _roll_result_flash_color(final_value, sides))
	await get_tree().create_timer(0.42).timeout
	dice_roll_stage.visible = false


func _roll_tick_face(sides: int, final_value: int, tick_index: int) -> int:
	if tick_index >= 7:
		return final_value
	return randi_range(0, sides)


func _tumble_die_icon(tick_index: int) -> void:
	if dice_roll_icon_tween != null:
		dice_roll_icon_tween.kill()
	var angle := deg_to_rad(float(45 + (tick_index % 4) * 28))
	var scale_peak := 1.12 if tick_index % 2 == 0 else 0.94
	dice_roll_icon_tween = create_tween().set_parallel(true)
	dice_roll_icon_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	dice_roll_icon_tween.tween_property(dice_roll_icon, "rotation", angle, 0.045)
	dice_roll_icon_tween.tween_property(dice_roll_icon, "scale", Vector2(scale_peak, scale_peak), 0.045)
	dice_roll_icon_tween.chain().tween_property(dice_roll_icon, "scale", Vector2.ONE, 0.035)


func _roll_result_label(label: String, final_value: int, sides: int) -> String:
	if sides == 20 and final_value == 20:
		return "%s\n20 大成功" % label
	if sides == 20 and final_value == 0:
		return "%s\n0 大失败" % label
	if sides == 3 and final_value == 3:
		return "%s\n3 满值" % label
	if sides == 3 and final_value == 0:
		return "%s\n0 空值" % label
	return "%s\n%d" % [label, final_value]


func _roll_result_flash_color(final_value: int, sides: int) -> Color:
	if sides == 20 and final_value == 20:
		return Color(1.0, 0.42, 0.25, 1.0)
	if sides == 20 and final_value == 0:
		return Color(0.42, 0.34, 0.22, 1.0)
	if sides == 3 and final_value == 3:
		return Color(0.96, 0.68, 0.28, 1.0)
	if sides == 3 and final_value == 0:
		return Color(0.34, 0.30, 0.24, 1.0)
	return Color(1.0, 0.82, 0.45, 1.0)


func _play_result_motion(result: Dictionary) -> void:
	var player_pose: String = _pose_for_action(int(result["player_action"]))
	var farmer_pose: String = _pose_for_action(int(result["enemy_action"]))
	if int(result["enemy_hp_delta"]) < 0:
		farmer_pose = "hit"
	if int(result["player_hp_delta"]) < 0:
		player_pose = "hit"
	_update_actor_pose(player_pose, farmer_pose)
	_show_hp_delta_popups(result)
	_nudge_actor_panels(player_pose, farmer_pose)


func _pop_node(node: Control) -> void:
	node.pivot_offset = node.size * 0.5
	node.scale = Vector2(0.82, 0.82)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.18)


func _flash_node(node: CanvasItem, color: Color = Color(1.0, 0.82, 0.45, 1.0)) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", color, 0.08)
	tween.tween_property(node, "modulate", Color.WHITE, 0.18)


func _flash_result_actor_panels(result: Dictionary) -> void:
	var player_delta := int(result.get("player_hp_delta", 0))
	var enemy_delta := int(result.get("enemy_hp_delta", 0))
	if player_delta < 0:
		_flash_actor_panel(player_actor, Color(1.0, 0.34, 0.24, 1.0))
	elif int(result.get("player_action", Dice.Action.ATTACK)) == Dice.Action.DEFEND:
		_flash_actor_panel(player_actor, Color(0.76, 0.90, 1.0, 1.0))
	if enemy_delta < 0:
		_flash_actor_panel(farmer_actor, Color(1.0, 0.34, 0.24, 1.0))
	elif int(result.get("enemy_action", Dice.Action.ATTACK)) == Dice.Action.DEFEND:
		_flash_actor_panel(farmer_actor, Color(0.76, 0.90, 1.0, 1.0))


func _flash_actor_panel(panel: Control, color: Color) -> void:
	if panel == null:
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "modulate", color, 0.08)
	tween.tween_property(panel, "modulate", Color.WHITE, 0.18)


func _show_hp_delta_popups(result: Dictionary) -> void:
	var player_delta := int(result.get("player_hp_delta", 0))
	var enemy_delta := int(result.get("enemy_hp_delta", 0))
	if player_delta != 0:
		_spawn_hp_delta_popup(player_actor, player_delta)
	if enemy_delta != 0:
		_spawn_hp_delta_popup(farmer_actor, enemy_delta)


func _spawn_hp_delta_popup(anchor: Control, delta: int) -> void:
	if anchor == null:
		return
	var popup := Label.new()
	popup.text = _format_delta(delta)
	popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	popup.add_theme_font_size_override("font_size", 34)
	popup.add_theme_color_override("font_color", _hp_delta_color(delta))
	popup.add_theme_color_override("font_shadow_color", Color(0.02, 0.012, 0.008, 1.0))
	popup.add_theme_constant_override("shadow_offset_x", 2)
	popup.add_theme_constant_override("shadow_offset_y", 2)
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.custom_minimum_size = Vector2(110.0, 48.0)
	add_child(popup)
	var start := anchor.global_position + Vector2(anchor.size.x * 0.5 - 55.0, -24.0)
	popup.global_position = start
	popup.scale = Vector2(0.86, 0.86)
	popup.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "global_position", start + Vector2(0.0, -54.0), 0.62)
	tween.tween_property(popup, "scale", Vector2(1.08, 1.08), 0.18)
	tween.tween_property(popup, "modulate:a", 1.0, 0.10)
	tween.chain().tween_property(popup, "modulate:a", 0.0, 0.20)
	tween.tween_callback(popup.queue_free)


func _hp_delta_color(delta: int) -> Color:
	if delta < 0:
		return Color(0.98, 0.36, 0.24, 1.0)
	return Color(0.62, 0.92, 0.68, 1.0)


func _play_result_banner(result: Dictionary) -> void:
	var hold_time := 0.52 if not _result_banner_hp_line(result).is_empty() else 0.34
	await _show_center_banner(_result_banner_text(result), _result_banner_color(result), hold_time)


func _show_room_entry_banner() -> void:
	var text := "%s\n%s" % [_encounter_progress_text(), _current_room_name()]
	_show_center_banner(text, Color(0.10, 0.085, 0.065, 0.94), 0.72)


func _show_log_fragment_banner() -> void:
	var title := String(current_log_fragment.get("title", "未命名碎片"))
	_show_center_banner("新碎片归档\n%s" % title, Color(0.13, 0.10, 0.055, 0.94), 0.82)


func _show_center_banner(text: String, bg_color: Color, hold_time: float) -> void:
	if result_banner == null or result_banner_label == null:
		return
	var banner_style := StyleBoxFlat.new()
	banner_style.bg_color = bg_color
	banner_style.border_color = Color(0.96, 0.82, 0.48, 1.0)
	banner_style.set_border_width_all(2)
	banner_style.set_corner_radius_all(4)
	result_banner.add_theme_stylebox_override("panel", banner_style)
	result_banner_label.text = text
	result_banner.visible = true
	result_banner.modulate = Color(1.0, 1.0, 1.0, 0.0)
	result_banner.scale = Vector2(0.92, 0.92)
	result_banner.pivot_offset = result_banner.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(result_banner, "scale", Vector2.ONE, 0.16)
	tween.tween_property(result_banner, "modulate:a", 1.0, 0.12)
	await get_tree().create_timer(hold_time).timeout
	var fade := create_tween()
	fade.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	fade.tween_property(result_banner, "modulate:a", 0.0, 0.18)
	await fade.finished
	result_banner.visible = false
	result_banner.modulate = Color.WHITE


func _result_banner_text(result: Dictionary) -> String:
	var event_text := String(result.get("event", "结算"))
	var title := event_text
	if event_text.contains("大成功"):
		title = "大成功"
	elif event_text.contains("完美防御"):
		title = "完美防御"
	elif event_text.contains("反弹"):
		title = "防御反弹"
	elif int(result.get("enemy_hp_delta", 0)) < 0 and int(result.get("player_hp_delta", 0)) < 0:
		title = "互相命中"
	elif int(result.get("enemy_hp_delta", 0)) < 0:
		title = "命中"
	elif int(result.get("player_hp_delta", 0)) < 0:
		title = "受击"
	var hp_line := _result_banner_hp_line(result)
	if hp_line.is_empty():
		return title
	return "%s\n%s" % [title, hp_line]


func _result_banner_hp_line(result: Dictionary) -> String:
	var player_delta := int(result.get("player_hp_delta", 0))
	var enemy_delta := int(result.get("enemy_hp_delta", 0))
	var parts: Array[String] = []
	if player_delta != 0:
		parts.append("你 %s" % _format_delta(player_delta))
	if enemy_delta != 0:
		parts.append("%s %s" % [_current_encounter_name(), _format_delta(enemy_delta)])
	return " / ".join(parts)


func _result_banner_color(result: Dictionary) -> Color:
	var event_text := String(result.get("event", ""))
	if event_text.contains("大成功"):
		return Color(0.42, 0.10, 0.055, 0.94)
	if event_text.contains("完美防御"):
		return Color(0.12, 0.22, 0.25, 0.94)
	if event_text.contains("反弹"):
		return Color(0.27, 0.18, 0.075, 0.94)
	if int(result.get("player_hp_delta", 0)) < 0:
		return Color(0.28, 0.075, 0.055, 0.94)
	if int(result.get("enemy_hp_delta", 0)) < 0:
		return Color(0.22, 0.15, 0.065, 0.94)
	return Color(0.085, 0.075, 0.06, 0.94)


func _nudge_actor_panels(player_pose: String, farmer_pose: String) -> void:
	if player_pose == "attack":
		_nudge_panel(player_actor, Vector2(26.0, 0.0))
	elif player_pose == "hit":
		_nudge_panel(player_actor, Vector2(-18.0, 0.0))
	if farmer_pose == "attack":
		_nudge_panel(farmer_actor, Vector2(-26.0, 0.0))
	elif farmer_pose == "hit":
		_nudge_panel(farmer_actor, Vector2(18.0, 0.0))


func _nudge_panel(panel: Control, offset: Vector2) -> void:
	var start_position := panel.position
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position", start_position + offset, 0.12)
	tween.tween_property(panel, "position", start_position, 0.18)


func _apply_result(result: Dictionary) -> void:
	player_hp = clampi(player_hp + int(result["player_hp_delta"]), 0, player_max_hp)
	enemy_hp = clampi(enemy_hp + int(result["enemy_hp_delta"]), 0, enemy_max_hp)


func _show_result(result: Dictionary) -> void:
	var player_action_name: String = _action_name(result["player_action"])
	var enemy_action_name: String = _action_name(result["enemy_action"])
	var lines: Array[String] = []
	lines.append("[b]%s[/b] 你：%s / %s：%s" % [_turn_phase_text(), player_action_name, _current_encounter_name(), enemy_action_name])
	lines.append(_combat_feedback_line(result))
	lines.append("[b]%s[/b]：%s" % [result["event"], result["summary"]])
	_append_roll(lines, "你的攻击骰", result["player_hit_roll"])
	_append_roll(lines, "你的防御骰", result["player_defense_roll"])
	_append_roll(lines, "你的蓄防骰", result["player_defense_roll_2"])
	_append_roll(lines, "你的效果骰/伤害", result["player_effect_roll"])
	_append_roll(lines, "你的奖励骰", result["player_bonus_roll"])
	_append_roll(lines, "%s攻击骰" % _current_encounter_name(), result["enemy_hit_roll"])
	_append_roll(lines, "%s防御骰" % _current_encounter_name(), result["enemy_defense_roll"])
	_append_roll(lines, "%s效果骰/伤害" % _current_encounter_name(), result["enemy_effect_roll"])
	lines.append("HP 变化：你 %s，%s %s" % [_format_delta(result["player_hp_delta"]), _current_encounter_name(), _format_delta(result["enemy_hp_delta"])])
	dice_label.text = "\n".join(lines)

	var barks: Dictionary = current_encounter.get("combat_barks", {})
	var farmer_bark: String = String(barks.get("defend" if result["enemy_action"] == Dice.Action.DEFEND else "attack", "……"))
	dialogue_label.text = "[b]%s[/b]\n%s" % [_current_encounter_name(), farmer_bark]

	var player_pose: String = _pose_for_action(int(result["player_action"]))
	var farmer_pose: String = _pose_for_action(int(result["enemy_action"]))
	if int(result["enemy_hp_delta"]) < 0:
		farmer_pose = "hit"
	if int(result["player_hp_delta"]) < 0:
		player_pose = "hit"
	_update_actor_pose(player_pose, farmer_pose)


func _pose_for_action(action: int) -> String:
	match action:
		Dice.Action.ATTACK, Dice.Action.HEAVY, Dice.Action.ULTIMATE:
			return "attack"
		Dice.Action.DEFEND:
			return "defend"
		_:
			return "idle"


func _combat_feedback_line(result: Dictionary) -> String:
	var event_text := String(result.get("event", ""))
	var player_delta := int(result.get("player_hp_delta", 0))
	var enemy_delta := int(result.get("enemy_hp_delta", 0))
	if event_text.contains("大失败"):
		return "[color=#8f7a52][b]失手[/b] 行动落空，田野短暂噎住。[/color]"
	if event_text.contains("完美防御"):
		return "[color=#9bd7de][b]完美防御[/b] 攻击被封住，并立刻反弹。[/color]"
	if event_text.contains("反弹"):
		return "[color=#e8c16a][b]防御反弹[/b] 防线反咬攻击者。[/color]"
	if event_text.contains("大成功"):
		return "[color=#ff8a5f][b]大成功[/b] 骰子咬穿了防线。[/color]"
	if enemy_delta < 0 and player_delta < 0:
		return "[color=#d9b06a][b]互相命中[/b] 双方都付出了血的代价。[/color]"
	if enemy_delta < 0:
		return "[color=#d9b06a][b]命中[/b] 样本被撕开一道可归档的裂口。[/color]"
	if player_delta < 0:
		return "[color=#ff7d68][b]受击[/b] 圣匣记录了一次失败风险。[/color]"
	return "[color=#c7b277][b]僵持[/b] 本回合没有造成伤害。[/color]"


func _enter_victory_story() -> void:
	state = DuelState.VICTORY_STORY
	_set_action_buttons_enabled(false)
	continue_button.visible = true
	continue_button.text = "归档日志"
	dialogue_label.text = _format_lines(_current_lines("victory_story", victory_story), _current_encounter_name())
	dice_label.text = "[center][b]胜利[/b]\n%s终于停下了。样本开始说完整的话。[/center]" % _current_encounter_name()
	_update_actor_pose("victory", "confess")
	_update_ui()


func _enter_reward_choice() -> void:
	state = DuelState.REWARD_CHOICE
	continue_button.visible = false
	reward_panel.visible = true
	archive_panel.visible = false
	if not archived_log:
		archived_fragments.append(current_log_fragment.duplicate())
		archive_fragment_index = archived_fragments.size() - 1
		_show_log_fragment_banner()
	archived_log = true
	archive_label.text = _archive_panel_text()
	_set_archive_expanded(false)
	dice_label.text = "[center]选择一项从%s身上留下来的东西。[/center]" % _current_encounter_name()
	dialogue_label.text = "[center]日志碎片已进入圣匣索引。A/D 切换奖励，Enter / Space 领取。[/center]"
	_apply_reward_button_texts()
	_update_ui()
	_set_reward_selection(reward_selection_index)


func _apply_reward_button_texts() -> void:
	var buttons: Array[Button] = [reward_sickle_button, reward_hat_button, reward_wheat_button]
	for i: int in range(buttons.size()):
		var reward := _reward_at(i)
		var prefix := "> 选择 " if i == reward_selection_index else "  "
		buttons[i].text = "%s%s\n[%s]\n%s" % [
			prefix,
			String(reward.get("title", "未知遗物")),
			_reward_kind_label(String(reward.get("kind", ""))),
			_reward_effect_short(String(reward.get("kind", "")))
		]


func _choose_reward_by_index(index: int) -> void:
	var reward := _reward_at(index)
	if reward.is_empty():
		return
	_choose_reward(String(reward.get("id", "")))


func _choose_reward(reward_id: String) -> void:
	if state != DuelState.REWARD_CHOICE:
		return

	selected_reward = reward_id
	var reward: Dictionary = {}
	for item: Variant in current_rewards:
		if item is Dictionary and String(item.get("id", "")) == reward_id:
			reward = item
			break
	var reward_title := String(reward.get("title", "未知遗物"))
	var reward_kind := String(reward.get("kind", "heal"))
	var reward_description := String(reward.get("description", "圣匣暂时无法解释它。"))
	if reward_kind == "attack_bonus":
		bonuses["sickle"] = int(bonuses.get("sickle", 0)) + 1
		dice_label.text = "[center][b]%s[/b]
%s
Attack bonus D3 x%d[/center]" % [reward_title, reward_description, int(bonuses["sickle"])]
	elif reward_kind == "defense_bonus":
		bonuses["hat"] = int(bonuses.get("hat", 0)) + 1
		dice_label.text = "[center][b]%s[/b]
%s
Defense bonus D3 x%d[/center]" % [reward_title, reward_description, int(bonuses["hat"])]
	else:
		var heal: int = Dice.roll_heal(rng)
		player_max_hp += heal
		player_hp = min(player_hp + heal, player_max_hp)
		dice_label.text = "[center][b]食用：%s[/b]\n%s\n本次增加 %d。[/center]" % [reward_title, reward_description, heal]

	state = DuelState.COMPLETE
	reward_panel.visible = false
	for button: Button in [reward_sickle_button, reward_hat_button, reward_wheat_button]:
		button.button_pressed = false
	continue_button.visible = true
	continue_button.text = "进入下一处" if _has_next_encounter() else "重新开始"
	archive_label.text = _archive_panel_text()
	if _has_next_encounter():
		dialogue_label.text = "[center]%s样本结束。圣匣已保存本轮日志，下一处异常正在打开。[/center]" % _current_encounter_name()
	else:
		dialogue_label.text = "[center]第一章样本完成。神之胃囊已归档低语田野的四段故事。[/center]"
	_update_ui()


func _set_reward_selection(index: int) -> void:
	reward_selection_index = wrapi(index, 0, 3)
	var buttons: Array[Button] = [reward_sickle_button, reward_hat_button, reward_wheat_button]
	for i: int in range(buttons.size()):
		buttons[i].button_pressed = i == reward_selection_index
	_apply_reward_button_texts()
	buttons[reward_selection_index].grab_focus()
	var reward := _reward_at(reward_selection_index)
	var reward_kind := String(reward.get("kind", ""))
	dialogue_label.text = "[center]当前选择：%s\nA/D 切换奖励，Enter / Space 领取。[/center]" % String(reward.get("title", "未知遗物"))
	dice_label.text = "[center][b]%s[/b]\n[%s] %s\n%s[/center]" % [
		String(reward.get("title", "未知遗物")),
		_reward_kind_label(reward_kind),
		_reward_effect_short(reward_kind),
		String(reward.get("description", "等待圣匣识别。"))
	]


func _confirm_reward_selection() -> void:
	_choose_reward_by_index(reward_selection_index)


func _reward_kind_label(kind: String) -> String:
	match kind:
		"attack_bonus":
			return "攻击遗物"
		"defense_bonus":
			return "防御遗物"
		"heal":
			return "食用样本"
		_:
			return "未知遗物"


func _reward_effect_short(kind: String) -> String:
	match kind:
		"attack_bonus":
			return "攻击追加 D3"
		"defense_bonus":
			return "防御追加 D3"
		"heal":
			return "最大 HP +1-3"
		_:
			return "等待归档"


func _archive_panel_text() -> String:
	var collected := archived_fragments.size()
	var story_progress := mini(collected, restore_story_threshold)
	var section_rule := "[color=#8f7a52]------------------------------[/color]"
	var latest: Dictionary = current_log_fragment
	var selected_number := 0
	var selected_total := collected
	if not archived_fragments.is_empty():
		archive_fragment_index = clampi(archive_fragment_index, 0, archived_fragments.size() - 1)
		latest = archived_fragments[archive_fragment_index]
		selected_number = archive_fragment_index + 1
	var lines: Array[String] = [
		"[b]圣匣日志 / %s[/b]" % _chapter_title(),
		"已归档样本：%d" % collected,
		"第一故事拼图：%s (%d / %d)" % [_story_progress_bar(story_progress, restore_story_threshold), story_progress, restore_story_threshold],
		"",
		"[b]当前样本 %d / %d：%s[/b]" % [selected_number, selected_total, String(latest.get("title", "未归档样本"))],
		String(latest.get("text", "")),
		"[i]胃囊反应：%s[/i]" % String(latest.get("reaction", "暂无反应")),
		"",
		section_rule,
		"[b]已收集碎片[/b]"
	]
	if archived_fragments.is_empty():
		lines.append("暂无。圣匣还在等待第一个可用样本。")
	else:
		for i: int in range(archived_fragments.size()):
			var fragment: Dictionary = archived_fragments[i]
			var marker := ">" if i == archive_fragment_index else " "
			lines.append("%s %d. %s" % [marker, i + 1, String(fragment.get("title", "未命名样本"))])
		if _archive_has_input_focus():
			lines.append("[color=#c7b277]A/D 翻阅样本，P 返回。[/color]")
		else:
			lines.append("[color=#c7b277]P 放大日志；奖励界面中 A/D 仍切换奖励。[/color]")
	lines.append("")
	lines.append(section_rule)
	lines.append("[b]失败回收[/b]")
	if failed_recoveries <= 0:
		lines.append("暂无。土地还没有学会你的死法。")
	else:
		lines.append("回收次数：%d" % failed_recoveries)
		lines.append("最近记录：%s" % last_failure_record)
	lines.append("")
	lines.append(section_rule)
	if collected >= restore_story_threshold:
		lines.append("")
		lines.append("[b]复原片段[/b]：田野不是饿了才吃人，是有人教会它把饥饿当成秩序。")
	else:
		lines.append("")
		lines.append("[i]还需要 %d 枚碎片才能复原第一段故事。[/i]" % maxi(restore_story_threshold - collected, 0))
	return "\n".join(lines)


func _step_archive_fragment(direction: int) -> void:
	if archived_fragments.is_empty():
		return
	archive_fragment_index = wrapi(archive_fragment_index + direction, 0, archived_fragments.size())
	archive_label.text = _archive_panel_text()


func _archive_has_input_focus() -> bool:
	return archive_panel.visible


func _story_progress_bar(progress: int, total: int) -> String:
	var safe_total := maxi(total, 1)
	var filled := clampi(progress, 0, safe_total)
	var slots: Array[String] = []
	for i: int in range(safe_total):
		slots.append("■" if i < filled else "□")
	var percent := int(round(float(filled) / float(safe_total) * 100.0))
	return "%s %d%%" % ["".join(slots), percent]


func _failure_record_text() -> String:
	return "第 %d 次回收：%s / %s" % [failed_recoveries, _current_room_name(), _current_encounter_name()]


func _enter_defeat() -> void:
	state = DuelState.DEFEAT
	failed_recoveries += 1
	last_failure_record = _failure_record_text()
	_set_action_buttons_enabled(false)
	reward_panel.visible = false
	archive_panel.visible = false
	continue_button.visible = true
	continue_button.text = "回圣匣重试"
	dialogue_label.text = "[center]%s仍在%s。你被这套流程回收。\n圣匣新增记录：%s[/center]" % [_current_encounter_name(), _current_room_name(), last_failure_record]
	dice_label.text = "[center][b]回收失败样本[/b]\n死因：没有在攻防骰里活下来。\n土地学习次数：%d[/center]" % failed_recoveries
	_show_center_banner("回收失败样本\n%s / %s" % [_current_room_name(), _current_encounter_name()], Color(0.20, 0.055, 0.045, 0.95), 0.95)
	_update_actor_pose("hit", "idle")
	_update_ui()


func _on_continue_pressed() -> void:
	match state:
		DuelState.SANCTUM_INTRO:
			_advance_sanctum_intro()
		DuelState.PRE_DIALOGUE:
			_enter_player_choice()
		DuelState.VICTORY_STORY:
			_enter_reward_choice()
		DuelState.COMPLETE:
			if _has_next_encounter():
				_advance_to_next_encounter()
			else:
				_reset_run()
		DuelState.DEFEAT:
			_reset_run()
		_:
			pass


func _advance_to_next_encounter() -> void:
	_set_current_encounter(current_encounter_index + 1)
	selected_reward = ""
	_enter_field_exploration()


func _reset_run() -> void:
	player_max_hp = PLAYER_MAX_HP_START
	player_hp = PLAYER_MAX_HP_START
	current_encounter_index = 0
	_set_current_encounter(0)
	turn_index = 0
	player_attack_count = 0
	player_guard_charged = false
	selected_reward = ""
	action_selection_index = 0
	reward_selection_index = 0
	archived_log = false
	archived_fragments.clear()
	bonuses = {
		"sickle": 0,
		"hat": 0
	}
	continue_button.text = "开始决斗"
	_enter_sanctum_intro()


func _current_enemy_action() -> int:
	var pattern := _current_enemy_pattern()
	return pattern[turn_index % pattern.size()]


func _update_ui() -> void:
	player_hp_label.text = "无韵回响 HP %d / %d" % [player_hp, player_max_hp]
	farmer_hp_label.text = "%s HP %d / %d" % [_current_encounter_name(), enemy_hp, enemy_max_hp]
	match state:
		DuelState.SANCTUM_INTRO:
			intent_label.text = "无声圣匣 | 收藏家记录样本"
			farmer_hp_label.text = "收藏家：待接入全身像"
		DuelState.FIELD_EXPLORATION:
			intent_label.text = "WASD / 方向键移动 | Space / Enter 对话"
			farmer_hp_label.text = "目标：%s" % _current_field_target()
		DuelState.FIELD_DIALOGUE, DuelState.PRE_DIALOGUE:
			intent_label.text = "对话失败将进入卡牌骰子决斗"
		DuelState.PLAYER_CHOICE, DuelState.RESOLVING:
			intent_label.text = "%s | %s | 大招 %d/3" % [_current_encounter_name(), _turn_phase_text(), mini(player_attack_count, 3)]
		_:
			intent_label.text = "样本归档 | 圣匣记录中"
	var archive_hint := "P 返回" if archive_panel.visible else "P 圣匣日志"
	state_label.text = "%s | %s | %s | %s" % [_encounter_progress_text(), _current_room_name(), _state_name(), archive_hint]
	title_label.text = "神烬使徒：%s卡牌骰子 Demo" % _chapter_title()


func _set_action_buttons_enabled(enabled: bool) -> void:
	var enemy_turn := _is_enemy_turn()
	attack_button.disabled = not enabled or enemy_turn
	heavy_button.disabled = not enabled or enemy_turn
	defend_button.disabled = not enabled
	ultimate_button.disabled = not enabled or enemy_turn or not _ultimate_ready()


func _is_enemy_turn() -> bool:
	return turn_index % 2 == 1


func _ultimate_ready() -> bool:
	return player_attack_count >= 3


func _turn_phase_text() -> String:
	if _is_enemy_turn():
		return "敌方攻击轮：自动投防御骰%s" % (" x2取高" if player_guard_charged else "")
	return "我方行动轮：攻击 / 重击 / 蓄防 / 大招"


func _update_actor_pose(player_pose: String, farmer_pose: String) -> void:
	_set_actor_pose("player", player_pose, player_pose in ["attack", "defend", "hit"])
	_set_actor_pose(_current_enemy_actor_key(), farmer_pose, farmer_pose in ["attack", "defend", "hit"])
	player_actor_label.text = "无韵回响\n[%s]\n\n脏银残片 / 胃纹微亮" % player_pose
	farmer_actor_label.text = "%s\n[%s]\n\n%s / 样本 %d" % [_current_encounter_name(), farmer_pose, _current_room_name(), current_encounter_index + 1]


func _ensure_actor_state(actor_key: String) -> void:
	if not actor_frames.has(actor_key):
		actor_frames[actor_key] = {}
	if not actor_pose.has(actor_key):
		actor_pose[actor_key] = "idle"
	if not actor_frame_index.has(actor_key):
		actor_frame_index[actor_key] = 0
	if not actor_frame_time.has(actor_key):
		actor_frame_time[actor_key] = 0.0
	if not actor_one_shot_time.has(actor_key):
		actor_one_shot_time[actor_key] = 0.0
	if not actor_return_pose.has(actor_key):
		actor_return_pose[actor_key] = "idle"


func _set_actor_pose(actor_key: String, pose: String, one_shot: bool) -> void:
	_ensure_actor_state(actor_key)
	if _get_actor_frames(actor_key, pose).is_empty():
		pose = "idle"
	actor_pose[actor_key] = pose
	actor_frame_index[actor_key] = 0
	actor_frame_time[actor_key] = 0.0
	actor_one_shot_time[actor_key] = _pose_duration(actor_key, pose) if one_shot else 0.0
	actor_return_pose[actor_key] = "idle"
	_apply_actor_frame(actor_key)


func _update_actor_animation(actor_key: String, delta: float) -> void:
	_ensure_actor_state(actor_key)
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
	_ensure_actor_state(actor_key)
	var sprite_key := actor_key
	if actor_key == _current_enemy_actor_key() and actor_sprites.has("farmer"):
		sprite_key = "farmer"
	if not actor_sprites.has(sprite_key):
		return
	var sprite: TextureRect = actor_sprites[sprite_key]
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
		lines.append("%s：%s" % [label, _format_roll_value(label, value)])


func _format_roll_value(label: String, value: int) -> String:
	if not label.contains("骰") or label.contains("效果") or label.contains("奖励"):
		return str(value)
	if value == Dice.HIT_MAX:
		return "%d [color=#ff8a5f]大成功[/color]" % value
	if value == Dice.HIT_MIN:
		return "%d [color=#8f7a52]大失败[/color]" % value
	return str(value)


func _format_delta(value: int) -> String:
	if value > 0:
		return "+%d" % value
	return str(value)


func _action_name(action: int) -> String:
	match action:
		Dice.Action.ATTACK:
			return "攻击"
		Dice.Action.DEFEND:
			return "蓄防"
		Dice.Action.HEAVY:
			return "重击"
		Dice.Action.ULTIMATE:
			return "大招"
		_:
			return "未知"


func _state_name() -> String:
	match state:
		DuelState.SANCTUM_INTRO:
			return "无声圣匣"
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
