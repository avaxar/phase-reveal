class_name Cube
extends RigidBody2D


@onready var sprite := $Sprite
@onready var collision_shape := $CollisionShape
@onready var particles := $Particles
@onready var crush_sfx := $CrushSFX

var position_history: PackedVector2Array
var death_position: Vector2
var is_dead := false


func _ready() -> void:
	position_history.resize(8)
	position_history.fill(global_position)


func _physics_process(_delta: float) -> void:
	# Out-of-bounds
	if global_position.y < 0 or global_position.y > 270:
		die()

	if is_dead:
		global_position = death_position
		rotation = 0.0

	for i: int in range(len(position_history) - 1):
		position_history[i] = position_history[i + 1]
	position_history[len(position_history) - 1] = global_position


func _on_suffocation_threshold_body_entered(_body: Node2D) -> void:
	collision_mask = 0
	collision_layer = 0
	die()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	sprite.visible = false
	collision_shape.set_deferred("disabled", true)
	particles.set_deferred("emitting", true)
	crush_sfx.playing = true

	# If it is suffocated, then the cube may be shot off far away by the physics engine,
	# so we're taking the average historical positions.
	var sum_pos := Vector2(0, 0)
	for historical_pos: Vector2 in position_history:
		sum_pos += historical_pos
	death_position = sum_pos / len(position_history)

	if not Manager.loading:
		Manager.emit_on_player_death()
