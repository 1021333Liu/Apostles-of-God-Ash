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
const INTENT_ICON_PATHS: Dictionary = {
	"attack": CARD_ART_ROOT + "/ui/intent/bubble_attack.png",
	"defend": CARD_ART_ROOT + "/ui/intent/bubble_defend.png"
}
const DICE_ICON_PATHS: Dictionary = {
	"hit": CARD_ART_ROOT + "/ui/dice/ui_die_hit_d20.png",
	"defense": CARD_ART_ROOT + "/ui/dice/ui_die_defense_d20.png",
	"effect": CARD_ART_ROOT + "/ui/dice/ui_die_effect_d3.png"
}
const DICE_ROLL_STAGE_PATH: String = CARD_ART_ROOT + "/ui/dice/dice_roll_stage.png"
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
		"idle": ["field_idle", "idle"],
		"mutter": ["card_mutter", "field_mutter", "mutter"],
		"attack": ["card_attack", "attack"],
		"defend": ["card_defend", "defend"],
		"hit": ["card_hurt", "hit"],
		"confess": ["card_confess", "confess"]
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
var field_layer: Control
var field_player_sprite: TextureRect
var field_farmer_sprite: TextureRect
var field_prompt_label: Label
var field_dialogue_panel: PanelContainer
var field_dialogue_label: RichTextLabel
var dice_roll_stage: PanelContainer
var dice_roll_icon: TextureRect
var dice_roll_label: Label
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
	_connect_signals()
	_build_theme()
	_setup_art_assets()
	_enter_sanctum_intro()


func _process(delta: float) -> void:
	_update_actor_animation("player", delta)
	_update_actor_animation("farmer", delta)
	if state == DuelState.FIELD_EXPLORATION:
		_update_field_exploration(delta)


func _connect_signals() -> void:
	attack_button.pressed.connect(func() -> void: _choose_action(Dice.Action.ATTACK))
	defend_button.pressed.connect(func() -> void: _choose_action(Dice.Action.DEFEND))
	continue_button.pressed.connect(_on_continue_pressed)
	reward_sickle_button.pressed.connect(func() -> void: _choose_reward("sickle"))
	reward_hat_button.pressed.connect(func() -> void: _choose_reward("hat"))
	reward_wheat_button.pressed.connect(func() -> void: _choose_reward("wheat"))


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
		button.add_theme_color_override("font_color", Color(0.93, 0.86, 0.72, 1.0))
		button.add_theme_color_override("font_hover_color", Color(1.0, 0.92, 0.70, 1.0))
		button.add_theme_font_size_override("font_size", 17)
		button.focus_mode = Control.FOCUS_ALL

	for label: Label in [title_label, state_label, player_hp_label, farmer_hp_label, intent_label, player_actor_label, farmer_actor_label]:
		label.add_theme_color_override("font_color", Color(0.92, 0.86, 0.73, 1.0))
		label.add_theme_color_override("font_shadow_color", Color(0.02, 0.015, 0.012, 0.90))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
	title_label.add_theme_font_size_override("font_size", 22)
	state_label.add_theme_font_size_override("font_size", 15)
	intent_label.add_theme_font_size_override("font_size", 15)

	for rich_label: RichTextLabel in [dialogue_label, dice_label, archive_label]:
		rich_label.add_theme_color_override("default_color", Color(0.91, 0.84, 0.70, 1.0))
		rich_label.add_theme_font_size_override("normal_font_size", 17)

	background.color = Color(0.13, 0.115, 0.075, 1.0)


func _ensure_gameplay_input_actions() -> void:
	_ensure_key_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_key_action("move_right", [KEY_D, KEY_RIGHT])
	_ensure_key_action("move_up", [KEY_W, KEY_UP])
	_ensure_key_action("move_down", [KEY_S, KEY_DOWN])


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


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if state == DuelState.SANCTUM_INTRO:
			_advance_sanctum_intro()
			get_viewport().set_input_as_handled()
		elif state == DuelState.FIELD_EXPLORATION and _is_near_farmer():
			_enter_field_dialogue()
			get_viewport().set_input_as_handled()
		elif state == DuelState.FIELD_DIALOGUE:
			_advance_field_dialogue()
			get_viewport().set_input_as_handled()


