extends Node2D

enum RunMode { SANCTUM, FIELD, COMPLETE }

const GOD_STOMACH_RELIC_SCRIPT := preload("res://scripts/systems/god_stomach_relic.gd")
const COMBAT_DATA_FACTORY_SCRIPT := preload("res://scripts/systems/combat_data_factory.gd")
const PlayerRuntimeScript := preload("res://scripts/systems/player_runtime.gd")
const EnemyRuntimeScript := preload("res://scripts/systems/enemy_runtime.gd")
const AttackRuntimeScript := preload("res://scripts/systems/attack_runtime.gd")
const ArtAssetRegistryScript := preload("res://scripts/systems/art_asset_registry.gd")
const LogFragmentDatabaseScript := preload("res://scripts/systems/log_fragment_database.gd")
const LogArchiveRuntimeScript := preload("res://scripts/systems/log_archive_runtime.gd")

const VIEWPORT_SIZE: Vector2 = Vector2(1280.0, 720.0)
const ARENA: Rect2 = Rect2(Vector2(120.0, 112.0), Vector2(1040.0, 468.0))
const PLAYER_MAX_HP: int = 100
const PLAYER_SPEED: float = 270.0
const PLAYER_RADIUS: float = 17.0
const BASE_DAMAGE: int = 18
const UI_SAFE_MARGIN: float = 24.0
const INTERACT_HINT: String = "E 进入 / 继续"
const HP_ICON_PATH: String = "res://assets/sprites/ui/ui_hp_heart.svg"
const STOMACH_OPEN_ICON_PATH: String = "res://assets/sprites/ui/ui_stomach_open.svg"
const STOMACH_CLOSED_ICON_PATH: String = "res://assets/sprites/ui/ui_stomach_closed.svg"
const STOMACH_OVERFLOW_ICON_PATH: String = "res://assets/sprites/ui/ui_stomach_overflow.svg"
const MEMORY_SHARD_ICON_PATH: String = "res://assets/sprites/ui/ui_memory_shard.svg"

var mode: RunMode = RunMode.SANCTUM
var player_runtime: PlayerRuntimeScript = PlayerRuntimeScript.new()
var attack_buffered: bool = false
var interact_buffered: bool = false
var death_count: int = 0
var last_death_note: String = ""
var god_stomach := GOD_STOMACH_RELIC_SCRIPT.new()
var enemy_runtime: EnemyRuntimeScript = EnemyRuntimeScript.new()
var attack_runtime: AttackRuntimeScript = AttackRuntimeScript.new()
var art_assets: ArtAssetRegistryScript = ArtAssetRegistryScript.new()
var log_database: RefCounted = LogFragmentDatabaseScript.new()
var log_archive: RefCounted = LogArchiveRuntimeScript.new()

var room_index: int = -1
var room_clock: float = 0.0
var room_cleared: bool = false
var boss_phase: int = 1
var boss_expose_timer: float = 2.5
var boss_weak_exposed: bool = false
var sample_record_text: String = ""
var sample_record_timer: float = 0.0
var dossier_text: String = ""
var dossier_timer: float = 0.0
var boss_rite_timer: float = 0.0
var player_hit_anim_timer: float = 0.0
var hit_stop_timer: float = 0.0
var screen_shake_timer: float = 0.0
var screen_shake_strength: float = 0.0
var damage_flash_timer: float = 0.0
var log_fragment_pulse_timer: float = 0.0
var logbook_open: bool = false
var logbook_index: int = 0

var rooms: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var hazards: Array[Dictionary] = []
var slashes: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var hit_bursts: Array[Dictionary] = []

var room_label: Label
var hp_label: Label
var hp_bar: ProgressBar
var hp_icon: TextureRect
var hp_icon_texture: Texture2D
var relic_label: Label
var organ_label: Label
var stomach_bar: ProgressBar
var stomach_icon: TextureRect
var stomach_open_texture: Texture2D
var stomach_closed_texture: Texture2D
var stomach_overflow_texture: Texture2D
var memory_shard_icon: TextureRect
var memory_shard_texture: Texture2D
var objective_label: Label
var dossier_label: Label
var sample_label: Label
var archive_label: Label
var boss_rite_label: Label
var dialogue_label: Label
var prompt_label: Label
var logbook_root: Control
var logbook_list_labels: Array[Label] = []
var logbook_title_label: Label
var logbook_meta_label: Label
var logbook_text_label: Label
var logbook_organ_label: Label
var logbook_progress_label: Label
var logbook_story_label: Label
var logbook_empty_label: Label
var logbook_item_bars: Array[ColorRect] = []
var logbook_art_backdrop: TextureRect
var logbook_art_preview: TextureRect


func _ready() -> void:
	_setup_input()
	_build_rooms()
	art_assets.load_all()
	log_database.call("load_from_disk")
	log_archive.call("configure", log_database)
	_load_ui_textures()
	_build_ui()
	player_runtime.configure(Vector2(640.0, 420.0), Vector2.RIGHT, PLAYER_MAX_HP)
	_return_to_sanctum("收藏家：你醒了。很好，这具身体还没有拒绝你。")
	set_process(true)
	set_physics_process(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_logbook"):
		_toggle_logbook()
		get_viewport().set_input_as_handled()
		return
	if logbook_open:
		if event.is_action_pressed("logbook_prev"):
			_shift_logbook(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("logbook_next"):
			_shift_logbook(1)
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("attack"):
		attack_buffered = true
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("interact"):
		interact_buffered = true
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	if hit_stop_timer > 0.0 and mode == RunMode.FIELD:
		attack_buffered = false
		interact_buffered = false
		_update_ui()
		queue_redraw()
		return
	if logbook_open:
		attack_buffered = false
		interact_buffered = false
		_update_logbook_ui()
		_update_ui()
		queue_redraw()
		return

	match mode:
		RunMode.SANCTUM:
			_update_player_movement(delta, Rect2(Vector2(250.0, 170.0), Vector2(780.0, 360.0)))
			if interact_buffered:
				_start_run()
		RunMode.FIELD:
			room_clock += delta
			_update_player_movement(delta, ARENA)
			_try_player_attack()
			_update_hazards(delta)
			_update_enemies(delta)
			_update_slashes(delta)
			_update_hit_bursts(delta)
			_update_effects(delta)
			_check_room_progress()
		RunMode.COMPLETE:
			_update_player_movement(delta, Rect2(Vector2(250.0, 170.0), Vector2(780.0, 360.0)))
			if interact_buffered:
				_return_to_sanctum("收藏家：吞食胃已经归档。它不干净，但很适合活下去。")

	attack_buffered = false
	interact_buffered = false
	_update_ui()
	queue_redraw()


func _draw() -> void:
	var shake_offset := _screen_shake_offset()
	draw_set_transform(shake_offset, 0.0, Vector2.ONE)
	match mode:
		RunMode.SANCTUM:
			_draw_sanctum()
		RunMode.FIELD:
			_draw_field_room()
		RunMode.COMPLETE:
			_draw_complete()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if damage_flash_timer > 0.0:
		var flash_alpha := 0.22 * clampf(damage_flash_timer / 0.22, 0.0, 1.0)
		draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.86, 0.05, 0.04, flash_alpha))


func _setup_input() -> void:
	_ensure_key_action("move_left", KEY_A, KEY_LEFT)
	_ensure_key_action("move_right", KEY_D, KEY_RIGHT)
	_ensure_key_action("move_up", KEY_W, KEY_UP)
	_ensure_key_action("move_down", KEY_S, KEY_DOWN)
	_ensure_joy_axis_action("move_left", JOY_AXIS_LEFT_X, -1.0)
	_ensure_joy_axis_action("move_right", JOY_AXIS_LEFT_X, 1.0)
	_ensure_joy_axis_action("move_up", JOY_AXIS_LEFT_Y, -1.0)
	_ensure_joy_axis_action("move_down", JOY_AXIS_LEFT_Y, 1.0)
	_ensure_key_action("attack", KEY_J, KEY_SPACE)
	_ensure_key_action("interact", KEY_E, KEY_ENTER)
	_ensure_key_action("toggle_logbook", KEY_P, KEY_TAB)
	_ensure_key_action("logbook_prev", KEY_A, KEY_LEFT)
	_ensure_key_action("logbook_next", KEY_D, KEY_RIGHT)


func _ensure_key_action(action_name: String, primary: Key, secondary: Key = KEY_NONE) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	if not InputMap.action_get_events(action_name).is_empty():
		return
	var primary_event := InputEventKey.new()
	primary_event.physical_keycode = primary
	InputMap.action_add_event(action_name, primary_event)
	if secondary != KEY_NONE:
		var secondary_event := InputEventKey.new()
		secondary_event.physical_keycode = secondary
		InputMap.action_add_event(action_name, secondary_event)


func _ensure_joy_axis_action(action_name: String, axis: JoyAxis, axis_value: float) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventJoypadMotion and event.axis == axis and is_equal_approx(event.axis_value, axis_value):
			return
	var joy_event := InputEventJoypadMotion.new()
	joy_event.axis = axis
	joy_event.axis_value = axis_value
	InputMap.action_add_event(action_name, joy_event)


