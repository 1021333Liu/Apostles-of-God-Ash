extends RefCounted

const PLAYER_ECHO_IDLE_PATH: String = "res://assets/sprites/characters/player/player_echo_idle.png"
const LOG_FRAGMENT_PATH: String = "res://assets/sprites/pickups/log_fragment.png"

const PLAYER_ATLAS_MANIFEST_PATH: String = "res://assets/sprites/atlases/player_echo_atlas.json"
const LOG_FRAGMENT_ATLAS_MANIFEST_PATH: String = "res://assets/sprites/atlases/log_fragment_atlas.json"

const ENEMY_ATLAS_MANIFEST_PATHS: Dictionary = {
	"empty": "res://assets/sprites/atlases/enemy_empty_atlas.json",
	"farmer": "res://assets/sprites/atlases/enemy_farmer_atlas.json",
	"scarecrow": "res://assets/sprites/atlases/enemy_scarecrow_atlas.json",
	"barn_king": "res://assets/sprites/atlases/boss_barn_king_atlas.json"
}

const PLAYER_FRAME_PATHS: Dictionary = {
	"idle": [
		"res://assets/sprites/characters/player/player_echo_idle_0.png",
		"res://assets/sprites/characters/player/player_echo_idle_1.png",
		"res://assets/sprites/characters/player/player_echo_idle_2.png",
		"res://assets/sprites/characters/player/player_echo_idle_3.png"
	],
	"walk": [
		"res://assets/sprites/characters/player/player_echo_walk_0.png",
		"res://assets/sprites/characters/player/player_echo_walk_1.png",
		"res://assets/sprites/characters/player/player_echo_walk_2.png",
		"res://assets/sprites/characters/player/player_echo_walk_3.png"
	],
	"attack": [
		"res://assets/sprites/characters/player/player_echo_attack_0.png",
		"res://assets/sprites/characters/player/player_echo_attack_1.png",
		"res://assets/sprites/characters/player/player_echo_attack_2.png",
		"res://assets/sprites/characters/player/player_echo_attack_3.png"
	],
	"hit": [
		"res://assets/sprites/characters/player/player_echo_hit_0.png",
		"res://assets/sprites/characters/player/player_echo_hit_1.png",
		"res://assets/sprites/characters/player/player_echo_hit_2.png"
	]
}

const ENEMY_FRAME_PATHS: Dictionary = {
	"empty": {
		"idle": [
			"res://assets/sprites/characters/enemies/enemy_empty_idle_0.png",
			"res://assets/sprites/characters/enemies/enemy_empty_idle_1.png",
			"res://assets/sprites/characters/enemies/enemy_empty_idle_2.png",
			"res://assets/sprites/characters/enemies/enemy_empty_idle_3.png"
		],
		"walk": [
			"res://assets/sprites/characters/enemies/enemy_empty_walk_0.png",
			"res://assets/sprites/characters/enemies/enemy_empty_walk_1.png",
			"res://assets/sprites/characters/enemies/enemy_empty_walk_2.png",
			"res://assets/sprites/characters/enemies/enemy_empty_walk_3.png"
		],
		"attack": [
			"res://assets/sprites/characters/enemies/enemy_empty_attack_0.png",
			"res://assets/sprites/characters/enemies/enemy_empty_attack_1.png",
			"res://assets/sprites/characters/enemies/enemy_empty_attack_2.png",
			"res://assets/sprites/characters/enemies/enemy_empty_attack_3.png"
		],
		"hit": [
			"res://assets/sprites/characters/enemies/enemy_empty_hit_0.png",
			"res://assets/sprites/characters/enemies/enemy_empty_hit_1.png",
			"res://assets/sprites/characters/enemies/enemy_empty_hit_2.png"
		]
	},
	"farmer": {
		"idle": [
			"res://assets/sprites/characters/enemies/enemy_farmer_idle_0.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_idle_1.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_idle_2.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_idle_3.png"
		],
		"walk": [
			"res://assets/sprites/characters/enemies/enemy_farmer_walk_0.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_walk_1.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_walk_2.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_walk_3.png"
		],
		"attack": [
			"res://assets/sprites/characters/enemies/enemy_farmer_attack_0.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_attack_1.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_attack_2.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_attack_3.png"
		],
		"hit": [
			"res://assets/sprites/characters/enemies/enemy_farmer_hit_0.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_hit_1.png",
			"res://assets/sprites/characters/enemies/enemy_farmer_hit_2.png"
		]
	},
	"scarecrow": {
		"idle": [
			"res://assets/sprites/characters/enemies/enemy_scarecrow_idle_0.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_idle_1.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_idle_2.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_idle_3.png"
		],
		"walk": [
			"res://assets/sprites/characters/enemies/enemy_scarecrow_walk_0.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_walk_1.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_walk_2.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_walk_3.png"
		],
		"attack": [
			"res://assets/sprites/characters/enemies/enemy_scarecrow_attack_0.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_attack_1.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_attack_2.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_attack_3.png"
		],
		"hit": [
			"res://assets/sprites/characters/enemies/enemy_scarecrow_hit_0.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_hit_1.png",
			"res://assets/sprites/characters/enemies/enemy_scarecrow_hit_2.png"
		]
	},
	"barn_king": {
		"phase1": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_idle_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_idle_1.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_idle_2.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_idle_3.png"
		],
		"phase2": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_idle_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_idle_1.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_idle_2.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_idle_3.png"
		],
		"phase3": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_idle_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_idle_1.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_idle_2.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_idle_3.png"
		],
		"phase1_attack": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_attack_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_attack_1.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_attack_2.png"
		],
		"phase2_attack": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_attack_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_attack_1.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_attack_2.png"
		],
		"phase3_attack": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_attack_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_attack_1.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_attack_2.png"
		],
		"phase1_hit": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_hit_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase1_hit_1.png"
		],
		"phase2_hit": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_hit_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase2_hit_1.png"
		],
		"phase3_hit": [
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_hit_0.png",
			"res://assets/sprites/characters/bosses/boss_barn_king_phase3_hit_1.png"
		],
		"hit": ["res://assets/sprites/characters/bosses/boss_barn_king_phase3_hit_0.png"]
	}
}

