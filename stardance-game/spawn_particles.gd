extends GPUParticles2D

@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D
@onready var gpu_particles_2d_2: GPUParticles2D = $GPUParticles2D2

func _ready() -> void:
	emitting = true
	gpu_particles_2d.emitting = true
	gpu_particles_2d_2.emitting = true

func _on_gpu_particles_2d_2_finished() -> void:
	queue_free()