func _build_rooms() -> void:
	rooms = [
		{
			"id": "field_gate",
			"title": "低语田野入口",
			"tagline": "路边的牌子写着丰收，背面刻着名单。",
			"dossier": "任务档案 01 | 低语田野入口\n异常：空腹者会追逐活体热源。\n建议：用三段斩击采样，观察胃囊吞噬反应。",
			"palette": Color(0.22, 0.18, 0.12),
			"enemies": [
				_enemy_data("empty", Vector2(470.0, 305.0)),
				_enemy_data("empty", Vector2(815.0, 390.0))
			],
			"hazards": []
		},
		{
			"id": "blood_wheat",
			"title": "血肉麦田",
			"tagline": "麦穗垂下来，像在等人低头。",
			"dossier": "任务档案 02 | 血肉麦田\n异常：农夫会把饥饿种到你前方。\n建议：看见淡红预警先离开，别把脚交给土地。",
			"palette": Color(0.26, 0.12, 0.10),
			"enemies": [
				_enemy_data("empty", Vector2(390.0, 245.0)),
				_enemy_data("empty", Vector2(885.0, 440.0)),
				_enemy_data("farmer", Vector2(790.0, 250.0))
			],
			"hazards": [
				_hazard_data(Vector2(610.0, 335.0), 46.0, 999.0, 9, Color(0.48, 0.08, 0.07, 0.55)),
				_hazard_data(Vector2(720.0, 430.0), 34.0, 999.0, 8, Color(0.43, 0.05, 0.07, 0.48))
			]
		},
		{
			"id": "gut_canal",
			"title": "肠道灌溉渠",
			"tagline": "渠水很热，流过时会带走祷告。",
			"dossier": "任务档案 03 | 肠道灌溉渠\n异常：固定麦脉会拖慢容器移动。\n建议：贴边绕行，优先处理远处农夫。",
			"palette": Color(0.19, 0.10, 0.12),
			"enemies": [
				_enemy_data("farmer", Vector2(420.0, 270.0)),
				_enemy_data("farmer", Vector2(865.0, 420.0)),
				_enemy_data("empty", Vector2(650.0, 500.0))
			],
			"hazards": [
				_hazard_data(Vector2(470.0, 330.0), 34.0, 999.0, 6, Color(0.52, 0.11, 0.09, 0.42), 0.0),
				_hazard_data(Vector2(640.0, 380.0), 34.0, 999.0, 6, Color(0.52, 0.11, 0.09, 0.42), 0.0),
				_hazard_data(Vector2(810.0, 330.0), 34.0, 999.0, 6, Color(0.52, 0.11, 0.09, 0.42), 0.0)
			]
		},
		{
			"id": "hungry_barn",
			"title": "饥饿谷仓",
			"tagline": "仓门半开着，里面没有粮声。",
			"dossier": "任务档案 04 | 饥饿谷仓\n异常：稻草人会展开麦浪封路。\n建议：等麦浪落空后近身，不要在场地中央贪刀。",
			"palette": Color(0.24, 0.13, 0.08),
			"enemies": [
				_enemy_data("scarecrow", Vector2(645.0, 320.0)),
				_enemy_data("empty", Vector2(430.0, 415.0)),
				_enemy_data("empty", Vector2(850.0, 245.0))
			],
			"hazards": [
				_hazard_data(Vector2(640.0, 430.0), 40.0, 999.0, 8, Color(0.50, 0.13, 0.05, 0.46), 0.0)
			]
		},
		{
			"id": "barn_king",
			"title": "谷仓王胃室",
			"tagline": "这里太满了，所以永远空着。",
			"dossier": "任务档案 05 | 谷仓王胃室\n异常：王的胃囊会周期性暴露。\n建议：红核外翻时进攻，样本伤害会被放大。",
			"palette": Color(0.15, 0.07, 0.07),
			"enemies": [
				_enemy_data("barn_king", Vector2(650.0, 300.0))
			],
			"hazards": []
		}
	]


func _enemy_data(kind: String, pos: Vector2) -> Dictionary:
	return COMBAT_DATA_FACTORY_SCRIPT.enemy(kind, pos)


func _hazard_data(pos: Vector2, radius: float, lifetime: float, damage: int, color: Color, arm_time: float = 0.55) -> Dictionary:
	return COMBAT_DATA_FACTORY_SCRIPT.hazard(pos, radius, lifetime, damage, color, arm_time)


func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)

	_make_panel(root, Vector2(22.0, 18.0), Vector2(420.0, 138.0))
	_make_panel(root, Vector2(858.0, 18.0), Vector2(400.0, 116.0))
	_make_panel(root, Vector2(170.0, 624.0), Vector2(940.0, 56.0))
	_make_panel_marks(root, Vector2(22.0, 18.0), Vector2(420.0, 138.0), Color(0.68, 0.13, 0.12))
	_make_panel_marks(root, Vector2(858.0, 18.0), Vector2(400.0, 116.0), Color(0.66, 0.58, 0.42))
	_make_panel_marks(root, Vector2(170.0, 624.0), Vector2(940.0, 56.0), Color(0.68, 0.13, 0.12))
	_make_accent(root, Vector2(34.0, 30.0), Vector2(4.0, 108.0), Color(0.68, 0.13, 0.12))
	_make_accent(root, Vector2(870.0, 30.0), Vector2(4.0, 86.0), Color(0.66, 0.58, 0.42))
	_make_accent(root, Vector2(158.0, 63.0), Vector2(184.0, 14.0), Color(0.01, 0.008, 0.01, 0.74))
	_make_accent(root, Vector2(158.0, 101.0), Vector2(184.0, 10.0), Color(0.01, 0.008, 0.01, 0.74))

	room_label = _make_label(root, "RoomLabel", Vector2(48.0, 26.0), Vector2(360.0, 28.0), 21, Color(0.93, 0.86, 0.76))
	hp_icon = _make_icon(root, hp_icon_texture, Vector2(48.0, 60.0), Vector2(22.0, 22.0))
	hp_label = _make_label(root, "HPLabel", Vector2(78.0, 61.0), Vector2(76.0, 22.0), 16, Color(0.90, 0.72, 0.66))
	hp_bar = _make_hp_bar(root, Vector2(158.0, 61.0), Vector2(178.0, 15.0))
	stomach_icon = _make_icon(root, stomach_open_texture, Vector2(49.0, 94.0), Vector2(19.0, 19.0))
	organ_label = _make_label(root, "OrganLabel", Vector2(78.0, 88.0), Vector2(340.0, 42.0), 14, Color(0.86, 0.70, 0.70))
	organ_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stomach_bar = _make_stomach_bar(root, Vector2(158.0, 101.0), Vector2(178.0, 10.0))
	memory_shard_icon = _make_icon(root, memory_shard_texture, Vector2(49.0, 128.0), Vector2(18.0, 18.0))
	relic_label = _make_label(root, "RelicLabel", Vector2(78.0, 125.0), Vector2(338.0, 22.0), 13, Color(0.66, 0.78, 0.78))
	objective_label = _make_label(root, "ObjectiveLabel", Vector2(884.0, 32.0), Vector2(330.0, 28.0), 18, Color(0.88, 0.82, 0.68))
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dossier_label = _make_label(root, "DossierLabel", Vector2(884.0, 68.0), Vector2(330.0, 54.0), 14, Color(0.76, 0.85, 0.78))
	dossier_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dossier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sample_label = _make_label(root, "SampleLabel", Vector2(728.0, 496.0), Vector2(430.0, 68.0), 15, Color(0.90, 0.78, 0.68))
	sample_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sample_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	archive_label = _make_label(root, "ArchiveLabel", Vector2(286.0, 118.0), Vector2(708.0, 238.0), 16, Color(0.74, 0.82, 0.78))
	archive_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	archive_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_rite_label = _make_label(root, "BossRiteLabel", Vector2(390.0, 164.0), Vector2(500.0, 66.0), 22, Color(1.0, 0.34, 0.28))
	boss_rite_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	boss_rite_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialogue_label = _make_label(root, "DialogueLabel", Vector2(190.0, 636.0), Vector2(900.0, 34.0), 18, Color(0.86, 0.83, 0.78))
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label = _make_label(root, "PromptLabel", Vector2(500.0, 572.0), Vector2(280.0, 32.0), 18, Color(0.92, 0.90, 0.74))
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_build_logbook_ui(root)


