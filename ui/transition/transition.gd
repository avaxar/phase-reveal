extends Control


@onready var sprite := $AnimatedSprite


func _ready() -> void:
    sprite.play("open")
    Manager.on_player_death.connect(_on_player_death)


func _on_player_death() -> void:
    await get_tree().create_timer(0.6).timeout
    sprite.play("close")


func close() -> void:
    sprite.play("close")
    await get_tree().create_timer(0.4).timeout
