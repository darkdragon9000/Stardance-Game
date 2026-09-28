extends Camera2D

# --- Screen shake ---
var shake_strength := 0.0
var shake_time_passed := 0.0
var shake_decay := 5.0
var shake_time := 0.0
var shake_time_speed := 20.0
var noise = FastNoiseLite.new()
var shake_offset := Vector2.ZERO

# --- Cursor lookahead ---
@export_group("Lookahead")
@export var cursor_max_shift := 256                # max px the cursor can pull the camera
@export_range(0.0, 0.9) var cursor_dead_zone := 0.3   # 0.1 = cursor within 10% of center does nothing
@export var shift_smoothing := 2.0                    # higher = catches up to the target faster
@export var shift_max_speed := 400.0                  # max px/s the camera is allowed to slide

var lookahead_offset := Vector2.ZERO


@onready var follow_body: CharacterBody2D = get_parent()


func _ready() -> void:

	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	_update_shake(delta)
	_update_lookahead(delta)
	offset = lookahead_offset + shake_offset   # the only line that writes offset


# --- Screen shake ---
func _update_shake(delta: float) -> void:
	if shake_time_passed > 0:
		shake_time += delta * shake_time_speed
		shake_time_passed -= delta
		shake_offset = Vector2(noise.get_noise_2d(shake_time, 0) * shake_strength, noise.get_noise_2d(0, shake_time) * shake_strength)
		shake_strength = max(shake_strength - (shake_decay * delta), 0)
	else:
		shake_offset = Vector2.ZERO


func screen_shake(strength: int, time: float) -> void:
	randomize()
	noise.seed = randi()
	noise.frequency = 2
	shake_strength = strength
	shake_time_passed = time
	shake_time = 0.0


# --- Cursor lookahead ---
func _update_lookahead(delta: float) -> void:
	var target := Vector2.ZERO
	if not follow_body.spawning:
		target = _get_cursor_shift()

	# ease toward the target, but never faster than shift_max_speed
	var step := (target - lookahead_offset) * (1.0 - exp(-shift_smoothing * delta))
	lookahead_offset += step.limit_length(shift_max_speed * delta)


func _get_cursor_shift() -> Vector2:
	var half := get_viewport_rect().size / 2.0
	var from_center := get_viewport().get_mouse_position() - half   # screen space, avoids the feedback loop
	var strength := (from_center / half).length()                   # 0 = center, 1 = screen edge
	if strength <= cursor_dead_zone:
		return Vector2.ZERO
	var t := clampf((strength - cursor_dead_zone) / (1.0 - cursor_dead_zone), 0.0, 1.0)
	return from_center.normalized() * t * cursor_max_shift
