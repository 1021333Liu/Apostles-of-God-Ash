extends RefCounted

const PLAYER_ECHO_IDLE_PATH: String = "res://assets/sprites/characters/player/player_echo_idle.png"
const LOG_FRAGMENT_PATH: String = "res://assets/sprites/pickups/log_fragment.png"

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
var enemy_textures: Dictionary = {}
var room_backgrounds: Dictionary = {}


func load_all() -> void:
	player_idle = _try_load_texture(PLAYER_ECHO_IDLE_PATH)
	log_fragment = _try_load_texture(LOG_FRAGMENT_PATH)

	enemy_textures.clear()
	for kind: String in ENEMY_TEXTURE_PATHS.keys():
		enemy_textures[kind] = _try_load_texture(String(ENEMY_TEXTURE_PATHS[kind]))

	room_backgrounds.clear()
	for room_id: String in ROOM_BACKGROUND_PATHS.keys():
		room_backgrounds[room_id] = _try_load_texture(String(ROOM_BACKGROUND_PATHS[room_id]))


func player_texture() -> Texture2D:
	return player_idle


func enemy_texture(kind: String) -> Texture2D:
	return enemy_textures.get(kind, null) as Texture2D


func room_background(room_id: String) -> Texture2D:
	return room_backgrounds.get(room_id, null) as Texture2D


func log_fragment_texture() -> Texture2D:
	return log_fragment


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
	if not ResourceLoader.exists(path):
		return null
	var resource := load(path)
	if resource is Texture2D:
		return resource as Texture2D
	return null
