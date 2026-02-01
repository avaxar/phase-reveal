extends Control
const TITLE_SCREEN = preload("uid://wncglugrhywk")

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	visible = false

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	Manager.emit_on_player_death()

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	if Manager.current_scene != null:
		Manager.current_scene.queue_free()
	get_tree().change_scene_to_packed(TITLE_SCREEN)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = !visible
		get_tree().set_deferred("paused", visible)
