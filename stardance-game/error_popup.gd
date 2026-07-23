extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var popup = randi_range(1, 4)
	match popup:
		1:
			texture = preload("uid://bnc7l723yrvrg")
		2:
			texture = preload("uid://bm8pdtslhuw7y")
		3:
			texture = preload("uid://bx8dgtewf8uuk")
		4:
			texture = preload("uid://dw3l1nvkmhqlg")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameManager.reloaded:
		queue_free()
