class_name LogArchiveRuntime
extends RefCounted


var database: RefCounted
var collected_ids: Dictionary = {}
var collected_fragments: Array[Dictionary] = []
var run_fragments: Array[Dictionary] = []
var total_kill_samples: int = 0


func configure(source_database: RefCounted) -> void:
	database = source_database


func reset_run() -> void:
	run_fragments.clear()
	total_kill_samples = 0


func try_collect_from_kill(enemy_kind: String, room_id: String = "") -> Dictionary:
	total_kill_samples += 1
	if database == null:
		return {}

	var fragment: Dictionary = database.call("roll_fragment", enemy_kind, collected_ids, room_id)
	if fragment.is_empty():
		return {}

	var id := String(fragment.get("id", ""))
	if id.is_empty() or collected_ids.has(id):
		return {}

	collected_ids[id] = true
	collected_fragments.append(fragment)
	run_fragments.append(fragment)
	return fragment.duplicate(true)


func collected_count() -> int:
	return collected_fragments.size()


func run_count() -> int:
	return run_fragments.size()


func latest_fragment() -> Dictionary:
	if collected_fragments.is_empty():
		return {}
	return collected_fragments.back().duplicate(true)


func story_progress() -> Dictionary:
	if database == null:
		return {"title": "", "text": "", "collected": 0, "required": 1, "unlocked": false}
	return database.call("story_progress", collected_ids)


func archive_summary(max_items: int = 3) -> String:
	var progress := story_progress()
	var lines: Array[String] = [
		"圣匣日志：" + str(collected_count()) + " / " + str(database.call("fragment_count") if database != null else 0),
		"主线拼图：" + str(progress["collected"]) + "/" + str(progress["required"])
	]
	if bool(progress["unlocked"]):
		lines.append("已解锁：" + String(progress["title"]))
	elif collected_fragments.is_empty():
		lines.append("建议：进入田野，采回第一份胃囊反应。")
	else:
		lines.append("继续采样：谷仓王的胃仍缺证词。")

	var start: int = maxi(0, collected_fragments.size() - max_items)
	for i in range(start, collected_fragments.size()):
		var fragment := collected_fragments[i]
		lines.append("[" + String(fragment.get("rarity", "common")) + "] " + String(fragment.get("title", "")) + " / " + _enemy_label(String(fragment.get("source_enemy", ""))))

	return "\n".join(lines)


func latest_sample_text(fragment: Dictionary) -> String:
	if fragment.is_empty():
		return "日志碎片：未归档"
	return "样本归档：" + String(fragment.get("title", "")) + "\n" + String(fragment.get("text", ""))


func sanctum_detail_text(death_count: int, last_death_note: String) -> String:
	var progress := story_progress()
	var lines: Array[String] = [
		"活器官档案柜 | 低语田野",
		"碎片：" + str(collected_count()) + " 份 | 本轮：" + str(run_count()) + " 份",
		"主线：" + str(progress["collected"]) + "/" + str(progress["required"]) + " " + ("已拼合" if bool(progress["unlocked"]) else "待补证")
	]

	if death_count > 0:
		lines.append("失败样本：" + str(death_count) + " | 最近死因：" + last_death_note)

	var latest := latest_fragment()
	if latest.is_empty():
		lines.append("空槽：尚未采回可归档记忆。")
	else:
		lines.append("最新：" + String(latest.get("title", "")) + " / " + _enemy_label(String(latest.get("source_enemy", ""))))
		lines.append(String(latest.get("stomach_reaction", "")))

	if bool(progress["unlocked"]):
		lines.append("故事：" + String(progress["text"]))

	return "\n".join(lines)


func _enemy_label(kind: String) -> String:
	match kind:
		"empty":
			return "空腹者"
		"farmer":
			return "饥民农夫"
		"scarecrow":
			return "饥饿稻草人"
		"barn_king":
			return "谷仓王"
		_:
			return kind
