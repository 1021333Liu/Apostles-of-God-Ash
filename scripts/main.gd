extends Node2D

enum RunMode { SANCTUM, FIELD, COMPLETE }

const GOD_STOMACH_RELIC_SCRIPT := preload("res://scripts/systems/god_stomach_relic.gd")
const COMBAT_DATA_FACTORY_SCRIPT := preload("res://scripts/systems/combat_data_factory.gd")
const PlayerRuntimeScript := preload("res://scripts/systems/player_runtime.gd")
const EnemyRuntimeScript := preload("res://scripts/systems/enemy_runtime.gd")
const AttackRuntimeScript := preload("res://scripts/systems/attack_runtime.gd")

const VIEWPORT_SIZE: Vector2 = Vector2(1280.0, 720.0)
const ARENA: Rect2 = Rect2(Vector2(120.0, 112.0), Vector2(1040.0, 468.0))
const PLAYER_MAX_HP: int = 100
const PLAYER_SPEED: float = 270.0
const PLAYER_RADIUS: float = 17.0
const BASE_DAMAGE: int = 18
const INTERACT_HINT: String = "E 进入 / 继续"

var mode: RunMode = RunMode.SANCTUM
var player_runtime: PlayerRuntimeScript = PlayerRuntimeScript.new()
var attack_buffered: bool = false
var interact_buffered: bool = false
var death_count: int = 0
var last_death_note: String = ""
var god_stomach := GOD_STOMACH_RELIC_SCRIPT.new()
var enemy_runtime: EnemyRuntimeScript = EnemyRuntimeScript.new()
var attack_runtime: AttackRuntimeScript = AttackRuntimeScript.new()

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
	player_runtime.configure(Vector2(640.0, 420.0), Vector2.RIGHT, PLAYER_MAX_HP)
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
	return COMBAT_DATA_FACTORY_SCRIPT.enemy(kind, pos)


func _hazard_data(pos: Vector2, radius: float, lifetime: float, damage: int, color: Color) -> Dictionary:
	return COMBAT_DATA_FACTORY_SCRIPT.hazard(pos, radius, lifetime, damage, color)


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
	attack_runtime.update(delta)
	god_stomach.update(delta)
	if mode == RunMode.FIELD and room_index == rooms.size() - 1:
		boss_expose_timer -= delta
		if boss_expose_timer <= 0.0:
			boss_weak_exposed = not boss_weak_exposed
			boss_expose_timer = 1.25 if boss_weak_exposed else 3.0


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
			final_damage += 16
			_emit_text_effect(enemy_pos + Vector2(0.0, -58.0), "胃囊暴露", Color(0.95, 0.42, 0.36))
		_damage_enemy(i, final_damage, (attack["dir"] as Vector2) * float(attack["knockback"]))


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
	_emit_text_effect(player_runtime.position + Vector2(0.0, -34.0), "胃囊回响", Color(0.70, 0.92, 0.84))
	var reward: Dictionary = god_stomach.apply_kill_reward(kind, player_runtime.hp, PLAYER_MAX_HP)
	player_runtime.apply_heal(int(reward["hp"]), PLAYER_MAX_HP)
	if bool(reward["locked"]):
		_emit_text_effect(player_runtime.position + Vector2(0.0, -58.0), "饥饿惩罚", Color(0.65, 0.55, 0.48))
	elif bool(reward["overflow"]):
		_emit_text_effect(player_runtime.position + Vector2(0.0, -58.0), "溢血转刃", Color(0.95, 0.50, 0.45))

	if kind == "barn_king":
		god_stomach.absorb_boss_memory()
		mode = RunMode.COMPLETE
		dialogue_label.text = "记忆：谷仓王剖开自己，把胃交给土地。他以为只要自己足够饥饿，人民就不用再饿。"
	else:
		dialogue_label.text = "采样记录：" + enemy_name + " 倒下后，土地短暂安静。你胸口的胃纹更深了一点。"


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
		var phase_text := "谷仓王撕开胃室。" if boss_phase == 2 else "谷仓王露出神之胃囊。"
		dialogue_label.text = phase_text
		_emit_text_effect(pos + Vector2(0.0, -70.0), "阶段 " + str(boss_phase), Color(1.0, 0.62, 0.42))

	_handle_enemy_event(enemy_runtime.update_barn_king(enemy, delta, player_runtime.position, boss_phase))