func _build_logbook_ui(parent: Node) -> void:
	logbook_root = Control.new()
	logbook_root.name = "LogbookOverlay"
	logbook_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	logbook_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logbook_root.visible = false
	parent.add_child(logbook_root)

	var dim := ColorRect.new()
	dim.position = Vector2.ZERO
	dim.size = VIEWPORT_SIZE
	dim.color = Color(0.0, 0.0, 0.0, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logbook_root.add_child(dim)

	logbook_art_backdrop = _make_texture_preview(logbook_root, art_assets.concept_texture("sacred_casket_ui"), Vector2(108.0, 70.0), Vector2(1064.0, 548.0), 0.32)

	_make_panel(logbook_root, Vector2(108.0, 70.0), Vector2(1064.0, 548.0))
	_make_panel_marks(logbook_root, Vector2(108.0, 70.0), Vector2(1064.0, 548.0), Color(0.68, 0.13, 0.12))
	_make_panel(logbook_root, Vector2(148.0, 186.0), Vector2(314.0, 350.0))
	_make_panel(logbook_root, Vector2(496.0, 186.0), Vector2(430.0, 350.0))
	_make_panel(logbook_root, Vector2(948.0, 186.0), Vector2(188.0, 170.0))
	logbook_art_preview = _make_texture_preview(logbook_root, art_assets.concept_texture("log_fragments"), Vector2(954.0, 206.0), Vector2(176.0, 132.0), 0.86)

	_make_label(logbook_root, "LogbookHeader", Vector2(150.0, 106.0), Vector2(390.0, 42.0), 30, Color(0.94, 0.86, 0.70)).text = "圣匣日志"
	_make_label(logbook_root, "LogbookHint", Vector2(732.0, 110.0), Vector2(318.0, 28.0), 18, Color(0.74, 0.80, 0.78)).text = "P 关闭 | A/D 或 ←/→ 切换"
	logbook_progress_label = _make_label(logbook_root, "LogbookProgress", Vector2(150.0, 150.0), Vector2(770.0, 26.0), 18, Color(0.64, 0.84, 0.84))
	_make_label(logbook_root, "LogbookExplain", Vector2(150.0, 170.0), Vector2(880.0, 22.0), 14, Color(0.66, 0.68, 0.62)).text = "吞食胃：击杀回血，读取记忆。判读：器官对碎片的反应。"

	_make_label(logbook_root, "LogbookListTitle", Vector2(176.0, 218.0), Vector2(244.0, 26.0), 21, Color(0.90, 0.78, 0.62)).text = "碎片列表"
	logbook_list_labels.clear()
	logbook_item_bars.clear()
	for i in 8:
		var item_bar := ColorRect.new()
		item_bar.name = "LogbookItemBar" + str(i)
		item_bar.position = Vector2(164.0, 255.0 + float(i) * 32.0)
		item_bar.size = Vector2(276.0, 28.0)
		item_bar.color = Color(0.0, 0.0, 0.0, 0.0)
		item_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		logbook_root.add_child(item_bar)
		logbook_item_bars.append(item_bar)
		var item_label := _make_label(logbook_root, "LogbookItem" + str(i), Vector2(176.0, 260.0 + float(i) * 32.0), Vector2(254.0, 28.0), 18, Color(0.70, 0.75, 0.72))
		logbook_list_labels.append(item_label)

	logbook_title_label = _make_label(logbook_root, "LogbookTitle", Vector2(526.0, 218.0), Vector2(372.0, 38.0), 27, Color(0.95, 0.84, 0.66))
	logbook_meta_label = _make_label(logbook_root, "LogbookMeta", Vector2(526.0, 260.0), Vector2(372.0, 28.0), 18, Color(0.62, 0.84, 0.84))
	logbook_text_label = _make_label(logbook_root, "LogbookText", Vector2(526.0, 316.0), Vector2(372.0, 78.0), 19, Color(0.88, 0.85, 0.78))
	logbook_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	logbook_organ_label = _make_label(logbook_root, "LogbookOrgan", Vector2(526.0, 424.0), Vector2(372.0, 58.0), 18, Color(0.82, 0.62, 0.58))
	logbook_organ_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	logbook_story_label = _make_label(logbook_root, "LogbookStory", Vector2(526.0, 492.0), Vector2(372.0, 28.0), 18, Color(0.64, 0.84, 0.84))
	logbook_empty_label = _make_label(logbook_root, "LogbookEmpty", Vector2(526.0, 292.0), Vector2(372.0, 92.0), 22, Color(0.84, 0.78, 0.68))
	logbook_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	logbook_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _make_label(parent: Node, node_name: String, pos: Vector2, size: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.name = node_name
	label.position = pos
	label.custom_minimum_size = size
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label


func _load_ui_textures() -> void:
	hp_icon_texture = _load_svg_texture(HP_ICON_PATH, Color(0.72, 0.12, 0.14, 1.0))
	stomach_open_texture = _load_svg_texture(STOMACH_OPEN_ICON_PATH, Color(0.45, 0.68, 0.62, 1.0))
	stomach_closed_texture = _load_svg_texture(STOMACH_CLOSED_ICON_PATH, Color(0.70, 0.18, 0.14, 1.0))
	stomach_overflow_texture = _load_svg_texture(STOMACH_OVERFLOW_ICON_PATH, Color(0.95, 0.28, 0.20, 1.0))
	memory_shard_texture = _load_svg_texture(MEMORY_SHARD_ICON_PATH, Color(0.58, 0.82, 0.90, 1.0))


func _load_svg_texture(path: String, fallback_color: Color) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource := ResourceLoader.load(path)
		if resource is Texture2D:
			return resource as Texture2D
	return _make_fallback_texture(fallback_color)


func _make_fallback_texture(color: Color) -> Texture2D:
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.05, 0.04, 0.04, 1.0))
	image.fill_rect(Rect2i(Vector2i(4, 4), Vector2i(16, 16)), color)
	image.fill_rect(Rect2i(Vector2i(7, 7), Vector2i(5, 5)), color.lightened(0.25))
	return ImageTexture.create_from_image(image)


func _make_panel(parent: Node, pos: Vector2, size: Vector2) -> Panel:
	var panel := Panel.new()
	panel.position = pos
	panel.size = size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.030, 0.026, 0.024, 0.76)
	style.border_color = Color(0.62, 0.56, 0.44, 0.58)
	style.set_border_width_all(1)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.48)
	style.shadow_size = 10
	style.shadow_offset = Vector2(2.0, 3.0)
	style.anti_aliasing = false
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel


func _make_panel_marks(parent: Node, pos: Vector2, size: Vector2, color: Color) -> void:
	var inset := 6.0
	var short_edge := 14.0
	var thick := 2.0
	_make_accent(parent, pos + Vector2(inset, inset), Vector2(short_edge, thick), color)
	_make_accent(parent, pos + Vector2(inset, inset), Vector2(thick, short_edge), color)
	_make_accent(parent, pos + Vector2(size.x - inset - short_edge, size.y - inset - thick), Vector2(short_edge, thick), color)
	_make_accent(parent, pos + Vector2(size.x - inset - thick, size.y - inset - short_edge), Vector2(thick, short_edge), color)


func _make_accent(parent: Node, pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var accent := ColorRect.new()
	accent.position = pos
	accent.size = size
	accent.color = color
	accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(accent)
	return accent


func _make_icon(parent: Node, texture: Texture2D, pos: Vector2, size: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.texture = texture
	icon.position = pos
	icon.size = size
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(icon)
	return icon


func _make_texture_preview(parent: Node, texture: Texture2D, pos: Vector2, size: Vector2, alpha: float = 1.0) -> TextureRect:
	var safe_rect := _safe_ui_rect(pos, size)
	var preview := TextureRect.new()
	preview.texture = texture
	preview.position = safe_rect.position
	preview.size = safe_rect.size
	preview.clip_contents = true
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.modulate = Color(1.0, 1.0, 1.0, alpha)
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(preview)
	return preview


func _safe_ui_rect(pos: Vector2, size: Vector2) -> Rect2:
	var safe_size := Vector2(
		minf(size.x, VIEWPORT_SIZE.x - UI_SAFE_MARGIN * 2.0),
		minf(size.y, VIEWPORT_SIZE.y - UI_SAFE_MARGIN * 2.0)
	)
	var safe_pos := Vector2(
		clampf(pos.x, UI_SAFE_MARGIN, VIEWPORT_SIZE.x - UI_SAFE_MARGIN - safe_size.x),
		clampf(pos.y, UI_SAFE_MARGIN, VIEWPORT_SIZE.y - UI_SAFE_MARGIN - safe_size.y)
	)
	return Rect2(safe_pos, safe_size)


func _make_hp_bar(parent: Node, pos: Vector2, size: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = size
	bar.max_value = PLAYER_MAX_HP
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.10, 0.055, 0.06, 0.94)
	background.border_color = Color(0.58, 0.55, 0.48, 0.88)
	background.set_border_width_all(2)
	background.anti_aliasing = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.56, 0.08, 0.09, 0.98)
	fill.border_color = Color(0.88, 0.24, 0.20, 0.72)
	fill.set_border_width_all(1)
	fill.anti_aliasing = false
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	parent.add_child(bar)
	return bar


func _make_stomach_bar(parent: Node, pos: Vector2, size: Vector2) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = size
	bar.max_value = 2.2
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.10, 0.055, 0.06, 0.94)
	background.border_color = Color(0.48, 0.52, 0.48, 0.80)
	background.set_border_width_all(1)
	background.anti_aliasing = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.56, 0.70, 0.66, 0.96)
	fill.border_color = Color(0.80, 0.90, 0.84, 0.72)
	fill.set_border_width_all(1)
	fill.anti_aliasing = false
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	parent.add_child(bar)
	return bar


