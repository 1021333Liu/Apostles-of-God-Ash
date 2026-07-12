extends SceneTree

const GameAudioScript := preload("res://scripts/card/game_audio.gd")

const REQUIRED_CUES: Array[String] = [
	"ui_focus",
	"ui_confirm",
	"ui_cancel",
	"ui_warning",
	"dialogue",
	"dice_tick",
	"dice_land",
	"dice_critical",
	"dice_fumble",
	"attack",
	"heavy",
	"guard",
	"ultimate",
	"hit",
	"block",
	"miss",
	"step",
	"intent_attack",
	"intent_defend",
	"archive",
	"room",
	"reward",
	"victory",
	"defeat"
]

var _audio_under_test: Variant


func _init() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var audio := GameAudioScript.new()
	_audio_under_test = audio
	root.add_child(audio)
	await process_frame
	if not audio.is_ready():
		_fail("Game audio should build its cached streams and player pools")
		return
	for bus_name: String in ["Music", "SFX", "UI"]:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			_fail("Missing runtime audio bus: %s" % bus_name)
			return
		if AudioServer.get_bus_send(bus_index) != "Master":
			_fail("Runtime audio bus should route to Master: %s" % bus_name)
			return
	for player: AudioStreamPlayer in audio.sfx_players:
		if player.bus != "SFX":
			_fail("SFX player should use the SFX bus")
			return
	for player: AudioStreamPlayer in audio.ui_players:
		if player.bus != "UI":
			_fail("UI player should use the UI bus")
			return
	for cue: String in REQUIRED_CUES:
		if not audio.streams.has(cue):
			_fail("Missing procedural cue: %s" % cue)
			return
		var stream := audio.streams[cue] as AudioStreamWAV
		if stream == null or stream.format != AudioStreamWAV.FORMAT_16_BITS or stream.mix_rate != 22050:
			_fail("Cue has invalid PCM format: %s" % cue)
			return
		if stream.data.size() < 512 or _sample_peak(stream.data) < 256:
			_fail("Cue is empty or effectively silent: %s" % cue)
			return
	var playback_cases: Array[Dictionary] = [
		{"cue": "ui_confirm", "ui": true, "play": func() -> void: audio.play_ui_cue("ui_confirm")},
		{"cue": "dice_tick", "play": func() -> void: audio.play_dice_tick(3, 20)},
		{"cue": "dice_critical", "play": func() -> void: audio.play_dice_result(20, 20)},
		{"cue": "dice_fumble", "play": func() -> void: audio.play_dice_result(1, 20)},
		{"cue": "dice_land", "play": func() -> void: audio.play_dice_result(3, 6)},
		{"cue": "attack", "play": func() -> void: audio.play_action(0, true)},
		{"cue": "guard", "play": func() -> void: audio.play_action(1, true)},
		{"cue": "heavy", "play": func() -> void: audio.play_action(2, true)},
		{"cue": "ultimate", "play": func() -> void: audio.play_action(3, true)},
		{"cue": "attack", "play": func() -> void: audio.play_action(1, false)},
		{"cue": "intent_attack", "play": func() -> void: audio.play_intent(true)},
		{"cue": "intent_defend", "play": func() -> void: audio.play_intent(false)},
		{"cue": "hit", "play": func() -> void: audio.play_combat_result({"enemy_hp_delta": -2, "player_hp_delta": 0, "event": "攻击命中"})},
		{"cue": "block", "play": func() -> void: audio.play_combat_result({"enemy_hp_delta": 0, "player_hp_delta": 0, "event": "防御成功"})},
		{"cue": "miss", "play": func() -> void: audio.play_combat_result({"enemy_hp_delta": 0, "player_hp_delta": 0, "event": "攻击大失败"})},
		{"cue": "step", "play": func() -> void: audio.play_step()}
	]
	for playback_case: Dictionary in playback_cases:
		audio.stop_all()
		var playback: Callable = playback_case["play"]
		playback.call()
		var pool: Array = audio.ui_players if bool(playback_case.get("ui", false)) else audio.sfx_players
		if not _pool_has_stream(pool, audio.streams[String(playback_case["cue"])]):
			_fail("Playback helper did not route cue: %s" % String(playback_case["cue"]))
			return
	playback_cases.clear()
	audio.stop_all()
	await create_timer(0.15).timeout
	for player: AudioStreamPlayer in audio.sfx_players + audio.ui_players:
		if player.playing or player.stream != null:
			_fail("stop_all should stop players and release their streams")
			return
	root.remove_child(audio)
	audio.free()
	_audio_under_test = null
	await create_timer(0.15).timeout
	print("procedural audio feedback smoke check passed")
	quit(0)


func _sample_peak(data: PackedByteArray) -> int:
	var peak := 0
	for offset: int in range(0, data.size() - 1, 2):
		peak = maxi(peak, absi(data.decode_s16(offset)))
	return peak


func _pool_has_stream(pool: Array, stream: AudioStream) -> bool:
	for player: AudioStreamPlayer in pool:
		if player.stream == stream:
			return true
	return false


func _fail(message: String) -> void:
	push_error(message)
	if _audio_under_test != null and is_instance_valid(_audio_under_test):
		_audio_under_test.stop_all()
		if _audio_under_test.get_parent() != null:
			_audio_under_test.get_parent().remove_child(_audio_under_test)
		_audio_under_test.free()
	_audio_under_test = null
	quit(1)
