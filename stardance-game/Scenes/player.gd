extends CharacterBody2D

const ACCELERATION = 1500.0
const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const FRICTION = 1500

var slam_charges := 1
var slamming := false
@export var slam_power := 150
var was_in_air := false

var bullet = preload("res://Scenes/bullet.tscn")

var can_shoot_pistol := true
var shot_in_air := false
var pistol_force := Vector2.ZERO
var knocked_back := false
@export var pistol_strength = 130
@export var air_decay = 0.75

var grapple = preload("res://Scenes/grapple.tscn")


@onready var pistol_cooldown: Timer = $PistolCooldown
@onready var SlamParticles: CPUParticles2D = $SlamParticles

func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		slamming = false
		slam_charges = 1
		shot_in_air = false
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if knocked_back:
		var target_x = pistol_force.x + direction * SPEED * 0.2 #target x velocity: (add pistol force to a fraction of player movement)
		velocity.x = move_toward(velocity.x, target_x, 6) #ease towards target_x
	else:
		# Normal delta-scaled acceleration/friction 
		# Feels loose and would like to revisit turning being snappier and a more standard platformer base feel
		if direction and not slamming:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta) #use move_towards to prevent velocity from snapping to speed as soon as recoil ends
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta) #delta-scaled friction to prevent knockback from snapping to 0 once recoil ends 
	#if direction and not slamming and not knocked_back:
	#	velocity.x = direction * SPEED
	#elif not direction and not slamming and not knocked_back:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)
		
	#handle ground slam mechanic
	if not is_on_floor() and slam_charges == 1 and Input.is_action_just_pressed("slam"):
		slam_charges = 0
		was_in_air = true
		#make sure you can't double jump or switch directions in a slam, also makes sure slam has unique gravity
		slamming = true
		velocity +=  get_gravity() * delta * slam_power
	if is_on_floor() and was_in_air:
		print("debug")
		SlamParticles.emitting = true
		was_in_air = false
		
	move_and_slide()
	if Input.is_action_just_pressed("shoot") and can_shoot_pistol:
		apply_recoil(get_global_mouse_position(), pistol_strength)
		shoot()

	
	velocity += pistol_force
	
	#make pistol_force decay
	pistol_force = pistol_force.move_toward(Vector2.ZERO, 800 * delta)
	
	if pistol_force.is_zero_approx():
		knocked_back = false
		
	if Input.is_action_just_pressed("grapple"):
		print("grap")
		var grapple_instance = grapple.instantiate()
		grapple.target_position = get_global_mouse_position() #makes raycast check toward current mouse position
		var grapple_anchor = grapple.get_collider() #finds the closest object in the direction of the raycast
		
func shoot():
	pistol_cooldown.start()
	can_shoot_pistol = false
	print("shoot")
	if not is_on_floor():
		shot_in_air = true
	var bullet_instance = bullet.instantiate()
	bullet_instance.rotation = get_angle_to(get_global_mouse_position())
	bullet_instance.global_position = global_position
	bullet_instance.add_collision_exception_with(bullet_instance)
	get_parent().add_child(bullet_instance)

func apply_recoil(source_position: Vector2, knockback_strength: float):
	var force_direction = (global_position - source_position).normalized() #create a vector for the direction of recoil
	if shot_in_air:
		pistol_force = (force_direction * (knockback_strength * air_decay)) #air decay makes your second and onwards shot in the air weaker so you can't fly
	else:
		pistol_force = (force_direction * knockback_strength)
	knocked_back = true

func _on_pistol_cooldown_timeout() -> void:
	can_shoot_pistol = true
