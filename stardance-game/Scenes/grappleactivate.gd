extends Area2D

func _ready() -> void:
	if GameManager.grapple_unlocked:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.grapple_unlocked = true
		body.can_grapple = true
		queue_free()
