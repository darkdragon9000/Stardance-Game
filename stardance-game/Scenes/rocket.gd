extends RigidBody2D


# Called when the node enters the scene tree for the first time.
var bulletSpeed = 1200
@onready var timer: Timer = $Timer

func _ready() -> void:
	linear_velocity = Vector2(bulletSpeed, 0).rotated(rotation)
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()
