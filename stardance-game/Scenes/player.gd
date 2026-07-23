extends CharacterBody2D
#basic movement
const ACCELERATION = 1500.0
const FRICTION = 1200
@export var SPEED := 300.0
@export var JUMP_VELOCITY := -400.0

#slam
var slam_charges := 1
var slamming := false
var was_in_air := false
@export var slam_power := 150
@onready var SlamParticles: CPUParticles2D = $SlamParticles

#shooting
var gun_equipped := 1
var bullet = preload("res://Scenes/bullet.tscn")
var rocket = preload("res://Scenes/rocket.tscn")
var mine = preload("res://Scenes/mine.tscn")

var error_popup = preload("res://Scenes/texture_rect.tscn")

var can_shoot_pistol := true
var pistol_shot := false
var can_shoot_rocket := true
var rocket_shot := false
var can_shoot_mine := true
var shot_in_air := false
var pistol_force := Vector2.ZERO
var rocket_force := Vector2.ZERO
var explosion_force := Vector2.ZERO
var knocked_back := false
var exploded := false

@export var pistol_strength = 130
@export var rocket_strength = 130

@export var air_decay = 0.75

#grapple
@export var grapple_speed = 100
@export var grapple_range = 700
var grapple_line = preload("res://Scenes/active_grapple_line.tscn")
var result = null
var is_grappling: bool
var anchor_point: Vector2
var active_grapple_line = null
var grappled_while_airborne = false
var can_shoot_grapple = true
var grapple_type: int
var grapple_target

@onready var grapple_cooldown = $GrappleCooldown
@onready var pistol_cooldown: Timer = $PistolCooldown
@onready var rocket_cooldown: Timer = $RocketCooldown
@onready var mine_cooldown: Timer = $MineCooldown

@onready var gun_label: Label = $"../CanvasLayer/PanelContainer/MarginContainer/Label"
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		slamming = false
		slam_charges = 1
		shot_in_air = false
	# Add the gravity.
	if not is_on_floor() and not is_grappling:
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if is_grappling and grapple_type != 2:
		pass
	elif knocked_back:
		var target_x = (pistol_force.x + rocket_force.x) + direction * SPEED * 0.2 #target x velocity: (add pistol force to a fraction of player movement)
		velocity.x = move_toward(velocity.x, target_x, 6) #ease towards target_x
	else:
		# Normal delta-scaled acceleration/friction 
		# Feels loose and would like to revisit turning being snappier and a more standard platformer base feel
		if direction and not slamming:
			if abs(velocity.x) <= SPEED and is_on_floor():  #if going slower than walk speed on the floor use basic movement to make it snappier
				velocity.x = direction * SPEED
			elif direction * velocity.x > 0 and abs(velocity.x) >= SPEED and not is_on_floor():
				pass
			else:
				velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta) #use move_towards to prevent velocity from snapping to speed as soon as recoil ends
		else:
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta) 

		
	#handle ground slam mechanic
	if not is_on_floor() and slam_charges == 1 and Input.is_action_just_pressed("slam"):
		slam_charges = 0
		was_in_air = true
		#make sure you can't double jump or switch directions in a slam, also makes sure slam has unique gravity
		slamming = true
		velocity +=  get_gravity() * delta * slam_power
	if is_on_floor() and was_in_air:
		print("slam")
		SlamParticles.emitting = true
		was_in_air = false
		
	move_and_slide()
	if gun_equipped == 1:
		if Input.is_action_just_pressed("shoot") and can_shoot_pistol:
			apply_recoil(get_global_mouse_position(), pistol_strength, false)
			shoot()
		if Input.is_action_just_pressed("alt shoot") and can_shoot_grapple:
			alt_shoot()
	if gun_equipped == 3:
		if not is_grappling: 
			if Input.is_action_just_pressed("shoot") and can_shoot_rocket:
				apply_recoil(get_global_mouse_position(), rocket_strength, false)
				shoot()
			if Input.is_action_just_pressed("alt shoot") and can_shoot_mine:
				alt_shoot()

	
	velocity = velocity + (pistol_force + rocket_force + explosion_force)
	
	#make shot force decay
	pistol_force = pistol_force.move_toward(Vector2.ZERO, 800 * delta)
	rocket_force = rocket_force.move_toward(Vector2.ZERO, 800 * delta)
	explosion_force = explosion_force.move_toward(Vector2.ZERO, 800 * delta)
	
	if pistol_force.is_zero_approx() and pistol_shot:
		knocked_back = false
		pistol_shot = false
	if rocket_force.is_zero_approx() and rocket_shot:
		knocked_back = false
		rocket_shot = false
	if explosion_force.is_zero_approx() and exploded:
		knocked_back = false
		exploded = false
	
		
	if Input.is_action_just_pressed("grapple") and can_shoot_grapple:
		start_grapple()
	
	if Input.is_action_just_released("grapple") or Input.is_action_just_released("alt shoot"):
		is_grappling = false
		clear_grapple()
	
	if is_grappling:
		slam_charges = 0
		if grapple_type == 2:
			if is_instance_valid(grapple_target):
				grapple_target.global_position = grapple_target.global_position.move_toward(global_position, grapple_speed * delta)
				anchor_point = grapple_target.global_position
				active_grapple_line.remove_point(active_grapple_line.get_point_count() - 1)
				active_grapple_line.add_point(anchor_point)
				if is_instance_valid(active_grapple_line) == true and global_position.distance_to(anchor_point) <= 15 or not is_instance_valid(grapple_target):
					grapple_target.reset_velocity()
					is_grappling = false
					clear_grapple()
		else:
			velocity += ((anchor_point - global_position).normalized()) * grapple_speed * delta
			if grapple_type == 1:
				anchor_point = grapple_target.global_position
				active_grapple_line.remove_point(active_grapple_line.get_point_count() - 1)
				active_grapple_line.add_point(anchor_point)
			if global_position.distance_to(anchor_point) <= 45:
				if grapple_type == 1:
					is_grappling = false
					clear_grapple()
				else:
					velocity.y = 0
					velocity.y += JUMP_VELOCITY
					velocity += ((anchor_point - global_position).normalized()) * grapple_speed * delta * 25
					is_grappling = false
					clear_grapple()
	
	if is_grappling and active_grapple_line != null:
		active_grapple_line.set_point_position(0, global_position)
	
	if Input.is_action_just_pressed("pistol"):
		gun_equipped = 1
	if Input.is_action_just_pressed("rocket launcher"):
		gun_equipped = 3
	
	if Input.is_action_just_pressed("cycle weapons right"):
		gun_equipped = wrapi(gun_equipped + 1, 1, 4)
		print(gun_equipped)
	if Input.is_action_just_pressed("cycle weapons left"):
		gun_equipped = wrapi(gun_equipped - 1, 1, 4)
		print(gun_equipped)
	
	match gun_equipped:
		1:
			gun_label.text = "Pistol"
		2:
			gun_label.text = "Shotgun"
		3:
			gun_label.text = "Rocket Launcher"
	
