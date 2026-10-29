extends CanvasLayer

@onready var rect: ColorRect = $ColorRect
var mat: ShaderMaterial
var busy := false
var level_text = preload("res://level_text.gd")

func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	mat = rect.material
	_set_intensity(0.0)
	_set_cover(0.0)

func _set_intensity(v: float) -> void:
	mat.set_shader_parameter("intensity", v)

func _set_cover(v: float) -> void:
	mat.set_shader_parameter("cover", v)

func go_to(path: String) -> void:
	if busy:
		return
	busy = true

	GameManager.bg_music.stop()
	var glitch_sfx := AudioStreamPlayer.new()
	glitch_sfx.stream = preload("res://Songs/dragon-studio-glitch-sound-effect-450447.mp3")
	add_child(glitch_sfx)
	glitch_sfx.play()

	# glitch up, then bars cut to black
	var t := create_tween()
	t.tween_method(_set_intensity, 0.0, 1.0, 0.45).set_ease(Tween.EASE_IN)
	t.tween_method(_set_cover, 0.0, 1.0, 0.25)
	await t.finished

	await get_tree().create_timer(1.5).timeout
	GameManager.player.camera_2d.zoom = Vector2(2.5,2.5)
	GameManager.do_spawn = true
	GameManager.spawning = true
	GameManager.particles_up = false
	get_tree().paused = false
	GameManager.popup_rep = 0
	get_tree().change_scene_to_file(path)
	await get_tree().create_timer(0.1).timeout
	GameManager.reloaded = true
	GameManager.bg_music.stream = preload("res://Songs/VECTORIZE_SURGE.mp3")
	GameManager.bg_music.volume_db = -20.0
	GameManager.bg_music.play()
	
	# bars clear, glitch settles
	var music_tween = create_tween()
	t = create_tween()
	music_tween.tween_property(GameManager.bg_music, "volume_db", GameManager.music_volume, 0.5)
	t.tween_method(_set_cover, 1.0, 0.0, 0.25)
	t.tween_method(_set_intensity, 1.0, 0.0, 0.4).set_ease(Tween.EASE_OUT)
	await t.finished
	busy = false
	await get_tree().create_timer(2.5).timeout
