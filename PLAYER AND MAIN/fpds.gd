extends CharacterBody3D

# MOVEMENT SPEEDS.
var speed
# NORMAL SPEED.
var normal_speed = 5.0
# SPRINT/RUNING SPEED.
var sprint_speed = 10.0
# accel_in_air STANDS FOR ACCELERATION IN HANPPENING IN AIR. 
# accel_normal STANDS FOR ACCELERATION IN NOT HANPPENING IN AIR BUT INSTEAD ON GROUND.
const accel_normal = 10.0
const accel_in_air = 1.0
#THESE CONSTANTS DEFINE TWO ACCELERATION VALUES:
#THESE VALUES CONTROL HOW QUICKLY THE PLAYER SPEEDS UP AND SLOWS DOWN IN DIFFERENT CONTEXTS.
# ACCEL_NORMAL FOR WHEN THE PLAYER IS ON THE GROUND, AND ACCEL_IN_AIR FOR WHEN THE PLAYER IS IN THE AIR. 
# ACCEL IS ABOUT THE CURRENT ACCELERATION.
@onready var accel = accel_normal
# Get the gravity from the project settings to be synced with RigidBody nodes.
#GETS THE GRAVITY AND JUMPING VARIABLES.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jump_velocity #NO NEED TO SET JUMP VALUE BECAUSE THE CROUCH FUNCTIONS DOES IT'S VALUE Changing.
# LOWEST HEIGHT AND MAXIMUM.
var normal_height = 2.0
var crouch_height = 1.0
# LOWEST HEIGHT AND MAXIMUM TRANSITION SPEED OF CROUCHING.
var crouch_speed = 10.0
# MOUSE SENSITIVITY.
var mouse_sense = 0.15
#IMPROTANT VARIABLES FOR PLAYER MOVEMENT.
var is_forward_moving = false
var direction = Vector3()
# PLAYER.

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var player_capsule = $CollisionShape3D
@onready var head_check = $RayCast3D

@onready var reach = $Head/Camera3D/REACH
@onready var hand = $Head/Camera3D/Hand

@onready var weapon_1_hr = preload("res://WEAPON_HR's/WEAPON 1 HR.tscn")
@onready var weapon_1 = preload("res://WEAPON_PICKUPS/WEAPON 1.tscn")

@onready var weapon_2_hr = preload("res://WEAPON_HR's/WEAPON 2 HR.tscn")
@onready var weapon_2 = preload("res://WEAPON_PICKUPS/WEAPON 2.tscn")
 
@onready var weapon_3_hr = preload("res://WEAPON_HR's/WEAPON 3 HR.tscn")
@onready var weapon_3 = preload("res://WEAPON_PICKUPS/WEAPON 3.tscn")

var weapon_to_spawn 
var weapon_to_drop

func WEAPON_PICKUP():
	if reach.is_colliding():
		if reach.get_collider().get_name() == "WEAPON 1":
			weapon_to_spawn = weapon_1_hr.instantiate()
		elif reach.get_collider().get_name() == "WEAPON 2":
			weapon_to_spawn = weapon_2_hr.instantiate()
		elif reach.get_collider().get_name() == "WEAPON 3":
			weapon_to_spawn = weapon_3_hr.instantiate()
		else:
			weapon_to_spawn = null
	else:
		weapon_to_spawn = null
		
	if not hand.get_children().is_empty():
		if hand.get_child(0).get_name() == "WEAPON 1 HR":
			weapon_to_drop = weapon_1.instantiate()
		elif hand.get_child(0).get_name() == "WEAPON 2 HR":
			weapon_to_drop = weapon_2.instantiate()
		elif hand.get_child(0).get_name() == "WEAPON 3 HR":
			weapon_to_drop = weapon_3.instantiate()
		else:
			weapon_to_drop = null
			
	if Input.is_action_just_pressed("PICKUP"):
		if weapon_to_spawn != null:
			if not hand.get_children().is_empty():
				get_parent().add_child(weapon_to_drop)
				weapon_to_drop.global_transform = hand.global_transform
				weapon_to_drop.dropped = true
				hand.get_child(0).queue_free()
			reach.get_collider().queue_free()
			hand.add_child(weapon_to_spawn)
			weapon_to_spawn.rotation = hand.rotation

