extends Node

var hitstop_timer : Timer
@onready var debug_lvl: Node = $"."
@onready var player: CharacterBody2D = get_node("/root/DebugLvl/Player")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HitstopEffect.visible = false
	GameManager.process_mode = Node.PROCESS_MODE_ALWAYS
	hitstop_timer = Timer.new()
	hitstop_timer.one_shot = true
	hitstop_timer.connect("timeout", _on_hitstop_timer_timeout)
	add_child(hitstop_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func hitstop(time: float) -> void:
	hitstop_timer.wait_time = time
	debug_lvl.get_tree().paused = true
	HitstopEffect.visible = true
	hitstop_timer.start()

func _on_hitstop_timer_timeout() -> void:
	debug_lvl.get_tree().paused = false
	HitstopEffect.visible = false

func screen_shake(strength: int, time: float):
	player.screen_shake(strength, time)
