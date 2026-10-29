extends CanvasLayer

@onready var label_2: Label = $"9PatchRect/Label2"
@onready var label_3: Label = $"9PatchRect/Label3"
@onready var h_slider: HSlider = $"9PatchRect/HSlider"
@onready var h_slider_2: HSlider = $"9PatchRect/HSlider2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible and is_instance_valid(h_slider) and is_instance_valid(h_slider_2):
		label_2.text = "Music Volume: " + str(h_slider.value) + "%"
		label_3.text = "Sfx Volume: " + str(h_slider_2.value) + "%"
	if is_instance_valid(h_slider) and is_instance_valid(h_slider_2) and not GameManager.intro_sequence:
		GameManager.bg_music.volume_db = linear_to_db(h_slider.value/100)
		GameManager.sfx_volume = linear_to_db(h_slider_2.value/100)


func _on_button_pressed() -> void:
	visible = false
