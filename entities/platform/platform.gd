@tool
class_name Platform
extends Maskable


@onready var tile_map := $TileMap
@onready var highlights := $Highlights


const TOP_LEFT := Vector2i(23, 2)
const TOP := Vector2i(24, 2)
const TOP_RIGHT := Vector2i(25, 2)
const LEFT = Vector2i(23, 3)
const MIDDLE = Vector2i(24, 3)
const RIGHT = Vector2i(25, 3)
const BOTTOM_LEFT = Vector2i(23, 4)
const BOTTOM = Vector2i(24, 4)
const BOTTOM_RIGHT = Vector2i(25, 4)

@export var tile_size := Vector2i(0, 0):
	set(value):
		tile_size = value
		if not is_inside_tree():
			await ready

		tile_map.clear()

		tile_map.set_cell(Vector2i(-1, -1), 0, TOP_LEFT)
		for x in range(tile_size.x):
			tile_map.set_cell(Vector2i(x, -1), 0, TOP)
		tile_map.set_cell(Vector2i(tile_size.x, -1), 0, TOP_RIGHT)

		for y in range(tile_size.y):
			tile_map.set_cell(Vector2i(-1, y), 0, LEFT)
			for x in range(tile_size.x):
				tile_map.set_cell(Vector2i(x, y), 0, MIDDLE)
			tile_map.set_cell(Vector2i(tile_size.x, y), 0, RIGHT)

		tile_map.set_cell(Vector2i(-1, tile_size.y), 0, BOTTOM_LEFT)
		for x in range(tile_size.x):
			tile_map.set_cell(Vector2i(x, tile_size.y), 0, BOTTOM)
		tile_map.set_cell(Vector2i(tile_size.x, tile_size.y), 0, BOTTOM_RIGHT)

		bottom_right = Vector2i(4, 4) + 16 * tile_size
		top_left = Vector2i(-4, -4)

		highlights.points = PackedVector2Array([
			Vector2(-0.5, -0.5),
			Vector2(tile_size.x * 16 + 0.5, -0.5),
			Vector2(tile_size.x * 16 + 0.5, tile_size.y * 16 + 0.5),
			Vector2(-0.5, tile_size.y * 16 + 0.5)
		])
		highlights.closed = true

var highlighted := false:
	set(value):
		if highlighted == value:
			return

		highlighted = value
		if not is_inside_tree():
			await ready

		if highlighted:
			create_tween().tween_property(tile_map, "self_modulate", Color(0.5, 0.5, 0.5), 0.0625)
		else:
			create_tween().tween_property(tile_map, "self_modulate", Color(1.0, 1.0, 1.0), 0.0625)


func _process(_delta: float) -> void:
	var color := Color(1.0 if red_mask else 0.5, 1.0 if green_mask else 0.5, 1.0 if blue_mask else 0.5)
	if is_included():
		tile_map.modulate = Color(color, 1.0)
	else:
		tile_map.modulate = Color(color, 0.25)

	if Engine.is_editor_hint():
		return

	var pulse := (1.0 - fmod(Manager.music_beat, 1.0)) ** 0.5 * float(highlighted)
	match int(Manager.music_beat) % 4:
		0:
			highlights.modulate = Color(1.0, 0.25, 0.25, pulse if red_mask else 0.0)
		1:
			highlights.modulate = Color(0.25, 1.0, 0.25, pulse if green_mask else 0.0)
		2:
			highlights.modulate = Color(0.25, 0.25, 1.0, pulse if blue_mask else 0.0)
		_:
			highlights.modulate = Color(0.0, 0.0, 0.0, 0.0)
