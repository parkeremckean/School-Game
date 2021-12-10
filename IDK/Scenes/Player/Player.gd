
extends KinematicBody

#MOVEMENT
var speed = 25
var accel = 10
var gravity = .3
var jump = 10

#SENSITIVITY
var mouse_sens = 0.03

#AMMO
var pistol_one_ammo = 100
var pistol_one_mag = 10
var pistol_one_mag_max = 10

#WEAPON
export var current_weapon = 0
var sway_amount = 30

var pistol_one_damage = 25


#VECTOR
var direction = Vector3()
var velocity = Vector3()
var fall = Vector3() 

#ONREADY
onready var head = $Head
onready var hand = $Head/Hand
onready var handloc = $Head/Handloc
onready var aimcast = $Head/Aimcast

#WEAPONS
onready var pistol_one = $Head/Hand/Weapon/Pistols/PistolOne

#HUD
onready var mag_hud = $HUD/Mag
onready var ammo_hud = $HUD/Ammo

#ANIM
onready var shoot_anim = $Animations/Shoot
onready var reload_anim = $Animations/Reload
onready var hud_anim = $Animations/HUD
onready var move_anim = $Animations/Movement

func _ready():
	#MOUSE CAPTURE
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#HAND TOP LEVEL
	hand.set_as_toplevel(true)
	
func _input(event):
	#MOUSE LOOK
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sens)) 
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))
	#QUIT ON ESC
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
func _process(delta):
	#WEAPON SWAY
	hand.global_transform.origin = handloc.global_transform.origin
	hand.rotation.y = lerp_angle(hand.rotation.y, rotation.y, sway_amount * delta)
	hand.rotation.x = lerp_angle(hand.rotation.x, head.rotation.x, sway_amount * delta)
	
	#CURRENT WEAPON
	if current_weapon == 1:
		pistol_one.visible = true
		mag_hud.text = str(pistol_one_mag)
		ammo_hud.text = str(pistol_one_ammo)
	else:
		pistol_one.visible = false
		
	
func _physics_process(delta):
	
	direction = Vector3()
	
	#GRAVITY
	if not is_on_floor():
		fall.y -= gravity
		accel = 2
	else:
		accel = 5
	
	#MOVE FORWARD
	if Input.is_action_pressed("front"):
		direction -= transform.basis.z
		
	#MOVE BACKWARD
	elif Input.is_action_pressed("back"):
		direction += transform.basis.z
		
	#MOVE LEFT
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
		
	#MOVE RIGHT
	elif Input.is_action_pressed("right"):
		direction += transform.basis.x
		
	#JUMP
	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = jump
	
	#MOVE AND SLIDE
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, accel * delta) 
	velocity = move_and_slide(velocity, Vector3.UP) 
	move_and_slide(fall, Vector3.UP)
	
	#RELOAD
	if current_weapon == 1:
		if Input.is_action_just_pressed("reload"):
			if not reload_anim.is_playing():
				if pistol_one_mag != pistol_one_mag_max:
					reload_anim.play("Pistol")
					pistol_one_mag = pistol_one_mag_max
		
	#SHOOT PISTOL ONE
	if current_weapon == 1:
		if Input.is_action_just_pressed("fire"):
			if not shoot_anim.is_playing():
				if not reload_anim.is_playing():
					if pistol_one_mag >= 1:
						shoot_anim.play("Pistol")
						pistol_one_mag -= 1
						if aimcast.is_colliding():
							var target = aimcast.get_collider()
							if target.is_in_group("Enemy"):
								target.health -= pistol_one_damage
								hud_anim.play("Hitmarker")
								target.hit()

func _on_Groundcheck_body_entered(body):
	move_anim.play("Fall")

func _on_Groundcheck_body_exited(body):
	move_anim.play("Jump")
