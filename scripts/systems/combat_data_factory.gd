class_name CombatDataFactory
extends RefCounted


static func enemy(kind: String, pos: Vector2) -> Dictionary:
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


static func hazard(pos: Vector2, radius: float, lifetime: float, damage: int, color: Color, arm_time: float = 0.55) -> Dictionary:
	return {
		"pos": pos,
		"radius": radius,
		"timer": lifetime,
		"damage": damage,
		"tick": 0.0,
		"arm_time": arm_time,
		"color": color
	}