func _update_timers(delta: float) -> void:
	attack_runtime.update(delta)
	god_stomach.update(delta)
	sample_record_timer = maxf(0.0, sample_record_timer - delta)
	dossier_timer = maxf(0.0, dossier_timer - delta)
	boss_rite_timer = maxf(0.0, boss_rite_timer - delta)
	player_hit_anim_timer = maxf(0.0, player_hit_anim_timer - delta)
	hit_stop_timer = maxf(0.0, hit_stop_timer - delta)
	screen_shake_timer = maxf(0.0, screen_shake_timer - delta)
	damage_flash_timer = maxf(0.0, damage_flash_timer - delta)
	log_fragment_pulse_timer = maxf(0.0, log_fragment_pulse_timer - delta)
	if mode == RunMode.FIELD and room_index == rooms.size() - 1:
		boss_expose_timer -= delta
		if boss_expose_timer <= 0.0:
			boss_weak_exposed = not boss_weak_exposed
			boss_expose_timer = 1.9 if boss_weak_exposed else 2.8
			if boss_weak_exposed:
				boss_rite_timer = 1.9
				_emit_text_effect(Vector2(640.0, 148.0), "胃囊暴露", Color(0.98, 0.26, 0.20))


func _update_player_movement(delta: float, bounds: Rect2) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	player_runtime.update_movement(input_dir, delta, bounds, PLAYER_SPEED, PLAYER_RADIUS, _player_inside_hazard())


func _try_player_attack() -> void:
	var attack: Dictionary = attack_runtime.try_start(
		attack_buffered,
		player_runtime.position,
		player_runtime.facing,
		BASE_DAMAGE,
		god_stomach.attack_bonus()
	)
	if attack.is_empty():
		return

	player_runtime.apply_impulse(attack["lunge"])
	slashes.append(attack["slash"])
	var slash_index := slashes.size() - 1
	var hit_count := 0

	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		var enemy_pos: Vector2 = enemy["pos"]
		var to_enemy := enemy_pos - (attack["origin"] as Vector2)
		if to_enemy.length() > float(attack["range"]) + float(enemy["radius"]):
			continue
		var angle := absf((attack["dir"] as Vector2).angle_to(to_enemy.normalized()))
		if angle > float(attack["half_angle"]) and to_enemy.length() > 34.0:
			continue
		var final_damage := int(attack["damage"])
		if String(enemy["kind"]) == "barn_king" and boss_weak_exposed:
			final_damage += 24
			_emit_text_effect(enemy_pos + Vector2(0.0, -58.0), "胃囊暴露", Color(0.95, 0.42, 0.36))
		_damage_enemy(i, final_damage, (attack["dir"] as Vector2) * float(attack["knockback"]))
		hit_count += 1
	if slash_index >= 0 and slash_index < slashes.size():
		slashes[slash_index]["hit"] = hit_count > 0
	if hit_count <= 0:
		_trigger_miss_feedback(attack)


func _damage_enemy(index: int, amount: int, knockback: Vector2) -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy: Dictionary = enemies[index]
	enemy["hp"] = float(enemy["hp"]) - float(amount)
	enemy["pos"] = (enemy["pos"] as Vector2) + knockback
	enemy["hit_flash"] = 0.20
	_emit_text_effect(enemy["pos"] as Vector2, str(amount), Color(0.96, 0.76, 0.58))
	_spawn_hit_burst(enemy["pos"] as Vector2, attack_runtime.combo_step, amount)
	var impactful_hit := float(enemy["hp"]) <= 0.0 or attack_runtime.combo_step == 3
	_trigger_hit_feedback(impactful_hit)

	if float(enemy["hp"]) > 0.0:
		return

	var killed_kind := String(enemy["kind"])
	var killed_name := String(enemy["name"])
	enemies.remove_at(index)
	_on_enemy_killed(killed_kind, killed_name, amount)


func _on_enemy_killed(kind: String, enemy_name: String, final_damage: int) -> void:
	_emit_text_effect(player_runtime.position + Vector2(0.0, -34.0), "器官回响", Color(0.70, 0.92, 0.84))
	var reward: Dictionary = god_stomach.apply_kill_reward(kind, player_runtime.hp, PLAYER_MAX_HP)
	player_runtime.apply_heal(int(reward["hp"]), PLAYER_MAX_HP)
	var room_id := _current_room_id()
	var archived_fragment: Dictionary = log_archive.call("try_collect_from_kill", kind, room_id)
	var fragment_collected := bool(archived_fragment.get("collected", false))
	if fragment_collected:
		_emit_text_effect(player_runtime.position + Vector2(0.0, -78.0), "样本归档", Color(0.58, 0.84, 0.92))
		log_fragment_pulse_timer = 3.1
	_show_sample_record(kind, enemy_name, int(reward["healed"]), bool(reward["locked"]), bool(reward["overflow"]), final_damage, archived_fragment)
	if bool(reward["locked"]):
		_emit_text_effect(player_runtime.position + Vector2(0.0, -58.0), "饥饿惩罚", Color(0.65, 0.55, 0.48))
	elif bool(reward["overflow"]):
		_emit_text_effect(player_runtime.position + Vector2(0.0, -58.0), "溢血转刃", Color(0.95, 0.50, 0.45))

	if kind == "barn_king":
		god_stomach.absorb_boss_memory()
		mode = RunMode.COMPLETE
		boss_rite_timer = 0.0
		var progress: Dictionary = log_archive.call("story_progress")
		dialogue_label.text = "记忆：" + ("第一故事已拼合。" if bool(progress["unlocked"]) else "谷仓王的胃还缺几份证词。")
	else:
		dialogue_label.text = enemy_name + " 倒下后，" + ("一份记忆被圣匣接收。" if fragment_collected else "土地短暂安静。")


func _show_sample_record(kind: String, enemy_name: String, healed: int, locked: bool, overflow: bool, final_damage: int, archived_fragment: Dictionary) -> void:
	var reaction := "吞噬成功"
	if locked:
		reaction = "胃囊闭合，样本拒收"
	elif overflow:
		reaction = "血量溢出，转写为刃"

	var fragment_collected := bool(archived_fragment.get("collected", false))
	var shard_note := _compact_sample_text(archived_fragment, "日志碎片：未归档")
	if bool(archived_fragment.get("missed", false)):
		shard_note = "日志碎片：未检出"
	if fragment_collected:
		reaction = String(archived_fragment.get("stomach_reaction", reaction))

	var progress_line := ""
	if fragment_collected:
		var progress: Dictionary = log_archive.call("story_progress")
		progress_line = "\n谷仓王故事 " + str(progress["collected"]) + "/" + str(progress["required"]) + " | P 查看"
	sample_record_text = shard_note + progress_line
	sample_record_timer = 3.1 if fragment_collected else 0.9


func _update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if i >= enemies.size():
			continue
		var enemy: Dictionary = enemies[i]
		enemy_runtime.update_timers(enemy, delta)

		match String(enemy["kind"]):
			"empty":
				enemy_runtime.update_empty(enemy, delta, player_runtime.position)
			"farmer":
				_handle_enemy_event(enemy_runtime.update_farmer(enemy, delta, player_runtime.position, player_runtime.velocity))
			"scarecrow":
				_handle_enemy_event(enemy_runtime.update_scarecrow(enemy, delta, player_runtime.position))
			"barn_king":
				_update_barn_king(enemy, delta)

		enemy_runtime.clamp_to_arena(enemy, ARENA)
		_try_enemy_contact(enemy)
		if mode != RunMode.FIELD:
			return


func _update_barn_king(enemy: Dictionary, delta: float) -> void:
	var pos: Vector2 = enemy["pos"]
	var next_phase := enemy_runtime.resolve_barn_king_phase(enemy)
	if next_phase != boss_phase:
		boss_phase = next_phase
		var phase_text := "谷仓王撕开胃室。" if boss_phase == 2 else "谷仓王露出吞食胃。"
		if boss_phase == 2:
			phase_text = "还不够。地还在喊，仓还在空。"
		elif boss_phase == 3:
			phase_text = "开仓。开腹。开一切还能装下东西的地方。"
		dialogue_label.text = phase_text
		_emit_text_effect(pos + Vector2(0.0, -70.0), "阶段 " + str(boss_phase), Color(1.0, 0.62, 0.42))
		boss_rite_timer = 1.9

	_handle_enemy_event(enemy_runtime.update_barn_king(enemy, delta, player_runtime.position, boss_phase))


func _handle_enemy_event(event: Dictionary) -> void:
	if event.is_empty():
		return

	match String(event["type"]):
		"farmer_seed":
			var seed_pos: Vector2 = event["pos"]
			_limit_temporary_hazards(10)
			hazards.append(_hazard_data(seed_pos, 34.0, 2.2, 8, Color(0.62, 0.08, 0.07, 0.55), 0.85))
			_emit_text_effect(seed_pos, "牙齿作物", Color(0.88, 0.44, 0.34))
		"scarecrow_wave":
			_limit_temporary_hazards(10)
			for center: Vector2 in event["centers"]:
				hazards.append(_hazard_data(center, 32.0, 1.5, 13, Color(0.67, 0.12, 0.04, 0.46)))
			_emit_text_effect((event["pos"] as Vector2) + Vector2(0.0, -48.0), "麦浪", Color(0.92, 0.63, 0.32))
		"barn_open":
			var pos: Vector2 = event["pos"]
			enemies.append(_enemy_data("empty", pos + Vector2(randf_range(-90.0, 90.0), randf_range(-65.0, 65.0))))
			_emit_text_effect(pos + Vector2(0.0, -76.0), "开仓", Color(0.86, 0.47, 0.35))
		"barn_acid":
			var acid_pos: Vector2 = event["pos"]
			_limit_temporary_hazards(10)
			hazards.append(_hazard_data(acid_pos, 52.0, 3.3, 14, Color(0.64, 0.10, 0.08, 0.56)))
			_emit_text_effect(acid_pos + Vector2(0.0, -42.0), "消化液", Color(0.86, 0.34, 0.26))
		"barn_contract":
			_limit_temporary_hazards(10)
			for center: Vector2 in event["centers"]:
				hazards.append(_hazard_data(center, 38.0, 1.8, 16, Color(0.78, 0.08, 0.07, 0.50)))
			_emit_text_effect((event["pos"] as Vector2) + Vector2(0.0, -82.0), "胃室收缩", Color(0.95, 0.28, 0.22))


