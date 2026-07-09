extends Camera2D

var shake_strength := 0.0
var shake_time_passed := 0.0

var shake_decay := 5.0

var shake_time := 0.0
var shake_time_speed := 20.0

var noise = FastNoiseLite.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_time_passed > 0:
		shake_time += delta * shake_time_speed
		shake_time_passed -= delta
		
		offset = Vector2(noise.get_noise_2d(shake_time, 0) * shake_strength, noise.get_noise_2d(0, shake_time) * shake_strength)
	
		shake_strength = max(shake_strength - (shake_decay * delta), 0)
	else:
		offset = lerp(offset, Vector2.ZERO, 1)

func screen_shake(strength: int, time: float) -> void:
	randomize()
	noise.seed = randi()
	noise.frequency = 2
	
	shake_strength = strength
	shake_time_passed = time
	shake_time = 0.0
