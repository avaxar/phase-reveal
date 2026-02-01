class_name Cube
extends RigidBody2D


@onready var sprite := $Sprite
@onready var inside_cast := $InsideCast
@onready var particles := $Particles
@onready var crush_sfx := $CrushSFX

var last_position: Vector2
var death_position: Vector2
var is_dead := false


func _process(_delta: float) -> void:
	if not Manager.loading and not is_dead and (inside_cast.is_colliding() or position.y < 0 or position.y > 270):
		is_dead = true
		sprite.visible = false
		death_position = last_position
		particles.emitting = true
		crush_sfx.playing = true
		Manager.emit_on_player_death()

	if is_dead:
		position = death_position
		rotation = 0.0

	last_position = position
