extends CanvasLayer

@onready var texture_rect: TextureRect = $CanvasLayer/TextureRect
var given_texture
var can_disappear := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_rect = get_child(0)
	print(given_texture)
	texture_rect.texture = given_texture
	visible = true
	print(texture_rect.texture)
	await get_tree().create_timer(3.0).timeout
	can_disappear = true


func _on_button_pressed() -> void:
	if can_disappear:
		queue_free()
	else:
		return