func shoot():
	match gun_equipped:
		1:
			pistol_cooldown.start()
			can_shoot_pistol = false
			print("shoot pistol")
			if not is_on_floor():
				shot_in_air = true
			var bullet_instance = bullet.instantiate()
			bullet_instance.rotation = get_angle_to(get_global_mouse_position())
			bullet_instance.global_position = global_position
			bullet_instance.add_collision_exception_with(bullet_instance)
			get_parent().add_child(bullet_instance)
			pistol_shot = true
			rocket_shot = false
			exploded = false
		2:
			pass #Aarav you better fucking lock in on the shotgun
		3:
			rocket_cooldown.start()
			can_shoot_rocket = false
			print("shoot rocket")
			if not is_on_floor():
				shot_in_air = true
			var rocket_instance = rocket.instantiate()
			rocket_instance.rotation = get_angle_to(get_global_mouse_position())
			rocket_instance.global_position = global_position
			rocket_instance.add_collision_exception_with(rocket_instance)
			rocket_instance.add_collision_exception_with(self)
			get_parent().add_child(rocket_instance)
			rocket_shot = true
			pistol_shot = false
			exploded = false

func alt_shoot():
	match gun_equipped:
		1:
			start_grapple()
		2:
			pass
		3:
			mine_cooldown.start()
			can_shoot_mine = false
			var mine_instance = mine.instantiate()
			mine_instance.global_position = global_position
			mine_instance.add_collision_exception_with(self)
			get_parent().add_child(mine_instance)

func apply_recoil(source_position: Vector2, knockback_strength: float, is_explosion: bool):
	var force_direction = (global_position - source_position).normalized() #create a vector for the direction of recoil
	if not is_explosion:
		match gun_equipped:
			1:
				if is_grappling:
					pass
				elif shot_in_air:
					pistol_force = (force_direction * (knockback_strength * air_decay)) #air decay makes your second and onwards shot in the air weaker so you can't fly
					knocked_back = true
				else:
					pistol_force = (force_direction * knockback_strength)
					knocked_back = true
			2:
				pass
			3: 
				if is_grappling:
					pass
				else:
					rocket_force = (force_direction * knockback_strength)
					knocked_back = true
	else:
		explosion_force = (force_direction * knockback_strength)
		knocked_back = true
		pistol_shot = false
		rocket_shot = false

func _on_pistol_cooldown_timeout() -> void:
	can_shoot_pistol = true

func _on_rocket_cooldown_timeout() -> void:
	can_shoot_rocket = true

func _on_mine_cooldown_timeout() -> void:
	can_shoot_mine = true

func _on_grapple_cooldown_timeout():
	can_shoot_grapple = true

func start_grapple():
	print("grapple")
	can_shoot_grapple = false
	grapple_cooldown.start()
	var space_state = get_world_2d().direct_space_state # use global coordinates, not local to node
	var grapple_direction = (get_global_mouse_position() - global_position).normalized()  #creates a vector for the direction of the grapple
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + (grapple_direction * grapple_range)) #sets start and end point for collison detecting ray
	query.exclude = [self]
	result = space_state.intersect_ray(query)
	if result:
		print(result.collider)
		if result.collider.is_in_group("mines"):
			grapple_type = 1
			grapple_target = result.collider
		elif result.collider.is_in_group("rockets"):
			grapple_type = 2
			grapple_target = result.collider
		else:
			grapple_type = 0
		anchor_point = result.position
		is_grappling = true
		
		shoot_grapple()

func shoot_grapple():
	active_grapple_line = grapple_line.instantiate()
	active_grapple_line.clear_points()
	active_grapple_line.add_point(global_position)
	active_grapple_line.add_point(anchor_point)
	get_parent().add_child(active_grapple_line)
	print("grapple spawned")

func clear_grapple():
	if is_instance_valid(active_grapple_line) == true:
		active_grapple_line.queue_free()
		active_grapple_line = null

func screen_shake(strength: int, time: float):
	camera_2d.screen_shake(strength, time)
		
