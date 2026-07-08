extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var despawn_timer: Timer = $DespawnTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var explosion_strength = 160
func _ready() -> void:
	despawn_timer.start()
	add_to_group("explosions")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player.exploded = true
		player.apply_recoil(global_position, explosion_strength, true)
		queue_free()


func _on_despawn_timer_timeout() -> void:
	queue_free()
