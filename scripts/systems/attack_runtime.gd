class_name AttackRuntime
extends RefCounted

const COMBO_WINDOW_DURATION: float = 0.78

var cooldown: float = 0.0
var combo_step: int = 0
var combo_window: float = 0.0


func reset() -> void:
	cooldown = 0.0
	combo_step = 0
	combo_window = 0.0


func update(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	combo_window = maxf(0.0, combo_window - delta)


func try_start(buffered: bool, origin: Vector2, facing: Vector2, base_damage: int, relic_bonus: int) -> Dictionary:
	if not buffered or cooldown > 0.0:
		return {}

	combo_step = 1 if combo_window <= 0.0 else (combo_step % 3) + 1
	combo_window = COMBO_WINDOW_DURATION
	var profile := _combo_profile(combo_step)
	cooldown = float(profile["cooldown"])

	var attack_dir := facing.normalized()
	var slash_center := origin + attack_dir * float(profile["center_offset"])
	return {
		"origin": origin,
		"dir": attack_dir,
		"damage": base_damage + int(profile["damage_bonus"]) + relic_bonus,
		"range": float(profile["range"]),
		"half_angle": float(profile["half_angle"]),
		"knockback": float(profile["knockback"]),
		"lunge": attack_dir * float(profile["lunge"]),
		"slash": {
			"pos": slash_center,
			"dir": attack_dir,
			"timer": float(profile["slash_timer"]),
			"combo": combo_step,
			"width": float(profile["width"]),
			"arc_radius": float(profile["arc_radius"])
		}
	}


func _combo_profile(step: int) -> Dictionary:
	match step:
		1:
			return {
				"cooldown": 0.24,
				"damage_bonus": 0,
				"range": 74.0,
				"half_angle": 0.66,
				"center_offset": 39.0,
				"slash_timer": 0.13,
				"width": 5.5,
				"arc_radius": 40.0,
				"knockback": 24.0,
				"lunge": 6.0
			}
		2:
			return {
				"cooldown": 0.26,
				"damage_bonus": 4,
				"range": 82.0,
				"half_angle": 0.76,
				"center_offset": 43.0,
				"slash_timer": 0.15,
				"width": 7.0,
				"arc_radius": 44.0,
				"knockback": 28.0,
				"lunge": 8.0
			}
		_:
			return {
				"cooldown": 0.34,
				"damage_bonus": 12,
				"range": 92.0,
				"half_angle": 0.88,
				"center_offset": 48.0,
				"slash_timer": 0.20,
				"width": 9.5,
				"arc_radius": 50.0,
				"knockback": 36.0,
				"lunge": 12.0
			}
