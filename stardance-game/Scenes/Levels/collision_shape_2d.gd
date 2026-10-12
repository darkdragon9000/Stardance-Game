extends Area2D

func _ready():
	pass

func _on_body_entered(body):
	if body.is_in_group("player"): 
		print("entered")
		GameManager.pistol_unlocked = true
		body.can_shoot_pistol = true
		GameManager.pistol_unlock()
		queue_free()
