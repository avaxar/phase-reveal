@tool
extends Container
class_name DiagonalContainer

@export var y_dev: float = 32.0:
	set(value):
		y_dev = value
		queue_sort()

@export var x_dev: float = 0.0:
	set(value):
		x_dev = value
		queue_sort()

@export var x_gap_dev: float = 2:
	set(value):
		x_gap_dev = value
		queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		var count: int = 0
		var current_x: float = 0.0
		var increment: float = x_dev
		
		# Must re-sort the children
		for c in get_children():
			c.position = Vector2(current_x, count * y_dev)
			current_x += increment
			increment += x_gap_dev
			count += 1
