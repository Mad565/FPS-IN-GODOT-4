extends Node3D


const ADS_LERP = 13
@export var default_position : Vector3
@export var ads_position : Vector3

@export var damage: int
@export var ammo: int
@export var max_ammo: int
@export var spare_ammo: int
@export var ammo_per_shot: int
@export var full_auto: bool
@export var reload_time: float
@export var firerate: float
var vertical_recoil : int = 0
@export var rayCast: NodePath
@onready var raycast = get_node(rayCast)
@export var shotgun : bool

@export var RAYCONTAINER: NodePath
@onready var raycontainer = get_node(RAYCONTAINER)

var can_fire = true
var reloading = false
# HEAD IS USED FOR VERTICAL_RECOIL.
@onready var head = $"../../.."
# NOTE THE OUR WEAPON SHOULD BE CHILD OF CAMERA. CAMERA IS USED FOR SIDE_RECOIL.
@onready var camera = $"../.." 

@onready var ammo_counter = $"../../HUD/Control/Label"
@onready var DECAL = preload("res://DECAL/decal.tscn")

const shotgun_spread : float = 0.05
const spread : int = 10

func _ready(): 
	randomize()

func _process(delta):
	ADS(delta)
	if reloading:
		ammo_counter.set_text(" RELOADING... ")
	else:
		ammo_counter.set_text("   %d - %d " % [ammo, spare_ammo])
	if ammo <= 0:
		can_fire = false
	if Input.is_action_just_pressed("R") and not reloading and ammo < max_ammo:
		reload()
	if Input.is_action_pressed("fire") and can_fire and full_auto:
		if shotgun == false:
			fire(delta)
			if ammo > 0 and not reloading:
				pass
			elif not reloading:
				reload()
		else:
			shotgun_fire(delta)
			if ammo > 0 and not reloading:
				pass
			elif not reloading:
				pass
	elif Input.is_action_just_pressed("fire") and can_fire and not full_auto:
		if shotgun == false:
			fire(delta)
			if ammo > 0 and not reloading:
				pass
			elif not reloading:
				reload()
		else:
			shotgun_fire(delta)
			if ammo > 0 and not reloading:
				pass
			elif not reloading:
				pass

func fire(delta):
	recoil_func(delta)
	can_fire = false
	ammo -= ammo_per_shot
	if raycast.get_collider() != null and raycast.get_collider().is_in_group("enemy"):
		raycast.get_collider().hp -= damage
	if $AnimationPlayer != null:
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("shot")
	await get_tree().create_timer(firerate).timeout
	if raycast.is_colliding():
		var col_point = raycast.get_collision_point()
		var D = DECAL.instantiate()
		get_tree().get_root().add_child(D)
		D.global_transform.origin = col_point
		var t = get_tree().create_tween()
		t.tween_interval(1)
		t.tween_callback(func():D.free())
	if not reloading:
		can_fire = true


func shotgun_fire(delta):
	can_fire = false
	ammo -= ammo_per_shot
	for r in raycontainer.get_children():
		
		r.target_position.x = randf_range(spread,-spread)
		r.target_position.y = randf_range(spread,-spread)
		
		r.rotation_degrees.x = rad_to_deg(randf_range(shotgun_spread, -shotgun_spread))
		r.rotation_degrees.y = rad_to_deg(randf_range(shotgun_spread, -shotgun_spread))
		
		await get_tree().create_timer(0.01).timeout
		
		r.rotation_degrees.x = 0
		r.rotation_degrees.y = 0
		
		if r.get_collider() != null && r.get_collider().is_in_group("enemy"):
			r.get_collider().hp -= damage
		
		if r.is_colliding():
			var col_point = r.get_collision_point()
			var D = DECAL.instantiate()
			get_tree().get_root().add_child(D)
			D.global_transform.origin = col_point
			var t = get_tree().create_tween()
			t.tween_interval(1)
			t.tween_callback(func():D.free())
			
	if $AnimationPlayer != null:
		$AnimationPlayer.stop(true)
		$AnimationPlayer.play("shot")
		await get_tree().create_timer(firerate).timeout
	if reloading == false:
		can_fire = true
	recoil_func(delta)

func ADS(delta):
	if Input.is_action_pressed("ADS"):
		transform.origin = transform.origin.lerp(ads_position, ADS_LERP * delta)
	else:
		transform.origin = transform.origin.lerp(default_position, ADS_LERP * delta)
func reload():
	reloading = true
	can_fire = false
	$AnimationPlayer.play("Reload")
	await get_tree().create_timer(reload_time).timeout
	if reloading == true:
		var ammo_to_add = min(max_ammo - ammo, spare_ammo)
		ammo += ammo_to_add
		spare_ammo -= ammo_to_add
	if ammo > 0:
		can_fire = true
	reloading = false

func recoil_func(delta):
	# Check if the variable can_fire is True
	if can_fire:
		# Calculate the horizontal recoil using the randf_range function
		var horizontal_recoil = randf_range(5 ,-5)
		# the strength of recoil.
		var recoil = randf_range(5, -5)
		# Add the vertical recoil to the vertical_recoil variable and multiply by delta
		vertical_recoil += recoil * delta
		# Update the rotation of the head object using the lerpf function
		head.rotation.x = lerpf(head.rotation.x,deg_to_rad(head.rotation_degrees.x + vertical_recoil ),delta)
		# Update the rotation of the camera object using the lerpf function
		camera.rotation.y = lerpf(camera.rotation.y,deg_to_rad(horizontal_recoil),5 * delta)
		# Clamp the vertical recoil to a maximum value of 80
		vertical_recoil = min(80,80)
		# Check if the variable can_fire is still True
	if can_fire:
		# Set the vertical recoil to 80
		vertical_recoil = 80
		# Clamp the rotation of the head object between -80 and 80 degrees
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -80, 80)
		# If the rotation of the head object is greater than or equal to 80 degrees
		if head.rotation_degrees.x >= 80:
		# Lerp the rotation of the head object towards 30 degrees
			head.rotation_degrees.x = lerpf(head.rotation_degrees.x ,30, 5 * delta)
