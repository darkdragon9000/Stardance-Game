extends Node

var hitstop_timer : Timer
var popup_timer : Timer
var canvas_layer : CanvasLayer
@onready var debug_lvl: Node = $"."
@onready var player: CharacterBody2D = get_node("/root/DebugLvl/Player")
var error_popup = preload("res://Scenes/texture_rect.tscn")
var can_popup := true
var popup_rep := 0
var reloaded := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HitstopEffect.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	hitstop_timer = Timer.new()
	hitstop_timer.one_shot = true
	hitstop_timer.connect("timeout", _on_hitstop_timer_timeout)
	add_child(hitstop_timer)
	popup_timer = Timer.new()
	popup_timer.wait_time = 0.5
	popup_timer.connect("timeout", _on_popup_timer_timeout)
	add_child(popup_timer)
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	reloaded = false

func hitstop(time: float) -> void:
	hitstop_timer.wait_time = time
	debug_lvl.get_tree().paused = true
	HitstopEffect.visible = true
	hitstop_timer.start()

func _on_hitstop_timer_timeout() -> void:
	debug_lvl.get_tree().paused = false
	HitstopEffect.visible = false

func _on_popup_timer_timeout() -> void:
	if popup_rep <= 75:
		var error_popup_instance = error_popup.instantiate()
		error_popup_instance.position = Vector2(randi_range(-200, 1000), randi_range(-500, 500))
		canvas_layer.add_child(error_popup_instance)
		popup_timer.wait_time *= 0.8
		popup_rep += 1
	else:
		reloaded = true
		get_tree().reload_current_scene()

func screen_shake(strength: int, time: float):
	player.screen_shake(strength, time)

func die() -> void:
	debug_lvl.get_tree().paused = true
	popup_timer.start()