func _handle_enemy_event(event: Dictionary) -> void:
	if event.is_empty():
		return

	match String(event["type"]):
		"farmer_seed":
			var seed_pos: Vector2 = event["pos"]
			hazards.append(_hazard_data(seed_pos, 30.0, 2.8, 9, Color(0.62, 0.08, 0.07, 0.55)))
			_emit_text_effect(seed_pos, "牙齿作物", Color(0.88, 0.44, 0.34))
		"scarecrow_wave":
			for center: Vector2 in event["centers"]:
				hazards.append(_hazard_data(center, 32.0, 1.5, 13, Color(0.67, 0.12, 0.04, 0.46)))
			_emit_text_effect((event["pos"] as Vector2) + Vector2(0.0, -48.0), "麦浪", Color(0.92, 0.63, 0.32))
		"barn_open":
			var pos: Vector2 = event["pos"]
			enemies.append(_enemy_data("empty", pos + Vector2(randf_range(-90.0, 90.0), randf_range(-65.0, 65.0))))
			_emit_text_effect(pos + Vector2(0.0, -76.0), "开仓", Color(0.86, 0.47, 0.35))
		"barn_acid":
			var acid_pos: Vector2 = event["pos"]
			hazards.append(_hazard_data(acid_pos, 52.0, 3.3, 14, Color(0.64, 0.10, 0.08, 0.56)))
			_emit_text_effect(acid_pos + Vector2(0.0, -42.0), "消化液", Color(0.86, 0.34, 0.26))
		"barn_contract":
			for center: Vector2 in event["centers"]:
				hazards.append(_hazard_data(center, 38.0, 1.8, 16, Color(0.78, 0.08, 0.07, 0.50)))
			_emit_text_effect((event["pos"] as Vector2) + Vector2(0.0, -82.0), "胃室收缩", Color(0.95, 0.28, 0.22))


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
		if float(hazard["timer"]) <= 0.0:
			hazards.remove_at(i)
			continue
		if player_runtime.position.distance_to(hazard["pos"] as Vector2) <= float(hazard["radius"]) + PLAYER_RADIUS and float(hazard["tick"]) <= 0.0:
			hazard["tick"] = 0.65
			_take_player_damage(int(hazard["damage"]), "咬人麦穗")
			if mode != RunMode.FIELD:
				return


func _player_inside_hazard() -> bool:
	for hazard: Dictionary in hazards:
		if player_runtime.position.distance_to(hazard["pos"] as Vector2) <= float(hazard["radius"]) + PLAYER_RADIUS:
			return true
	return false


func _take_player_damage(amount: int, source: String) -> void:
	player_runtime.apply_damage(amount)
	god_stomach.close_from_damage()
	_emit_text_effect(player_runtime.position + Vector2(0.0, -42.0), "-" + str(amount), Color(1.0, 0.34, 0.30))
	dialogue_label.text = "受击：" + source + " 让神之胃囊短暂闭合，击杀回血暂停。"
	if player_runtime.hp <= 0:
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
		elif not god_stomach.has_relic:
			god_stomach.has_relic = true
			mode = RunMode.COMPLETE


func _start_run() -> void:
	mode = RunMode.FIELD
	god_stomach.reset_for_run()
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
	attack_runtime.reset()
	player_runtime.reset_for_sanctum(Vector2(640.0, 410.0), PLAYER_MAX_HP)
	god_stomach.reset_for_sanctum()
	dialogue_label.text = text


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

	hp_label.text = "HP %d/%d | 胃囊：%s%s" % [player_runtime.hp, PLAYER_MAX_HP, god_stomach.status_text(), god_stomach.buff_text()]
	relic_label.text = "残骸：神之胃囊" + (" 已归档" if god_stomach.has_relic else " 试用中") + " | 记忆晶片 " + str(god_stomach.memory_shards)


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
	var stomach_color := Color(0.64, 0.08, 0.08) if god_stomach.has_relic or mode == RunMode.FIELD else Color(0.28, 0.30, 0.32)
	draw_circle(player_runtime.position, PLAYER_RADIUS, body_color)
	draw_circle(player_runtime.position + player_runtime.facing * 8.0, 5.0, Color(0.12, 0.14, 0.15))
	draw_circle(player_runtime.position + Vector2(0.0, 5.0), 6.0, stomach_color)
	draw_line(player_runtime.position, player_runtime.position + player_runtime.facing * 28.0, Color(0.76, 0.78, 0.75), 4.0)


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
	var width := float(slash.get("width", 5.0 + float(int(slash["combo"])) * 1.5))
	var arc_radius := float(slash.get("arc_radius", 42.0))
	draw_arc(pos, arc_radius, dir.angle() - 0.9, dir.angle() + 0.9, 24, Color(0.90, 0.88, 0.76, 0.88), width)


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
		if i == 0 and (god_stomach.has_relic or mode == RunMode.FIELD):
			color = Color(0.76, 0.14, 0.12, 0.95)
		draw_circle(pos, 10.0, color)