func _limit_temporary_hazards(max_count: int) -> void:
	var temporary_indexes: Array[int] = []
	for i in hazards.size():
		if float(hazards[i].get("timer", 0.0)) < 900.0:
			temporary_indexes.append(i)
	while temporary_indexes.size() >= max_count:
		hazards.remove_at(temporary_indexes.pop_front())
		for n in temporary_indexes.size():
			temporary_indexes[n] = int(temporary_indexes[n]) - 1


func _try_enemy_contact(enemy: Dictionary) -> void:
	var contact: Dictionary = enemy_runtime.try_contact(enemy, player_runtime.position, PLAYER_RADIUS)
	if not bool(contact["hit"]):
		return
	_take_player_damage(int(contact["damage"]), String(contact["name"]))
	if mode != RunMode.FIELD:
		return
	player_runtime.apply_impulse(contact["push"])


func _update_hazards(delta: float) -> void:
	for i in range(hazards.size() - 1, -1, -1):
		if i >= hazards.size():
			continue
		var hazard: Dictionary = hazards[i]
		hazard["timer"] = float(hazard["timer"]) - delta
		hazard["tick"] = maxf(0.0, float(hazard["tick"]) - delta)
		hazard["arm_time"] = maxf(0.0, float(hazard.get("arm_time", 0.0)) - delta)
		if float(hazard["timer"]) <= 0.0:
			hazards.remove_at(i)
			continue
		if float(hazard["arm_time"]) > 0.0:
			continue
		if player_runtime.position.distance_to(hazard["pos"] as Vector2) <= float(hazard["radius"]) + PLAYER_RADIUS and float(hazard["tick"]) <= 0.0:
			hazard["tick"] = 0.65
			_take_player_damage(int(hazard["damage"]), "咬人麦穗")
			if mode != RunMode.FIELD:
				return


func _player_inside_hazard() -> bool:
	for hazard: Dictionary in hazards:
		if float(hazard.get("arm_time", 0.0)) > 0.0:
			continue
		if player_runtime.position.distance_to(hazard["pos"] as Vector2) <= float(hazard["radius"]) + PLAYER_RADIUS:
			return true
	return false


func _take_player_damage(amount: int, source: String) -> void:
	player_runtime.apply_damage(amount)
	player_hit_anim_timer = 0.30
	damage_flash_timer = 0.22
	screen_shake_timer = maxf(screen_shake_timer, 0.18)
	screen_shake_strength = maxf(screen_shake_strength, 5.5)
	god_stomach.close_from_damage()
	_emit_text_effect(player_runtime.position + Vector2(0.0, -42.0), "-" + str(amount), Color(1.0, 0.34, 0.30))
	dialogue_label.text = "受击：" + source + " 让吞食胃短暂闭合，击杀回血暂停。"
	if player_runtime.hp <= 0:
		death_count += 1
		last_death_note = source
		var archive_text := "回收失败样本 #" + str(death_count) + "\n死因：" + source + "\n土地学习：你的停顿、贪刀和路径选择已被低语田野记录。"
		_return_to_sanctum(_death_recovery_line(source))
		dossier_text = archive_text
		dossier_timer = 7.0


func _update_slashes(delta: float) -> void:
	for i in range(slashes.size() - 1, -1, -1):
		var slash: Dictionary = slashes[i]
		slash["timer"] = float(slash["timer"]) - delta
		if float(slash["timer"]) <= 0.0:
			slashes.remove_at(i)


func _update_hit_bursts(delta: float) -> void:
	for i in range(hit_bursts.size() - 1, -1, -1):
		var burst: Dictionary = hit_bursts[i]
		burst["timer"] = float(burst["timer"]) - delta
		burst["radius"] = float(burst["radius"]) + 115.0 * delta
		if float(burst["timer"]) <= 0.0:
			hit_bursts.remove_at(i)


func _update_effects(delta: float) -> void:
	for i in range(effects.size() - 1, -1, -1):
		var effect: Dictionary = effects[i]
		effect["timer"] = float(effect["timer"]) - delta
		effect["pos"] = (effect["pos"] as Vector2) + Vector2(0.0, -28.0) * delta
		if float(effect["timer"]) <= 0.0:
			effects.remove_at(i)


func _emit_text_effect(pos: Vector2, text: String, color: Color) -> void:
	effects.append({"pos": pos, "text": text, "color": color, "timer": 0.8})


func _trigger_hit_feedback(impactful: bool) -> void:
	hit_stop_timer = maxf(hit_stop_timer, 0.09 if impactful else 0.05)
	screen_shake_timer = maxf(screen_shake_timer, 0.16 if impactful else 0.10)
	screen_shake_strength = maxf(screen_shake_strength, 7.0 if impactful else 4.0)


func _trigger_miss_feedback(attack: Dictionary) -> void:
	var pos := (attack["origin"] as Vector2) + (attack["dir"] as Vector2) * 56.0
	_emit_text_effect(pos + Vector2(0.0, -18.0), "掠空", Color(0.72, 0.70, 0.62))
	screen_shake_timer = maxf(screen_shake_timer, 0.045)
	screen_shake_strength = maxf(screen_shake_strength, 1.4)


func _spawn_hit_burst(pos: Vector2, combo: int, amount: int) -> void:
	hit_bursts.append({
		"pos": pos,
		"timer": 0.22 if combo >= 3 else 0.16,
		"radius": 18.0 + float(combo) * 4.0,
		"combo": combo,
		"amount": amount
	})


func _screen_shake_offset() -> Vector2:
	if screen_shake_timer <= 0.0:
		return Vector2.ZERO
	var strength := screen_shake_strength * clampf(screen_shake_timer / 0.16, 0.0, 1.0)
	return Vector2(randf_range(-strength, strength), randf_range(-strength, strength))


func _check_room_progress() -> void:
	if mode != RunMode.FIELD:
		return
	if enemies.is_empty():
		if not room_cleared and not hazards.is_empty():
			hazards.clear()
			_emit_text_effect(player_runtime.position + Vector2(0.0, -48.0), "危险消退", Color(0.82, 0.76, 0.58))
		room_cleared = true
		if room_index < rooms.size() - 1:
			if interact_buffered:
				_load_room(room_index + 1)
		elif not god_stomach.has_relic:
			god_stomach.has_relic = true
			mode = RunMode.COMPLETE


func _start_run() -> void:
	mode = RunMode.FIELD
	god_stomach.reset_for_run()
	log_archive.call("reset_run")
	attack_runtime.reset()
	player_runtime.reset_for_run(Vector2(640.0, 500.0), Vector2.UP, PLAYER_MAX_HP)
	_load_room(0)


func _load_room(index: int) -> void:
	room_index = index
	room_clock = 0.0
	room_cleared = false
	boss_phase = 1
	boss_expose_timer = 2.5
	boss_weak_exposed = false
	player_runtime.position = Vector2(640.0, 500.0)
	enemies.clear()
	hazards.clear()
	slashes.clear()
	effects.clear()
	hit_bursts.clear()

	var room: Dictionary = rooms[room_index]
	for enemy: Dictionary in room["enemies"]:
		enemies.append(enemy.duplicate(true))
	for hazard: Dictionary in room["hazards"]:
		hazards.append(hazard.duplicate(true))
	dialogue_label.text = String(room["tagline"])
	dossier_text = String(room["dossier"])
	dossier_timer = 6.0


func _return_to_sanctum(text: String) -> void:
	mode = RunMode.SANCTUM
	room_index = -1
	room_cleared = false
	enemies.clear()
	hazards.clear()
	slashes.clear()
	effects.clear()
	hit_bursts.clear()
	attack_runtime.reset()
	player_runtime.reset_for_sanctum(Vector2(640.0, 410.0), PLAYER_MAX_HP)
	god_stomach.reset_for_sanctum()
	boss_rite_timer = 0.0
	dialogue_label.text = text


