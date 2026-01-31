extends Control
const LEVEL_SELECT = preload("uid://bu6jy5mbuujwc")

@export var pitch_step: float = 0.1
@export var pitch_base: float = 1.0
@export var pitch_max: float = 1.2
@onready var hover_sound: AudioStreamPlayer2D = $HoverSound
@onready var click_sound: AudioStreamPlayer2D = $ClickSound
@onready var diagonal_container: DiagonalContainer = $ButtonsContainer/DiagonalContainer
@onready var circular_container: CircularContainer = $CreditsContainer/CircularContainer
@onready var splash_container: MarginContainer = $SplashContainer
@onready var buttons_container: MarginContainer = $ButtonsContainer
@onready var credits_container: MarginContainer = $CreditsContainer
@onready var back_container: MarginContainer = $BackContainer
@onready var level_select_container: GridContainer = $LevelSelectContainer

var count: int = 0
var pitch: float = pitch_base

#func _enter_tree() -> void:
	#SignalHub.on_button_hover.connect(on_button_hover)

func _ready() -> void:
	for c: GameButton in diagonal_container.get_children():
		c.on_button_hover.connect(on_button_hover)
		c.on_button_pressed.connect(on_button_pressed)
	for c: GameButton in circular_container.get_children():
		c.on_button_hover.connect(on_button_hover)
		c.on_button_pressed.connect(on_button_pressed)
	
	var back: GameButton = back_container.get_child(0)
	back.on_button_hover.connect(on_button_hover)
	back.on_button_pressed.connect(on_button_pressed)
	
	#if diagonal_container.get_child_count() > 0:
		#diagonal_container.get_child(0).grab_button_focus()

func on_button_hover() -> void:
	pitch = min(pitch + pitch_step, pitch_max)
	if hover_sound.playing == false:
		pitch = pitch_base
	hover_sound.pitch_scale = pitch
	hover_sound.play()
	
func on_button_pressed(action_id: String) -> void:
	print("PRESS")
	click_sound.play()
	match action_id:
		"start":
			start_game()
		"levels":
			load_level_select()
		"credits":
			load_credits()
		"exit":
			get_tree().quit()
		"back":
			load_main()
			
func start_game() -> void:
	print("Start")

func load_level_select() -> void:
	splash_container.visible = false
	buttons_container.visible = false
	level_select_container.visible = true
	back_container.visible = true

func load_credits() -> void:
	splash_container.visible = false
	buttons_container.visible = false
	credits_container.visible = true
	back_container.visible = true
	#if b and circular_container.get_child_count() > 0:
		#circular_container.get_child(0).grab_button_focus()
	#if !b and diagonal_container.get_child_count() > 0:
		#diagonal_container.get_child(0).grab_button_focus()

func load_main() -> void:
	splash_container.visible = true
	buttons_container.visible = true
	credits_container.visible = false
	level_select_container.visible = false
	back_container.visible = false
