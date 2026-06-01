extends Node2D

enum RunMode { SANCTUM, FIELD, COMPLETE }

const VIEWPORT_SIZE: Vector2 = Vector2(1280.0, 720.0)
const ARENA: Rect2 = Rect2(Vector2(120.0, 112.0), Vector2(1040.0, 468.0))
const PLAYER_MAX_HP: int = 100
const PLAYER_SPEED: float = 270.0
const PLAYER_RADIUS: float = 17.0
const BASE_DAMAGE: int = 18
const SLASH_RANGE: float = 78.0
const SLASH_HALF_ANGLE: float = 0.72
const ATTACK_COOLDOWN: float = 0.28
const INTERACT_HINT: String = "E 进入 / 继续"

var mode: RunMode = RunMode.SANCTUM
var player_position: Vector2 = Vector2(640.0, 420.0)
var player_velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT
var player_hp: int = PLAYER_MAX_HP
var attack_cooldown: float = 0.0
var combo_step: int = 0
var combo_window: float = 0.0
var hunger_lock: float = 0.0
var overflow_power: float = 0.0
var attack_buffered: bool = false
var interact_buffered: bool = false
var death_count: int = 0
var memory_shards: int = 0
var has_god_stomach: bool = false
var last_death_note: String = ""

var room_index: int = -1
var room_clock: float = 0.0
var room_cleared: bool = false
var boss_phase: int = 1
var boss_expose_timer: float = 2.5
var boss_weak_exposed: bool = false

var rooms: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var hazards: Array[Dictionary] = []
var slashes: Array[Dictionary] = []
var effects: Array[Dictionary] = []

var room_label: Label
var hp_label: Label
var relic_label: Label
var objective_label: Label
var dialogue_label: Label
var prompt_label: Label


