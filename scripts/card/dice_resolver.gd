class_name DiceResolver
extends RefCounted

const HIT_MIN: int = 0
const HIT_MAX: int = 20
const EFFECT_MIN: int = 0
const EFFECT_MAX: int = 3
const ULTIMATE_MAX: int = 6
const REFLECT_MARGIN: int = 5

enum Action { ATTACK, DEFEND, HEAVY, ULTIMATE }


static func roll_hit(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(HIT_MIN, HIT_MAX)


static func roll_effect(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(EFFECT_MIN, EFFECT_MAX)


static func roll_heal(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(1, EFFECT_MAX)


static func roll_ultimate(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(1, ULTIMATE_MAX)


static func resolve_player_action(player_action: Action, rng: RandomNumberGenerator, bonuses: Dictionary, ultimate_ready: bool = false) -> Dictionary:
	var result := _base_result(player_action, Action.DEFEND)
	if player_action == Action.DEFEND:
		result["event"] = "蓄防"
		result["summary"] = "你放弃本次攻击，把残片收回身前。下一次防御骰会投两次，取最高值。"
		result["player_guarded"] = true
	elif player_action == Action.ULTIMATE:
		_resolve_ultimate(result, rng, ultimate_ready)
	elif player_action == Action.HEAVY:
		_resolve_player_attack(result, rng, bonuses, true)
	else:
		_resolve_player_attack(result, rng, bonuses, false)
	return result


static func resolve_enemy_attack(rng: RandomNumberGenerator, bonuses: Dictionary, player_guarded: bool = false) -> Dictionary:
	var result := _base_result(Action.DEFEND, Action.ATTACK)
	result["player_guarded"] = player_guarded
	_resolve_enemy_attack(result, rng, bonuses, player_guarded)
	return result


static func resolve_exchange(player_action: Action, enemy_action: Action, rng: RandomNumberGenerator, bonuses: Dictionary) -> Dictionary:
	var result := _base_result(player_action, enemy_action)

	if player_action == Action.ATTACK and enemy_action == Action.ATTACK:
		_resolve_attack_vs_attack(result, rng, bonuses)
	elif player_action in [Action.ATTACK, Action.HEAVY] and enemy_action == Action.DEFEND:
		_resolve_player_attack(result, rng, bonuses, player_action == Action.HEAVY)
	elif player_action == Action.DEFEND and enemy_action == Action.ATTACK:
		_resolve_enemy_attack(result, rng, bonuses, false)
	else:
		_resolve_standoff(result)

	return result


static func _base_result(player_action: Action, enemy_action: Action) -> Dictionary:
	return {
		"player_action": player_action,
		"enemy_action": enemy_action,
		"player_hp_delta": 0,
		"enemy_hp_delta": 0,
		"player_hit_roll": -1,
		"player_defense_roll": -1,
		"player_defense_roll_2": -1,
		"player_effect_roll": -1,
		"player_effect_sides": EFFECT_MAX,
		"player_bonus_roll": -1,
		"player_bonus_rolls": [],
		"player_guarded": false,
		"enemy_hit_roll": -1,
		"enemy_defense_roll": -1,
		"enemy_effect_roll": -1,
		"enemy_effect_sides": EFFECT_MAX,
		"event": "",
		"summary": ""
	}


static func _resolve_player_attack(result: Dictionary, rng: RandomNumberGenerator, bonuses: Dictionary, heavy: bool) -> void:
	var attack_roll: int = roll_hit(rng)
	var defense_roll: int = roll_hit(rng)
	result["player_hit_roll"] = attack_roll
	result["enemy_defense_roll"] = defense_roll

	if defense_roll >= HIT_MAX:
		result["event"] = "防御封死"
		result["summary"] = "对方防御骰掷出 20，这次攻击被完全封住。"
		return

	if attack_roll == HIT_MIN:
		result["event"] = "攻击大失败"
		result["summary"] = "攻击骰掷出 0，动作失去意义。"
		return

	if attack_roll == HIT_MAX:
		result["player_effect_roll"] = EFFECT_MAX
		var critical_damage := EFFECT_MAX * (2 if heavy else 1)
		critical_damage += _apply_bonus_rolls(result, rng, int(bonuses.get("sickle", 0)))
		_apply_attack_damage(result, true, critical_damage, "攻击大成功", "攻击骰掷出 20，直接撕开防线。")
		return

	if heavy:
		if attack_roll < defense_roll + REFLECT_MARGIN:
			result["event"] = "重击落空"
			result["summary"] = "重击需要攻击骰比防御骰高 5 点以上，本次没有压过防线。"
			return
		var heavy_damage := roll_effect(rng)
		result["player_effect_roll"] = heavy_damage
		var total_heavy_damage := heavy_damage * 2
		if total_heavy_damage > 0:
			total_heavy_damage += _apply_bonus_rolls(result, rng, int(bonuses.get("sickle", 0)))
		_apply_attack_damage(result, true, total_heavy_damage, "重击命中", "攻击骰高出防御 5 点以上，伤害骰翻倍。")
		return

	if attack_roll <= defense_roll:
		result["event"] = "防御成功"
		result["summary"] = "对方防御骰挡住了你的攻击。"
		return

	var damage: int = roll_effect(rng)
	result["player_effect_roll"] = damage
	if damage > 0:
		damage += _apply_bonus_rolls(result, rng, int(bonuses.get("sickle", 0)))
	_apply_attack_damage(result, true, damage, "攻击命中", "攻击骰高于防御骰，造成效果骰伤害。")


static func _resolve_enemy_attack(result: Dictionary, rng: RandomNumberGenerator, bonuses: Dictionary, player_guarded: bool) -> void:
	var attack_roll: int = roll_hit(rng)
	var defense_roll: int = roll_hit(rng)
	result["enemy_hit_roll"] = attack_roll
	result["player_defense_roll"] = defense_roll
	if player_guarded:
		var second_defense_roll := roll_hit(rng)
		result["player_defense_roll_2"] = second_defense_roll
		defense_roll = maxi(defense_roll, second_defense_roll)
	defense_roll += _apply_bonus_rolls(result, rng, int(bonuses.get("hat", 0)))
	if attack_roll == HIT_MIN:
		result["event"] = "敌人失手"
		result["summary"] = "对方攻击骰为 0，攻击落空。"
		return
	if defense_roll >= attack_roll:
		if player_guarded:
			var reflect_damage: int = EFFECT_MAX if defense_roll >= HIT_MAX else roll_effect(rng)
			result["player_effect_roll"] = reflect_damage
			_apply_reflect(result, false, reflect_damage, "防御反弹", "蓄防生效：防御成功后反弹伤害。")
		else:
			result["event"] = "防御成功"
			result["summary"] = "你的防御骰挡住了攻击，本次没有受到伤害。"
		return

	if defense_roll >= HIT_MAX:
		_apply_reflect(result, false, EFFECT_MAX, "完美防御", "你的防御骰达到 20，攻击被完全封住并触发反弹。")
		return

	if attack_roll == HIT_MAX:
		_apply_attack_damage(result, false, EFFECT_MAX, "敌人大成功", "对方攻击骰掷出 20，普通防御无法抵挡。")
		return

	if attack_roll == HIT_MIN:
		result["event"] = "敌人大失败"
		result["summary"] = "对方攻击骰掷出 0，攻击落空。"
		return

	if defense_roll >= attack_roll + REFLECT_MARGIN:
		var reflect_damage: int = roll_effect(rng)
		_apply_reflect(result, false, reflect_damage, "防御反弹", "你的防御高出攻击 5 点以上，触发反弹。")
		return

	if defense_roll >= attack_roll:
		result["event"] = "防御成功"
		result["summary"] = "你挡住了这次攻击，但没有形成反弹。"
		return

	var damage: int = roll_effect(rng)
	_apply_attack_damage(result, false, damage, "受到攻击", "对方攻击骰高于你的防御骰，造成效果骰伤害。")


static func _resolve_ultimate(result: Dictionary, rng: RandomNumberGenerator, ultimate_ready: bool) -> void:
	if not ultimate_ready:
		result["event"] = "大招未就绪"
		result["summary"] = "攻击样本还不够，至少需要完成三次攻击选择。"
		return
	var damage := roll_ultimate(rng)
	result["player_effect_roll"] = damage
	result["player_effect_sides"] = ULTIMATE_MAX
	_apply_attack_damage(result, true, damage, "大招释放", "无视防御，直接造成 D6 伤害。")


static func _resolve_attack_vs_attack(result: Dictionary, rng: RandomNumberGenerator, bonuses: Dictionary) -> void:
	result["player_hit_roll"] = roll_hit(rng)
	result["enemy_hit_roll"] = roll_hit(rng)

	var player_damage: int = _damage_for_attack(result["player_hit_roll"], rng)
	var enemy_damage: int = _damage_for_attack(result["enemy_hit_roll"], rng)

	if player_damage > 0:
		player_damage += _apply_bonus_rolls(result, rng, int(bonuses.get("sickle", 0)))

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
		defense_roll += _apply_bonus_rolls(result, rng, int(bonuses.get("hat", 0)))

	if defense_roll >= HIT_MAX:
		_apply_reflect(result, player_is_attacker, EFFECT_MAX, "完美防御", "防御骰掷出 20，攻击被完全封住并触发反弹。")
		return

	if attack_roll == HIT_MAX:
		var critical_damage := EFFECT_MAX
		if player_is_attacker:
			critical_damage += _apply_bonus_rolls(result, rng, int(bonuses.get("sickle", 0)))
		_apply_attack_damage(result, player_is_attacker, critical_damage, "攻击大成功", "攻击骰掷出 20，普通防御无法抵挡。")
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
	if player_is_attacker and damage > 0:
		damage += _apply_bonus_rolls(result, rng, int(bonuses.get("sickle", 0)))
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
		if int(result.get("player_effect_roll", -1)) < 0:
			result["player_effect_roll"] = damage
	else:
		result["player_hp_delta"] = -damage
		if int(result.get("enemy_effect_roll", -1)) < 0:
			result["enemy_effect_roll"] = damage
	result["event"] = event
	result["summary"] = summary


static func _apply_reflect(result: Dictionary, attacker_is_player: bool, damage: int, event: String, summary: String) -> void:
	if attacker_is_player:
		result["player_hp_delta"] = -damage
	else:
		result["enemy_hp_delta"] = -damage
	result["event"] = event
	result["summary"] = summary


static func _apply_bonus_rolls(result: Dictionary, rng: RandomNumberGenerator, count: int) -> int:
	var total := 0
	var rolls: Array = result.get("player_bonus_rolls", [])
	for i: int in range(maxi(count, 0)):
		var roll := roll_effect(rng)
		rolls.append(roll)
		total += roll
	result["player_bonus_rolls"] = rolls
	var visible_total := 0
	for roll: Variant in rolls:
		visible_total += int(roll)
	result["player_bonus_roll"] = visible_total if not rolls.is_empty() else -1
	return total
