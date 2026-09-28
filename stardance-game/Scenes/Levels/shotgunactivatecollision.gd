extends Area2D

func _ready() -> void:
	if GameManager.shotgun_unlocked:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.shotgun_unlocked = true
		body.can_shoot_shotgun = true
		queue_free()
