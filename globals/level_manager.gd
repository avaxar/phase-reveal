extends Node

@export var levels: Dictionary[PackedScene, bool] #locked = false, unlocked = true
var current_level: int = 1

func get_level_total() -> int:
	return levels.size()

func load_level(level: int): #Use Level Number 1-6
	get_tree().change_scene_to_packed(levels.keys()[level - 1])

func load_next_level() -> void: #Loads next level
	current_level += 1
	unlock_level(current_level)
	load_level(current_level)

func is_level_available(level: int) -> bool:
	return levels.values()[level - 1]
	
func unlock_level(level: int):
	levels.values()[level - 1] = true
