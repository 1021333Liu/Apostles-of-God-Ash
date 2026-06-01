class_name PlayerRuntime
extends RefCounted

var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.RIGHT
var hp: int = 100


func configure(initial_position: Vector2, initial_facing: Vector2, max_hp: int) -> void:
	position = initial_position
	velocity = Vector2.ZERO
	facing = initial_facing
	hp = max_hp


func reset_for_run(start_position: Vector2, start_facing: Vector2, max_hp: int) -> void:
	configure(start_position, start_facing, max_hp)


func reset_for_sanctum(start_position: Vector2, max_hp: int) -> void:
	configure(start_position, Vector2.UP, max_hp)


func update_movement(input_dir: Vector2, delta: float, bounds: Rect2, speed: float, radius: float, slowed: bool) -> void:
	if input_dir != Vector2.ZERO:
		facing = input_dir.normalized()
		velocity = velocity.move_toward(input_dir * speed, 1800.0 * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 1500.0 * delta)

	var speed_scale := 0.72 if slowed else 1.0
	position += velocity * speed_scale * delta
	position.x = clampf(position.x, bounds.position.x + radius, bounds.end.x - radius)
	position.y = clampf(position.y, bounds.position.y + radius, bounds.end.y - radius)


func apply_damage(amount: int) -> int:
	hp = maxi(0, hp - amount)
	return hp


func apply_heal(next_hp: int, max_hp: int) -> int:
	hp = clampi(next_hp, 0, max_hp)
	return hp


func apply_impulse(offset: Vector2) -> void:
	position += offset
