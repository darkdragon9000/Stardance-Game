extends Node2D

@export var range = 200
@export var falloff_speed = 1.02
@onready var rays := [$RayCast2D,$RayCast2D2, $RayCast2D3, $RayCast2D4, $RayCast2D5, $RayCast2D6, $RayCast2D7]
@onready var cpu_particles_2d = $CPUParticles2D


func _ready():
	add_to_group("shotgun shells")

func fire():
	var total: float
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var hit_distance = ray.get_collision_point().distance_to(global_position)
			var normalized = hit_distance / range
			var falloff = pow(1.0 - normalized, falloff_speed)
			total += falloff
	total = total / rays.size()
	cpu_particles_2d.emitting = true
	return total

func _on_timer_timeout():
	queue_free()
