extends Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

@export var timer_min: float = 5.0
@export var timer_max: float = 15.0
@export var x_dev: float = 40.0
@export var y_dev: float = 40.0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_timer() 

func start_timer() -> void:
	timer.wait_time = randf_range(timer_min, timer_max)
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	animated_sprite_2d.position.x = randf_range(animated_sprite_2d.position.x - x_dev, animated_sprite_2d.position.x + x_dev)
	animated_sprite_2d.position.y = randf_range(animated_sprite_2d.position.y - y_dev, animated_sprite_2d.position.y + y_dev)
	animated_sprite_2d.show()
	animated_sprite_2d.play()
	start_timer() 

func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.hide()
