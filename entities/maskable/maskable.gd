@tool
class_name Maskable
extends StaticBody2D


@export var red_mask := false
@export var green_mask := false
@export var blue_mask := false


@onready var collision_shape := $CollisionShape
@onready var mask_area := $MaskArea
@onready var mask_area_shape := $MaskArea/CollisionShape


@export var disabled := false:
	set(value):
		if collision_shape == null:
			return

		collision_shape.set_deferred("disabled", value)

var size: Vector2i:
	get:
		if collision_shape == null:
			return Vector2i(0, 0)

		return Vector2i(collision_shape.shape.size)

var _bypass_setter := false # This is so inelegant

@export var top_left := Vector2i(-8, -8):
	set(value):
		if collision_shape == null:
			set_deferred("top_left", value) # Lets the `collision_shape` be instantiated first
			return

		if not _bypass_setter:
			collision_shape.position = (value + bottom_right) / 2.0
			collision_shape.shape.size = Vector2(bottom_right - value)
			mask_area.position = collision_shape.position
			mask_area_shape.shape = collision_shape.shape

		top_left = value
		if not _bypass_setter:
			_bypass_setter = true
			bottom_right = Vector2i(collision_shape.position + collision_shape.shape.size / 2)
			_bypass_setter = false

@export var bottom_right := Vector2i(8, 8):
	set(value):
		if collision_shape == null:
			set_deferred("bottom_right", value) # Lets the `collision_shape` be instantiated first
			return

		if not _bypass_setter:
			collision_shape.position = (top_left + value) / 2.0
			collision_shape.shape.size = Vector2(value - top_left)
			mask_area.position = collision_shape.position
			mask_area_shape.shape = collision_shape.shape

		bottom_right = value
		if not _bypass_setter:
			_bypass_setter = true
			top_left = Vector2i(collision_shape.position - collision_shape.shape.size / 2)
			_bypass_setter = false


var mask_intersection_count := 0
signal mask_joined(maskable: Maskable)
signal mask_freed(maskable: Maskable)


func _on_mask_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is not Maskable:
		return

	mask_intersection_count += 1
	if mask_intersection_count == 1:
		mask_joined.emit(self)


func _on_mask_area_area_exited(area: Area2D) -> void:
	if area.get_parent() is not Maskable:
		return

	mask_intersection_count -= 1
	if mask_intersection_count == 0:
		mask_freed.emit(self)
