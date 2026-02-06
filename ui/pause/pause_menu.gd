extends Control
const TITLE_SCREEN = preload("uid://wncglugrhywk")

var can_pause := true
@onready var sound: AudioStreamPlayer2D = $Sound

func _ready() -> void:
	Manager.on_player_death.connect(_on_player_death)

func _on_player_death() -> void:
	can_pause = false

func _on_resume_button_pressed() -> void:
	sound.play()
	get_tree().paused = false
	visible = false

func _on_restart_button_pressed() -> void:
	sound.play()
	get_tree().paused = false
	visible = false
	Manager.emit_on_player_death()

func _on_menu_button_pressed() -> void:
	sound.play()
	get_tree().paused = false
	visible = false
	Manager.music_playing = false
	get_tree().change_scene_to_packed(TITLE_SCREEN)

func _unhandled_input(event: InputEvent) -> void:
	if not can_pause:
		return

	if event.is_action_pressed("pause"):
		visible = not visible
		get_tree().set_deferred("paused", visible)
