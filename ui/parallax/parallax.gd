extends Node2D
@export var offset_amount: int = 100

func _enter_tree() -> void:
	Manager.on_level_start.connect(setup_parallax)

# Called when the node enters the scene tree for the first time.
func setup_parallax(level_number: int) -> void:
	for child: Node2D in get_children():
		if child is Parallax2D:
			child.scroll_offset.x += offset_amount * level_number
