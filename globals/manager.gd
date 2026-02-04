extends Node

var attempts: int = 0
var loading := false
signal on_player_death
const TITLE_SCREEN = preload("uid://wncglugrhywk")
const OUTRO = preload("uid://ci5cmglnd0f7w")

@export var levels: Dictionary[PackedScene, bool] # locked = false, unlocked = true
var current_level := 1

func reset_level() -> void:
	attempts += 1
	load_level(current_level)

func emit_on_player_death() -> void: # Play the transition here!
	if loading:
		return

	loading = true
	on_player_death.emit()
	await get_tree().create_timer(1.25).timeout
	reset_level()
	loading = false

func get_level_total() -> int:
	return levels.size()

func load_level(level: int): # Uses level numbers 1-6
	get_tree().change_scene_to_packed(levels.keys()[level - 1])


func load_next_level() -> void: # Loads the next level
	if current_level >= get_level_total():
		play_outro()
		return

	current_level += 1
	unlock_level(current_level)
	load_level(current_level)


func is_level_available(level: int) -> bool:
	return levels.values()[level - 1]


func unlock_level(level: int):
	levels[levels.keys()[level - 1]] = true
	print(levels)

func play_outro() -> void:
	get_tree().paused = false
	Manager.music_playing = false
	get_tree().change_scene_to_packed(OUTRO)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("unlock_all"):
		for level in levels:
			levels[level] = true
		get_tree().change_scene_to_packed(TITLE_SCREEN)


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


# --- Music ---

@onready var music := $Music

const ON_DB = -0.0
const OFF_DB = -20.0
const MUSIC_TRANS = 0.25


var music_playing := false:
	set(value):
		if music_playing != value:
			music_playing = value
			music.playing = value

var red_volume: float:
	get:
		if music == null:
			return 0.0

		return music.stream.get_sync_stream_volume(1)

	set(value):
		music.stream.set_sync_stream_volume(1, value)

var green_volume: float:
	get:
		return music.stream.get_sync_stream_volume(2)

	set(value):
		music.stream.set_sync_stream_volume(2, value)

var blue_volume: float:
	get:
		return music.stream.get_sync_stream_volume(3)

	set(value):
		music.stream.set_sync_stream_volume(3, value)

var music_beat := 0.0


func _process(_delta: float) -> void:
	if music_playing:
		var loop_music: AudioStreamOggVorbis = music.stream.get_sync_stream(0)
		var timestamp: float = music.get_playback_position() + (
			AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
		)
		timestamp = fmod(timestamp, loop_music.get_length())
		if timestamp < 0.0:
			music_beat = -1.0
		else:
			music_beat = timestamp / 60.0 * loop_music.bpm


func _on_mask_changed(red_changed: bool, green_changed: bool, blue_changed: bool) -> void:
	if red_changed:
		create_tween().tween_property(self , "red_volume", ON_DB if red_mask else OFF_DB, MUSIC_TRANS)
	if green_changed:
		create_tween().tween_property(self , "green_volume", ON_DB if green_mask else OFF_DB, MUSIC_TRANS)

	if blue_changed:
		create_tween().tween_property(self , "blue_volume", ON_DB if blue_mask else OFF_DB, MUSIC_TRANS)
