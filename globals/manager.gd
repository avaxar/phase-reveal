extends Node

var attempts: int = 0
signal on_player_death

@export var levels: Dictionary[PackedScene, bool] # locked = false, unlocked = true
var current_level := 1

func reset_level() -> void:
	attempts += 1
	load_level(current_level)

func emit_on_player_death() -> void:
	on_player_death.emit()
	await get_tree().create_timer(1.0).timeout
	reset_level()

func get_level_total() -> int:
	return levels.size()

var current_scene: Node
func load_level(level: int): # Uses level numbers 1-6
	if get_tree().current_scene != null:
		current_scene = get_tree().current_scene
	
	print(levels.keys()[level - 1])
	#get_tree().change_scene_to_packed(levels.keys()[level - 1])
	var next_level = levels.keys()[level - 1].instantiate()
	var root_node = current_scene.get_parent()
	current_scene.queue_free()
	root_node.add_child(next_level)
	current_scene = next_level


func load_next_level() -> void: # Loads the next level
	current_level += 1
	unlock_level(current_level)
	load_level(current_level)


func is_level_available(level: int) -> bool:
	return levels.values()[level - 1]


func unlock_level(level: int):
	levels.values()[level - 1] = true


# --- Persisting mechanics ---

signal mask_changed(red_changed: bool, green_changed: bool, blue_changed: bool)

@export var red_mask := false:
	set(value):
		if red_mask != value:
			red_mask = value
			mask_changed.emit(true, false, false)

@export var green_mask := false:
	set(value):
		if green_mask != value:
			green_mask = value
			mask_changed.emit(false, true, false)

@export var blue_mask := false:
	set(value):
		if blue_mask != value:
			blue_mask = value
			mask_changed.emit(false, false, true)
