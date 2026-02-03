extends Control

@export var frames: Array[TextureRect]
@export var duration: float = 1.0
@export var end_wait_time: float = 2.0

var tween: Tween
var current_index := 0


func _ready():
	for frame in frames:
		frame.modulate.a = 0.0

	play_current_frame()

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		skip_current_frame()

func play_current_frame():
	if current_index > frames.size() - 1:
		await get_tree().create_timer(end_wait_time).timeout
		Manager.unlock_level(1)
		Manager.load_level(1)
		return

	var frame := frames[current_index]

	tween = create_tween()
	tween.tween_property(frame, "modulate:a", 1.0, duration)
	tween.finished.connect(on_frame_finished)

func skip_current_frame():
	if current_index >= frames.size():
		return

	if tween and tween.is_running():
		tween.kill()
		frames[current_index].modulate.a = 1.0

	on_frame_finished()

func on_frame_finished():
	current_index += 1
	play_current_frame()
