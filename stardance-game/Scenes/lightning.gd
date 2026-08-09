extends AnimatedSprite2D


@onready var lightning_timer: Timer = $LightningTimer
@onready var flash: AnimatedSprite2D = $Flash

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	flash.frame = 5
	frame = 7
	lightning_timer.wait_time = randf_range(0.05, 1.5)
	lightning_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_lightning_timer_timeout() -> void:
	scale = Vector2(randf_range(0.3, 1.5), randf_range(0.3, 1.5))
	position = Vector2(randf_range(-250, 250), randf_range(-50, 100 * scale.y))
	flash.global_scale = Vector2(2,2)
	animation = str(randi_range(1, 3))
	rotation = deg_to_rad(randf_range(-15, 15))
	if scale.y <= 0.8:
		position.y -= 80
	flash.global_rotation = 0
	play()
	if scale.x >= 1.4 or scale.y >= 1.4:
		flash.play()
	lightning_timer.wait_time = randf_range(0.05, 3.0)
