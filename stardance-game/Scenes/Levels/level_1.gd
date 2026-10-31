extends Node2D

signal level_ready(level_node)

func _ready() -> void:
	level_ready.connect(GameManager._on_level_ready)
	level_ready.emit(self)
