extends Area2D

@onready var player: CharacterBody2D = $"../Player"
@onready var despawn_timer: Timer = $DespawnTimer
@onready var flash: GPUParticles2D = $Node2D/Flash
@onready var fire: GPUParticles2D = $Node2D/Fire
@onready var smoke: GPUParticles2D = $Node2D/Smoke
@onready var sparks: GPUParticles2D = $Node2D/Sparks
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
var explosion_strength = 160
func _ready() -> void:
	despawn_timer.start()
	add_to_group("explosions")
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player.exploded = true
		player.apply_recoil(global_position, explosion_strength, true)
		collision_shape_2d.disabled = true


func _on_despawn_timer_timeout() -> void:
	collision_shape_2d.disabled = true



func _on_smoke_finished() -> void:
	queue_free()
