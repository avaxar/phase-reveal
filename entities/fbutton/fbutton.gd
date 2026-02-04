@tool
class_name FButton
extends Area2D


@onready var collision_shape = $CollisionShape
@onready var tile_map = $TileMap


@export var triggered_doors: Array[Door]
@export var triggered_animation: Array[AnimationPlayer]:
	set(value):
		triggered_animation = value
		_update_color()



const SINGLE_PRESSED := Vector2i(22, 0)
const LEFT_PRESSED := Vector2i(19, 0)
const MIDDLE_PRESSED := Vector2i(20, 0)
const RIGHT_PRESSED := Vector2i(21, 0)

const SINGLE_STILL := Vector2i(22, 1)
const LEFT_STILL := Vector2i(19, 1)
const MIDDLE_STILL := Vector2i(20, 1)
const RIGHT_STILL := Vector2i(21, 1)

func _ready() -> void:
	_update_color()

@export var width := 2:
	set(value):
		width = value
		pressed = false

var pressed := false:
	set(value):
		pressed = value
		if not is_inside_tree():
			await ready

		tile_map.clear()
		if width == 1:
			tile_map.set_cell(Vector2i(0, 0), 0, SINGLE_PRESSED if pressed else SINGLE_STILL)
		else:
			tile_map.set_cell(Vector2i(0, 0), 0, LEFT_PRESSED if pressed else LEFT_STILL)
			for x in range(1, width - 1):
				tile_map.set_cell(Vector2i(x, 0), 0, MIDDLE_PRESSED if pressed else MIDDLE_STILL)
			tile_map.set_cell(Vector2i(width - 1, 0), 0, RIGHT_PRESSED if pressed else RIGHT_STILL)

		collision_shape.position = Vector2(width * 16.0 / 2.0, 10.0)
		collision_shape.shape.size = Vector2(width * 16.0, 12.0)

var body_count := 0:
	set(value):
		if body_count != value:
			if value > 0 and body_count == 0:
				pressed = true
				for door: Door in triggered_doors:
					door.open()
				for anim: AnimationPlayer in triggered_animation:
					anim.play(anim.get_animation_list()[1])
				
			if body_count > 0 and value == 0:
				pressed = false
				for door: Door in triggered_doors:
					door.close()
				for anim: AnimationPlayer in triggered_animation:
					anim.pause()
				

			body_count = value


func _on_body_entered(_body: Node2D) -> void:
	body_count += 1


func _on_body_exited(_body: Node2D) -> void:
	body_count -= 1

func _update_color() -> void:
	if not is_inside_tree():
		await ready
	if tile_map == null:
		return
	tile_map.modulate = Color("67ffff") if triggered_animation.size() > 0 else Color.WHITE
