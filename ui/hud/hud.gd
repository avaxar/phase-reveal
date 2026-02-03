extends Control


@onready var mask_red := $TopRight/Masks/MaskRed
@onready var mask_green := $TopRight/Masks/MaskGreen
@onready var mask_blue := $TopRight/Masks/MaskBlue
@onready var label: Label = $TopLeft/Label


func _ready():
	Manager.mask_changed.connect(_on_mask_changed)
	_on_mask_changed(true, true, true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mask_red"):
		Manager.red_mask = !Manager.red_mask
	elif event.is_action_pressed("mask_green"):
		Manager.green_mask = !Manager.green_mask
	elif event.is_action_pressed("mask_blue"):
		Manager.blue_mask = !Manager.blue_mask

func _process(_delta: float) -> void:
	label.text = str(Manager.current_level)

func _on_mask_red_pressed() -> void:
	Manager.red_mask = !Manager.red_mask


func _on_mask_green_pressed() -> void:
	Manager.green_mask = !Manager.green_mask


func _on_mask_blue_pressed() -> void:
	Manager.blue_mask = !Manager.blue_mask


func _on_mask_changed(red_changed: bool, green_changed: bool, blue_changed: bool) -> void:
	if red_changed:
		mask_red.modulate = Color(1.0, 1.0, 1.0, 1.0) if Manager.red_mask else Color(1.0, 1.0, 1.0, 0.25)
	if green_changed:
		mask_green.modulate = Color(1.0, 1.0, 1.0, 1.0) if Manager.green_mask else Color(1.0, 1.0, 1.0, 0.25)
	if blue_changed:
		mask_blue.modulate = Color(1.0, 1.0, 1.0, 1.0) if Manager.blue_mask else Color(1.0, 1.0, 1.0, 0.25)