func _ready() -> void:
	_setup_input()
	_build_rooms()
	_build_ui()
	_return_to_sanctum("收藏家：容器醒了。先别谈救世，先证明你能活过一片田。")
	set_process(true)
	set_physics_process(true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		attack_buffered = true
		get_viewport().set_input_as_handled()
	if event.is_action_pressed("interact"):
		interact_buffered = true
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	_update_timers(delta)

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
			_update_effects(delta)
			_check_room_progress()
		RunMode.COMPLETE:
			_update_player_movement(delta, Rect2(Vector2(250.0, 170.0), Vector2(780.0, 360.0)))
			if interact_buffered:
				_return_to_sanctum("收藏家：胃囊已经归档。下一次，我们会知道它先吞掉敌人，还是先吞掉你。")

	attack_buffered = false
	interact_buffered = false
	_update_ui()
	queue_redraw()


func _draw() -> void:
	match mode:
		RunMode.SANCTUM:
			_draw_sanctum()
		RunMode.FIELD:
			_draw_field_room()
		RunMode.COMPLETE:
			_draw_complete()


func _setup_input() -> void:
	_ensure_key_action("move_left", KEY_A, KEY_LEFT)
	_ensure_key_action("move_right", KEY_D, KEY_RIGHT)
	_ensure_key_action("move_up", KEY_W, KEY_UP)
	_ensure_key_action("move_down", KEY_S, KEY_DOWN)
	_ensure_key_action("attack", KEY_J, KEY_SPACE)
	_ensure_key_action("interact", KEY_E, KEY_ENTER)


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


func _build_rooms() -> void:
	rooms = [
		{
			"id": "field_gate",
			"title": "低语田野入口",
			"tagline": "第一块土地还在判断你是不是粮食。",
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
			"tagline": "麦穗有牙。别把停顿交给土地。",
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
			"tagline": "水渠不是水渠，是谷仓还没合拢的喉咙。",
			"palette": Color(0.19, 0.10, 0.12),
			"enemies": [
				_enemy_data("farmer", Vector2(420.0, 270.0)),
				_enemy_data("farmer", Vector2(865.0, 420.0)),
				_enemy_data("empty", Vector2(650.0, 500.0))
			],
			"hazards": [
				_hazard_data(Vector2(460.0, 355.0), 58.0, 999.0, 11, Color(0.52, 0.11, 0.09, 0.50)),
				_hazard_data(Vector2(640.0, 345.0), 58.0, 999.0, 11, Color(0.52, 0.11, 0.09, 0.50)),
				_hazard_data(Vector2(820.0, 355.0), 58.0, 999.0, 11, Color(0.52, 0.11, 0.09, 0.50))
			]
		},
		{
			"id": "hungry_barn",
			"title": "饥饿谷仓",
			"tagline": "稻草人守着粮仓，也守着一场主动献祭。",
			"palette": Color(0.24, 0.13, 0.08),
			"enemies": [
				_enemy_data("scarecrow", Vector2(645.0, 320.0)),
				_enemy_data("empty", Vector2(430.0, 415.0)),
				_enemy_data("empty", Vector2(850.0, 245.0))
			],
			"hazards": [
				_hazard_data(Vector2(640.0, 430.0), 44.0, 999.0, 10, Color(0.50, 0.13, 0.05, 0.46))
			]
		},
		{
			"id": "barn_king",
			"title": "谷仓王胃室",
			"tagline": "他曾经想吃掉饥荒。后来他只记得吃。",
			"palette": Color(0.15, 0.07, 0.07),
			"enemies": [
				_enemy_data("barn_king", Vector2(650.0, 300.0))
			],
			"hazards": []
		}
	]


func _enemy_data(kind: String, pos: Vector2) -> Dictionary:
	var data: Dictionary = {
		"kind": kind,
		"pos": pos,
		"cooldown": 0.0,
		"special": 1.4,
		"hit_flash": 0.0
	}
	match kind:
		"empty":
			data.merge({"hp": 42.0, "max_hp": 42.0, "speed": 82.0, "radius": 18.0, "damage": 10, "name": "空腹者"})
		"farmer":
			data.merge({"hp": 54.0, "max_hp": 54.0, "speed": 58.0, "radius": 19.0, "damage": 8, "name": "饥民农夫"})
		"scarecrow":
			data.merge({"hp": 130.0, "max_hp": 130.0, "speed": 34.0, "radius": 28.0, "damage": 16, "name": "饥饿稻草人"})
		"barn_king":
			data.merge({"hp": 360.0, "max_hp": 360.0, "speed": 46.0, "radius": 48.0, "damage": 20, "name": "谷仓王"})
	return data


func _hazard_data(pos: Vector2, radius: float, lifetime: float, damage: int, color: Color) -> Dictionary:
	return {
		"pos": pos,
		"radius": radius,
		"timer": lifetime,
		"damage": damage,
		"tick": 0.0,
		"color": color
	}


func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(root)

	room_label = _make_label(root, "RoomLabel", Vector2(28.0, 20.0), Vector2(520.0, 38.0), 24, Color(0.93, 0.86, 0.76))
	hp_label = _make_label(root, "HPLabel", Vector2(28.0, 62.0), Vector2(430.0, 30.0), 19, Color(0.90, 0.72, 0.66))
	relic_label = _make_label(root, "RelicLabel", Vector2(28.0, 94.0), Vector2(520.0, 30.0), 17, Color(0.70, 0.86, 0.86))
	objective_label = _make_label(root, "ObjectiveLabel", Vector2(760.0, 20.0), Vector2(480.0, 54.0), 18, Color(0.88, 0.82, 0.68))
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dialogue_label = _make_label(root, "DialogueLabel", Vector2(110.0, 606.0), Vector2(1060.0, 70.0), 20, Color(0.86, 0.83, 0.78))
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label = _make_label(root, "PromptLabel", Vector2(510.0, 548.0), Vector2(260.0, 32.0), 18, Color(0.92, 0.90, 0.74))
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


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


func _update_timers(delta: float) -> void:
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	combo_window = maxf(0.0, combo_window - delta)
	hunger_lock = maxf(0.0, hunger_lock - delta)
	overflow_power = maxf(0.0, overflow_power - delta)
	if mode == RunMode.FIELD and room_index == rooms.size() - 1:
		boss_expose_timer -= delta
		if boss_expose_timer <= 0.0:
			boss_weak_exposed = not boss_weak_exposed
			boss_expose_timer = 1.25 if boss_weak_exposed else 3.0


func _update_player_movement(delta: float, bounds: Rect2) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_dir != Vector2.ZERO:
		facing = input_dir.normalized()
		player_velocity = player_velocity.move_toward(input_dir * PLAYER_SPEED, 1800.0 * delta)
	else:
		player_velocity = player_velocity.move_toward(Vector2.ZERO, 1500.0 * delta)

	var speed_scale := 1.0
	if _player_inside_hazard():
		speed_scale = 0.72
	player_position += player_velocity * speed_scale * delta
	player_position.x = clampf(player_position.x, bounds.position.x + PLAYER_RADIUS, bounds.end.x - PLAYER_RADIUS)
	player_position.y = clampf(player_position.y, bounds.position.y + PLAYER_RADIUS, bounds.end.y - PLAYER_RADIUS)


func _try_player_attack() -> void:
	if not attack_buffered or attack_cooldown > 0.0:
		return
	attack_cooldown = ATTACK_COOLDOWN
	combo_step = 1 if combo_window <= 0.0 else (combo_step % 3) + 1
	combo_window = 0.72

	var damage := BASE_DAMAGE + (8 if combo_step == 3 else 0) + (12 if overflow_power > 0.0 else 0)
	var slash_center := player_position + facing * 42.0
	slashes.append({"pos": slash_center, "dir": facing, "timer": 0.16, "combo": combo_step})

	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		var enemy_pos: Vector2 = enemy["pos"]
		var to_enemy := enemy_pos - player_position
		if to_enemy.length() > SLASH_RANGE + float(enemy["radius"]):
			continue
		var angle := absf(facing.angle_to(to_enemy.normalized()))
		if angle > SLASH_HALF_ANGLE and to_enemy.length() > 34.0:
			continue
		var final_damage := damage
		if String(enemy["kind"]) == "barn_king" and boss_weak_exposed:
			final_damage += 16
			_emit_text_effect(enemy_pos + Vector2(0.0, -58.0), "胃囊暴露", Color(0.95, 0.42, 0.36))
		_damage_enemy(i, final_damage, facing * 28.0)


func _damage_enemy(index: int, amount: int, knockback: Vector2) -> void:
	if index < 0 or index >= enemies.size():
		return
	var enemy: Dictionary = enemies[index]
	enemy["hp"] = float(enemy["hp"]) - float(amount)
	enemy["pos"] = (enemy["pos"] as Vector2) + knockback
	enemy["hit_flash"] = 0.12
	_emit_text_effect(enemy["pos"] as Vector2, str(amount), Color(0.96, 0.76, 0.58))

	if float(enemy["hp"]) > 0.0:
		return

	var killed_kind := String(enemy["kind"])
	var killed_name := String(enemy["name"])
	enemies.remove_at(index)
	_on_enemy_killed(killed_kind, killed_name)


func _on_enemy_killed(kind: String, enemy_name: String) -> void:
	_emit_text_effect(player_position + Vector2(0.0, -34.0), "胃囊回响", Color(0.70, 0.92, 0.84))
	if hunger_lock <= 0.0:
		var heal := 10 if kind == "barn_king" else 8
		var old_hp := player_hp
		player_hp = mini(PLAYER_MAX_HP, player_hp + heal)
		if old_hp + heal > PLAYER_MAX_HP:
			overflow_power = 4.0
			_emit_text_effect(player_position + Vector2(0.0, -58.0), "溢血转刃", Color(0.95, 0.50, 0.45))
	else:
		_emit_text_effect(player_position + Vector2(0.0, -58.0), "饥饿惩罚", Color(0.65, 0.55, 0.48))

	if kind == "barn_king":
		has_god_stomach = true
		memory_shards += 1
		mode = RunMode.COMPLETE
		dialogue_label.text = "记忆：谷仓王剖开自己，把胃交给土地。他以为只要自己足够饥饿，人民就不用再饿。"
	else:
		dialogue_label.text = "采样记录：" + enemy_name + " 倒下后，土地短暂安静。你胸口的胃纹更深了一点。"


func _update_enemies(delta: float) -> void:
	for i in range(enemies.size() - 1, -1, -1):
		var enemy: Dictionary = enemies[i]
		enemy["cooldown"] = maxf(0.0, float(enemy["cooldown"]) - delta)
		enemy["special"] = maxf(0.0, float(enemy["special"]) - delta)
		enemy["hit_flash"] = maxf(0.0, float(enemy["hit_flash"]) - delta)

		match String(enemy["kind"]):
			"empty":
				_update_empty(enemy, delta)
			"farmer":
				_update_farmer(enemy, delta)
			"scarecrow":
				_update_scarecrow(enemy, delta)
			"barn_king":
				_update_barn_king(enemy, delta)

		enemy["pos"] = _clamp_to_arena(enemy["pos"] as Vector2, float(enemy["radius"]))
		_try_enemy_contact(enemy)


func _update_empty(enemy: Dictionary, delta: float) -> void:
	var pos: Vector2 = enemy["pos"]
	var hp_ratio := float(enemy["hp"]) / float(enemy["max_hp"])
	var speed := float(enemy["speed"]) * (1.42 if hp_ratio <= 0.35 else 1.0)
	var dir := (player_position - pos).normalized()
	enemy["pos"] = pos + dir * speed * delta


func _update_farmer(enemy: Dictionary, delta: float) -> void:
	var pos: Vector2 = enemy["pos"]
	var to_player := player_position - pos
	var distance := to_player.length()
	var move_dir := Vector2.ZERO
	if distance < 175.0:
		move_dir = -to_player.normalized()
	elif distance > 260.0:
		move_dir = to_player.normalized()
	enemy["pos"] = pos + move_dir * float(enemy["speed"]) * delta

	if float(enemy["special"]) <= 0.0:
		enemy["special"] = 2.4
		var seed_pos := player_position + player_velocity.normalized() * 26.0
		hazards.append(_hazard_data(seed_pos, 30.0, 2.8, 9, Color(0.62, 0.08, 0.07, 0.55)))
		_emit_text_effect(seed_pos, "牙齿作物", Color(0.88, 0.44, 0.34))


func _update_scarecrow(enemy: Dictionary, delta: float) -> void:
	var pos: Vector2 = enemy["pos"]
	if float(enemy["special"]) <= 0.0:
		enemy["special"] = 2.8
		for offset in [Vector2(-95.0, 0.0), Vector2(0.0, 0.0), Vector2(95.0, 0.0)]:
			hazards.append(_hazard_data(player_position + offset.rotated(randf_range(-0.35, 0.35)), 32.0, 1.5, 13, Color(0.67, 0.12, 0.04, 0.46)))
		_emit_text_effect(pos + Vector2(0.0, -48.0), "麦浪", Color(0.92, 0.63, 0.32))
	else:
		var dir := (player_position - pos).normalized()
		enemy["pos"] = pos + dir * float(enemy["speed"]) * delta


func _update_barn_king(enemy: Dictionary, delta: float) -> void:
	var pos: Vector2 = enemy["pos"]
	var hp_ratio := float(enemy["hp"]) / float(enemy["max_hp"])
	var next_phase := 3 if hp_ratio <= 0.34 else (2 if hp_ratio <= 0.67 else 1)
	if next_phase != boss_phase:
		boss_phase = next_phase
		var phase_text := "谷仓王撕开胃室。" if boss_phase == 2 else "谷仓王露出神之胃囊。"
		dialogue_label.text = phase_text
		_emit_text_effect(pos + Vector2(0.0, -70.0), "阶段 " + str(boss_phase), Color(1.0, 0.62, 0.42))

	var speed := float(enemy["speed"]) * (1.0 + 0.22 * float(boss_phase - 1))
	enemy["pos"] = pos + (player_position - pos).normalized() * speed * delta

	if float(enemy["special"]) <= 0.0:
		enemy["special"] = 3.2 if boss_phase == 1 else 2.45
		if boss_phase == 1:
			enemies.append(_enemy_data("empty", pos + Vector2(randf_range(-90.0, 90.0), randf_range(-65.0, 65.0))))
			_emit_text_effect(pos + Vector2(0.0, -76.0), "开仓", Color(0.86, 0.47, 0.35))
		elif boss_phase == 2:
			hazards.append(_hazard_data(player_position, 52.0, 3.3, 14, Color(0.64, 0.10, 0.08, 0.56)))
			_emit_text_effect(player_position + Vector2(0.0, -42.0), "消化液", Color(0.86, 0.34, 0.26))
		else:
			for n in 4:
				var angle := TAU * float(n) / 4.0 + randf_range(-0.25, 0.25)
				hazards.append(_hazard_data(pos + Vector2.RIGHT.rotated(angle) * 125.0, 38.0, 1.8, 16, Color(0.78, 0.08, 0.07, 0.50)))
			_emit_text_effect(pos + Vector2(0.0, -82.0), "胃室收缩", Color(0.95, 0.28, 0.22))


func _try_enemy_contact(enemy: Dictionary) -> void:
	if float(enemy["cooldown"]) > 0.0:
		return
	var enemy_pos: Vector2 = enemy["pos"]
	var distance := enemy_pos.distance_to(player_position)
	if distance > float(enemy["radius"]) + PLAYER_RADIUS:
		return
	enemy["cooldown"] = 0.85
	_take_player_damage(int(enemy["damage"]), String(enemy["name"]))
	var push_dir := (player_position - enemy_pos).normalized()
	player_position += push_dir * 22.0


func _update_hazards(delta: float) -> void:
	for i in range(hazards.size() - 1, -1, -1):
		var hazard: Dictionary = hazards[i]
		hazard["timer"] = float(hazard["timer"]) - delta
		hazard["tick"] = maxf(0.0, float(hazard["tick"]) - delta)
		if float(hazard["timer"]) <= 0.0:
			hazards.remove_at(i)
			continue
		if player_position.distance_to(hazard["pos"] as Vector2) <= float(hazard["radius"]) + PLAYER_RADIUS and float(hazard["tick"]) <= 0.0:
			hazard["tick"] = 0.65
			_take_player_damage(int(hazard["damage"]), "咬人麦穗")


func _player_inside_hazard() -> bool:
	for hazard: Dictionary in hazards:
		if player_position.distance_to(hazard["pos"] as Vector2) <= float(hazard["radius"]) + PLAYER_RADIUS:
			return true
	return false


func _take_player_damage(amount: int, source: String) -> void:
	player_hp = maxi(0, player_hp - amount)
	hunger_lock = 2.2
	_emit_text_effect(player_position + Vector2(0.0, -42.0), "-" + str(amount), Color(1.0, 0.34, 0.30))
	dialogue_label.text = "受击：" + source + " 让神之胃囊短暂闭合，击杀回血暂停。"
	if player_hp <= 0:
		death_count += 1
		last_death_note = source
		_return_to_sanctum("收藏家：第 " + str(death_count) + " 次回收。死因：" + source + "。田野学会了你的停顿。")


func _update_slashes(delta: float) -> void:
	for i in range(slashes.size() - 1, -1, -1):
		var slash: Dictionary = slashes[i]
		slash["timer"] = float(slash["timer"]) - delta
		if float(slash["timer"]) <= 0.0:
			slashes.remove_at(i)


func _update_effects(delta: float) -> void:
	for i in range(effects.size() - 1, -1, -1):
		var effect: Dictionary = effects[i]
		effect["timer"] = float(effect["timer"]) - delta
		effect["pos"] = (effect["pos"] as Vector2) + Vector2(0.0, -28.0) * delta
		if float(effect["timer"]) <= 0.0:
			effects.remove_at(i)


func _emit_text_effect(pos: Vector2, text: String, color: Color) -> void:
	effects.append({"pos": pos, "text": text, "color": color, "timer": 0.8})


func _check_room_progress() -> void:
	if mode != RunMode.FIELD:
		return
	if enemies.is_empty():
		room_cleared = true
		if room_index < rooms.size() - 1:
			if interact_buffered:
				_load_room(room_index + 1)
		elif not has_god_stomach:
			has_god_stomach = true
			mode = RunMode.COMPLETE


func _start_run() -> void:
	mode = RunMode.FIELD
	has_god_stomach = false
	player_hp = PLAYER_MAX_HP
	player_position = Vector2(640.0, 500.0)
	player_velocity = Vector2.ZERO
	facing = Vector2.UP
	hunger_lock = 0.0
	overflow_power = 0.0
	memory_shards = 0
	_load_room(0)


func _load_room(index: int) -> void:
	room_index = index
	room_clock = 0.0
	room_cleared = false
	boss_phase = 1
	boss_expose_timer = 2.5
	boss_weak_exposed = false
	player_position = Vector2(640.0, 500.0)
	enemies.clear()
	hazards.clear()
	slashes.clear()
	effects.clear()

	var room: Dictionary = rooms[room_index]
	for enemy: Dictionary in room["enemies"]:
		enemies.append(enemy.duplicate(true))
	for hazard: Dictionary in room["hazards"]:
		hazards.append(hazard.duplicate(true))
	dialogue_label.text = String(room["tagline"])


func _return_to_sanctum(text: String) -> void:
	mode = RunMode.SANCTUM
	room_index = -1
	room_cleared = false
	enemies.clear()
	hazards.clear()
	slashes.clear()
	effects.clear()
	player_hp = PLAYER_MAX_HP
	player_position = Vector2(640.0, 410.0)
	player_velocity = Vector2.ZERO
	dialogue_label.text = text


func _clamp_to_arena(pos: Vector2, radius: float) -> Vector2:
	return Vector2(
		clampf(pos.x, ARENA.position.x + radius, ARENA.end.x - radius),
		clampf(pos.y, ARENA.position.y + radius, ARENA.end.y - radius)
	)


func _update_ui() -> void:
	match mode:
		RunMode.SANCTUM:
			room_label.text = "无声圣匣"
			objective_label.text = "目标：按 E 进入低语田野"
			prompt_label.text = INTERACT_HINT
		RunMode.FIELD:
			var room: Dictionary = rooms[room_index]
			room_label.text = String(room["title"])
			if room_cleared:
				objective_label.text = "房间已清空：按 E 进入下一处" if room_index < rooms.size() - 1 else "Boss 已倒下"
				prompt_label.text = INTERACT_HINT if room_index < rooms.size() - 1 else ""
			else:
				objective_label.text = "清除敌人：" + str(enemies.size()) + " 个残响仍在活动"
				prompt_label.text = "J / Space 近战"
		RunMode.COMPLETE:
			room_label.text = "回收完成"
			objective_label.text = "神之胃囊已获得：按 E 回圣匣"
			prompt_label.text = INTERACT_HINT

	var lock_text := "闭合 %.1fs" % hunger_lock if hunger_lock > 0.0 else "可吞噬"
	var buff_text := " | 溢血刃 %.1fs" % overflow_power if overflow_power > 0.0 else ""
	hp_label.text = "HP %d/%d | 胃囊：%s%s" % [player_hp, PLAYER_MAX_HP, lock_text, buff_text]
	relic_label.text = "残骸：神之胃囊" + (" 已归档" if has_god_stomach else " 试用中") + " | 记忆晶片 " + str(memory_shards)


func _draw_sanctum() -> void:
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), Color(0.045, 0.050, 0.058))
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
	draw_rect(Rect2(Vector2.ZERO, VIEWPORT_SIZE), room["palette"])
	draw_rect(ARENA.grow(18.0), Color(0.055, 0.045, 0.040))
	draw_rect(ARENA, Color(0.18, 0.12, 0.08))
	_draw_field_marks()
	for hazard: Dictionary in hazards:
		draw_circle(hazard["pos"] as Vector2, float(hazard["radius"]), hazard["color"])
		draw_arc(hazard["pos"] as Vector2, float(hazard["radius"]) + 3.0, 0.0, TAU, 32, Color(0.95, 0.30, 0.18, 0.45), 2.0)
	for enemy: Dictionary in enemies:
		_draw_enemy(enemy)
	for slash: Dictionary in slashes:
		_draw_slash(slash)
	_draw_player()
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
	var body_color := Color(0.82, 0.86, 0.82)
	var stomach_color := Color(0.64, 0.08, 0.08) if has_god_stomach or mode == RunMode.FIELD else Color(0.28, 0.30, 0.32)
	draw_circle(player_position, PLAYER_RADIUS, body_color)
	draw_circle(player_position + facing * 8.0, 5.0, Color(0.12, 0.14, 0.15))
	draw_circle(player_position + Vector2(0.0, 5.0), 6.0, stomach_color)
	draw_line(player_position, player_position + facing * 28.0, Color(0.76, 0.78, 0.75), 4.0)


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
	draw_circle(pos, radius, color)
	if kind == "farmer":
		draw_line(pos + Vector2(-18.0, -18.0), pos + Vector2(18.0, 18.0), Color(0.82, 0.78, 0.60), 3.0)
	elif kind == "scarecrow":
		draw_line(pos + Vector2(-34.0, -6.0), pos + Vector2(34.0, -6.0), Color(0.82, 0.70, 0.42), 5.0)
	elif kind == "barn_king":
		draw_circle(pos, radius * 0.56, Color(0.28, 0.03, 0.03))
		if boss_weak_exposed:
			draw_circle(pos + Vector2(0.0, 8.0), radius * 0.34, Color(0.96, 0.20, 0.15))
	draw_rect(Rect2(pos + Vector2(-radius, -radius - 12.0), Vector2(radius * 2.0 * hp_ratio, 4.0)), Color(0.78, 0.10, 0.08))


func _draw_slash(slash: Dictionary) -> void:
	var pos: Vector2 = slash["pos"]
	var dir: Vector2 = slash["dir"]
	var width := 5.0 + float(int(slash["combo"])) * 1.5
	draw_arc(pos, 42.0, dir.angle() - 0.9, dir.angle() + 0.9, 24, Color(0.90, 0.88, 0.76, 0.88), width)


func _draw_text_effect(effect: Dictionary) -> void:
	var alpha := clampf(float(effect["timer"]) / 0.8, 0.0, 1.0)
	var color: Color = effect["color"]
	color.a = alpha
	draw_string(ThemeDB.fallback_font, effect["pos"] as Vector2, String(effect["text"]), HORIZONTAL_ALIGNMENT_CENTER, 120.0, 18, color)


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
		if i == 0 and (has_god_stomach or mode == RunMode.FIELD):
			color = Color(0.76, 0.14, 0.12, 0.95)
		draw_circle(pos, 10.0, color)
