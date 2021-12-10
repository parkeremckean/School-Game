extends KinematicBody

var health = 1000

onready var hit_anim = $Animation/Hit

func _ready():
	pass
	
func _physics_process(delta):
	if health <= 0:
		queue_free()
		
func hit():
	hit_anim.play("Hit")
