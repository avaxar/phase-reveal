extends Control
class_name GameButton

@export var action_id: String
@export var move_length: Vector2 = Vector2(0, -10)
@export var scale_size: Vector2 = Vector2(1.5, 1.5)
@export var label_text: String = ""

@onready var label: Label = get_node_or_null("TextureButton/Label")
@onready var texture_button: TextureButton = $TextureButton

signal on_button_hover
signal on_button_pressed(action_id)
static var active_button: GameButton = null

var original_scale: Vector2
var original_position: Vector2
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if label != null and !label_text.is_empty():
		label.text = label_text
	original_scale = texture_button.scale
	original_position = texture_button.position

func activate() -> void:
	if active_button and active_button != self:
		active_button.deactivate()
	on_button_hover.emit()
	active_button = self
	tween_button_entered()
	z_index = 1

func deactivate() -> void:
	if active_button == self:
		active_button = null
	tween_button_exitted()
	z_index = 0

func tween_button_entered() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(texture_button, "position", original_position + move_length, 0.1)
	tween.tween_property(self , "scale", original_scale * scale_size, 0.1)
	z_index += 1

func tween_button_exitted() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self , "scale", original_scale, 0.1)
	tween.tween_property(texture_button, "position", original_position, 0.1)
	tween.set_parallel(false)
	z_index = 0

func grab_button_focus() -> void:
	texture_button.grab_focus()

func _on_texture_button_mouse_entered() -> void:
	activate()

func _on_texture_button_mouse_exited() -> void:
	deactivate()

func _on_texture_button_focus_entered() -> void:
	activate()

func _on_texture_button_focus_exited() -> void:
	deactivate()

func _on_texture_button_pressed() -> void:
	on_button_pressed.emit(action_id)
