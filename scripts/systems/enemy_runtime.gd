class_name EnemyRuntime
extends RefCounted

const CONTACT_COOLDOWN: float = 0.85
const FARMER_SPECIAL_COOLDOWN: float = 2.4
const SCARECROW_SPECIAL_COOLDOWN: float = 2.8
const BARN_KING_PHASE_ONE_SPECIAL_COOLDOWN: float = 3.2
const BARN_KING_LATE_SPECIAL_COOLDOWN: float = 2.45


func update_timers(enemy: Dictionary, delta: float) -> void:
	enemy["cooldown"] = maxf(0.0, float(enemy["cooldown"]) - delta)
	enemy["special"] = maxf(0.0, float(enemy["special"]) - delta)
	enemy["hit_flash"] = maxf(0.0, float(enemy["hit_flash"]) - delta)


func update_empty(enemy: Dictionary, delta: float, player_position: Vector2) -> void:
	var pos: Vector2 = enemy["pos"]
	var hp_ratio := float(enemy["hp"]) / float(enemy["max_hp"])
	var speed := float(enemy["speed"]) * (1.42 if hp_ratio <= 0.35 else 1.0)
	var dir := (player_position - pos).normalized()
	enemy["pos"] = pos + dir * speed * delta


func update_farmer(enemy: Dictionary, delta: float, player_position: Vector2, player_velocity: Vector2) -> Dictionary:
	var pos: Vector2 = enemy["pos"]
	var to_player := player_position - pos
	var distance := to_player.length()
	var move_dir := Vector2.ZERO
	if distance < 175.0:
		move_dir = -to_player.normalized()
	elif distance > 260.0:
		move_dir = to_player.normalized()
	enemy["pos"] = pos + move_dir * float(enemy["speed"]) * delta

	if float(enemy["special"]) > 0.0:
		return {}

	enemy["special"] = FARMER_SPECIAL_COOLDOWN
	return {
		"type": "farmer_seed",
		"pos": player_position + player_velocity.normalized() * 26.0
	}


func update_scarecrow(enemy: Dictionary, delta: float, player_position: Vector2) -> Dictionary:
	var pos: Vector2 = enemy["pos"]
	if float(enemy["special"]) <= 0.0:
		enemy["special"] = SCARECROW_SPECIAL_COOLDOWN
		var centers: Array[Vector2] = []
		for offset: Vector2 in [Vector2(-95.0, 0.0), Vector2(0.0, 0.0), Vector2(95.0, 0.0)]:
			centers.append(player_position + offset.rotated(randf_range(-0.35, 0.35)))
		return {
			"type": "scarecrow_wave",
			"pos": pos,
			"centers": centers
		}

	var dir := (player_position - pos).normalized()
	enemy["pos"] = pos + dir * float(enemy["speed"]) * delta
	return {}


func resolve_barn_king_phase(enemy: Dictionary) -> int:
	var hp_ratio := float(enemy["hp"]) / float(enemy["max_hp"])
	return 3 if hp_ratio <= 0.34 else (2 if hp_ratio <= 0.67 else 1)


func update_barn_king(enemy: Dictionary, delta: float, player_position: Vector2, boss_phase: int) -> Dictionary:
	var pos: Vector2 = enemy["pos"]
	var speed := float(enemy["speed"]) * (1.0 + 0.22 * float(boss_phase - 1))
	enemy["pos"] = pos + (player_position - pos).normalized() * speed * delta

	if float(enemy["special"]) > 0.0:
		return {}

	enemy["special"] = BARN_KING_PHASE_ONE_SPECIAL_COOLDOWN if boss_phase == 1 else BARN_KING_LATE_SPECIAL_COOLDOWN
	if boss_phase == 1:
		return {
			"type": "barn_open",
			"pos": pos
		}
	if boss_phase == 2:
		return {
			"type": "barn_acid",
			"pos": player_position
		}

	var centers: Array[Vector2] = []
	for n in 4:
		var angle := TAU * float(n) / 4.0 + randf_range(-0.25, 0.25)
		centers.append(pos + Vector2.RIGHT.rotated(angle) * 125.0)
	return {
		"type": "barn_contract",
		"pos": pos,
		"centers": centers
	}


func clamp_to_arena(enemy: Dictionary, arena: Rect2) -> void:
	var pos: Vector2 = enemy["pos"]
	var radius := float(enemy["radius"])
	enemy["pos"] = Vector2(
		clampf(pos.x, arena.position.x + radius, arena.end.x - radius),
		clampf(pos.y, arena.position.y + radius, arena.end.y - radius)
	)


func try_contact(enemy: Dictionary, player_position: Vector2, player_radius: float) -> Dictionary:
	if float(enemy["cooldown"]) > 0.0:
		return {"hit": false}

	var enemy_pos: Vector2 = enemy["pos"]
	var distance := enemy_pos.distance_to(player_position)
	if distance > float(enemy["radius"]) + player_radius:
		return {"hit": false}

	enemy["cooldown"] = CONTACT_COOLDOWN
	return {
		"hit": true,
		"damage": int(enemy["damage"]),
		"name": String(enemy["name"]),
		"push": (player_position - enemy_pos).normalized() * 22.0
	}
