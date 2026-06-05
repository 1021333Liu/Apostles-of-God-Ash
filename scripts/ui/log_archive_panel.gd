class_name LogArchivePanel
extends RefCounted


static func compact_sample(fragment: Dictionary, fallback_note: String) -> String:
	if fragment.is_empty():
		return fallback_note
	return "样本归档：" + String(fragment.get("title", "")) + "\n" + String(fragment.get("text", ""))


static func compact_sanctum(archive: RefCounted, death_count: int, last_death_note: String) -> String:
	if archive == null:
		if death_count <= 0:
			return "圣匣档案：暂无失败样本\n建议：进入田野，采回第一份胃囊反应。"
		return "圣匣档案：失败样本 " + str(death_count) + " 份\n最近死因：" + last_death_note + "\n土地学习仍在继续。"
	return archive.call("sanctum_detail_text", death_count, last_death_note)
