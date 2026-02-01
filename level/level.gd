extends Node2D


@onready var collision_proxies := $CollisionProxies
@onready var passthrough_visualizer := $PassthroughVisualizer
@onready var player := $Player
@onready var hud = $CanvasLayer/HUD


func _ready():
	Manager.mask_changed.connect(update_masks)
	for maskable: Maskable in get_tree().get_nodes_in_group("maskables"):
		maskable.mask_joined.connect(_on_mask_joined)
		maskable.mask_freed.connect(_on_mask_freed)


func _process(_delta: float) -> void:
	for maskable: Maskable in get_tree().get_nodes_in_group("maskables"):
		if maskable in maskable_rects:
			continue

		maskable.disabled = not maskable.is_included()

	watch_masks()
	regenerate_chunks()


const CHUNK_SIZE := 32
var dirty_chunks: Dictionary[Vector2i, bool]
var addition_chunks: Dictionary[Vector2i, PackedByteArray]
var bitmask_chunks: Dictionary[Vector2i, BitMap]
var passthrough_chunks: Dictionary[Vector2i, BitMap]
var chunk_bodies: Dictionary[Vector2i, StaticBody2D]
var passthrough_polygons: Dictionary[Vector2i, Node2D]
var maskable_rects: Dictionary[Maskable, Rect2i]
var maskable_drawn: Dictionary[Maskable, bool]


func _on_mask_joined(maskable: Maskable) -> void:
	print("Joined: ", maskable)
	maskable.disabled = true
	maskable_rects[maskable] = Rect2i(maskable.to_global(maskable.top_left), maskable.size)
	maskable_drawn[maskable] = false
	update_mask(maskable)


func _on_mask_freed(maskable: Maskable) -> void:
	print("Left: ", maskable)
	maskable.disabled = not maskable.is_included()
	update_mask(maskable, true)
	if maskable in maskable_rects:
		maskable_rects.erase(maskable)


func watch_masks() -> void:
	for maskable: Maskable in maskable_rects:
		var old_rect := maskable_rects[maskable]
		var rect := Rect2i(maskable.to_global(maskable.top_left), maskable.size)

		if old_rect != rect:
			if maskable_drawn[maskable]:
				mask_rect(old_rect, -1)
				mask_rect(rect, 1)
			maskable_rects[maskable] = rect


func update_masks(red_changed: bool, green_changed: bool, blue_changed: bool) -> void:
	for maskable: Maskable in maskable_rects:
		if ((red_changed and maskable.red_mask)
			or (green_changed and maskable.green_mask)
			or (blue_changed and maskable.blue_mask)):
			update_mask(maskable)


func update_mask(maskable: Maskable, remove := false) -> void:
	if maskable not in maskable_drawn:
		return
	
	if (not maskable.is_included() or remove) and maskable_drawn[maskable]:
		if maskable in maskable_rects:
			mask_rect(maskable_rects[maskable], -1)

		maskable_drawn[maskable] = false
	elif maskable.is_included() and not maskable_drawn[maskable]:
		mask_rect(maskable_rects[maskable], 1)
		maskable_drawn[maskable] = true


func mask_rect(rect: Rect2i, delta: int) -> void:
	var tl_chunk := Vector2i((rect.position / float(CHUNK_SIZE)).floor())
	var br_chunk := Vector2i((rect.end / float(CHUNK_SIZE)).ceil())

	for chunk_y: int in range(tl_chunk.y, br_chunk.y):
		var start_y := 0 if chunk_y != tl_chunk.y else posmod(rect.position.y, CHUNK_SIZE)
		var end_y := CHUNK_SIZE if chunk_y != br_chunk.y - 1 \
			else (CHUNK_SIZE if posmod(rect.end.y, CHUNK_SIZE) == 0 else posmod(rect.end.y, CHUNK_SIZE))

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

			var passthrough_chunk: BitMap
			if chunk in passthrough_chunks:
				passthrough_chunk = passthrough_chunks[chunk]
			else:
				passthrough_chunk = BitMap.new()
				passthrough_chunk.create(Vector2i(CHUNK_SIZE, CHUNK_SIZE))
				passthrough_chunks[chunk] = passthrough_chunk

			var start_x := 0 if chunk_x != tl_chunk.x else posmod(rect.position.x, CHUNK_SIZE)
			var end_x := CHUNK_SIZE if chunk_x != br_chunk.x - 1 \
				else (CHUNK_SIZE if posmod(rect.end.x, CHUNK_SIZE) == 0 else posmod(rect.end.x, CHUNK_SIZE))

			for y in range(start_y, end_y):
				for x in range(start_x, end_x):
					var cumulative := addition_chunk[y * CHUNK_SIZE + x] + delta
					addition_chunk[y * CHUNK_SIZE + x] = cumulative
					bitmask_chunk.set_bit(x, y, cumulative % 2 == 1) # Solid when odd
					passthrough_chunk.set_bit(x, y, (cumulative % 2 == 0) and cumulative != 0)


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

		for polygon: PackedVector2Array in bitmask_chunks[chunk].opaque_to_polygons(
				Rect2i(Vector2i(0, 0), Vector2i(CHUNK_SIZE, CHUNK_SIZE)), 0.0):
			var poly := CollisionPolygon2D.new()
			poly.polygon = polygon
			chunk_body.add_child(poly)

		var passthrough_polygon: Node2D
		if chunk in passthrough_polygons:
			passthrough_polygon = passthrough_polygons[chunk]
		else:
			passthrough_polygon = Node2D.new()
			passthrough_visualizer.add_child(passthrough_polygon)
			passthrough_polygon.global_position = Vector2(chunk) * CHUNK_SIZE
			passthrough_polygon.use_parent_material = true
			passthrough_polygons[chunk] = passthrough_polygon

		for child: Node in passthrough_polygon.get_children():
			child.queue_free()

		for polygon: PackedVector2Array in passthrough_chunks[chunk].opaque_to_polygons(
				Rect2i(Vector2i(0, 0), Vector2i(CHUNK_SIZE, CHUNK_SIZE)), 0.0):
			var poly := Polygon2D.new()
			poly.polygon = polygon
			poly.use_parent_material = true
			passthrough_polygon.add_child(poly)

	dirty_chunks = {}
