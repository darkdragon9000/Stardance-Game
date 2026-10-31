extends Area2D

var tip_scn = preload("res://Scenes/weapon_tip.tscn")
var tip = preload("res://sprites/weapon tips/rocket tip.png")

func _ready() -> void:
	if GameManager.rocket_unlocked:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.rocket_unlocked = true
		body.can_shoot_rocket = true
		GameManager.mine_unlocked = true
		body.can_shoot_mine = true
		var wt_instance = tip_scn.instantiate()
		print(wt_instance)
		wt_instance.given_texture = tip
		get_parent().add_child(wt_instance)
		queue_free()
