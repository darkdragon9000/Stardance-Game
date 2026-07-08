extends RigidBody2D

@export var move_speed : int
var impulse_applied := false
var explosion = preload("res://Scenes/explosion.tscn")
@onready var explode_timer: Timer = $ExplodeTimer
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



func _on_explode_timer_timeout() -> void:
	var explosion_instance = explosion.instantiate()
	explosion_instance.global_position = global_position
	get_parent().add_child(explosion_instance)
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("pistol_bullets"):
		explode_timer.stop()
		var explosion_instance = explosion.instantiate()
		explosion_instance.global_position = global_position
		get_parent().add_child(explosion_instance)
		queue_free()
	if body.is_in_group("rockets") or body.is_in_group("explosions"):
		explode_timer.stop()
		var explosion_instance = explosion.instantiate()
		explosion_instance.global_position = global_position
		explosion_instance.explosion_strength *= 1.5
		explosion_instance.scale *= 1.5
		get_parent().add_child(explosion_instance)
		queue_free()
