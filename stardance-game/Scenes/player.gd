extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var slam_charges = 1
var slamming = false
const slam_power = 100
var was_in_air = false
var bullet = preload("res://Scenes/bullet.tscn")
@onready var SlamParticles: CPUParticles2D = $SlamParticles

func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		slamming = false
		slam_charges = 1
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction and not slamming:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	#handle ground slam mechanic
	if not is_on_floor() and slam_charges == 1 and Input.is_action_just_pressed("slam"):
		slam_charges = 0
		was_in_air = true
		#make sure you can't double jump or switch directions in a slam, also makes sure slam has unique gravity
		slamming = true
		velocity +=  get_gravity() * delta * 50
	if is_on_floor() and was_in_air:
		print("debug")
		SlamParticles.emitting = true
		was_in_air = false
		
	move_and_slide()
	
	shoot()

func shoot():
	if Input.is_action_just_pressed("shoot"):
		print("shoot")
		var bullet_instance = bullet.instantiate()
		bullet_instance.rotation = get_angle_to(get_global_mouse_position())
		bullet_instance.global_position = global_position
		bullet_instance.add_collision_exception_with(bullet_instance)
		get_parent().add_child(bullet_instance)

	move_and_slide()
