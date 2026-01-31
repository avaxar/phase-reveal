@tool
extends Container
class_name CircularContainer

@export var y_dev: float = 32.0:
	set(value):
		y_dev = value
		queue_sort()

@export var x_dev: float = 0.0:
	set(value):
		x_dev = value
		queue_sort()

@export var flipped: bool = false:
	set(value):
		flipped = value
		queue_sort()

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		var children = get_children()
		var count: int = children.size()
		if count == 0:
			return
			
		var mid: float = (count - 1) / 2
		
		# Must re-sort the children
		for i in count:
			var c = children[i]
			var dist = abs(mid - i) if flipped else -abs(mid-i)
			c.position = Vector2(dist * x_dev ,i * y_dev)