func _update_ui() -> void:
	match mode:
		RunMode.SANCTUM:
			room_label.text = "无声圣匣"
			objective_label.text = "E 进入田野"
			prompt_label.text = "E 进入 | P 日志"
			dossier_label.text = ""
			archive_label.text = dossier_text if dossier_timer > 0.0 else _sanctum_archive_text()
		RunMode.FIELD:
			var room: Dictionary = rooms[room_index]
			room_label.text = String(room["title"])
			if room_cleared:
				objective_label.text = "已清空：E 下一处" if room_index < rooms.size() - 1 else "Boss 已倒下"
				prompt_label.text = ("E 下一处 | P 日志" if room_index < rooms.size() - 1 else "P 日志")
			else:
				objective_label.text = "清敌：" + str(enemies.size())
				prompt_label.text = "J / Space 近战"
			dossier_label.text = _field_dossier_summary(room) if dossier_timer > 0.0 or room_cleared else ""
			archive_label.text = ""
		RunMode.COMPLETE:
			room_label.text = "回收完成"
			objective_label.text = "E 回圣匣"
			prompt_label.text = "E 回圣匣 | P 日志"
			dossier_label.text = ""
			archive_label.text = "残骸归档：吞食胃\n本轮日志：" + str(log_archive.call("run_count")) + " 份\n提示：按 E 回收样本"

	hp_label.text = "HP %d/%d" % [player_runtime.hp, PLAYER_MAX_HP]
	hp_bar.value = player_runtime.hp
	var story_progress: Dictionary = log_archive.call("story_progress")
	relic_label.text = "吞食胃" + (" 已归档" if god_stomach.has_relic else " 试用") + " | 日志 " + str(story_progress["collected"]) + "/" + str(story_progress["required"])
	organ_label.text = _organ_state_text()
	stomach_bar.value = god_stomach.hunger_lock if god_stomach.hunger_lock > 0.0 else 2.2
	var stomach_fill := stomach_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if stomach_fill:
		stomach_fill.bg_color = Color(0.68, 0.16, 0.14, 0.96) if god_stomach.hunger_lock > 0.0 else Color(0.56, 0.70, 0.66, 0.96)
	stomach_icon.texture = stomach_closed_texture if god_stomach.hunger_lock > 0.0 else (stomach_overflow_texture if god_stomach.overflow_power > 0.0 else stomach_open_texture)
	sample_label.text = sample_record_text if sample_record_timer > 0.0 else ""
	boss_rite_label.text = "弱点暴露\n窗口期：样本伤害 +24" if boss_rite_timer > 0.0 and mode == RunMode.FIELD else ""


func _organ_state_text() -> String:
	var state := "饥饿：击杀回血"
	if god_stomach.hunger_lock > 0.0:
		state = "闭合 %.1fs" % god_stomach.hunger_lock
	elif god_stomach.overflow_power > 0.0:
		state = "溢血刃 %.1fs" % god_stomach.overflow_power
	elif god_stomach.has_relic:
		state = "已归档"
	return "吞食胃：" + state


func _field_dossier_summary(room: Dictionary) -> String:
	return "样本 " + str(enemies.size()) + " / 伤口 " + str(hazards.size())


func _sanctum_archive_text() -> String:
	return _compact_sanctum_text()


func _toggle_logbook() -> void:
	logbook_open = not logbook_open
	var count: int = int(log_archive.call("collected_count"))
	if count <= 0:
		logbook_index = 0
	else:
		logbook_index = clampi(logbook_index, 0, count - 1)
	logbook_root.visible = logbook_open
	_update_logbook_ui()


func _shift_logbook(delta: int) -> void:
	var count: int = int(log_archive.call("collected_count"))
	if count <= 0:
		logbook_index = 0
		_update_logbook_ui()
		return
	logbook_index = wrapi(logbook_index + delta, 0, count)
	_update_logbook_ui()


func _update_logbook_ui() -> void:
	if logbook_root == null:
		return
	var count: int = int(log_archive.call("collected_count"))
	var total: int = int(log_archive.call("fragment_count_total"))
	var progress: Dictionary = log_archive.call("story_progress")
	logbook_progress_label.text = "归档碎片 " + str(count) + "/" + str(total) + "  |  谷仓王故事 " + str(progress["collected"]) + "/" + str(progress["required"])

	for label: Label in logbook_list_labels:
		label.text = ""
		label.add_theme_color_override("font_color", Color(0.70, 0.75, 0.72))
	for item_bar: ColorRect in logbook_item_bars:
		item_bar.color = Color(0.0, 0.0, 0.0, 0.0)

	if count <= 0:
		logbook_empty_label.visible = true
		logbook_empty_label.text = "圣匣空槽\n击杀敌人后自动归档第一份样本"
		if logbook_art_preview:
			logbook_art_preview.texture = art_assets.concept_texture("log_fragments")
		if not logbook_list_labels.is_empty():
			logbook_list_labels[0].text = "暂无样本"
			logbook_list_labels[0].add_theme_color_override("font_color", Color(0.58, 0.60, 0.58))
		logbook_title_label.text = "等待样本"
		logbook_meta_label.text = ""
		logbook_text_label.text = ""
		logbook_organ_label.text = ""
		logbook_story_label.text = "主线进度：" + str(progress["collected"]) + "/" + str(progress["required"])
		return

	logbook_empty_label.visible = false
	logbook_index = clampi(logbook_index, 0, count - 1)
	var first_index: int = clampi(logbook_index - 3, 0, maxi(0, count - 8))
	for offset in range(0, min(logbook_list_labels.size(), count - first_index)):
		var index := first_index + offset
		var fragment: Dictionary = log_archive.call("fragment_at", index)
		var selected := index == logbook_index
		var label := logbook_list_labels[offset]
		if offset < logbook_item_bars.size():
			logbook_item_bars[offset].color = Color(0.45, 0.09, 0.08, 0.72) if selected else Color(0.08, 0.07, 0.06, 0.36)
		label.text = ("▶ " if selected else "  ") + String(fragment.get("title", "未命名样本"))
		label.add_theme_color_override("font_color", Color(0.96, 0.88, 0.76) if selected else Color(0.70, 0.75, 0.72))

	var current: Dictionary = log_archive.call("fragment_at", logbook_index)
	if logbook_art_preview:
		logbook_art_preview.texture = _logbook_preview_texture(String(current.get("source_enemy", "")))
	logbook_title_label.text = String(current.get("title", "未命名样本"))
	logbook_meta_label.text = _enemy_log_label(String(current.get("source_enemy", ""))) + "  |  " + _rarity_label(String(current.get("rarity", "common")))
	logbook_text_label.text = String(current.get("text", ""))
	logbook_organ_label.text = "判读：" + String(current.get("stomach_reaction", ""))
	logbook_story_label.text = "主线进度：" + str(progress["collected"]) + "/" + str(progress["required"]) + (" 已拼合" if bool(progress["unlocked"]) else " 待补证")


func _logbook_preview_texture(source_enemy: String) -> Texture2D:
	if source_enemy == "barn_king":
		return art_assets.concept_texture("boss_barn_king")
	if source_enemy == "empty" or source_enemy == "farmer" or source_enemy == "scarecrow":
		return art_assets.concept_texture("enemies")
	return art_assets.concept_texture("log_fragments")


func _compact_sample_text(fragment: Dictionary, fallback_note: String) -> String:
	if fragment.is_empty():
		return fallback_note
	return "样本归档：" + String(fragment.get("title", ""))


func _compact_sanctum_text() -> String:
	var progress: Dictionary = log_archive.call("story_progress")
	var lines: Array[String] = [
		"圣匣日志 | 低语田野",
		"碎片：" + str(log_archive.call("collected_count")) + " 份 | 本轮：" + str(log_archive.call("run_count")) + " 份",
		"主线：" + str(progress["collected"]) + "/" + str(progress["required"]) + " " + ("已拼合" if bool(progress["unlocked"]) else "待补证")
	]

	if death_count > 0:
		lines.append("失败样本：" + str(death_count) + " | 最近死因：" + last_death_note)

	var latest: Dictionary = log_archive.call("latest_fragment")
	if latest.is_empty():
		lines.append("空槽：尚未采回可归档记忆。")
	else:
		lines.append("最新：" + String(latest.get("title", "")) + " / " + _enemy_log_label(String(latest.get("source_enemy", ""))))
		lines.append("器官判读：" + String(latest.get("stomach_reaction", "")))

	if bool(progress["unlocked"]):
		lines.append("故事：" + String(progress["text"]))

	return "\n".join(lines)


func _enemy_log_label(kind: String) -> String:
	match kind:
		"empty":
			return "空腹者"
		"farmer":
			return "饥民农夫"
		"scarecrow":
			return "饥饿稻草人"
		"barn_king":
			return "谷仓王"
		_:
			return kind


func _rarity_label(rarity: String) -> String:
	match rarity:
		"common":
			return "普通碎片"
		"uncommon":
			return "关键碎片"
		"rare":
			return "稀有碎片"
		"boss":
			return "Boss记忆"
		_:
			return rarity


func _current_room_id() -> String:
	if room_index < 0 or room_index >= rooms.size():
		return ""
	return String(rooms[room_index].get("id", ""))


func _death_recovery_line(source: String) -> String:
	if death_count == 1:
		return "收藏家：回来了。第一次死在田里的人，通常还会相信自己只是运气不好。"
	match source:
		"空腹者":
			return "收藏家：它曾经站在队伍最后。最后的人最容易相信下一次会轮到自己。"
		"饥民农夫":
			return "收藏家：他们下手很稳。人只要重复得够久，什么事都像农活。"
		"饥饿稻草人":
			return "收藏家：那东西还在守田。守到田主死了，守到名字烂了。"
		"咬人麦穗":
			return "收藏家：你把血交给了渠。低语田野最会把一点点变成一整季。"
		"谷仓王":
			return "收藏家：他记住你了。不是记住脸，是记住你能喂养多少人。"
		_:
			return "收藏家：你开始听见差别了。哭声、命令、祈祷，它们不是同一种声音。"


