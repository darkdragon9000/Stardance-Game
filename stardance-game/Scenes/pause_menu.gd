extends CanvasLayer

@onready var texture_rect: TextureRect = $TextureRect
@onready var button: Button = $Button
@onready var button_2: Button = $Button2
@onready var button_3: Button = $Button3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pause() -> void:
	print(visible)
	get_tree().paused = true
	GameManager.music_volume *= 0.5
	visible = true
	texture_rect.global_position.x = -750
	button.global_position.x = -750
	button_2.global_position.x = -750
	button_3.global_position.x = -750
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_QUINT)
	var tween3 = create_tween()
	tween3.set_ease(Tween.EASE_OUT)
	tween3.set_trans(Tween.TRANS_QUART)
	var tween4 = create_tween()
	tween4.set_ease(Tween.EASE_OUT)
	tween4.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(texture_rect, "global_position", Vector2(0,0), 1)
	tween2.tween_property(button, "global_position", Vector2(0,188), 1)
	tween3.tween_property(button_2, "global_position", Vector2(0,408), 1)
	tween4.tween_property(button_3, "global_position", Vector2(0,638), 1)


func _on_button_pressed() -> void:
	print(visible)
	get_tree().paused = false
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_EXPO)
	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_IN)
	tween2.set_trans(Tween.TRANS_QUINT)
	var tween3 = create_tween()
	tween3.set_ease(Tween.EASE_IN)
	tween3.set_trans(Tween.TRANS_QUART)
	var tween4 = create_tween()
	tween4.set_ease(Tween.EASE_IN)
	tween4.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(texture_rect, "global_position", Vector2(-750,0), 0.5)
	tween2.tween_property(button, "global_position", Vector2(-750,188), 0.5)
	tween3.tween_property(button_2, "global_position", Vector2(-750,408), 0.5)
	tween4.tween_property(button_3, "global_position", Vector2(-750,638), 0.5)
	await tween4.finished
	visible = false


func _on_button_3_pressed() -> void:
	GameManager.spawning = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	get_tree().paused = false
	visible = false
	texture_rect.global_position.x = -750
	button.global_position.x = -750
	button_2.global_position.x = -750
	button_3.global_position.x = -750


func _on_button_2_pressed() -> void:
	print("pressed")
	Configuremenu.appear()
