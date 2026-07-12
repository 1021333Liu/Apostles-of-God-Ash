extends SceneTree

const SettingsStore := preload("res://scripts/card/game_settings_store.gd")
const SaveStore := preload("res://scripts/card/run_save_store.gd")
const MainScene := preload("res://scenes/card_duel_demo.tscn")


func _init() -> void:
	var expected_root := OS.get_environment("GODASH_TEST_USER_DATA").replace("\\", "/").trim_suffix("/")
	var actual_root := ProjectSettings.globalize_path("user://").replace("\\", "/").trim_suffix("/")
	if not expected_root.is_absolute_path() or not _path_is_within(actual_root, expected_root):
		push_error("Refusing to touch user:// without GODASH_TEST_USER_DATA pointing to its isolated parent directory")
		quit(2)
		return
	call_deferred("_run_checks")


func _run_checks() -> void:
	SaveStore.delete_run()
	SettingsStore.delete_settings()

	var first_save := _sample_save(9)
	if SaveStore.save_run(first_save) != OK:
		_fail("Run save should be writable")
		return
	var loaded := SaveStore.load_run()
	if int(loaded.get("player_hp", -1)) != 9 or int(loaded.get("version", -1)) != SaveStore.SAVE_VERSION:
		_fail("Run save should round-trip with a version")
		return

	var second_save := _sample_save(7)
	if SaveStore.save_run(second_save) != OK:
		_fail("Second run save should rotate a backup")
		return
	var corrupt_file := FileAccess.open(SaveStore.SAVE_PATH, FileAccess.WRITE)
	if corrupt_file == null:
		_fail("Smoke check could not create a corrupt primary save")
		return
	corrupt_file.store_string("not-json")
	corrupt_file.close()
	var recovered := SaveStore.load_run()
	if int(recovered.get("player_hp", -1)) != 9:
		_fail("Invalid primary save should recover from the previous backup")
		return
	if SaveStore.save_run(recovered) != OK:
		_fail("Recovered save should be writable as a new primary")
		return
	corrupt_file = FileAccess.open(SaveStore.SAVE_PATH, FileAccess.WRITE)
	if corrupt_file == null:
		_fail("Smoke check could not corrupt the repaired primary save")
		return
	corrupt_file.store_string("not-json-again")
	corrupt_file.close()
	var recovered_again := SaveStore.load_run()
	if int(recovered_again.get("player_hp", -1)) != 9:
		_fail("A repaired save should preserve the last known-good backup")
		return
	if SaveStore.save_run(recovered_again) != OK:
		_fail("Second recovered save should be writable")
		return

	var settings := {
		"master_volume": 0.35,
		"sfx_volume": 0.42,
		"fullscreen": false
	}
	if SettingsStore.save_settings(settings) != OK:
		_fail("Settings should be writable")
		return
	var loaded_settings := SettingsStore.load_settings()
	if not is_equal_approx(float(loaded_settings.get("master_volume", -1.0)), 0.35):
		_fail("Master volume should round-trip")
		return
	if not is_equal_approx(float(loaded_settings.get("sfx_volume", -1.0)), 0.42):
		_fail("SFX volume should round-trip")
		return
	SettingsStore.apply_settings(loaded_settings)

	var controller := MainScene.instantiate()
	root.add_child(controller)
	await process_frame
	var sfx_slider := controller.product_shell.get("_sfx_slider") as HSlider
	if sfx_slider == null or not is_equal_approx(float(sfx_slider.value), 42.0):
		_fail("Product shell should display the saved SFX volume")
		return
	for bus_name: String in ["SFX", "UI"]:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index < 0 or AudioServer.is_bus_mute(bus_index) or not is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(bus_index)), 0.42):
			_fail("%s bus should apply the saved SFX volume" % bus_name)
			return
	sfx_slider.value = 37.0
	await create_timer(0.35, true).timeout
	if not is_equal_approx(float(SettingsStore.load_settings().get("sfx_volume", -1.0)), 0.37):
		_fail("Changing the SFX slider should persist the new value")
		return
	for bus_name: String in ["SFX", "UI"]:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if AudioServer.is_bus_mute(bus_index) or not is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(bus_index)), 0.37):
			_fail("%s bus should follow the SFX slider" % bus_name)
			return
	sfx_slider.value = 0.0
	await process_frame
	for bus_name: String in ["SFX", "UI"]:
		if not AudioServer.is_bus_mute(AudioServer.get_bus_index(bus_name)):
			_fail("%s bus should mute at zero SFX volume" % bus_name)
			return
	sfx_slider.value = 42.0
	await process_frame
	if controller.product_shell == null or not controller.product_shell.is_title_open():
		_fail("Game should start on the title screen")
		return
	var focus_owner := root.gui_get_focus_owner()
	if not focus_owner is Button or (focus_owner as Button).disabled:
		_fail("Title screen should focus an enabled menu button")
		return
	var title_start_event := InputEventAction.new()
	title_start_event.action = "pause_game"
	title_start_event.pressed = true
	Input.parse_input_event(title_start_event)
	await process_frame
	if not controller.product_shell.is_title_open():
		_fail("Gamepad Start should not act as Cancel on the title screen")
		return
	if not _has_key_binding("pause_game", KEY_ESCAPE) or not _has_joy_button_binding("pause_game", JOY_BUTTON_START):
		_fail("Pause input should support Escape and gamepad Start")
		return
	if not _has_joy_button_binding("ui_accept", JOY_BUTTON_A) or not _has_joy_button_binding("ui_cancel", JOY_BUTTON_B):
		_fail("Menu input should support gamepad confirm and cancel")
		return
	var new_game_button := controller.product_shell.get("_new_game_button") as Button
	new_game_button.grab_focus()
	new_game_button.pressed.emit()
	await process_frame
	var cancel_button := controller.product_shell.get("_confirm_cancel_button") as Button
	var accept_button := controller.product_shell.get("_confirm_accept_button") as Button
	if root.gui_get_focus_owner() != cancel_button:
		_fail("Destructive confirmation should focus Cancel")
		return
	if cancel_button.get_node(cancel_button.focus_next) != accept_button or accept_button.get_node(accept_button.focus_next) != cancel_button:
		_fail("Confirmation focus should remain inside the modal")
		return
	controller.product_shell.handle_back()
	await process_frame
	if root.gui_get_focus_owner() != new_game_button:
		_fail("Canceling confirmation should restore the triggering button")
		return
	controller.call("_open_pause_menu")
	if not controller.product_shell.is_open():
		_fail("Pause shell should open")
		return
	if not paused:
		_fail("Pause shell should pause the scene tree")
		return
	var resume_event := InputEventAction.new()
	resume_event.action = "pause_game"
	resume_event.pressed = true
	Input.parse_input_event(resume_event)
	await process_frame
	if controller.product_shell.is_open() or paused:
		_fail("Pause input should resume gameplay while the tree is paused")
		return
	controller.call("_continue_saved_run")
	if int(controller.state) != 1 or int(controller.player_hp) != 9 or int(controller.player_attack_count) != 2:
		_fail("Continue should restore the encounter-entry checkpoint")
		return
	if int(controller.bonuses.get("sickle", 0)) != 1 or controller.archived_fragments.size() != 1 or controller.selected_reward_ids != ["empty_bowl"]:
		_fail("Continue should restore rewards and archive history")
		return
	controller.player_hp = 0
	controller.failed_recoveries = 1
	controller.last_failure_record = "test failure"
	controller.call("_store_failure_metadata")
	var failure_save := SaveStore.load_run()
	if int(failure_save.get("player_hp", 0)) != 9 or int(failure_save.get("failed_recoveries", 0)) != 1:
		_fail("Failure metadata should preserve entry-checkpoint health")
		return
	controller.call("_retry_current_encounter")
	if int(controller.player_hp) != 9 or int(controller.state) != 1:
		_fail("Retry should restart the same encounter from its stable checkpoint")
		return
	controller.state = 8
	controller.continue_button.visible = true
	controller.call("_toggle_archive_panel")
	controller.call("_toggle_archive_panel")
	if controller.archive_panel.visible or not controller.continue_button.visible or not controller.dialogue_panel.visible:
		_fail("Closing the archive should restore completion-state controls")
		return
	await create_timer(1.1).timeout
	root.remove_child(controller)
	controller.free()

	SaveStore.delete_run()
	SettingsStore.delete_settings()
	print("product shell storage smoke check passed")
	quit(0)