const LOG_FRAGMENT_FRAME_PATHS: Array[String] = [
	"res://assets/sprites/pickups/log_fragment_pulse_0.png",
	"res://assets/sprites/pickups/log_fragment_pulse_1.png",
	"res://assets/sprites/pickups/log_fragment_pulse_2.png",
	"res://assets/sprites/pickups/log_fragment_pulse_3.png",
	"res://assets/sprites/pickups/log_fragment_pulse_4.png",
	"res://assets/sprites/pickups/log_fragment_0.png",
	"res://assets/sprites/pickups/log_fragment_1.png",
	"res://assets/sprites/pickups/log_fragment_2.png",
	"res://assets/sprites/pickups/log_fragment_3.png",
	"res://assets/sprites/pickups/log_fragment_4.png"
]

const ENEMY_TEXTURE_PATHS: Dictionary = {
	"empty": "res://assets/sprites/characters/enemies/enemy_empty_idle.png",
	"farmer": "res://assets/sprites/characters/enemies/enemy_farmer_idle.png",
	"scarecrow": "res://assets/sprites/characters/enemies/enemy_scarecrow_idle.png",
	"barn_king": "res://assets/sprites/characters/bosses/boss_barn_king_phase1_idle.png"
}

const ROOM_BACKGROUND_PATHS: Dictionary = {
	"field_gate": "res://assets/backgrounds/rooms/bg_field_gate_base.png",
	"blood_wheat": "res://assets/backgrounds/rooms/bg_blood_wheat_base.png",
	"gut_canal": "res://assets/backgrounds/rooms/bg_gut_canal_base.png",
	"hungry_barn": "res://assets/backgrounds/rooms/bg_hungry_barn_base.png",
	"barn_king": "res://assets/backgrounds/rooms/bg_barn_king_base.png"
}

var player_idle: Texture2D
var log_fragment: Texture2D
var player_frames: Dictionary = {}
var enemy_textures: Dictionary = {}
var enemy_frames: Dictionary = {}
var room_backgrounds: Dictionary = {}
var log_fragment_frames: Array[Texture2D] = []
var atlas_manifests: Dictionary = {}


