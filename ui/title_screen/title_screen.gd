extends Control

@export var pitch_step: float = 0.1
@export var pitch_base: float = 1.0
@export var pitch_max: float = 1.2
@onready var hover_sound: AudioStreamPlayer2D = $HoverSound
@onready var click_sound: AudioStreamPlayer2D = $ClickSound
@onready var diagonal_container: DiagonalContainer = $ButtonsContainer/DiagonalContainer
@onready var circular_container: CircularContainer = $CreditsContainer/CircularContainer
@onready var splash_container: MarginContainer = $SplashContainer
@onready var buttons_container: MarginContainer = $ButtonsContainer

var count: int = 0
var pitch: float = pitch_base

#func _enter_tree() -> void:
	#SignalHub.on_button_hover.connect(on_button_hover)

func _ready() -> void:
	for c: GameButton in diagonal_container.get_children():
		c.on_button_hover.connect(on_button_hover)
		c.on_button_pressed.connect(on_button_pressed)
	#for c: GameButton in circular_container.get_children():
		#c.on_button_hover.connect(on_button_hover)
	
	#if diagonal_container.get_child_count() > 0:
		#diagonal_container.get_child(0).grab_button_focus()

func on_button_hover() -> void:
	pitch = min(pitch + pitch_step, pitch_max)
	if hover_sound.playing == false:
		pitch = pitch_base
	hover_sound.pitch_scale = pitch
	hover_sound.play()
	
func on_button_pressed(action_id: String) -> void:
	click_sound.play()
	match action_id:
		"start":
			start_game()
		"levels":
			load_level_select()
		"credits":
			load_credits(true)
		"exit":
			get_tree().quit()
		"back":
			load_credits(false)
			
func start_game() -> void:
	print("Start")

func load_level_select() -> void:
	pass

func load_credits(b: bool) -> void:
	splash_container.visible = !b
	buttons_container.visible = !b
	#if b and circular_container.get_child_count() > 0:
		#circular_container.get_child(0).grab_button_focus()
	#if !b and diagonal_container.get_child_count() > 0:
		#diagonal_container.get_child(0).grab_button_focus()
