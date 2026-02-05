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

var passthrough_meshes: Array[MeshInstance2D]


func _ready():
	Manager.music_playing = true
	Manager.red_mask = default_red
	Manager.green_mask = default_green
	Manager.blue_mask = default_blue

	camera.limit_right = end.position.x


func _on_end_body_entered(body: Node2D) -> void:
	if body is Player:
		Manager.loading = true
		await transition.close()
		Manager.loading = false
		Manager.load_next_level()


func _process(_delta: float) -> void:
	draw_visualizer()


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
