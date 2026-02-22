extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@export var min_time: float = 20
@export var max_time: float = 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_wait_and_play()


func _wait_and_play() -> void:
	await get_tree().create_timer(randf_range(min_time, max_time)).timeout
	animated_sprite_2d.play()
	await animated_sprite_2d.animation_finished
	_wait_and_play()
