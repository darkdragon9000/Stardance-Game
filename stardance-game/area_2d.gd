extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.set_physics_process(false)  # stop the player moving mid-glitch
		match get_tree().current_scene.name:
			"level1":
				Transition.go_to("res://Scenes/level_2.tscn")
