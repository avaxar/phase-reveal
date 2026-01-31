extends Control
const TITLE_SCREEN = preload("uid://wncglugrhywk")

func _on_resume_button_pressed() -> void:
	print("resume")

func _on_restart_button_pressed() -> void:
	print("restart")

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(TITLE_SCREEN)
