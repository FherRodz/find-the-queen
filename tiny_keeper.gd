extends RigidBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var direction = 1


func _ready() -> void:
	show()
	$AnimatedSprite2D.play()
	
func _physics_process(delta: float) -> void:
	pass
		
func update_animation(direction: int, idle: bool) -> void:
	#print("direction: ", direction, " idle: ", idle)
	
	if idle:
		$AnimatedSprite2D.animation = "idle"
	else:
		$AnimatedSprite2D.animation = "walk"
	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false
