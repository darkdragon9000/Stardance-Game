extends AnimatedSprite2D


@onready var lightning_timer: Timer = $LightningTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frame = 7
	lightning_timer.wait_time = randf_range(0.05, 1.5)
	lightning_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_lightning_timer_timeout() -> void:
	position = Vector2(randf_range(-250, 250), randf_range(0, 150))
	scale = Vector2(randf_range(0.5, 1.5), randf_range(0.5, 1.5))
	animation = str(randi_range(1, 3))
	if animation != "1":
		rotation = deg_to_rad(randf_range(-15, 15))
	else:
		rotation = deg_to_rad(randf_range(-5, 5))
	print(rad_to_deg(rotation))
	position.y += (1 - scale.y) * 20
	play()
	lightning_timer.wait_time = randf_range(0.05, 3.0)
