class_name GodStomachRelic
extends RefCounted

const NORMAL_KILL_HEAL: int = 8
const BOSS_KILL_HEAL: int = 10
const OVERFLOW_DAMAGE_BONUS: int = 12
const OVERFLOW_DURATION: float = 4.0
const HUNGER_LOCK_DURATION: float = 2.2

var hunger_lock: float = 0.0
var overflow_power: float = 0.0
var has_relic: bool = false
var memory_shards: int = 0


func reset_for_run() -> void:
	hunger_lock = 0.0
	overflow_power = 0.0
	has_relic = false
	memory_shards = 0


func reset_for_sanctum() -> void:
	hunger_lock = 0.0
	overflow_power = 0.0


func update(delta: float) -> void:
	hunger_lock = maxf(0.0, hunger_lock - delta)
	overflow_power = maxf(0.0, overflow_power - delta)


func close_from_damage() -> void:
	hunger_lock = HUNGER_LOCK_DURATION


func attack_bonus() -> int:
	return OVERFLOW_DAMAGE_BONUS if overflow_power > 0.0 else 0


func status_text() -> String:
	return "闭合 %.1fs" % hunger_lock if hunger_lock > 0.0 else "可吞噬"


func buff_text() -> String:
	return " | 溢血刃 %.1fs" % overflow_power if overflow_power > 0.0 else ""


func absorb_boss_memory() -> void:
	has_relic = true
	memory_shards += 1


func apply_kill_reward(kind: String, current_hp: int, max_hp: int) -> Dictionary:
	if hunger_lock > 0.0:
		return {
			"hp": current_hp,
			"healed": 0,
			"overflow": false,
			"locked": true
		}

	var heal := BOSS_KILL_HEAL if kind == "barn_king" else NORMAL_KILL_HEAL
	var next_hp := mini(max_hp, current_hp + heal)
	var overflow := current_hp + heal > max_hp
	if overflow:
		overflow_power = OVERFLOW_DURATION

	return {
		"hp": next_hp,
		"healed": next_hp - current_hp,
		"overflow": overflow,
		"locked": false
	}