func _draw_sanctum() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.045, 0.050, 0.058))
	var casket_texture := art_assets.concept_texture("sacred_casket_ui")
	if casket_texture:
		_draw_safe_texture_rect(casket_texture, Vector2(84.0, 56.0), Vector2(1112.0, 626.0), Color(1.0, 1.0, 1.0, 0.16))
	var player_concept := art_assets.concept_texture("player_echo")
	if player_concept:
		_draw_safe_texture_rect(player_concept, Vector2(878.0, 132.0), Vector2(300.0, 168.0), Color(1.0, 1.0, 1.0, 0.52))
	var fragment_concept := art_assets.concept_texture("log_fragments")
	if fragment_concept:
		_draw_safe_texture_rect(fragment_concept, Vector2(126.0, 146.0), Vector2(210.0, 118.0), Color(1.0, 1.0, 1.0, 0.54))
	draw_circle(Vector2(640.0, 350.0), 190.0, Color(0.11, 0.13, 0.15))
	draw_circle(Vector2(640.0, 350.0), 122.0, Color(0.17, 0.19, 0.20))
	draw_arc(Vector2(640.0, 350.0), 210.0, 0.0, TAU, 96, Color(0.62, 0.67, 0.64, 0.45), 3.0)
	draw_rect(Rect2(Vector2(356.0, 502.0), Vector2(568.0, 34.0)), Color(0.20, 0.18, 0.16, 0.95))
	draw_circle(Vector2(420.0, 270.0), 34.0, Color(0.55, 0.57, 0.52))
	draw_line(Vector2(420.0, 304.0), Vector2(420.0, 398.0), Color(0.55, 0.57, 0.52), 8.0)
	_draw_player()
	_draw_relic_slots(Vector2(560.0, 520.0))


func _draw_field_room() -> void:
	var room: Dictionary = rooms[room_index]
	var background := art_assets.room_background(String(room["id"]))
	if background:
		draw_texture_rect(background, Rect2(Vector2.ZERO, VIEWPORT_SIZE), false)
		_draw_room_readability_overlay(String(room["id"]))
	else:
		draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), room["palette"])
		draw_rect(ARENA.grow(18.0), Color(0.055, 0.045, 0.040))
		draw_rect(ARENA, Color(0.18, 0.12, 0.08))
		_draw_field_marks()
	if boss_weak_exposed and room_index == rooms.size() - 1:
		draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.50, 0.02, 0.02, 0.26))
	for hazard: Dictionary in hazards:
		var arm_time := float(hazard.get("arm_time", 0.0))
		var hazard_color: Color = hazard["color"]
		if arm_time > 0.0:
			hazard_color = Color(0.72, 0.12, 0.08, 0.16)
		draw_circle(hazard["pos"] as Vector2, float(hazard["radius"]), hazard_color)
		var outline_color := Color(1.0, 0.58, 0.30, 0.88) if arm_time > 0.0 else Color(0.95, 0.30, 0.18, 0.45)
		var outline_width := 4.0 if arm_time > 0.0 else 2.0
		draw_arc(hazard["pos"] as Vector2, float(hazard["radius"]) + 3.0, 0.0, TAU, 32, outline_color, outline_width)
	for enemy: Dictionary in enemies:
		_draw_enemy(enemy)
	for burst: Dictionary in hit_bursts:
		_draw_hit_burst(burst)
	for slash: Dictionary in slashes:
		_draw_slash(slash)
	_draw_player()
	_draw_active_log_fragment()
	if room_cleared and room_index < rooms.size() - 1:
		draw_rect(Rect2(Vector2(590.0, 108.0), Vector2(100.0, 22.0)), Color(0.80, 0.72, 0.45, 0.90))
	for effect: Dictionary in effects:
		_draw_text_effect(effect)


func _draw_complete() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.070, 0.045, 0.050))
	draw_circle(Vector2(640.0, 340.0), 210.0, Color(0.18, 0.08, 0.08))
	draw_circle(Vector2(640.0, 340.0), 78.0, Color(0.72, 0.12, 0.10))
	draw_arc(Vector2(640.0, 340.0), 92.0, 0.0, TAU, 64, Color(0.86, 0.80, 0.70), 4.0)
	_draw_player()
	_draw_relic_slots(Vector2(560.0, 520.0))


func _draw_player() -> void:
	var attack_ratio := clampf(attack_runtime.cooldown / 0.34, 0.0, 1.0)
	draw_circle(player_runtime.position + Vector2(0.0, 18.0), 26.0, Color(0.02, 0.018, 0.014, 0.34))
	draw_arc(player_runtime.position, 37.0, 0.0, TAU, 36, Color(0.12, 0.32, 0.38, 0.34), 2.0)
	if attack_ratio > 0.0:
		var start_angle := player_runtime.facing.angle() - 0.82
		var end_angle := player_runtime.facing.angle() + 0.82
		draw_arc(player_runtime.position, 43.0 + 8.0 * attack_ratio, start_angle, end_angle, 24, Color(0.93, 0.78, 0.38, 0.26 + 0.30 * attack_ratio), 5.0)
	var player_texture := art_assets.player_frame(_player_anim_state(), _anim_frame_index(8.0))
	if player_texture:
		var draw_size := Vector2(94.0, 94.0)
		_draw_centered_texture_modulated(player_texture, player_runtime.position + Vector2(-2.0, 1.0), draw_size + Vector2(8.0, 8.0), Color(0.10, 0.34, 0.40, 0.40), player_runtime.facing.x < -0.05)
		_draw_centered_texture_modulated(player_texture, player_runtime.position + Vector2(2.0, -1.0), draw_size + Vector2(5.0, 5.0), Color(0.86, 0.70, 0.36, 0.28), player_runtime.facing.x < -0.05)
		_draw_centered_texture(player_texture, player_runtime.position, draw_size, player_runtime.facing.x < -0.05)
	else:
		var body_color := Color(0.82, 0.86, 0.82)
		var stomach_color := Color(0.64, 0.08, 0.08) if god_stomach.has_relic or mode == RunMode.FIELD else Color(0.28, 0.30, 0.32)
		draw_circle(player_runtime.position, PLAYER_RADIUS, body_color)
		draw_circle(player_runtime.position + player_runtime.facing * 8.0, 5.0, Color(0.12, 0.14, 0.15))
		draw_circle(player_runtime.position + Vector2(0.0, 5.0), 6.0, stomach_color)
	if god_stomach.hunger_lock > 0.0:
		draw_arc(player_runtime.position + Vector2(0.0, 5.0), 10.0, 0.0, TAU, 24, Color(0.18, 0.18, 0.18, 0.92), 2.0)
	elif god_stomach.overflow_power > 0.0:
		draw_arc(player_runtime.position + Vector2(0.0, 5.0), 12.0, -0.4, TAU - 0.4, 32, Color(1.0, 0.26, 0.20, 0.86), 3.0)
	else:
		draw_arc(player_runtime.position + Vector2(0.0, 5.0), 11.0, -0.6, TAU - 0.6, 28, Color(0.74, 0.52, 0.30, 0.62), 2.0)


func _draw_active_log_fragment() -> void:
	if log_fragment_pulse_timer <= 0.0:
		return
	var shard_texture := art_assets.log_fragment_frame(_anim_frame_index(10.0))
	var pos := player_runtime.position + Vector2(42.0, -46.0)
	if shard_texture:
		_draw_centered_texture(shard_texture, pos, Vector2(42.0, 42.0))
	else:
		draw_circle(pos, 12.0, Color(0.50, 0.82, 0.88, 0.90))


func _player_anim_state() -> String:
	if player_hit_anim_timer > 0.0:
		return "hit"
	if attack_runtime.cooldown > 0.08:
		return "attack"
	if player_runtime.velocity.length() > 12.0:
		return "walk"
	return "idle"


func _draw_enemy(enemy: Dictionary) -> void:
	var pos: Vector2 = enemy["pos"]
	var radius := float(enemy["radius"])
	var kind := String(enemy["kind"])
	var hp_ratio := float(enemy["hp"]) / float(enemy["max_hp"])
	var color := Color(0.55, 0.26, 0.16)
	match kind:
		"empty":
			color = Color(0.55, 0.31, 0.20)
		"farmer":
			color = Color(0.46, 0.38, 0.22)
		"scarecrow":
			color = Color(0.62, 0.45, 0.20)
		"barn_king":
			color = Color(0.50, 0.08, 0.07)
	if float(enemy["hit_flash"]) > 0.0:
		color = Color(0.96, 0.78, 0.62)
	var enemy_texture := art_assets.enemy_frame(kind, _enemy_anim_state(enemy), _anim_frame_index(7.0))
	if enemy_texture:
		var flash_alpha := clampf(float(enemy["hit_flash"]) / 0.20, 0.0, 1.0)
		if flash_alpha > 0.0:
			draw_circle(pos, radius + 18.0, Color(1.0, 0.78, 0.36, 0.22 * flash_alpha))
			draw_arc(pos, radius + 23.0, -0.25, TAU - 0.25, 36, Color(1.0, 0.52, 0.28, 0.58 * flash_alpha), 3.0)
		_draw_centered_texture(enemy_texture, pos, art_assets.enemy_draw_size(kind), _enemy_should_flip(enemy))
	else:
		draw_circle(pos, radius, color)
		if kind == "farmer":
			draw_line(pos + Vector2(-18.0, -18.0), pos + Vector2(18.0, 18.0), Color(0.82, 0.78, 0.60), 3.0)
		elif kind == "scarecrow":
			draw_line(pos + Vector2(-34.0, -6.0), pos + Vector2(34.0, -6.0), Color(0.82, 0.70, 0.42), 5.0)
		elif kind == "barn_king":
			draw_circle(pos, radius * 0.56, Color(0.28, 0.03, 0.03))
	if kind == "barn_king" and boss_weak_exposed:
		_draw_boss_weakpoint_reticle(pos + Vector2(0.0, 8.0), radius)
	draw_rect(Rect2(pos + Vector2(-radius, -radius - 12.0), Vector2(radius * 2.0 * hp_ratio, 4.0)), Color(0.78, 0.10, 0.08))


