extends CanvasLayer

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible_ratio = 0
	await get_tree().create_timer(1.0).timeout
	match get_tree().get_first_node_in_group("Levels"):
		"level1":
			label.text = "Storage"
		"level2":
			label.text = "power supply"
	var text_tween = create_tween()
	text_tween.tween_property(label, "visible_ratio", 1.0, 0.5)
	await get_tree().create_timer(1.5).timeout
	text_tween.tween_property(label, "visible_ratio", 0.0, 0.5)
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
