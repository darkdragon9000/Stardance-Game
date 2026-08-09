extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("obstacles")

func _process(delta: float) -> void:
	sprite_2d.rotation += delta * 7

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.die()
