extends Area2D

var tip_scn = preload("res://Scenes/weapon_tip.tscn")
var tip = preload("res://sprites/weapon tips/grapple tip.png")

func _ready() -> void:
	if GameManager.grapple_unlocked:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.grapple_unlocked = true
		body.can_grapple = true
		var wt_instance = tip_scn.instantiate()
		wt_instance.given_texture = tip
		get_parent().add_child(wt_instance)
		queue_free()
