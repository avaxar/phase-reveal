extends Control
@export var level_number: int
@onready var level_label: Label = $TextureButton/LevelLabel
@onready var lock: TextureRect = $TextureButton/Lock

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_label.text = str(level_number)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
