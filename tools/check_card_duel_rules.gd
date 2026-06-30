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
	var demo := scene.instantiate()
	root.add_child(demo)
	await process_frame
	demo._on_continue_pressed()
	await process_frame
	if demo.player_hp < 0 or demo.enemy_hp < 0:
		push_error("Card duel demo produced negative HP")
		quit(1)
		return
	print("card duel rules and scene smoke check passed")
	quit(0)
