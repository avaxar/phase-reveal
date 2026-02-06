class_name Maskable
extends AnimatableBody2D


@export var unmaskable := false
@export var red_mask := false
@export var green_mask := false
@export var blue_mask := false


@onready var mask_area := $MaskArea
@onready var mask_area_shape := $MaskArea/CollisionShape


var _bypass_setter := false # This is so inelegant

@export var top_left := Vector2i(-8, -8):
	set(value):
		top_left = value
		if not is_inside_tree():
			await ready

		if not _bypass_setter:
			mask_area.position = (value + bottom_right) / 2.0
			mask_area_shape.shape.size = Vector2(bottom_right - value)

			_bypass_setter = true
			bottom_right = Vector2i(mask_area.position + mask_area_shape.shape.size / 2)
			_bypass_setter = false

@export var bottom_right := Vector2i(8, 8):
	set(value):
		bottom_right = value
		if not is_inside_tree():
			await ready

		if not _bypass_setter:
			mask_area.position = (top_left + value) / 2.0
			mask_area_shape.shape.size = Vector2(value - top_left)

			_bypass_setter = true
			top_left = Vector2i(mask_area.position - mask_area_shape.shape.size / 2)
			_bypass_setter = false

var size: Vector2i:
	get:
		return bottom_right - top_left

var global_rect: Rect2i:
	get:
		return Rect2i(to_global(top_left), to_global(bottom_right) - to_global(top_left))


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	Manager.mask_changed.connect(_on_mask_changed)
	_on_mask_changed(true, true, true)


func is_included() -> bool:
	if Engine.is_editor_hint():
		return true
	else:
		return unmaskable or bool(
			int(red_mask and Manager.red_mask)
			^ int(green_mask and Manager.green_mask)
			^ int(blue_mask and Manager.blue_mask)
		)


# -- Masking logic! --

var intersecting: Array[Maskable]
var divisions: Dictionary[Rect2i, int]
var colliders: Array[CollisionShape2D]
static var rect_to_collider: Dictionary[Rect2i, CollisionShape2D]
static var rect_to_speed: Dictionary[Rect2i, float]


func _on_mask_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is not Maskable:
		return

	var maskable: Maskable = area.get_parent()
	intersecting.append(maskable)

	reset_mask(false)


func _on_mask_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is not Maskable:
		return

	var maskable: Maskable = area.get_parent()
	intersecting.remove_at(intersecting.find(maskable))

	reset_mask(false)


var previous_rect := global_rect
var speed := 0.0
func _physics_process(delta: float) -> void:
	if global_rect == previous_rect:
		return
	else:
		speed = ((global_rect.position - previous_rect.position)).length() / delta
		previous_rect = global_rect

	# if len(intersecting) == 0:
	# 	return

	reset_mask()


func _on_mask_changed(red_changed: bool, green_changed: bool, blue_changed: bool) -> void:
	if (len(intersecting) > 0
		or (red_changed and red_mask)
		or (green_changed and green_mask)
		or (blue_changed and blue_mask)):
		reset_mask()


func reset_mask(chaining := true):
	if Engine.is_editor_hint():
		return

	if chaining:
		for maskable: Maskable in intersecting:
			maskable.reset_mask(false)

	if not is_included():
		divisions = {}
		for collider: CollisionShape2D in colliders:
			collider.set_deferred("disabled", true)
		return

	divisions = {global_rect: 1}
	for maskable: Maskable in intersecting:
		if not maskable.is_included():
			continue

		var new_divisions: Dictionary[Rect2i, int] = {}
		for division: Rect2i in divisions:
			var count := divisions[division]
			var partitions := partition_rect(division, maskable.global_rect)
			for partition: Rect2i in partitions:
				if partitions[partition]:
					new_divisions[partition] = count + 1
				else:
					new_divisions[partition] = count

		divisions = new_divisions

	if len(divisions) > len(colliders):
		for i in range(len(divisions) - len(colliders)):
			var collider := CollisionShape2D.new()
			collider.shape = RectangleShape2D.new()
			collider.disabled = true
			call_deferred("add_child", collider)
			colliders.append(collider)
	elif len(divisions) < len(colliders):
		for i: int in range(len(divisions), len(colliders)):
			colliders[i].set_deferred("disabled", true)

	for i: int in range(len(divisions)):
		var division: Rect2i = divisions.keys()[i]
		var count := divisions[division]
		var collider := colliders[i]

		if count % 2 == 1:
			var local_division := Rect2(
				to_local(division.position),
				to_local(division.end) - to_local(division.position)
			)

			collider.set_deferred("disabled", false)
			collider.position = local_division.get_center()
			collider.shape.size = local_division.size

			var existing_speed := rect_to_speed[division] if division in rect_to_speed else 0.0
			if speed >= existing_speed:
				if (division in rect_to_collider and rect_to_collider[division] != null
					and rect_to_collider[division] != collider):
					rect_to_collider[division].set_deferred("disabled", true)

				rect_to_collider[division] = collider
				rect_to_speed[division] = speed
		else:
			collider.set_deferred("disabled", true)


static func partition_rect(rect: Rect2i, mask: Rect2i) -> Dictionary[Rect2i, bool]:
	var result: Dictionary[Rect2i, bool] = {}

	# Central segment
	var intersection := rect.intersection(mask)
	if intersection.has_area():
		result[intersection] = true
	else:
		# No overlap
		result[rect] = false
		return result

	# Top segment
	if intersection.position.y > rect.position.y:
		result[Rect2i(
			Vector2i(rect.position.x, rect.position.y),
			Vector2i(rect.size.x, intersection.position.y - rect.position.y)
		)] = false

	# Bottom segment
	if intersection.end.y < rect.end.y:
		result[Rect2i(
			Vector2i(rect.position.x, intersection.end.y),
			Vector2i(rect.size.x, rect.end.y - intersection.end.y)
		)] = false

	# Left segment
	if intersection.position.x > rect.position.x:
		result[Rect2i(
			Vector2i(rect.position.x, intersection.position.y),
			Vector2i(intersection.position.x - rect.position.x, intersection.size.y)
		)] = false

	# Right segment
	if intersection.end.x < rect.end.x:
		result[Rect2i(
			Vector2i(intersection.end.x, intersection.position.y),
			Vector2i(rect.end.x - intersection.end.x, intersection.size.y)
		)] = false

	return result
