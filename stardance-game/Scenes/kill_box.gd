extends Area2D

func _ready() -> void:
	add_to_group("lasers")

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.die()
