class_name DiceResolver
extends RefCounted

const HIT_MIN: int = 0
const HIT_MAX: int = 20
const EFFECT_MIN: int = 0
const EFFECT_MAX: int = 3
const REFLECT_MARGIN: int = 5

enum Action { ATTACK, DEFEND }


static func roll_hit(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(HIT_MIN, HIT_MAX)


static func roll_effect(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(EFFECT_MIN, EFFECT_MAX)


static func roll_heal(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(1, EFFECT_MAX)


static func resolve_exchange(player_action: Action, enemy_action: Action, rng: RandomNumberGenerator, bonuses: Dictionary) -> Dictionary:
	var result: Dictionary = {
		"player_action": player_action,
		"enemy_action": enemy_action,
		"player_hp_delta": 0,
		"enemy_hp_delta": 0,
		"player_hit_roll": -1,
		"player_defense_roll": -1,
		"player_effect_roll": -1,
		"player_bonus_roll": -1,
		"enemy_hit_roll": -1,
		"enemy_defense_roll": -1,
		"enemy_effect_roll": -1,
		"event": "",
		"summary": ""
	}

	if player_action == Action.ATTACK and enemy_action == Action.ATTACK:
		_resolve_attack_vs_attack(result, rng, bonuses)
	elif player_action == Action.ATTACK and enemy_action == Action.DEFEND:
		_resolve_attack_vs_defense(result, true, rng, bonuses)
	elif player_action == Action.DEFEND and enemy_action == Action.ATTACK:
		_resolve_attack_vs_defense(result, false, rng, bonuses)
	else:
		_resolve_standoff(result)

	return result


static func _resolve_attack_vs_attack(result: Dictionary, rng: RandomNumberGenerator, bonuses: Dictionary) -> void:
	result["player_hit_roll"] = roll_hit(rng)
	result["enemy_hit_roll"] = roll_hit(rng)

	var player_damage: int = _damage_for_attack(result["player_hit_roll"], rng)
	var enemy_damage: int = _damage_for_attack(result["enemy_hit_roll"], rng)

	if player_damage > 0 and bonuses.get("sickle", false):
		result["player_bonus_roll"] = roll_effect(rng)
		player_damage += result["player_bonus_roll"]

	result["enemy_hp_delta"] = -player_damage
	result["player_hp_delta"] = -enemy_damage

	if result["player_hit_roll"] == HIT_MIN and result["enemy_hit_roll"] == HIT_MIN:
		result["event"] = "双重大失败"
		result["summary"] = "双方都没能理解对方的动作，攻击落空。"
	elif result["player_hit_roll"] == HIT_MAX and result["enemy_hit_roll"] == HIT_MAX:
		result["event"] = "双重大成功"
		result["summary"] = "双方都命中了最坏的位置。"
	elif result["player_hit_roll"] == HIT_MAX:
		result["event"] = "攻击大成功"
		result["summary"] = "你的残片刃切开了农夫的防线。"
	elif result["enemy_hit_roll"] == HIT_MAX:
		result["event"] = "敌人大成功"
		result["summary"] = "农夫的镰刃正好落在你没防住的地方。"
	else:
		result["event"] = "互相攻击"
		result["summary"] = "双方都选择进攻，伤害同时结算。"


static func _resolve_attack_vs_defense(result: Dictionary, player_is_attacker: bool, rng: RandomNumberGenerator, bonuses: Dictionary) -> void:
	var attack_roll: int = roll_hit(rng)
	var defense_roll: int = roll_hit(rng)

	if player_is_attacker:
		result["player_hit_roll"] = attack_roll
		result["enemy_defense_roll"] = defense_roll
	else:
		result["enemy_hit_roll"] = attack_roll
		result["player_defense_roll"] = defense_roll
		if bonuses.get("hat", false):
			result["player_bonus_roll"] = roll_effect(rng)
			defense_roll += result["player_bonus_roll"]

	if defense_roll >= HIT_MAX:
		_apply_reflect(result, player_is_attacker, EFFECT_MAX, "完美防御", "防御骰掷出 20，攻击被完全封住并触发反弹。")
		return

	if attack_roll == HIT_MAX:
		_apply_attack_damage(result, player_is_attacker, EFFECT_MAX, "攻击大成功", "攻击骰掷出 20，普通防御无法抵挡。")
		return

	if attack_roll == HIT_MIN:
		result["event"] = "攻击大失败"
		result["summary"] = "攻击骰掷出 0，动作失去意义。"
		return

	if defense_roll >= attack_roll + REFLECT_MARGIN:
		var reflect_damage: int = roll_effect(rng)
		_apply_reflect(result, player_is_attacker, reflect_damage, "防御反弹", "防御高出攻击 5 点以上，触发反弹。")
		return

	if defense_roll >= attack_roll:
		result["event"] = "防御成功"
		result["summary"] = "防御挡住了攻击，但没有形成反弹。"
		return

	var damage: int = roll_effect(rng)
	if player_is_attacker and damage > 0 and bonuses.get("sickle", false):
		result["player_bonus_roll"] = roll_effect(rng)
		damage += result["player_bonus_roll"]
	_apply_attack_damage(result, player_is_attacker, damage, "攻击命中", "攻击骰高于防御骰，造成效果骰伤害。")


static func _resolve_standoff(result: Dictionary) -> void:
	result["player_defense_roll"] = -1
	result["enemy_defense_roll"] = -1
	result["event"] = "僵持"
	result["summary"] = "双方都选择防御。田野安静了一拍。"


static func _damage_for_attack(hit_roll: int, rng: RandomNumberGenerator) -> int:
	if hit_roll == HIT_MAX:
		return EFFECT_MAX
	if hit_roll == HIT_MIN:
		return 0
	return roll_effect(rng)


static func _apply_attack_damage(result: Dictionary, player_is_attacker: bool, damage: int, event: String, summary: String) -> void:
	if player_is_attacker:
		result["enemy_hp_delta"] = -damage
		result["player_effect_roll"] = damage
	else:
		result["player_hp_delta"] = -damage
		result["enemy_effect_roll"] = damage
	result["event"] = event
	result["summary"] = summary


static func _apply_reflect(result: Dictionary, attacker_is_player: bool, damage: int, event: String, summary: String) -> void:
	if attacker_is_player:
		result["enemy_hp_delta"] = -damage
	else:
		result["player_hp_delta"] = -damage
	result["event"] = event
	result["summary"] = summary
