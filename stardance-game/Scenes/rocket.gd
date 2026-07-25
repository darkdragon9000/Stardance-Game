extends RigidBody2D


# Called when the node enters the scene tree for the first time.
@export var bulletSpeed: int
@onready var timer: Timer = $Timer
var explosion = preload("res://Scenes/explosion.tscn")


func _ready() -> void:
	linear_velocity = Vector2(bulletSpeed, 0).rotated(rotation)
	timer.start()
	add_to_group("rockets")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player") and not body.is_in_group("explosions"):
		var explosion_instance = explosion.instantiate()
		explosion_instance.global_position = global_position
		get_parent().add_child(explosion_instance)
		if body.is_in_group("mines") or body.is_in_group("pistol_bullets") or body.is_in_group("rockets"):
			GameManager.hitstop(0.3)
			GameManager.screen_shake(10, 0.15)
		queue_free()

func reset_velocity() -> void:
	linear_velocity = Vector2(bulletSpeed, 0).rotated(rotation)