func _sample_save(player_hp: int) -> Dictionary:
	return {
		"checkpoint_kind": "encounter_start",
		"content_revision": "godash.low_whispering_field.encounters.v1",
		"encounter_index": 1,
		"encounter_id": "famine_farmer",
		"player_max_hp": 12,
		"player_hp": player_hp,
		"player_attack_count": 2,
		"bonuses": {"sickle": 1, "hat": 0},
		"archived_fragment_ids": ["field_empty_01"],
		"selected_reward_ids": ["empty_bowl"],
		"failed_recoveries": 0,
		"last_failure_record": "",
		"cutscenes_played": {},
		"chapter_complete": false
	}


func _has_key_binding(action_name: String, physical_keycode: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var key_event := event as InputEventKey
		if key_event != null and key_event.physical_keycode == physical_keycode:
			return true
	return false


func _has_joy_button_binding(action_name: String, button_index: int) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		var button_event := event as InputEventJoypadButton
		if button_event != null and button_event.button_index == button_index:
			return true
	return false


func _path_is_within(child_path: String, parent_path: String) -> bool:
	var child := child_path.to_lower()
	var parent := parent_path.to_lower()
	return child == parent or child.begins_with(parent + "/")


func _fail(message: String) -> void:
	push_error(message)
	SaveStore.delete_run()
	SettingsStore.delete_settings()
	quit(1)
