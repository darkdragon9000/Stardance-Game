extends Area2D

func _ready() -> void:
	if GameManager.rocket_unlocked:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.rocket_unlocked = true
		body.can_shoot_rocket = true
		GameManager.mine_unlocked = true
		body.can_shoot_mine = true
		queue_free()
