extends Node

var hitstop_timer : Timer
var popup_timer : Timer
var canvas_layer : CanvasLayer
@onready var debug_lvl: Node = $"."
var player: CharacterBody2D
var error_popup = preload("res://Scenes/texture_rect.tscn")
var spawn_particles = preload("res://spawn_particles.tscn")
var popup_rep := 0
var reloaded := false
var zooming_in := false
var zooming_out := false
var target_zoom : Vector2
var camera_pause_pos : Vector2
var hitstopping := false
var spawn_pos := Vector2(1000,800)
var spawning := true
var particles_up := false
var do_spawn := true
var dying := false
var checkpoint_reached := false
var pistol_unlocked := false
var shotgun_unlocked := false
var rocket_unlocked := false
var mine_unlocked := false
var grapple_unlocked := true
var first_play := false
var platform : StaticBody2D
var waiting_for_shot := false
var click_tooltip : TextureRect
var click_tooltip_alpha = 0
var bg_music : AudioStreamPlayer
var world_environment : WorldEnvironment
var intro_sequence := false
var bass_drop = preload("res://Songs/dragon-studio-drop-the-bass-463664.mp3")
var texture_rect : TextureRect
var texture_rect_2 : TextureRect
var texture_rect_3 : TextureRect
var music_volume := 0.0
var sfx_volume := 0.0
var level : int
var level_text = preload("res://level_text.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().current_scene.name != "MainMenu":
		texture_rect = get_node("/root/" + str(get_tree().get_first_node_in_group("Levels").name) + "/CanvasLayer/Control/TextureRect")
		texture_rect_2 = get_node("/root/" + str(get_tree().get_first_node_in_group("Levels").name) + "/CanvasLayer/Control/TextureRect2")
		texture_rect_3 = get_node("/root/" + str(get_tree().get_first_node_in_group("Levels").name) + "/CanvasLayer/Control/TextureRect3")
	print(get_tree().current_scene.name)
	world_environment = get_tree().get_first_node_in_group("world_environment")
	if get_tree().current_scene.name == "level1":
		print("click gotten")
		click_tooltip = get_tree().get_first_node_in_group("tooltips")
		world_environment.environment.adjustment_brightness = 0.0
		var intro_tween = create_tween()
		intro_tween.set_ease(Tween.EASE_IN)
		intro_tween.set_trans(Tween.TRANS_QUINT)
		intro_tween.tween_property(world_environment.environment, "adjustment_brightness", 0.3, 10.0)
		intro_sequence = true
		get_node("/root/level1/CanvasLayer/NinePatchRect").visible = false
		get_node("/root/level1/CanvasLayer/Control/TextureRect").visible = false
		get_node("/root/level1/CanvasLayer/Control/TextureRect2").visible = false
		pistol_unlocked = false
		shotgun_unlocked = false
	if get_tree().current_scene.name == "DebugLvl":
		pistol_unlocked = true
		shotgun_unlocked = true
		rocket_unlocked = true
		mine_unlocked = true
		grapple_unlocked = true
	if get_tree().current_scene.name == "MainMenu":
		do_spawn = false
		spawning = false
	if not do_spawn:
		spawning = false
	get_tree().paused = false
	popup_rep = 0
	reloaded = false
	HitstopEffect.visible = false
	bg_music = AudioStreamPlayer.new()
	match get_tree().current_scene.name:
		"level1":
			bg_music.stream = preload("res://Songs/VECTORIZE_BOOT_SEQUENCE().mp3")
			bg_music.volume_db = -20
		"DebugLvl":
			bg_music.stream = preload("res://Songs/VECTORIZE_BOOT_SEQUENCE().mp3")
			bg_music.volume_db = music_volume
		"Level2":
			bg_music.stream = preload("res://Songs/VECTORIZE_SURGE.mp3")
			bg_music.volume_db = music_volume
	add_child(bg_music)
	bg_music.play()
	var vol_tween = create_tween()
	vol_tween.set_trans(Tween.TRANS_LINEAR)
	vol_tween.tween_property(bg_music, "volume_db", -5, 5)
	process_mode = Node.PROCESS_MODE_ALWAYS
	hitstop_timer = Timer.new()
	hitstop_timer.one_shot = true
	hitstop_timer.connect("timeout", _on_hitstop_timer_timeout)
	add_child(hitstop_timer)
	popup_timer = Timer.new()
	popup_timer.wait_time = 0.6
	popup_timer.connect("timeout", _on_popup_timer_timeout)
	add_child(popup_timer)
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	print(spawn_pos)
	print(get_node("/root/" + str(get_tree().get_first_node_in_group("Levels").name) + "/CanvasLayer/TextureRect").visible)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if reloaded:
		texture_rect = get_node("/root/" + str(get_tree().get_first_node_in_group("Levels").name) + "/CanvasLayer/Control/TextureRect")
		texture_rect_2 = get_node("/root/" + str(get_tree().get_first_node_in_group("Levels").name) + "/CanvasLayer/Control/TextureRect2")
		texture_rect_3 = get_node("/root/" + str(get_tree().get_first_node_in_group("Levels").name) + "/CanvasLayer/Control/TextureRect3")
		reloaded = false
	if hitstopping:
		player.camera_2d.position = camera_pause_pos
	if zooming_in:
		player.camera_2d.zoom = player.camera_2d.zoom.move_toward(target_zoom, delta * 10)
		if player.camera_2d.zoom.is_equal_approx(target_zoom):
			zooming_in = false
	if zooming_out:
		player.camera_2d.zoom = player.camera_2d.zoom.move_toward(Vector2(1,1), delta)
		if player.camera_2d.zoom.is_equal_approx(Vector2(1,1)):
			zooming_out = false
	if spawning:
		if player.camera_2d.zoom > Vector2(1.002,1.002):
			player.camera_2d.zoom = lerp(player.camera_2d.zoom, Vector2(1,1), delta * 2)
			#print(player.camera_2d.zoom)
		else:
			if player.camera_2d.zoom > Vector2(0.802,0.802):
				player.camera_2d.zoom = lerp(player.camera_2d.zoom, Vector2(1,1), delta * 2)
			else:
				player.camera_2d.zoom = Vector2(1,1)
			if not particles_up:
				var spawn_particles_instance = spawn_particles.instantiate()
				spawn_particles_instance.global_position = spawn_pos
				get_parent().add_child(spawn_particles_instance)
				particles_up = true
				spawn_particles_instance.emitting = true
				player.spawning = false
				player.can_shoot_grapple = grapple_unlocked
				player.animated_sprite_2d.visible = true
				do_spawn = false
				spawning = false
	if waiting_for_shot:
		#while click_tooltip.modulate != Color(1,1,1,1):
		#	click_tooltip.modulate = Color(1,1,1,click_tooltip_alpha)
		#	click_tooltip_alpha += 0.01
		if bg_music.stream.resource_path == "res://Songs/VECTORIZE_BOOT_SEQUENCE().mp3":
			bg_music.stream = bass_drop
			bg_music.play()
			screen_shake(3,0.15)
		if Input.is_action_just_pressed("shoot"):
			print("go")
			get_tree().get_first_node_in_group("title").visible = true
			var tween = create_tween()
			var fx_tween = create_tween()
			print(Engine.time_scale)
			tween.tween_property(Engine, "time_scale", 1.0, 1.0)
			player.pistol_strength = 200
			player.camera_2d.position_smoothing_speed = 4
			world_environment.environment.adjustment_brightness = 2.0
			fx_tween.set_trans(Tween.TRANS_EXPO)
			fx_tween.set_ease(Tween.EASE_OUT)
			fx_tween.tween_property(world_environment.environment, "adjustment_brightness", 1.0, 1.0)
			bg_music.stream = preload("res://Songs/opening_impact.mp3")
			bg_music.play()
			await bg_music.finished
			player.camera_2d.position_smoothing_enabled = 2
			bg_music.stream = preload("res://Songs/VECTORIZE_run().mp3")
			bg_music.volume_db = 0.0
			bg_music.play()
			waiting_for_shot = false
			await get_tree().create_timer(2.0).timeout
			get_tree().get_first_node_in_group("title").visible = false
			get_node("/root/level1/CanvasLayer/NinePatchRect").visible = true
			get_node("/root/level1/CanvasLayer/Control/TextureRect").visible = true
			intro_sequence = false
			player.pistol_strength = 130
			show_level_text()
		#	click_tooltip.modulate = Color(1,1,1,0)

func _input(event: InputEvent) -> void:
	if dying:
		if event.is_pressed() and not event.is_echo():
			popup_rep = 76
			dying = false
	if event.is_action_pressed("pistol"):
		set_gun(1)
	if event.is_action_pressed("shotgun"):
		set_gun(2)
	if event.is_action_pressed("rocket launcher"):
		set_gun(3)
	if event.is_action_pressed("cycle weapons right"):
		set_gun(wrapi(player.gun_equipped + 1, 1, 4))
	if event.is_action_pressed("cycle weapons left"):
		set_gun(wrapi(player.gun_equipped - 1, 1, 4))
	if event.is_action_pressed("pause") and not get_tree().paused:
		PauseMenu.pause()

func pistol_unlock() -> void:
	var tween = create_tween()
	print(Engine.time_scale)
	tween.tween_property(Engine, "time_scale", 1.0, 1.0)
	Engine.time_scale = 0.05
	platform = get_tree().get_first_node_in_group("platform")
	platform.queue_free()
	waiting_for_shot = true
	player.pistol_strength = 180

func hitstop(time: float) -> void:
	camera_pause_pos = player.camera_2d.position
	hitstop_timer.wait_time = time
	hitstopping = true
	zooming_in = true
	zooming_out = false
	target_zoom = player.camera_2d.zoom * Vector2(1.2,1.2)
	debug_lvl.get_tree().paused = true
	HitstopEffect.visible = true
	HitstopEffect.get_child(1).playing = true
	print(HitstopEffect.get_child(1).volume_db)
	hitstop_timer.start()

func _on_hitstop_timer_timeout() -> void:
	debug_lvl.get_tree().paused = false
	hitstopping = false
	zooming_in = false
	zooming_out = true
	HitstopEffect.visible = false
	screen_shake(3, 0.15)

func _on_popup_timer_timeout() -> void:
	print(popup_rep)
	if popup_rep <= 75:
		var error_popup_instance = error_popup.instantiate()
		error_popup_instance.position = Vector2(randi_range(-100, get_viewport().size.x), randi_range(-250, get_viewport().size.y))
		canvas_layer.add_child(error_popup_instance)
		popup_timer.wait_time *= 0.8
		popup_rep += 1
	else:
		popup_timer.stop()
		popup_timer.wait_time = 0.6
		popup_rep = 0
		reloaded = true
		get_tree().paused = false
		get_tree().call_deferred("reload_current_scene")
		spawning = true
		particles_up = false
		bg_music.stream_paused = false

func screen_shake(strength: int, time: float):
	player.screen_shake(strength, time)

func die() -> void:
	popup_rep = 0
	debug_lvl.get_tree().paused = true
	popup_timer.start()
	dying = true
	bg_music.stream_paused = true

func set_gun(gun: int) -> void:
	player.gun_equipped = gun
	texture_rect.visible = gun == 1
	texture_rect_2.visible = gun == 2
	texture_rect_3.visible = gun == 3

func show_level_text() -> void:
	var level_text_instance = level_text.new()
	get_parent().add_child(level_text_instance)