func load_all() -> void:
	player_idle = _try_load_texture(PLAYER_ECHO_IDLE_PATH)
	log_fragment = _try_load_texture(LOG_FRAGMENT_PATH)
	atlas_manifests.clear()
	player_frames = _load_atlas_frame_groups(PLAYER_ATLAS_MANIFEST_PATH)
	if player_frames.is_empty():
		player_frames = _load_frame_groups(PLAYER_FRAME_PATHS)

	enemy_textures.clear()
	for kind: String in ENEMY_TEXTURE_PATHS.keys():
		enemy_textures[kind] = _try_load_texture(String(ENEMY_TEXTURE_PATHS[kind]))
	enemy_frames.clear()
	for kind: String in ENEMY_FRAME_PATHS.keys():
		var atlas_groups := _load_atlas_frame_groups(String(ENEMY_ATLAS_MANIFEST_PATHS.get(kind, "")))
		enemy_frames[kind] = atlas_groups if not atlas_groups.is_empty() else _load_frame_groups(ENEMY_FRAME_PATHS[kind])

	room_backgrounds.clear()
	for room_id: String in ROOM_BACKGROUND_PATHS.keys():
		room_backgrounds[room_id] = _try_load_texture(String(ROOM_BACKGROUND_PATHS[room_id]))
	var log_fragment_groups := _load_atlas_frame_groups(LOG_FRAGMENT_ATLAS_MANIFEST_PATH)
	log_fragment_frames = log_fragment_groups.get("pulse", []) as Array[Texture2D] if not log_fragment_groups.is_empty() else _load_frame_list(LOG_FRAGMENT_FRAME_PATHS)


func player_texture() -> Texture2D:
	return player_idle


func player_frame(state: String, frame_index: int) -> Texture2D:
	return _frame_from_group(player_frames, state, frame_index, player_idle)


func enemy_texture(kind: String) -> Texture2D:
	return enemy_textures.get(kind, null) as Texture2D


func enemy_frame(kind: String, state: String, frame_index: int) -> Texture2D:
	var groups := enemy_frames.get(kind, {}) as Dictionary
	return _frame_from_group(groups, state, frame_index, enemy_texture(kind))


func room_background(room_id: String) -> Texture2D:
	return room_backgrounds.get(room_id, null) as Texture2D


func log_fragment_texture() -> Texture2D:
	return log_fragment


func log_fragment_frame(frame_index: int) -> Texture2D:
	if log_fragment_frames.is_empty():
		return log_fragment
	return log_fragment_frames[frame_index % log_fragment_frames.size()]


func enemy_draw_size(kind: String) -> Vector2:
	match kind:
		"barn_king":
			return Vector2(260.0, 260.0)
		"scarecrow":
			return Vector2(104.0, 104.0)
		"farmer":
			return Vector2(86.0, 86.0)
		_:
			return Vector2(76.0, 76.0)


func _try_load_texture(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var resource := load(path)
		if resource is Texture2D:
			return resource as Texture2D
	if path.get_extension().to_lower() == "png" and FileAccess.file_exists(path):
		var image := Image.new()
		if image.load(path) == OK:
			return ImageTexture.create_from_image(image)
	return null


func _load_atlas_frame_groups(manifest_path: String) -> Dictionary:
	if manifest_path.is_empty() or not FileAccess.file_exists(manifest_path):
		return {}
	var manifest := _read_atlas_manifest(manifest_path)
	if manifest.is_empty():
		return {}
	var texture := _try_load_texture(String(manifest.get("texture", "")))
	if not texture:
		return {}
	var groups_data := manifest.get("groups", {}) as Dictionary
	var loaded: Dictionary = {}
	for state: String in groups_data.keys():
		var frames: Array[Texture2D] = []
		for frame_data in groups_data[state]:
			if frame_data is Dictionary:
				var region_values := (frame_data as Dictionary).get("region", []) as Array
				if region_values.size() == 4:
					frames.append(_make_atlas_texture(texture, region_values))
		if not frames.is_empty():
			loaded[state] = frames
	return loaded


func _read_atlas_manifest(path: String) -> Dictionary:
	if atlas_manifests.has(path):
		return atlas_manifests[path] as Dictionary
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		atlas_manifests[path] = parsed
		return parsed as Dictionary
	return {}


func _make_atlas_texture(texture: Texture2D, region_values: Array) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = texture
	atlas_texture.region = Rect2(
		Vector2(float(region_values[0]), float(region_values[1])),
		Vector2(float(region_values[2]), float(region_values[3]))
	)
	return atlas_texture


func _load_frame_groups(groups: Dictionary) -> Dictionary:
	var loaded: Dictionary = {}
	for state: String in groups.keys():
		loaded[state] = _load_frame_list(groups[state])
	return loaded


func _load_frame_list(paths: Array) -> Array[Texture2D]:
	var frames: Array[Texture2D] = []
	for path_value in paths:
		var texture := _try_load_texture(String(path_value))
		if texture:
			frames.append(texture)
	return frames


func _frame_from_group(groups: Dictionary, state: String, frame_index: int, fallback: Texture2D) -> Texture2D:
	var frames := groups.get(state, []) as Array
	if frames.is_empty():
		frames = groups.get("idle", []) as Array
	if frames.is_empty():
		return fallback
	return frames[frame_index % frames.size()] as Texture2D