func _setup_art_assets() -> void:
	_setup_background_art()
	_load_actor_frames("player", PLAYER_ART_ROOT, "actor_player_echo", PLAYER_POSES)
	_load_actor_frames("farmer", FARMER_ART_ROOT, "actor_enemy_farmer", FARMER_POSES)
	_setup_actor_sprite("player", player_actor, player_actor_label)
	_setup_actor_sprite("farmer", farmer_actor, farmer_actor_label)
	_setup_reward_icons()
	_setup_field_layer()
	_setup_combat_presentation_layer()


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
	dice_roll_icon.custom_minimum_size = Vector2(50.0, 50.0)
	dice_roll_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	dice_roll_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
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


func _setup_field_layer() -> void:
	field_layer = Control.new()
	field_layer.name = "FieldExplorationLayer"
	field_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	field_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(field_layer)
	move_child(field_layer, background.get_index() + 2)

	field_farmer_sprite = _make_field_sprite("FieldFarmer", "farmer", "mutter", Vector2(220.0, 220.0))
	field_farmer_sprite.position = FIELD_FARMER_POS - field_farmer_sprite.custom_minimum_size * 0.5
	field_layer.add_child(field_farmer_sprite)

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
	field_dialogue_panel.offset_left = 160.0
	field_dialogue_panel.offset_right = -160.0
	field_dialogue_panel.offset_top = -178.0
	field_dialogue_panel.offset_bottom = -32.0
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
	field_dialogue_label.add_theme_color_override("default_color", Color(0.93, 0.86, 0.72, 1.0))
	dialogue_margin.add_child(field_dialogue_label)
	_update_field_positions()


func _make_field_sprite(sprite_name: String, actor_key: String, pose: String, size: Vector2) -> TextureRect:
	var sprite := TextureRect.new()
	sprite.name = sprite_name
	sprite.custom_minimum_size = size
	sprite.size = size
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


func _enter_sanctum_intro() -> void:
	state = DuelState.SANCTUM_INTRO
	collector_intro_index = 0
	if field_layer != null:
		field_layer.visible = false
	_set_duel_ui_visible(true)
	_set_action_buttons_enabled(false)
	reward_panel.visible = false
	archive_panel.visible = false
	continue_button.visible = true
	continue_button.text = "继续"
	_update_actor_pose("idle", "confess")
	_show_collector_intro_line()
	_update_ui()


func _advance_sanctum_intro() -> void:
	collector_intro_index += 1
	if collector_intro_index >= collector_intro_lines.size():
		_enter_field_exploration()
		return
	_show_collector_intro_line()


func _show_collector_intro_line() -> void:
	var line := collector_intro_lines[collector_intro_index]
	dialogue_label.text = "[b]收藏家[/b]\n%s" % line
	dice_label.text = "[center][b]无声圣匣[/b]\n一具银白空壳在档案匣中醒来。收藏家的正式立绘尚未接入。[/center]"
	intent_label.text = "开场：收藏家记录样本 | 按 空格 / 回车 或继续"
	player_actor_label.text = "无韵回响\n[刚醒来]\n\n脏银残片 / 胃纹未稳定"
	farmer_actor_label.text = "收藏家\n[占位剪影]\n\n银灰长袍 / 记录器具 / 像医生不像恶魔"


func _enter_field_exploration() -> void:
	state = DuelState.FIELD_EXPLORATION
	field_player_position = FIELD_PLAYER_START
	field_dialogue_index = 0
	get_viewport().gui_release_focus()
	_set_duel_ui_visible(false)
	if field_layer != null:
		field_layer.visible = true
	if field_dialogue_panel != null:
		field_dialogue_panel.visible = false
	_set_action_buttons_enabled(false)
	reward_panel.visible = false
	archive_panel.visible = false
	continue_button.visible = false
	_update_field_positions()
	_update_field_prompt()


