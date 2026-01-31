extends Control
class_name LevelButton

@export var level_number: int
@onready var level_label: Label = $TextureButton/LevelLabel
@onready var lock_sprite: TextureRect = $TextureButton/Lock
var unlocked: bool = false

func _ready() -> void:
	level_label.text = str(level_number)

func lock() -> void:
	level_label.hide()
	lock_sprite.show()
	unlocked = false
	
func unlock() -> void:
	level_label.show()
	lock_sprite.hide()
	unlocked = true

func _on_texture_button_pressed() -> void:
	if unlocked:
		LevelManager.load_level(level_number)
