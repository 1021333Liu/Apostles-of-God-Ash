extends SceneTree

const Dice := preload("res://scripts/card/dice_resolver.gd")


func _init() -> void:
	var scene: PackedScene = load("res://scenes/card_duel_demo.tscn")
	if scene == null:
		push_error("Failed to load card duel demo scene")
		quit(1)
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = 19
	var bonuses: Dictionary = {
		"sickle": 1,
		"hat": 1
	}
	if Dice.HIT_MIN != 1 or Dice.HIT_MAX != 20 or Dice.EFFECT_MIN != 1 or Dice.EFFECT_MAX != 3:
		push_error("Core dice should use standard D20 and D3 ranges")
		quit(1)
		return
	for seed_value: int in range(256):
		rng.seed = seed_value
		var hit_roll := Dice.roll_hit(rng)
		var effect_roll := Dice.roll_effect(rng)
		var bonus_roll := Dice.roll_bonus(rng)
		if hit_roll < 1 or hit_roll > 20:
			push_error("D20 rolled outside 1-20")
			quit(1)
			return
		if effect_roll < 1 or effect_roll > 3:
			push_error("D3 damage rolled outside 1-3")
			quit(1)
			return
		if bonus_roll < 0 or bonus_roll > 3:
			push_error("Bonus roll should remain within 0-3")
			quit(1)
			return
	for i: int in 20:
		var result: Dictionary
		match i % 4:
			0:
				result = Dice.resolve_player_action(Dice.Action.ATTACK, rng, bonuses)
			1:
				result = Dice.resolve_player_action(Dice.Action.HEAVY, rng, bonuses)
			2:
				result = Dice.resolve_enemy_attack(rng, bonuses, true)
			_:
				result = Dice.resolve_player_action(Dice.Action.ULTIMATE, rng, bonuses, true)
		if not result.has("event") or str(result["event"]).is_empty():
			push_error("Missing event in card duel result")
			quit(1)
			return
		if not result.has("summary") or str(result["summary"]).is_empty():
			push_error("Missing summary in card duel result")
			quit(1)
			return
	for seed_value: int in range(200):
		rng.seed = seed_value
		var unguarded := Dice.resolve_enemy_attack(rng, {}, false)
		if int(unguarded["player_defense_roll"]) >= int(unguarded["enemy_hit_roll"]):
			if int(unguarded["player_hp_delta"]) != 0:
				push_error("Successful automatic defense should not damage player")
				quit(1)
				return
			if int(unguarded["enemy_hp_delta"]) != 0:
				push_error("Unguarded automatic defense should not reflect")
				quit(1)
				return
		rng.seed = seed_value
		var guarded := Dice.resolve_enemy_attack(rng, {}, true)
		var best_defense: int = maxi(int(guarded["player_defense_roll"]), int(guarded["player_defense_roll_2"]))
		if best_defense >= int(guarded["enemy_hit_roll"]):
			if int(guarded["player_hp_delta"]) != 0:
				push_error("Charged guard success should not damage player")
				quit(1)
				return
			if int(guarded["enemy_hp_delta"]) > 0:
				push_error("Charged guard reflect should not heal enemy")
				quit(1)
				return
	var defended := Dice.resolve_enemy_action(Dice.Action.DEFEND, rng, {}, true)
	if int(defended["player_hp_delta"]) != 0 or int(defended["enemy_hp_delta"]) != 0:
		push_error("Enemy defend intent should not change HP")
		quit(1)
		return
	if int(defended["player_defense_roll"]) != -1 or int(defended["enemy_hit_roll"]) != -1:
		push_error("Enemy defend intent should not roll dice")
		quit(1)
		return
	if bool(defended.get("player_active", true)):
		push_error("Enemy defend intent should not present a player action")
		quit(1)
		return
	if String(defended["event"]) != "敌方防御":
		push_error("Enemy defend result should use enemy-facing terminology")
		quit(1)
		return
	for seed_value: int in range(96):
		rng.seed = seed_value
		var guarded_attack := Dice.resolve_player_action(Dice.Action.ATTACK, rng, {}, false, true)
		var attack_roll := int(guarded_attack["player_hit_roll"])
		var first_guard_roll := int(guarded_attack["enemy_defense_roll"])
		var second_guard_roll := int(guarded_attack["enemy_defense_roll_2"])
		var best_guard_roll := maxi(first_guard_roll, second_guard_roll)
		if not bool(guarded_attack.get("enemy_guarded", false)) or second_guard_roll < 1:
			push_error("Enemy defend intent should give normal attacks two defense dice")
			quit(1)
			return
		var attack_should_fail := best_guard_roll >= Dice.HIT_MAX or attack_roll == Dice.HIT_MIN or (attack_roll != Dice.HIT_MAX and attack_roll <= best_guard_roll)
		if attack_should_fail and int(guarded_attack["enemy_hp_delta"]) != 0:
			push_error("Enemy guard should use the higher defense die")
			quit(1)
			return
		if not attack_should_fail and int(guarded_attack["enemy_hp_delta"]) >= 0:
			push_error("A normal attack above both guard dice should deal damage")
			quit(1)
			return
		rng.seed = seed_value
		var guarded_heavy := Dice.resolve_player_action(Dice.Action.HEAVY, rng, {}, false, true)
		if int(guarded_heavy["enemy_defense_roll_2"]) != -1:
			push_error("Heavy attacks should ignore the enemy guard's extra die")
			quit(1)
			return
	rng.seed = 27
	var guarded_ultimate := Dice.resolve_player_action(Dice.Action.ULTIMATE, rng, {}, true, true)
	if int(guarded_ultimate["enemy_defense_roll"]) != -1 or int(guarded_ultimate["enemy_defense_roll_2"]) != -1 or int(guarded_ultimate["enemy_hp_delta"]) >= 0:
		push_error("Ultimate should bypass enemy guard")
		quit(1)
		return
	var demo := scene.instantiate()
	root.add_child(demo)
	await process_frame
	var original_encounter: Dictionary = demo.current_encounter
	demo.current_encounter = {"intent_pattern": ["attack", "defend", "attack"]}
	demo.enemy_intent_index = 0
	if demo._current_enemy_action() != Dice.Action.ATTACK:
		push_error("Intent sequence should start with attack")
		quit(1)
		return
	var forecast: String = demo._intent_forecast_text()
	if not forecast.contains("本轮：攻击") or not forecast.contains("下轮：防御"):
		push_error("Intent forecast should show both current and next actions")
		quit(1)
		return
	demo.turn_index = 1
	if demo._current_enemy_action() != Dice.Action.ATTACK:
		push_error("Player and enemy half-turns should share one intent")
		quit(1)
		return
	demo.enemy_intent_index = 1
	if demo._current_enemy_action() != Dice.Action.DEFEND:
		push_error("Intent sequence should advance to defend exactly once")
		quit(1)
		return
	demo.enemy_intent_index = 3
	if demo._current_enemy_action() != Dice.Action.ATTACK:
		push_error("Intent sequence should loop for odd-length patterns")
		quit(1)
		return
	demo.turn_index = 0
	demo.enemy_intent_index = 0
	demo._advance_turn_counters(false)
	if demo.turn_index != 1 or demo.enemy_intent_index != 0:
		push_error("Player half-turn should not advance enemy intent")
		quit(1)
		return
	demo._advance_turn_counters(true)
	if demo.turn_index != 2 or demo.enemy_intent_index != 1:
		push_error("Enemy half-turn should advance intent exactly once")
		quit(1)
		return
	demo.player_guard_charged = true
	demo._consume_player_guard_for_enemy_action(Dice.Action.DEFEND)
	if not demo.player_guard_charged:
		push_error("Enemy defend intent should preserve charged guard")
		quit(1)
		return
	demo._consume_player_guard_for_enemy_action(Dice.Action.ATTACK)
	if demo.player_guard_charged:
		push_error("Enemy attack intent should consume charged guard")
		quit(1)
		return
	demo.player_guard_charged = true
	demo.player_attack_count = 2
	var combat_resources: String = demo._combat_resource_text()
	if not combat_resources.contains("蓄防 就绪") or not combat_resources.contains("■■□"):
		push_error("HUD should expose charged guard and ultimate progress")
		quit(1)
		return
	demo._set_action_buttons_enabled(true)
	if not demo.defend_button.disabled:
		push_error("Charged guard should disable redundant guard selection")
		quit(1)
		return
	demo.player_guard_charged = false
	demo.player_attack_count = 0
	var walk_frames: Array = demo._get_actor_frames("player", "walk")
	if walk_frames.is_empty():
		push_error("Player walk presentation requires an existing source frame")
		quit(1)
		return
	demo.actor_pose["player"] = "walk"
	demo.actor_frame_index["player"] = walk_frames.size() - 1
	var expected_walk_order: Array[int] = [0, 1, 2, 4, 5]
	for walk_step: int in range(expected_walk_order.size()):
		demo.field_walk_phase = TAU * float(walk_step) / float(expected_walk_order.size()) + 0.001
		demo._update_field_positions()
		if demo.field_player_sprite.texture != walk_frames[expected_walk_order[walk_step]]:
			push_error("Field walk should use the curated frame order and skip the unstable pose")
			quit(1)
			return
	demo.actor_pose["player"] = "idle"
	demo.field_walk_phase = 0.0
	demo._update_field_positions()
	demo.current_encounter = original_encounter
	demo.turn_index = 0
	demo.enemy_intent_index = 0
	var hover_overlay := demo.action_card_overlays.get("attack", {}).get("hover", null) as NinePatchRect
	var selected_overlay := demo.action_card_overlays.get("attack", {}).get("selected", null) as NinePatchRect
	if hover_overlay == null or hover_overlay.texture == null or selected_overlay == null or selected_overlay.texture == null:
		push_error("Action cards should load hover and selected frame textures")
		quit(1)
		return
	var cached_texture_a: Texture2D = demo._load_texture("res://assets/card_demo/ui/cards/card_selected_frame.png")
	var cached_texture_b: Texture2D = demo._load_texture("res://assets/card_demo/ui/cards/card_selected_frame.png")
	if cached_texture_a == null or cached_texture_a != cached_texture_b:
		push_error("Texture loader should reuse cached textures")
		quit(1)
		return
	demo._on_continue_pressed()
	await process_frame
	if demo.player_hp < 0 or demo.enemy_hp < 0:
		push_error("Card duel demo produced negative HP")
		quit(1)
		return
	if demo.game_audio != null:
		demo.game_audio.stop_all()
	root.remove_child(demo)
	demo.free()
	await create_timer(0.15).timeout
	print("card duel rules and scene smoke check passed")
	quit(0)
