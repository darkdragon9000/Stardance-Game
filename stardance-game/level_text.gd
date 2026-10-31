extends CanvasLayer

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label = get_child(0)
	label.visible_ratio = 0.0
	await get_tree().create_timer(1.0).timeout
	match get_tree().get_first_node_in_group("Levels").name:
		"level1":
			label.text = "Storage"
		"Level2":
			label.text = "power supply"
		"level4":
			label.text = "GPU"
	print(label.text)
	var text_tween = create_tween()
	text_tween.tween_property(label, "visible_ratio", 1.0, 0.5)
	text_tween.tween_interval(1.5)
	text_tween.tween_property(label, "visible_ratio", 0.0, 0.5)
	await text_tween.finished
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(label.visible_ratio)
