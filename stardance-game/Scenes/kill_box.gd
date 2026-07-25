extends Area2D

@onready var player: CharacterBody2D = $"../Player"

func _on_body_entered(body):
	if body.is_in_group("player"):
		GameManager.die()
