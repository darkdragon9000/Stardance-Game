extends RigidBody2D

@export var move_speed : int
var impulse_applied := false
var explosion = preload("res://Scenes/explosion.tscn")
@onready var explode_timer: Timer = $ExplodeTimer
@onready var area_2d: Area2D = $Area2D
var hit_by_rocket := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explode_timer.start()
	add_to_group("mines")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not impulse_applied:
		var direction = (get_global_mouse_position() - global_position).normalized()
		state.apply_central_impulse(direction * move_speed)
		impulse_applied = true


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("pistol_bullets"):
		explode_timer.stop()
		var explosion_instance = explosion.instantiate()
		explosion_instance.global_position = global_position
		get_parent().add_child(explosion_instance)
		GameManager.hitstop(0.3)
		GameManager.screen_shake(10, 0.15)
		queue_free()
	if body.is_in_group("rockets"):
		explode_timer.stop()
		hit_by_rocket = true
		var explosion_instance = explosion.instantiate()
		explosion_instance.global_position = global_position
		explosion_instance.explosion_strength *= 1.2
		print(explosion_instance.explosion_strength)
		explosion_instance.scale *= 1.2
		get_parent().add_child(explosion_instance)
		GameManager.hitstop(0.3)
		GameManager.screen_shake(10, 0.15)
		queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("explosions") and not hit_by_rocket and explode_timer.time_left > 0:
		print("debug")
		explode_timer.stop()
		var explosion_instance = explosion.instantiate()
		explosion_instance.global_position = global_position
		explosion_instance.explosion_strength *= 1.5
		print(explosion_instance.explosion_strength)
		explosion_instance.scale *= 1.2
		get_parent().add_child(explosion_instance)
		GameManager.hitstop(0.5)
		GameManager.screen_shake(20, 0.15)
		queue_free()


func _on_explode_timer_timeout() -> void:
	var explosion_instance = explosion.instantiate()
	explosion_instance.global_position = global_position
	get_parent().add_child(explosion_instance)
	queue_free()
