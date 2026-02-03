class_name ColorBlind
extends ColorRect


static var type := 0
const types_n := 4
var current_type := -1


func _process(_delta: float):
	if current_type != type:
		current_type = type
		material.set_shader_parameter("mode", type - 1)
