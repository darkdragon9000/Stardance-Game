extends Line2D

@export var length : int

@onready var bullet: RigidBody2D = $".."
var offset := Vector2.ZERO

func _ready() -> void:
	offset = global_position
	top_level = true

func _physics_process(_delta: float):
	var point = global_position + offset
	point = bullet.global_position
	add_point(point, 0)
	if get_point_count() > length:
		remove_point(get_point_count() - 1)