func _draw_boss_weakpoint_reticle(center: Vector2, radius: float) -> void:
	var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.014)
	var timer_ratio := clampf(boss_expose_timer / 1.9, 0.0, 1.0)
	var target_radius := radius * (0.46 + 0.08 * pulse)
	var outer_radius := radius * (0.66 - 0.08 * timer_ratio)
	draw_circle(center, radius * 0.34, Color(1.0, 0.05, 0.04, 0.48 + 0.24 * pulse))
	draw_arc(center, target_radius, 0.0, TAU, 42, Color(1.0, 0.70, 0.34, 0.92), 4.0)
	draw_arc(center, outer_radius, -0.55, TAU - 0.55, 46, Color(1.0, 0.20, 0.12, 0.44 + 0.26 * pulse), 3.0)
	var arm := radius * 0.78
	var gap := radius * 0.30
	var line_color := Color(1.0, 0.86, 0.50, 0.78)
	draw_line(center + Vector2(-arm, 0.0), center + Vector2(-gap, 0.0), line_color, 3.0)
	draw_line(center + Vector2(gap, 0.0), center + Vector2(arm, 0.0), line_color, 3.0)
	draw_line(center + Vector2(0.0, -arm), center + Vector2(0.0, -gap), line_color, 3.0)
	draw_line(center + Vector2(0.0, gap), center + Vector2(0.0, arm), line_color, 3.0)


func _enemy_anim_state(enemy: Dictionary) -> String:
	var kind := String(enemy["kind"])
	if kind == "barn_king":
		var phase_state := "phase" + str(boss_phase)
		if float(enemy["hit_flash"]) > 0.0:
			return phase_state + "_hit"
		if boss_rite_timer > 0.0 or float(enemy["special"]) > 2.15:
			return phase_state + "_attack"
		return phase_state
	if float(enemy["hit_flash"]) > 0.0:
		return "hit"
	if float(enemy["cooldown"]) > 0.65 or float(enemy["special"]) > 2.35:
		return "attack"
	return "walk"


func _enemy_should_flip(enemy: Dictionary) -> bool:
	return player_runtime.position.x < (enemy["pos"] as Vector2).x


func _anim_frame_index(fps: float) -> int:
	return int(floor(Time.get_ticks_msec() * 0.001 * fps))


func _draw_slash(slash: Dictionary) -> void:
	var pos: Vector2 = slash["pos"]
	var dir: Vector2 = slash["dir"]
	var combo := int(slash.get("combo", 1))
	var width := float(slash.get("width", 5.0 + float(combo) * 1.5))
	var arc_radius := float(slash.get("arc_radius", 42.0))
	var did_hit := bool(slash.get("hit", false))
	var slash_alpha := (0.62 if not did_hit else 0.82) + 0.06 * float(combo)
	var slash_width := width + (2.0 if combo >= 3 else 0.0)
	var slash_color := Color(0.94, 0.90, 0.74, clampf(slash_alpha, 0.0, 1.0))
	if combo >= 3:
		slash_color = Color(1.0, 0.54, 0.34, clampf(slash_alpha, 0.0, 1.0))
	draw_arc(pos, arc_radius + 8.0, dir.angle() - 1.02, dir.angle() + 1.02, 28, Color(0.08, 0.20, 0.24, 0.24), slash_width + 4.0)
	draw_arc(pos, arc_radius, dir.angle() - 0.9, dir.angle() + 0.9, 28, slash_color, slash_width)
	draw_arc(pos, arc_radius - 10.0, dir.angle() - 0.58, dir.angle() + 0.58, 18, Color(1.0, 1.0, 0.88, 0.36 if did_hit else 0.18), maxf(2.0, slash_width * 0.38))


func _draw_hit_burst(burst: Dictionary) -> void:
	var timer := float(burst["timer"])
	var alpha := clampf(timer / 0.22, 0.0, 1.0)
	var pos: Vector2 = burst["pos"]
	var radius := float(burst["radius"])
	var combo := int(burst.get("combo", 1))
	var core_color := Color(1.0, 0.78, 0.42, 0.70 * alpha)
	if combo >= 3:
		core_color = Color(1.0, 0.30, 0.18, 0.78 * alpha)
	draw_circle(pos, radius * 0.42, Color(1.0, 0.95, 0.76, 0.18 * alpha))
	draw_arc(pos, radius, 0.0, TAU, 32, core_color, 3.0 + float(combo))
	draw_line(pos + Vector2(-radius * 0.55, 0.0), pos + Vector2(radius * 0.55, 0.0), Color(1.0, 0.86, 0.52, 0.48 * alpha), 2.0 + float(combo))
	draw_line(pos + Vector2(0.0, -radius * 0.45), pos + Vector2(0.0, radius * 0.45), Color(1.0, 0.86, 0.52, 0.38 * alpha), 2.0)


func _draw_text_effect(effect: Dictionary) -> void:
	var alpha := clampf(float(effect["timer"]) / 0.8, 0.0, 1.0)
	var color: Color = effect["color"]
	color.a = alpha
	draw_string(ThemeDB.fallback_font, effect["pos"] as Vector2, String(effect["text"]), HORIZONTAL_ALIGNMENT_CENTER, 120.0, 18, color)


func _draw_room_readability_overlay(room_id: String) -> void:
	if room_id == "barn_king":
		draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.02, 0.01, 0.01, 0.12))
	else:
		draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.12, 0.08, 0.04, 0.18))
		draw_rect(ARENA, Color(0.92, 0.78, 0.48, 0.055))
	draw_rect(ARENA.grow(6.0), Color(0.05, 0.035, 0.025, 0.30), false, 3.0)
	draw_rect(ARENA, Color(0.86, 0.70, 0.38, 0.26), false, 2.0)


func _draw_centered_texture(texture: Texture2D, center: Vector2, size: Vector2, flip_h: bool = false) -> void:
	var fitted_rect := _fit_texture_rect(texture, Rect2(center - size * 0.5, size))
	if not flip_h:
		draw_texture_rect(texture, fitted_rect, false)
		return
	draw_set_transform(center, 0.0, Vector2(-1.0, 1.0))
	draw_texture_rect(texture, Rect2(fitted_rect.position - center, fitted_rect.size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_centered_texture_modulated(texture: Texture2D, center: Vector2, size: Vector2, modulate: Color, flip_h: bool = false) -> void:
	var fitted_rect := _fit_texture_rect(texture, Rect2(center - size * 0.5, size))
	if not flip_h:
		draw_texture_rect(texture, fitted_rect, false, modulate)
		return
	draw_set_transform(center, 0.0, Vector2(-1.0, 1.0))
	draw_texture_rect(texture, Rect2(fitted_rect.position - center, fitted_rect.size), false, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_safe_texture_rect(texture: Texture2D, pos: Vector2, size: Vector2, modulate: Color) -> void:
	var rect := _safe_ui_rect(pos, size)
	draw_texture_rect(texture, _fit_texture_rect(texture, rect), false, modulate)


func _fit_texture_rect(texture: Texture2D, bounds: Rect2) -> Rect2:
	var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return bounds
	var scale := minf(bounds.size.x / texture_size.x, bounds.size.y / texture_size.y)
	var fitted_size := texture_size * scale
	return Rect2(bounds.position + (bounds.size - fitted_size) * 0.5, fitted_size)


func _draw_field_marks() -> void:
	for n in 14:
		var x: float = ARENA.position.x + 45.0 + float(n % 7) * 150.0
		var y: float = ARENA.position.y + 50.0 + floor(float(n) / 7.0) * 245.0
		draw_line(Vector2(x, y), Vector2(x + 32.0, y - 28.0), Color(0.42, 0.26, 0.11, 0.48), 4.0)
		draw_circle(Vector2(x + 35.0, y - 30.0), 7.0, Color(0.50, 0.10, 0.08, 0.45))


func _draw_relic_slots(origin: Vector2) -> void:
	for i in 7:
		var pos := origin + Vector2(float(i) * 28.0, 0.0)
		var color := Color(0.55, 0.58, 0.55, 0.65)
		if i == 0 and (god_stomach.has_relic or mode == RunMode.FIELD):
			color = Color(0.76, 0.14, 0.12, 0.95)
		draw_circle(pos, 10.0, color)
