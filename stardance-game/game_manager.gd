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
var spawn_pos := Vector2(575,325)
var spawning := true
var particles_up := false
var do_spawn := true
var dying := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not do_spawn:
		spawning = false
	get_tree().paused = false
	popup_rep = 0
	reloaded = false
	HitstopEffect.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	hitstop_timer = Timer.new()
	hitstop_timer.one_shot = true
	hitstop_timer.connect("timeout", _on_hitstop_timer_timeout)
	add_child(hitstop_timer)
	popup_timer = Timer.new()
	popup_timer.wait_time = 0.2
	popup_timer.connect("timeout", _on_popup_timer_timeout)
	add_child(popup_timer)
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
			print(player.camera_2d.zoom)
		else:
			if player.camera_2d.zoom > Vector2(0.802,0.802):
				player.camera_2d.zoom = lerp(player.camera_2d.zoom, Vector2(0.8,0.8), delta * 2)
			else:
				player.camera_2d.zoom = Vector2(0.8,0.8)
			if not particles_up:
				var spawn_particles_instance = spawn_particles.instantiate()
				spawn_particles_instance.global_position = spawn_pos
				get_parent().add_child(spawn_particles_instance)
				particles_up = true
				spawn_particles_instance.emitting = true
				player.spawning = false
				player.can_shoot_grapple = true
				player.animated_sprite_2d.visible = true
				do_spawn = false
				spawning = false

func _input(event: InputEvent) -> void:
	if dying:
		if event.is_pressed() and not event.is_echo():
			popup_rep = 76
			dying = false

func hitstop(time: float) -> void:
	camera_pause_pos = player.camera_2d.position
	hitstop_timer.wait_time = time
	hitstopping = true
	zooming_in = true
	zooming_out = false
	target_zoom = player.camera_2d.zoom * Vector2(1.2,1.2)
	debug_lvl.get_tree().paused = true
	HitstopEffect.visible = true
	hitstop_timer.start()

func _on_hitstop_timer_timeout() -> void:
	debug_lvl.get_tree().paused = false
	hitstopping = false
	zooming_in = false
	zooming_out = true
	HitstopEffect.visible = false
	screen_shake(10, 0.15)

func _on_popup_timer_timeout() -> void:
	if popup_rep <= 75:
		var error_popup_instance = error_popup.instantiate()
		error_popup_instance.position = Vector2(randi_range(-200, 1000), randi_range(-500, 500))
		canvas_layer.add_child(error_popup_instance)
		popup_timer.wait_time *= 0.8
		popup_rep += 1
	else:
		popup_timer.stop()
		popup_timer.wait_time = 0.2
		popup_rep = 0
		reloaded = true
		get_tree().paused = false
		get_tree().call_deferred("reload_current_scene")
		spawning = true
		particles_up = false
		

func screen_shake(strength: int, time: float):
	player.screen_shake(strength, time)

func die() -> void:
	debug_lvl.get_tree().paused = true
	popup_timer.start()
	dying = true
