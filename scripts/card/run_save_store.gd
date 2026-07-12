class_name RunSaveStore
extends RefCounted

const SAVE_VERSION: int = 1
const SAVE_PATH: String = "user://run_save.json"
const BACKUP_PATH: String = "user://run_save.backup.json"
const TEMP_PATH: String = "user://run_save.tmp.json"


static func save_run(run_data: Dictionary) -> Error:
	var payload := run_data.duplicate(true)
	payload["version"] = SAVE_VERSION
	payload["saved_at"] = int(Time.get_unix_time_from_system())

	var user_dir_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://"))
	if user_dir_error != OK:
		push_error("RunSaveStore: cannot create user directory (%d)" % user_dir_error)
		return user_dir_error

	var file := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
	if file == null:
		var open_error := FileAccess.get_open_error()
		push_error("RunSaveStore: cannot open temporary save (%d)" % open_error)
		return open_error
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	file.close()

	var save_absolute := ProjectSettings.globalize_path(SAVE_PATH)
	var backup_absolute := ProjectSettings.globalize_path(BACKUP_PATH)
	var temp_absolute := ProjectSettings.globalize_path(TEMP_PATH)
	var primary_exists := FileAccess.file_exists(SAVE_PATH)
	var primary_is_valid := primary_exists and not _load_path(SAVE_PATH, false).is_empty()
	var primary_rotated := false
	if FileAccess.file_exists(SAVE_PATH):
		if primary_is_valid:
			if FileAccess.file_exists(BACKUP_PATH):
				var remove_backup_error := DirAccess.remove_absolute(backup_absolute)
				if remove_backup_error != OK:
					push_error("RunSaveStore: cannot replace save backup (%d)" % remove_backup_error)
					return remove_backup_error
			var backup_error := DirAccess.rename_absolute(save_absolute, backup_absolute)
			if backup_error != OK:
				push_error("RunSaveStore: cannot rotate save backup (%d)" % backup_error)
				return backup_error
			primary_rotated = true
		else:
			var remove_primary_error := DirAccess.remove_absolute(save_absolute)
			if remove_primary_error != OK:
				push_error("RunSaveStore: cannot remove invalid primary save (%d)" % remove_primary_error)
				return remove_primary_error

	var replace_error := DirAccess.rename_absolute(temp_absolute, save_absolute)
	if replace_error != OK:
		push_error("RunSaveStore: cannot replace save (%d)" % replace_error)
		if primary_rotated and FileAccess.file_exists(BACKUP_PATH) and not FileAccess.file_exists(SAVE_PATH):
			DirAccess.rename_absolute(backup_absolute, save_absolute)
		return replace_error
	return OK


static func load_run() -> Dictionary:
	var payload := _load_path(SAVE_PATH)
	if not payload.is_empty():
		return payload
	return _load_path(BACKUP_PATH)


static func has_resumable_save() -> bool:
	var payload := load_run()
	return not payload.is_empty() and not bool(payload.get("chapter_complete", false))


static func has_any_run_file() -> bool:
	for path: String in [SAVE_PATH, BACKUP_PATH, TEMP_PATH]:
		if FileAccess.file_exists(path):
			return true
	return false


static func delete_run() -> Error:
	var first_error: Error = OK
	for path: String in [SAVE_PATH, BACKUP_PATH, TEMP_PATH]:
		if FileAccess.file_exists(path):
			var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			if error != OK and first_error == OK:
				first_error = error
	return first_error


static func _load_path(path: String, report_warning: bool = true) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		if report_warning:
			push_warning("RunSaveStore: cannot read %s" % path)
		return {}
	var file_text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var parse_error := json.parse(file_text)
	if parse_error != OK:
		if report_warning:
			push_warning("RunSaveStore: invalid JSON in %s" % path)
		return {}
	var parsed: Variant = json.data
	if not parsed is Dictionary:
		if report_warning:
			push_warning("RunSaveStore: save root is not a dictionary in %s" % path)
		return {}
	return _migrate_and_validate(parsed as Dictionary, report_warning)


static func _migrate_and_validate(raw_payload: Dictionary, report_warning: bool = true) -> Dictionary:
	var version := int(raw_payload.get("version", 0))
	if version != SAVE_VERSION:
		if report_warning:
			push_warning("RunSaveStore: unsupported save version %d" % version)
		return {}
	for required_key: String in [
		"checkpoint_kind",
		"content_revision",
		"encounter_index",
		"encounter_id",
		"player_max_hp",
		"player_hp",
		"player_attack_count",
		"bonuses",
		"archived_fragment_ids",
		"selected_reward_ids",
		"failed_recoveries",
		"last_failure_record",
		"cutscenes_played",
		"chapter_complete"
	]:
		if not raw_payload.has(required_key):
			if report_warning:
				push_warning("RunSaveStore: missing key %s" % required_key)
			return {}
	if String(raw_payload.get("checkpoint_kind", "")) != "encounter_start":
		if report_warning:
			push_warning("RunSaveStore: unsupported checkpoint kind")
		return {}
	if String(raw_payload.get("content_revision", "")).is_empty() or String(raw_payload.get("encounter_id", "")).is_empty():
		if report_warning:
			push_warning("RunSaveStore: missing checkpoint identity")
		return {}
	var max_hp := int(raw_payload.get("player_max_hp", 0))
	var hp := int(raw_payload.get("player_hp", 0))
	if max_hp < 1 or hp < 1 or hp > max_hp:
		if report_warning:
			push_warning("RunSaveStore: invalid player health")
		return {}
	if not raw_payload.get("bonuses") is Dictionary or not raw_payload.get("cutscenes_played") is Dictionary:
		if report_warning:
			push_warning("RunSaveStore: invalid dictionary payload")
		return {}
	if not raw_payload.get("archived_fragment_ids") is Array or not raw_payload.get("selected_reward_ids") is Array:
		if report_warning:
			push_warning("RunSaveStore: invalid history payload")
		return {}
	return raw_payload.duplicate(true)
