extends CharacterBody2D

@export_category("Basic Movement")
@export var speed: float = 150
@export var jump_velocity: float = -270
@export var terminal_velocity: float = 500
@export var default_gravity: float = 980

@export_category("Buffer Jump")
@export var jump_buffer_time: float = 0.1

@export_category("Coyote Time")
@export var coyote_time: float = 0.1

@export_category("Variable Jump Height")
@export var gravity_modifier: float = 1.2

@export_category("Death")
@export var knockback_velocity: Vector2 = Vector2(0, 300)

# SFX
const DEATH = preload("uid://n0ux7lb83ufp")
const JUMP = preload("uid://q0ubgob4wj1d")
const MASK = preload("uid://wel37ciib3k0")
const WALK = preload("uid://ci6i5gbv6h07s")
@onready var sound: AudioStreamPlayer2D = $Sound

@onready var buffer_timer: Timer = $BufferTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var debug_label: Label = $DebugLabel
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var box_detector: Area2D = $BoxDetector
@onready var inside_cast: RayCast2D = $InsideCast

# Buffer Jump & Coyote Time
var jump_available: bool = true
var jump_buffer: bool = false

# Current Gravity
var current_gravity: float = 0

var was_on_floor: bool = false

var has_box: bool = false
const CUBE = preload("uid://dfe3nvn1lo8gt")

var is_dead: bool = false

func _enter_tree() -> void:
	Manager.on_player_death.connect(die)

func _ready() -> void:
	Manager.mask_changed.connect(_on_mask_changed)
	_on_mask_changed(true, true, true)

	buffer_timer.wait_time = jump_buffer_time
	coyote_timer.wait_time = coyote_time
	current_gravity = default_gravity


func _process(_delta: float) -> void:
	if inside_cast.is_colliding():
		die()


func _physics_process(delta: float) -> void:
	update_debug_label()
	handle_fall(delta)
	handle_jump()
	handle_movement()
	handle_flip()

	if velocity.y > terminal_velocity:
		velocity.y = terminal_velocity

	move_and_slide()
	handle_anim()
	was_on_floor = is_on_floor()


func handle_fall(delta: float) -> void:
	if !is_on_floor():
		if jump_available and coyote_timer.is_stopped():
			coyote_timer.start()

		if velocity.y < 0 and Input.is_action_just_released("jump"): # If Falling
			current_gravity = default_gravity * gravity_modifier

		velocity.y += current_gravity * delta
	else:
		jump_available = true
		current_gravity = default_gravity
		coyote_timer.stop()
		if jump_buffer and !buffer_timer.is_stopped():
			jump()


func handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if jump_available:
			jump()
		else:
			jump_buffer = true
			buffer_timer.start()


func handle_movement() -> void:
	if is_dead:
		return

	var direction := Input.get_axis("left", "right")
	velocity.x = direction * speed


func handle_anim() -> void:
	if is_dead:
		return

	if !was_on_floor and is_on_floor() and !has_box:
		sprite.play("land")

	if sprite.is_playing() and sprite.animation == "land":
		return

	if !is_on_floor():
		if sprite.animation != "jump":
			if has_box:
				sprite.play("hold_jump")
			else:
				sprite.play("jump")
		return

	if !is_zero_approx(velocity.x):
		if has_box:
			sprite.play("hold_walk")
		else:
			sprite.play("walk")
	else:
		if has_box:
			sprite.play("hold_idle")
		else:
			sprite.play("idle")


func handle_flip() -> void:
	if !is_zero_approx(velocity.x):
		sprite.flip_h = velocity.x <= 0


func jump() -> void:
	velocity.y = jump_velocity
	jump_available = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if has_box:
			drop_box()
		else:
			try_pickup_box()

	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused


func try_pickup_box() -> void:
	var bodies: Array = box_detector.get_overlapping_bodies()
	for body in bodies:
		if body is cube:
			has_box = true
			body.queue_free()
			return


func drop_box() -> void:
	print("BOX DROP!")
	var nc: cube = CUBE.instantiate()
	get_parent().add_child(nc)
	nc.global_position = global_position + Vector2(0, -30)
	has_box = false


func _on_coyote_timer_timeout() -> void:
	jump_available = false


func update_debug_label() -> void:
	var text: String = ""
	text += "BUFF: %.2f\n" % buffer_timer.time_left
	text += "COY: %.2f\n" % coyote_timer.time_left
	text += "GRAV: %.2f," % current_gravity
	text += "AVA: %s" % jump_available
	debug_label.text = text


func _on_buffer_timer_timeout() -> void:
	jump_buffer = false


func _on_hitbox_body_entered(_body: Node2D) -> void:
	Manager.emit_on_player_death()


func die() -> void:
	if is_dead:
		return

	sound.stop()
	sound.stream = DEATH
	sound.play()
	hitbox.set_deferred("disabled", true)
	await get_tree().create_timer(0.1).timeout
	velocity = Vector2(knockback_velocity.x, -knockback_velocity.y)
	is_dead = true
	sprite.play("dead")
	collision_shape_2d.set_deferred("disabled", true)


func _on_mask_changed(_red_changed: bool, _green_changed: bool, _blue_changed: bool) -> void:
	sprite.material.set_shader_parameter(
		"mask_color",
		Color(
			1.0 if Manager.red_mask else 0.5,
			1.0 if Manager.green_mask else 0.5,
			1.0 if Manager.blue_mask else 0.5
		)
	)
