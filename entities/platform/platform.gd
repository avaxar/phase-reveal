@tool
class_name Platform
extends Maskable


@onready var tile_map = $TileMap


const TOP_LEFT := Vector2i(23, 2)
const TOP := Vector2i(24, 2)
const TOP_RIGHT := Vector2i(25, 2)
const LEFT = Vector2i(23, 3)
const MIDDLE = Vector2i(24, 3)
const RIGHT = Vector2i(25, 3)
const BOTTOM_LEFT = Vector2i(23, 4)
const BOTTOM = Vector2i(24, 4)
const BOTTOM_RIGHT = Vector2i(25, 4)

@export var tile_size := Vector2i(2, 1):
    set(value):
        if tile_map == null:
            set_deferred("tile_size", value)
            return

        tile_size = value
        tile_map.clear()

        tile_map.set_cell(Vector2i(0, 0), 0, TOP_LEFT)
        for x in range(tile_size.x):
            tile_map.set_cell(Vector2i(x + 1, 0), 0, TOP)
        tile_map.set_cell(Vector2i(tile_size.x + 1, 0), 0, TOP_RIGHT)

        for y in range(tile_size.y):
            tile_map.set_cell(Vector2i(0, y + 1), 0, LEFT)
            for x in range(tile_size.x):
                tile_map.set_cell(Vector2i(x + 1, y + 1), 0, MIDDLE)
            tile_map.set_cell(Vector2i(tile_size.x + 1, y + 1), 0, RIGHT)

        tile_map.set_cell(Vector2i(0, tile_size.y + 1), 0, BOTTOM_LEFT)
        for x in range(tile_size.x):
            tile_map.set_cell(Vector2i(x + 1, tile_size.y + 1), 0, BOTTOM)
        tile_map.set_cell(Vector2i(tile_size.x + 1, tile_size.y + 1), 0, BOTTOM_RIGHT)

        bottom_right = Vector2i(20, 20) + 16 * tile_size
        top_left = Vector2i(12, 12)
