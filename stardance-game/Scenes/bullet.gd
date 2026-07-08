extends RigidBody2D


# Called when the node enters the scene tree for the first time.
var bulletSpeed = 2500
@onready var timer: Timer = $Timer


func _ready() -> void:
	linear_velocity = Vector2(bulletSpeed, 0).rotated(rotation)
	timer.start()
	add_to_group("pistol_bullets")

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("rockets") or body.is_in_group("mines"):
		queue_free()
	
