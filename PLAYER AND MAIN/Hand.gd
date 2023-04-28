extends Node3D

# VARIABLES ARE USED TO STORE VALUES LIKE WE ARE DOING TO SWITCH WEAPONS.
var current_weapon = 0
@onready var ANIM = $"../AnimationPlayer"
# CALLED EVERY FRAME. 'DELTA' IS THE ELAPSED TIME SINCE THE PREVIOUS FRAME. BUT WE WILL BE NOT USING IT.
func _process(_delta):
	# WE HAVE CALLED THE WEAPON SWITCH FUNCTION TO USE IT AND TO SWITCH WEAPONS
	weapon_switch()
	# THIS PART RIGHT HERE PREVENTD US FROM GOING OVER THE CHILD AMOUNT CASING A DUAL ERROR
	if current_weapon == get_child_count():
		current_weapon = 0
 
# THIS FUNCTION RIGHT HERE CHECKS THE SCROLL WHEEL AND SWITCHS WEAPON ACCORDING TO IT'S MOVEMENT.
func _input(event):
	weapon_switch()
	# IT CHECKS THE SCROLL INPUT.
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				ANIM.play("SWITCH")
				current_weapon = 1
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				ANIM.play("SWITCH")
				current_weapon = 2
 
# CALLED WHEN THE NODE ENTERS THE SCENE TREE FOR THE FIRST TIME.
func _ready():
	# IT CHECKS THE CHILD COUNT 
	for child in get_child_count():
		# THIS PART DOWN HERE HIDES AND DISABLES THE SCRIPT OF THE DIFFRENT WEAPON IN LOADOUT.
		get_child(child).hide()
		get_child(child).process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		# THIS PART DOWN HERE SHOWS AND ENABLES THE SCRIPT OF THE THE CURRENT WEAPON WHICH IS EQUIPED.
	get_child(current_weapon).show()
	get_child(current_weapon).process_mode = Node.PROCESS_MODE_INHERIT
 
# THIS FUNCTION ALLOWS US SWITCH WEAPON
func weapon_switch():
	for child in get_child_count():
		# THIS PART DOWN HERE HIDES AND DISABLES THE SCRIPT OF THE DIFFRENT WEAPON IN LOADOUT.
		get_child(child).hide()
		get_child(child).process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		# THIS PART DOWN HERE SHOWS AND ENABLES THE SCRIPT OF THE THE CURRENT WEAPON WHICH IS EQUIPED.
	get_child(current_weapon-1).show()
	get_child(current_weapon-1).process_mode = Node.PROCESS_MODE_INHERIT
