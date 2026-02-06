extends Node2D


@export var default_red := false
@export var default_green := false
@export var default_blue := false

@onready var passthrough_visualizer := $PassthroughVisualizer
@onready var player := $Player
@onready var camera := $Player/Camera
@onready var end := $End
@onready var hud := $CanvasLayer/HUD
@onready var transition := $CanvasLayer/Transition


func _ready():
	Manager.music_playing = true
	Manager.red_mask = default_red
	Manager.green_mask = default_green
	Manager.blue_mask = default_blue

	camera.limit_right = end.position.x
	
	Manager.emit_on_level_start()


func _on_end_body_entered(body: Node2D) -> void:
	if body is Player:
		Manager.loading = true
		await transition.close()
		Manager.loading = false
		Manager.load_next_level()


func _physics_process(_delta: float) -> void:
	Maskable.rect_to_collider = {}
	Maskable.rect_to_speed = {}


var highlighting := false
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("highlight"):
		highlighting = not highlighting

		player.can_move = not highlighting
		for platform: Platform in get_tree().get_nodes_in_group("platforms"):
			platform.highlighted = highlighting

		camera.position_smoothing_enabled = not highlighting
		if not highlighting:
			camera.position = Vector2(0.0, 0.0)


func _process(delta: float) -> void:
	draw_visualizer()
	if highlighting:
		handle_camera_movement(delta)


const CAMERA_SPEED := 250.0
func handle_camera_movement(delta: float) -> void:
	var direction := Input.get_axis("left", "right")
	camera.position.x += direction * CAMERA_SPEED * delta

	# Clamps from the sides
	camera.global_position.x = max(camera.limit_left + 480.0 / 2.0, camera.global_position.x)
	camera.global_position.x = min(camera.global_position.x, camera.limit_right - 480 / 2.0)


var passthrough_meshes: Array[MeshInstance2D]
func draw_visualizer() -> void:
	# Uses a makeshift set to get rid of duplicates
	var masked_rects: Dictionary[Rect2i, bool] = {}
	for maskable: Maskable in get_tree().get_nodes_in_group("maskables"):
		for division: Rect2i in maskable.divisions:
			var count := maskable.divisions[division]
			if count != 0 and count % 2 == 0:
				masked_rects[division] = true

	if len(masked_rects) > len(passthrough_meshes):
		for i in range(len(masked_rects) - len(passthrough_meshes)):
			var mesh := MeshInstance2D.new()
			mesh.mesh = QuadMesh.new()
			mesh.visible = false
			mesh.use_parent_material = true
			passthrough_visualizer.add_child(mesh)
			passthrough_meshes.append(mesh)
	elif len(masked_rects) < len(passthrough_meshes):
		for i: int in range(len(masked_rects), len(passthrough_meshes)):
			passthrough_meshes[i].visible = false

	for i: int in len(masked_rects):
		var rect: Rect2i = masked_rects.keys()[i]
		var mesh := passthrough_meshes[i]

		mesh.visible = true
		mesh.position = Rect2(rect).get_center()
		mesh.mesh.size = rect.size
