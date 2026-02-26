extends RigidBody2D

@export var target: RigidBody2D


const ATTRACT_RADIUS := 30.0
const MAX_ATTRACT_RADIUS := 100.0
const ATTRACTION_STRENGTH := 15.0

const WANDER_IMPULSE := 4.0
const WANDER_INTERVAL_MIN := 0.4
const WANDER_INTERVAL_MAX := 1.2

var wander_timer := 0.0

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if not target:
		return
		
	var difference = target.global_position - global_position
	var distance_to_queen = difference.length()

	# If already close enough, do nothing
	if distance_to_queen <= ATTRACT_RADIUS:
		return
	
	if distance_to_queen <= MAX_ATTRACT_RADIUS:
		# Normalize direction
		var direction = difference / distance_to_queen
		_swarm_queen(delta, direction, distance_to_queen)
		
	#wander
	_random_movement(delta)
	
func _swarm_queen(delta, direction, distance) -> void:
	wander_timer -= delta
	if wander_timer > 0.0:
		return

	# Reset timer
	wander_timer = randf_range(
		WANDER_INTERVAL_MIN,
		WANDER_INTERVAL_MAX
	)
	
	# Scale force based on distance
	var t = clamp(
		(distance - ATTRACT_RADIUS) / (MAX_ATTRACT_RADIUS - ATTRACT_RADIUS),
		0.0,
		1.0
	)

	# Wake body if stacked
	sleeping = false

	# Apply impulse toward queen
	apply_central_impulse(direction * ATTRACTION_STRENGTH * t)
	
func _random_movement(delta: float) -> void:
	wander_timer -= delta
	if wander_timer > 0.0:
		return

	# Reset timer
	wander_timer = randf_range(
		WANDER_INTERVAL_MIN,
		WANDER_INTERVAL_MAX
	)

	# Random direction
	var angle = randf() * TAU
	var direction = Vector2(cos(angle), sin(angle))

	sleeping = false
	apply_central_impulse(direction * WANDER_IMPULSE)
	
