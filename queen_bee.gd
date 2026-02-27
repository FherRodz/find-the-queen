extends RigidBody2D

const SPEED = 30
var direction: float

const WANDER_IMPULSE := 4.0
const WANDER_INTERVAL_MIN := 0.4
const WANDER_INTERVAL_MAX := 1.2

var wander_timer := 0.0

signal is_caught

func _physics_process(delta: float) -> void:
	_random_movement(delta)
			
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_was_caught()
			
func _was_caught():
	queue_free()
	is_caught.emit()
	
func _random_movement(delta: float) -> void:
	wander_timer -= delta
	if wander_timer > 0.0:
		return

	# Reset timer
	wander_timer = randf_range(
		WANDER_INTERVAL_MIN,
		WANDER_INTERVAL_MAX
	)

	var direction = _random_direction()

	sleeping = false
	look_at(direction)
	apply_central_impulse(direction * WANDER_IMPULSE)
	
func _random_direction() -> Vector2:
	var angle = randf() * TAU
	var direction = Vector2(cos(angle), sin(angle))
	return direction
	