# CALLED WHEN THE NODE ENTERS THE SCENE TREE FOR THE FIRST TIME.
func _ready():
	#HIDES THE CURSOR.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#CHECKS THE MOUSE MOVEMENT INPUT.
func _input(event):
	#GET MOUSE INPUT FOR CAMERA ROTATION AND CLAMP THE UP AND DOWN ROTATIONS.
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-90.0), deg_to_rad(90.0))

# CALLED EVERY FRAME. 'DELTA' IS THE ELAPSED TIME SINCE THE PREVIOUS FRAME.
# ALSO THIS WILL HANDLE ALL THE PLAYERS MOVEMENT AND PHYSICS.
func _physics_process(delta):
	WEAPON_PICKUP()
	# ADDS CROUCHING TO THE PLAYER MEANING IT CALLS THE CROUCH FUNCTION WHICH WE MADE.
	CROUCH(delta)
	# IF ESCAPE IS PRESSED IT WILL SHOW THE MOUSE CURSOR.
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#GET KEYBOARD INPUT.
	direction = Vector3.ZERO
	speed = normal_speed
	# GETS KEYBOARD INPUT.
	# GET THE INPUT DIRECTION AND HANDLE THE MOVEMENT/DECELERATION.
	# AS GOOD PRACTICE, YOU SHOULD REPLACE UI ACTIONS WITH CUSTOM GAMEPLAY ACTIONS.
	var input_direction = Input.get_vector("MOVE_LEFT", "MOVE_RIGHT", "MOVE_FORWARD", "MOVE_BACKWARD")
	if input_direction.y < 0.0:
		is_forward_moving = true
	else:
		is_forward_moving = false
	direction = (transform.basis * Vector3(input_direction.x, 0.0, input_direction.y)).normalized()
	#SWITCHING BETWEEN SPEEDS 
	if Input.is_action_pressed("sprint") and is_forward_moving:
		speed = sprint_speed
	if Input.is_action_pressed("crouch") and Input.is_action_pressed("sprint"):
		speed = normal_speed
	# ADDS JUMPING AND GRAVITY.
	if not is_on_floor():
		accel = accel_in_air
		velocity.y -= gravity * delta
	else:
		accel = accel_normal
		velocity.y -= jump_velocity
	# HANDLES JUMP.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# IF THE PLAYER PRESSES THE "ui_accept" AND WHEN THE CHARACTER IS ON THE FLOOR,
	# SET THE Y VELOCITY TO THE JUMP VELOCITY.
		velocity.y = jump_velocity
	#MAKES IT MOVE.
	velocity = velocity.lerp(direction * speed, accel * delta)
	#MOVES THE BODY BASED ON VELOCITY.
	move_and_slide()

# THE CROUCH FUNCTION.
func CROUCH(delta):
	var colliding = false
	if head_check.is_colliding():
		colliding = true
	if Input.is_action_pressed("crouch"):
		# IT WILL LOWER THE SIZE OF THE CAPSULE BY THE CROUCHING SPEED AND DECREASES THE JUMP VALUE AND ,
		# SETS SPEED TO NORMAL SPEED. 
		sprint_speed = 5.0
		jump_velocity = 0.0
		player_capsule.shape.height -= crouch_speed * delta
	elif not colliding:
		# IT WILL INCREASE THE SIZE OF THE CAPSULE BY THE CROUCHING SPEED AND RESETS THE JUMP VALUE.
		sprint_speed = 10.0
		jump_velocity = 4.5
		player_capsule.shape.height += crouch_speed * delta
	player_capsule.shape.height =  clamp(player_capsule.shape.height, crouch_height,normal_height)