func _update_field_exploration(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		field_player_position += input_dir * FIELD_PLAYER_SPEED * delta
		field_player_position.x = clampf(field_player_position.x, 150.0, 1130.0)
		field_player_position.y = clampf(field_player_position.y, 250.0, 620.0)
	_update_field_positions()
	_update_field_prompt()


func _update_field_positions() -> void:
	if field_player_sprite == null:
		return
	field_player_sprite.position = field_player_position - field_player_sprite.custom_minimum_size * 0.5


func _update_field_prompt() -> void:
	if field_prompt_label == null:
		return
	if _is_near_farmer():
		field_prompt_label.text = "按 空格 / 回车 与农夫对话"
	else:
		field_prompt_label.text = "WASD / 方向键移动，靠近田路中央的农夫"


func _is_near_farmer() -> bool:
	return field_player_position.distance_to(FIELD_FARMER_POS) <= FIELD_INTERACT_DISTANCE


func _enter_field_dialogue() -> void:
	state = DuelState.FIELD_DIALOGUE
	field_dialogue_index = 0
	if field_dialogue_panel != null:
		field_dialogue_panel.visible = true
	if field_prompt_label != null:
		field_prompt_label.text = "空格 / 回车 继续"
	_show_field_dialogue_line()


func _advance_field_dialogue() -> void:
	field_dialogue_index += 1
	if field_dialogue_index >= field_dialogue_lines.size():
		_enter_pre_dialogue()
		return
	_show_field_dialogue_line()


func _show_field_dialogue_line() -> void:
	if field_dialogue_label == null:
		return
	field_dialogue_label.text = "[b]饥民农夫[/b]\n%s" % field_dialogue_lines[field_dialogue_index]


func _set_duel_ui_visible(visible: bool) -> void:
	for node: Control in [title_label, state_label, player_hp_label, farmer_hp_label, intent_label, player_actor, farmer_actor, dialogue_panel, dice_panel, attack_button, defend_button, continue_button, reward_panel, archive_panel]:
		node.visible = visible


func _enter_pre_dialogue() -> void:
	state = DuelState.PRE_DIALOGUE
	if field_layer != null:
		field_layer.visible = false
	_set_duel_ui_visible(true)
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
	attack_button.text = "攻击\nD20 命中 + D3"
	defend_button.text = "防御\nD20 抵挡"
	attack_button.grab_focus()


func _choose_action(player_action: int) -> void:
	if state != DuelState.PLAYER_CHOICE:
		return

	state = DuelState.RESOLVING
	_set_action_buttons_enabled(false)
	var enemy_action: int = _current_enemy_action()
	var result: Dictionary = Dice.resolve_exchange(player_action, enemy_action, rng, bonuses)
	await _play_combat_presentation(result)
	_finish_resolved_action(result)


func _finish_resolved_action(result: Dictionary) -> void:
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


func _play_combat_presentation(result: Dictionary) -> void:
	var player_action: int = result["player_action"]
	var enemy_action: int = result["enemy_action"]
	dialogue_label.text = "[center]双方亮出行动。[/center]"
	dice_label.text = "[center]骰子正在落下。[/center]"
	_show_action_bubbles(player_action, enemy_action)
	_update_actor_pose("idle", "mutter")
	await get_tree().create_timer(0.55).timeout
	await _roll_relevant_dice(result)
	_hide_action_bubbles()
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


func _configure_action_bubble(bubble: PanelContainer, action: int) -> void:
	var action_key := "attack" if action == Dice.Action.ATTACK else "defend"
	var bg := bubble.find_child("BubbleArt", true, false) as TextureRect
	if bg != null:
		bg.texture = _load_texture(INTENT_ICON_PATHS[action_key])
	var icon := bubble.find_child("Icon", true, false) as TextureRect
	if icon != null:
		icon.texture = _load_texture(DICE_ICON_PATHS["hit" if action == Dice.Action.ATTACK else "defense"])
	var label := bubble.find_child("Label", true, false) as Label
	if label != null:
		label.text = "ATTACK" if action == Dice.Action.ATTACK else "GUARD"


func _hide_action_bubbles() -> void:
	if player_bubble != null:
		player_bubble.visible = false
	if farmer_bubble != null:
		farmer_bubble.visible = false


func _roll_relevant_dice(result: Dictionary) -> void:
	var roll_steps: Array[Dictionary] = []
	var player_action: int = result["player_action"]
	var enemy_action: int = result["enemy_action"]
	if player_action == Dice.Action.ATTACK:
		_add_roll_step(roll_steps, "我方命中 D20", result["player_hit_roll"], "hit", 20)
	else:
		_add_roll_step(roll_steps, "我方防御 D20", result["player_defense_roll"], "defense", 20)
	if enemy_action == Dice.Action.ATTACK:
		_add_roll_step(roll_steps, "农夫命中 D20", result["enemy_hit_roll"], "hit", 20)
	else:
		_add_roll_step(roll_steps, "农夫防御 D20", result["enemy_defense_roll"], "defense", 20)
	if int(result["player_effect_roll"]) >= 0:
		_add_roll_step(roll_steps, "我方效果 D3", result["player_effect_roll"], "effect", 3)
	elif int(result["enemy_effect_roll"]) >= 0:
		_add_roll_step(roll_steps, "农夫效果 D3", result["enemy_effect_roll"], "effect", 3)
	if int(result["player_bonus_roll"]) >= 0:
		_add_roll_step(roll_steps, "奖励 D3", result["player_bonus_roll"], "effect", 3)
	for step: Dictionary in roll_steps:
		await _roll_single_die(step["label"], int(step["value"]), step["kind"], int(step["sides"]))


func _add_roll_step(roll_steps: Array[Dictionary], label: String, value: int, kind: String, sides: int) -> void:
	if value >= 0:
		roll_steps.append({"label": label, "value": value, "kind": kind, "sides": sides})


func _roll_single_die(label: String, final_value: int, kind: String, sides: int) -> void:
	if dice_roll_stage == null or dice_roll_label == null:
		return
	if dice_roll_icon != null:
		dice_roll_icon.texture = _load_texture(DICE_ICON_PATHS.get(kind, DICE_ICON_PATHS["hit"]))
	dice_roll_stage.visible = true
	dice_roll_stage.scale = Vector2(0.88, 0.88)
	_pop_node(dice_roll_stage)
	for i: int in range(8):
		var face := randi_range(0, sides)
		dice_roll_label.text = "%s\n%d" % [label, face]
		await get_tree().create_timer(0.055 + float(i) * 0.012).timeout
	dice_roll_label.text = "%s\n%d" % [label, final_value]
	_flash_node(dice_roll_stage)
	await get_tree().create_timer(0.42).timeout
	dice_roll_stage.visible = false


func _play_result_motion(result: Dictionary) -> void:
	var player_pose: String = "attack" if result["player_action"] == Dice.Action.ATTACK else "defend"
	var farmer_pose: String = "attack" if result["enemy_action"] == Dice.Action.ATTACK else "defend"
	if int(result["enemy_hp_delta"]) < 0:
		farmer_pose = "hit"
	if int(result["player_hp_delta"]) < 0:
		player_pose = "hit"
	_update_actor_pose(player_pose, farmer_pose)
	_nudge_actor_panels(player_pose, farmer_pose)


func _pop_node(node: Control) -> void:
	node.pivot_offset = node.size * 0.5
	node.scale = Vector2(0.82, 0.82)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2.ONE, 0.18)


