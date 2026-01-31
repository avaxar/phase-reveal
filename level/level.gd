extends Node2D


@export var red_mask := true
@export var green_mask := true
@export var blue_mask := true

@onready var collision_proxies := $CollisionProxies


func _ready():
	for maskable: Maskable in get_tree().get_nodes_in_group("maskables"):
		maskable.mask_joined.connect(_on_mask_joined)
		maskable.mask_freed.connect(_on_mask_freed)


func _process(_delta: float) -> void:
	for maskable: Maskable in get_tree().get_nodes_in_group("maskables"):
		if maskable_rects.has(maskable):
			continue

		conform_mask(maskable)

	regenerate_chunks()


const CHUNK_SIZE := 32
var dirty_chunks: Dictionary[Vector2i, bool]
var addition_chunks: Dictionary[Vector2i, PackedByteArray]
var bitmask_chunks: Dictionary[Vector2i, BitMap]
var chunk_bodies: Dictionary[Vector2i, StaticBody2D]
var maskable_rects: Dictionary[Maskable, Rect2i]


func _on_mask_joined(maskable: Maskable) -> void:
	print("Joined: ", maskable)
	maskable.disabled = true
	maskable_rects[maskable] = Rect2i(maskable.to_global(maskable.top_left), maskable.size)
	mask_rect(maskable_rects[maskable], 1)


func _on_mask_freed(maskable: Maskable) -> void:
	print("Left: ", maskable)
	conform_mask(maskable)
	if maskable in maskable_rects:
		mask_rect(maskable_rects[maskable], -1)
		maskable_rects.erase(maskable)


func conform_mask(maskable: Maskable) -> void:
	maskable.disabled = not (
		(maskable.red_mask and red_mask)
		or (maskable.green_mask and green_mask)
		or (maskable.blue_mask and blue_mask)
	)


func mask_rect(rect: Rect2i, delta: int) -> void:
	var tl_chunk := Vector2i((rect.position / float(CHUNK_SIZE)).floor())
	var br_chunk := Vector2i((rect.end / float(CHUNK_SIZE)).ceil())

	for chunk_y: int in range(tl_chunk.y, br_chunk.y):
		var start_y := 0 if chunk_y != tl_chunk.y else posmod(rect.position.y, CHUNK_SIZE)
		var end_y := CHUNK_SIZE if chunk_y != br_chunk.y - 1 else posmod(rect.end.y, CHUNK_SIZE)

		for chunk_x: int in range(tl_chunk.x, br_chunk.x):
			var chunk := Vector2i(chunk_x, chunk_y)
			dirty_chunks[chunk] = true

			var addition_chunk: PackedByteArray
			if chunk in addition_chunks:
				addition_chunk = addition_chunks[chunk]
			else:
				addition_chunk = PackedByteArray()
				addition_chunk.resize(CHUNK_SIZE * CHUNK_SIZE)
				addition_chunk.fill(0)
				addition_chunks[chunk] = addition_chunk

			var bitmask_chunk: BitMap
			if chunk in bitmask_chunks:
				bitmask_chunk = bitmask_chunks[chunk]
			else:
				bitmask_chunk = BitMap.new()
				bitmask_chunk.create(Vector2i(CHUNK_SIZE, CHUNK_SIZE))
				bitmask_chunks[chunk] = bitmask_chunk

			var start_x := 0 if chunk_x != tl_chunk.x else posmod(rect.position.x, CHUNK_SIZE)
			var end_x := CHUNK_SIZE if chunk_x != br_chunk.x - 1 else posmod(rect.end.x, CHUNK_SIZE)

			for y in range(start_y, end_y):
				for x in range(start_x, end_x):
					var cumulative := addition_chunk[y * CHUNK_SIZE + x] + delta
					addition_chunk[y * CHUNK_SIZE + x] = cumulative
					bitmask_chunk.set_bit(x, y, bool(cumulative % 2)) # Solid when odd


func regenerate_chunks() -> void:
	for chunk: Vector2i in dirty_chunks:
		var chunk_body: StaticBody2D
		if chunk in chunk_bodies:
			chunk_body = chunk_bodies[chunk]
		else:
			chunk_body = StaticBody2D.new()
			collision_proxies.add_child(chunk_body)
			chunk_body.global_position = Vector2(chunk) * CHUNK_SIZE
			chunk_bodies[chunk] = chunk_body

		for child: Node in chunk_body.get_children():
			child.queue_free()

		# Image.create_from_data(32, 32, false, Image.FORMAT_R8, addition_chunks[chunk]).save_png("/home/avaxar/testt.png")
		# bitmask_chunks[chunk].convert_to_image().save_png("/home/avaxar/test.png")

		for polygon: PackedVector2Array in bitmask_chunks[chunk].opaque_to_polygons(
				Rect2i(Vector2i(0, 0), Vector2i(CHUNK_SIZE, CHUNK_SIZE)), 0.0):
			var poly := CollisionPolygon2D.new()
			poly.polygon = polygon
			chunk_body.add_child(poly)

	dirty_chunks = {}
