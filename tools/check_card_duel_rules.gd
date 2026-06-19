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
		"sickle": false,
		"hat": false
	}
	for i: int in 20:
		var player_action: int = Dice.Action.ATTACK if i % 2 == 0 else Dice.Action.DEFEND
		var enemy_action: int = Dice.Action.DEFEND if i % 3 == 0 else Dice.Action.ATTACK
		var result: Dictionary = Dice.resolve_exchange(player_action, enemy_action, rng, bonuses)
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
	for i: int in 8:
		if demo.state != demo.DuelState.PLAYER_CHOICE:
			break
		var action: int = Dice.Action.ATTACK if i % 2 == 0 else Dice.Action.DEFEND
		demo._choose_action(action)
		await process_frame
	if demo.player_hp < 0 or demo.farmer_hp < 0:
		push_error("Card duel demo produced negative HP")
		quit(1)
		return
	print("card duel rules and scene smoke check passed")
	quit(0)
