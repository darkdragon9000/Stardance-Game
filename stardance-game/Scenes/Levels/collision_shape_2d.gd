extends Area2D

func _ready():
	if GameManager.pistol_unlocked:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"): 
		print("entered")
		GameManager.pistol_unlocked = true
		body.can_shoot_pistol = true
		queue_free()
