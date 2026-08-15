extends Node2D

@export var range = 200
@export var falloff_speed = 1.02
@onready var rays : Array= [$RayCast2D,$RayCast2D2, $RayCast2D3, $RayCast2D4, $RayCast2D5, $RayCast2D6, $RayCast2D7]
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var alt_fire_particles = $AltFireParticles
@onready var smoke: GPUParticles2D = $Smoke
@onready var area_2d: Area2D = $Area2D
var can_hitstop := true

func _ready():
	area_2d.add_to_group("shotgun_shells")

func fire():
	var total: float
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var hit_distance = ray.get_collision_point().distance_to(global_position)
			var normalized = hit_distance / range
			var falloff = pow(1.0 - normalized, falloff_speed)
			total += falloff
			if ray.get_collider().is_in_group("obstacles"):
				total += normalized * 1.5
				print("hit")
				if can_hitstop:
					GameManager.hitstop(0.3)
					can_hitstop = false
			
	can_hitstop = true
	total = total / rays.size()
	gpu_particles_2d.emitting = true
	smoke.emitting = true
	print(total)
	return total

func alt_fire():
	var total: float
	var straight_ray = rays.get(0)
	straight_ray.force_raycast_update()
	if straight_ray.is_colliding():
		var hit_distance = straight_ray.get_collision_point().distance_to(global_position)
		var normalized = hit_distance / range
		var falloff = pow(1.0 - normalized, falloff_speed)
		total += falloff
		if straight_ray.get_collider().is_in_group("obstacles"):
			total += normalized * 1.5
			print("hit")
			if can_hitstop:
					GameManager.hitstop(0.3)
					can_hitstop = false
	alt_fire_particles.emitting = true
	smoke.emitting = true
	return total

func cooldown_check():
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			if ray.get_collider().is_in_group("rockets") or ray.get_collider().is_in_group("mines"):
				return true
			else:
				return false

func _on_timer_timeout():
	queue_free()
