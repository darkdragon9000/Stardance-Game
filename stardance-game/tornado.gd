extends Parallax2D

@onready var particles: GPUParticles2D = $GPUParticles2D

var midline := randf_range(-800, 800)
var target_midline := randf_range(-800, 800)
var amplitude = 25
var time : float
var frequency = 5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(midline)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	midline = move_toward(midline,target_midline, delta * 50)
	if midline == target_midline:
		target_midline = randf_range(-500, 500)
	particles.global_position.x = (amplitude * sin(time*5)) + midline
	frequency = 3 * sin(time * 10) + 5
