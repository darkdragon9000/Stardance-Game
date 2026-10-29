extends AnimatedSprite2D


@onready var lightning_timer: Timer = $LightningTimer
@onready var flash: AnimatedSprite2D = $Flash
var thunder_1 = preload("res://Songs/freesound_community-big-thunder-recorded-in-stereo-with-rain-fall-and-lightning-67697.mp3")
var thunder_2 = preload("res://Songs/tanweraman-big-thunder-rumble-321631.mp3")
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


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
	var thunder = randi_range(1,2)
	scale = Vector2(randf_range(0.3, 1.5), randf_range(0.3, 1.5))
	position = Vector2(randf_range(-250, 250), randf_range(-50, 100 * scale.y))
	flash.global_scale = Vector2(4,4)
	animation = str(randi_range(1, 2))
	rotation = deg_to_rad(randf_range(-15, 15))
	if scale.y <= 0.8:
		position.y -= 80
	flash.global_rotation = 0
	play()
	if scale.x >= 1.4 or scale.y >= 1.4 and not audio_stream_player_2d.playing:
		print("flash")
		match thunder:
			1:
				audio_stream_player_2d.stream = thunder_1
			2:
				audio_stream_player_2d.stream = thunder_2
		flash.play()
		audio_stream_player_2d.play()
	lightning_timer.wait_time = randf_range(0.05, 3.0)
