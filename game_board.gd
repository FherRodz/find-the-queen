extends Node2D
@onready var keeper = $Path2D/PathFollow2D/TinyKeeper
@onready var keeper_path = $Path2D/PathFollow2D

const SPEED = 30.0
var keeper_last_position: Vector2
var direction: int = 1
var idle: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_tiny_keeper()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("ratio: ", keeper_path.progress_ratio)
	if not idle:
		_walk_keeper(delta)
	if keeper_path.progress_ratio == 1.0 or keeper_path.progress_ratio == 0.0:
		_idle_keeper()
		await get_tree().create_timer(3).timeout
		idle = false
	
func _walk_keeper(delta: float) -> void:
	idle = false
	if keeper_path.progress_ratio == 1:
		direction = -1
	if keeper_path.progress_ratio == 0:
		direction = 1
	keeper_path.progress += (SPEED * delta) * direction
	
	keeper.global_position = keeper_path.global_position
	
	keeper.update_animation(direction, idle)

func _idle_keeper() -> void:
	idle = true
	keeper_path.progress = keeper_path.progress
	
	keeper.update_animation(direction, idle)

func _spawn_tiny_keeper() -> void:
	keeper_path.progress_ratio = randf()
	
	keeper_last_position = keeper_path.global_position
	keeper.global_position = keeper_path.global_position
	keeper.rotation = 0.0


func _on_tiny_keeper_interact() -> void:
	_idle_keeper()
	await get_tree().create_timer(3).timeout
	idle = false
