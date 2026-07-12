class_name GameSettingsStore
extends RefCounted

const SETTINGS_PATH: String = "user://settings.cfg"
const DEFAULT_MASTER_VOLUME: float = 0.8
const DEFAULT_SFX_VOLUME: float = 0.85
const DEFAULT_FULLSCREEN: bool = false


static func defaults() -> Dictionary:
	return {
		"master_volume": DEFAULT_MASTER_VOLUME,
		"sfx_volume": DEFAULT_SFX_VOLUME,
		"fullscreen": DEFAULT_FULLSCREEN
	}


static func load_settings() -> Dictionary:
	var settings := defaults()
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)
	if error != OK:
		return settings
	settings["master_volume"] = clampf(float(config.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME)), 0.0, 1.0)
	settings["sfx_volume"] = clampf(float(config.get_value("audio", "sfx_volume", DEFAULT_SFX_VOLUME)), 0.0, 1.0)
	settings["fullscreen"] = bool(config.get_value("video", "fullscreen", DEFAULT_FULLSCREEN))
	return settings


static func save_settings(settings: Dictionary) -> Error:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", clampf(float(settings.get("master_volume", DEFAULT_MASTER_VOLUME)), 0.0, 1.0))
	config.set_value("audio", "sfx_volume", clampf(float(settings.get("sfx_volume", DEFAULT_SFX_VOLUME)), 0.0, 1.0))
	config.set_value("video", "fullscreen", bool(settings.get("fullscreen", DEFAULT_FULLSCREEN)))
	return config.save(SETTINGS_PATH)


static func apply_settings(settings: Dictionary) -> void:
	var master_volume := clampf(float(settings.get("master_volume", DEFAULT_MASTER_VOLUME)), 0.0, 1.0)
	_set_bus_volume("Master", master_volume)
	var sfx_volume := clampf(float(settings.get("sfx_volume", DEFAULT_SFX_VOLUME)), 0.0, 1.0)
	_set_bus_volume("SFX", sfx_volume)
	_set_bus_volume("UI", sfx_volume)
	if DisplayServer.get_name() != "headless":
		var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if bool(settings.get("fullscreen", DEFAULT_FULLSCREEN)) else DisplayServer.WINDOW_MODE_WINDOWED
		DisplayServer.window_set_mode(mode)


static func _set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_mute(bus_index, is_zero_approx(linear_volume))
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear_volume, 0.0001)))


static func delete_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SETTINGS_PATH))
