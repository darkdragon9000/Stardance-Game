extends Area2D

var spawn_particles = preload("res://spawn_particles.tscn")
@onready var sprite_2d: Sprite2D = $Sprite2D
var initial_pos := global_position
var time := 0.0
func _process(delta: float) -> void:
	time += delta
	sprite_2d.global_position.y += sin(rad_to_deg(time/20))/2
	#print(sin(rad_to_deg(time)))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.spawn_pos = global_position
		var particles_instance = spawn_particles.instantiate()
		particles_instance.global_position = global_position
		get_parent().add_child(particles_instance)
		queue_free()
