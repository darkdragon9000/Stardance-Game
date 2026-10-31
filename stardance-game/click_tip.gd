extends Node2D

@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_rect.modulate = Color(1,1,1,0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var t = create_tween()
	texture_rect.modulate
	t.tween_property(texture_rect, "modulate", Color(1,1,1,1), 1.0)
	if Input.is_action_just_pressed("shoot"):
		queue_free()