func _flash_node(node: CanvasItem) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "modulate", Color(1.0, 0.82, 0.45, 1.0), 0.08)
	tween.tween_property(node, "modulate", Color.WHITE, 0.18)


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
		DuelState.SANCTUM_INTRO:
			_advance_sanctum_intro()
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
	_enter_sanctum_intro()


func _current_enemy_action() -> int:
	return FARMER_PATTERN[turn_index % FARMER_PATTERN.size()]


func _update_ui() -> void:
	player_hp_label.text = "无韵回响 HP %d / %d" % [player_hp, player_max_hp]
	farmer_hp_label.text = "饥民农夫 HP %d / %d" % [farmer_hp, FARMER_MAX_HP]
	match state:
		DuelState.SANCTUM_INTRO:
			intent_label.text = "无声圣匣 | 收藏家记录样本"
			farmer_hp_label.text = "收藏家：待接入全身像"
		DuelState.FIELD_EXPLORATION:
			intent_label.text = "WASD / 方向键移动 | Space / Enter 对话"
			farmer_hp_label.text = "目标：田路中央的农夫"
		DuelState.FIELD_DIALOGUE, DuelState.PRE_DIALOGUE:
			intent_label.text = "对话失败将进入卡牌骰子决斗"
		DuelState.PLAYER_CHOICE, DuelState.RESOLVING:
			intent_label.text = "农夫意图：%s | 序列 防御 - 攻击 - 防御 - 攻击" % _action_name(_current_enemy_action())
		_:
			intent_label.text = "样本归档 | 圣匣记录中"
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
