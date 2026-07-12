class_name GameAudio
extends Node

const AudioBank := preload("res://scripts/card/procedural_audio_bank.gd")
const SFX_POOL_SIZE: int = 8
const UI_POOL_SIZE: int = 4
const INTENT_REPEAT_GUARD_MSEC: int = 550

var streams: Dictionary = {}
var sfx_players: Array[AudioStreamPlayer] = []
var ui_players: Array[AudioStreamPlayer] = []
var sfx_pool_index: int = 0
var ui_pool_index: int = 0
var last_ui_focus_msec: int = -1000
var last_intent_msec: int = -1000
var last_intent_is_attack: bool = false
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	rng.randomize()
	_ensure_audio_buses()
	streams = AudioBank.build()
	sfx_players = _build_pool("SFX", SFX_POOL_SIZE)
	ui_players = _build_pool("UI", UI_POOL_SIZE)


func _exit_tree() -> void:
	stop_all()


func is_ready() -> bool:
	return not streams.is_empty() and sfx_players.size() == SFX_POOL_SIZE and ui_players.size() == UI_POOL_SIZE


func stream_names() -> Array:
	return streams.keys()


func stream_sample_count(cue: String) -> int:
	var stream := streams.get(cue) as AudioStreamWAV
	if stream == null:
		return 0
	return stream.data.size() / 2


func play_ui_cue(cue: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if cue == "ui_focus":
		var now := Time.get_ticks_msec()
		if now - last_ui_focus_msec < 48:
			return
		last_ui_focus_msec = now
	_play_from_pool(ui_players, cue, volume_db, pitch_scale, true)


func play_sfx(cue: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	_play_from_pool(sfx_players, cue, volume_db, pitch_scale, false)


func play_dice_tick(tick_index: int, sides: int) -> void:
	var pitch := 0.88 + float(tick_index) * 0.035 + (0.04 if sides >= 20 else 0.0)
	play_sfx("dice_tick", -4.0, pitch)


func play_dice_result(final_value: int, sides: int) -> void:
	if sides == 20 and final_value == 20:
		play_sfx("dice_critical", -1.0)
	elif sides == 20 and final_value == 1:
		play_sfx("dice_fumble", -1.0)
	else:
		play_sfx("dice_land", -2.0, rng.randf_range(0.94, 1.06))


func play_action(action: int, player_active: bool = true) -> void:
	if not player_active:
		play_sfx("attack", -4.0, 0.78)
		return
	match action:
		0:
			play_sfx("attack", -3.0, rng.randf_range(0.96, 1.04))
		1:
			play_sfx("guard", -3.0)
		2:
			play_sfx("heavy", -2.0)
		3:
			play_sfx("ultimate", -1.0)


func play_combat_result(result: Dictionary) -> void:
	var player_delta := int(result.get("player_hp_delta", 0))
	var enemy_delta := int(result.get("enemy_hp_delta", 0))
	var event_text := String(result.get("event", ""))
	if event_text in ["蓄防", "敌方防御"]:
		return
	if player_delta < 0 or enemy_delta < 0:
		play_sfx("hit", -1.0, rng.randf_range(0.92, 1.05))
	elif event_text.contains("防御") or event_text.contains("反弹"):
		play_sfx("block", -2.0, rng.randf_range(0.96, 1.04))
	else:
		play_sfx("miss", -4.0, rng.randf_range(0.94, 1.06))


func play_step() -> void:
	play_sfx("step", -8.0, rng.randf_range(0.90, 1.10))


func play_intent(is_attack: bool) -> void:
	var now := Time.get_ticks_msec()
	if is_attack == last_intent_is_attack and now - last_intent_msec < INTENT_REPEAT_GUARD_MSEC:
		return
	last_intent_is_attack = is_attack
	last_intent_msec = now
	play_sfx("intent_attack" if is_attack else "intent_defend", -6.0)


func stop_all() -> void:
	for player: AudioStreamPlayer in sfx_players + ui_players:
		player.stop()
		player.stream = null


func _ensure_audio_buses() -> void:
	_ensure_bus("Music", "Master")
	_ensure_bus("SFX", "Master")
	_ensure_bus("UI", "Master")


func _ensure_bus(bus_name: String, send_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var index := AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, send_name)


func _build_pool(bus_name: String, pool_size: int) -> Array[AudioStreamPlayer]:
	var pool: Array[AudioStreamPlayer] = []
	for i: int in range(pool_size):
		var player := AudioStreamPlayer.new()
		player.name = "%sPlayer%02d" % [bus_name, i]
		player.bus = bus_name
		add_child(player)
		pool.append(player)
	return pool


func _play_from_pool(pool: Array[AudioStreamPlayer], cue: String, volume_db: float, pitch_scale: float, is_ui: bool) -> void:
	var stream := streams.get(cue) as AudioStreamWAV
	if stream == null or pool.is_empty():
		return
	var start_index := ui_pool_index if is_ui else sfx_pool_index
	var selected_index := start_index
	for offset: int in range(pool.size()):
		var candidate := (start_index + offset) % pool.size()
		if not pool[candidate].playing:
			selected_index = candidate
			break
	var player := pool[selected_index]
	player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = clampf(pitch_scale, 0.55, 1.65)
	player.play()
	if is_ui:
		ui_pool_index = (selected_index + 1) % pool.size()
	else:
		sfx_pool_index = (selected_index + 1) % pool.size()
