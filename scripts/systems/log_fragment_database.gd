class_name LogFragmentDatabase
extends RefCounted


const DATA_PATH: String = "res://data/log_fragments/low_whispering_field.json"

var story_key: String = ""
var story_title: String = ""
var story_text: String = ""
var unlock_required: int = 0
var fragments: Array[Dictionary] = []
var fragments_by_id: Dictionary = {}
var fragments_by_enemy: Dictionary = {}


func load_from_disk(path: String = DATA_PATH) -> void:
	fragments.clear()
	fragments_by_id.clear()
	fragments_by_enemy.clear()
	story_key = ""
	story_title = ""
	story_text = ""
	unlock_required = 0

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("LogFragmentDatabase: missing data file " + path)
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		push_warning("LogFragmentDatabase: invalid JSON root in " + path)
		return

	var data := parsed as Dictionary
	story_key = String(data.get("story_key", ""))
	story_title = String(data.get("story_title", ""))
	story_text = String(data.get("story_text", ""))
	unlock_required = int(data.get("unlock_required", 0))

	var raw_fragments: Array = data.get("fragments", [])
	for item: Variant in raw_fragments:
		if not item is Dictionary:
			continue
		var fragment := (item as Dictionary).duplicate(true)
		var id := String(fragment.get("id", ""))
		var enemy := String(fragment.get("source_enemy", ""))
		if id.is_empty() or enemy.is_empty():
			continue
		fragments.append(fragment)
		fragments_by_id[id] = fragment
		if not fragments_by_enemy.has(enemy):
			fragments_by_enemy[enemy] = []
		(fragments_by_enemy[enemy] as Array).append(fragment)


func fragment_count() -> int:
	return fragments.size()


func get_fragment(id: String) -> Dictionary:
	return (fragments_by_id.get(id, {}) as Dictionary).duplicate(true)


func roll_fragment(enemy_kind: String, collected_ids: Dictionary, room_id: String = "") -> Dictionary:
	var candidates: Array = fragments_by_enemy.get(enemy_kind, [])
	var weighted: Array[Dictionary] = []
	var total_weight := 0
	for item: Variant in candidates:
		var fragment := item as Dictionary
		var id := String(fragment.get("id", ""))
		if id.is_empty() or collected_ids.has(id):
			continue
		var fragment_room := String(fragment.get("source_room", ""))
		var room_bonus := 2 if room_id.is_empty() or fragment_room == room_id else 0
		var weight: int = max(1, int(fragment.get("drop_weight", 1)) + room_bonus)
		weighted.append({"fragment": fragment, "weight": weight})
		total_weight += weight

	if weighted.is_empty():
		return {}

	var pick := randi_range(1, total_weight)
	var cursor := 0
	for entry: Dictionary in weighted:
		cursor += int(entry["weight"])
		if pick <= cursor:
			return (entry["fragment"] as Dictionary).duplicate(true)

	return (weighted.back()["fragment"] as Dictionary).duplicate(true)


func story_progress(collected_ids: Dictionary) -> Dictionary:
	var collected_story_count := 0
	for fragment: Dictionary in fragments:
		var id := String(fragment.get("id", ""))
		if collected_ids.has(id) and String(fragment.get("main_story_key", "")) == story_key:
			collected_story_count += 1
	var required: int = max(1, unlock_required)
	return {
		"key": story_key,
		"title": story_title,
		"text": story_text,
		"collected": collected_story_count,
		"required": required,
		"unlocked": collected_story_count >= required
	}
