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
