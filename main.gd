extends Node
@export var queen_bee_scene: PackedScene
@export var drone_bee_scene: PackedScene
@onready var game_state_manager = $GameStateManager
@onready var game_stats_hud = $GameStatsHUD

var State

# Constants
const DRONE_INNER_RADIUS: float = 50
const DRONE_OUTER_RADIUS: float = 150
const RING_SPAWN_WEIGHT = 0.6
const MAX_RING_ATTEMPTS = 6
const MIN_DISTANCE_FROM_QUEEN = DRONE_INNER_RADIUS
const MAX_BOARD_ATTEMPTS = 8
const BASE_SCORE = 60

# Stats
var run_score = 0
var level_score = BASE_SCORE
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_state_manager.state_changed.connect(_on_game_state_changed)
	State = game_state_manager.State
	game_state_manager.change_state(State.TITLE)

func _on_game_state_changed(new_state):
	match new_state:
		State.TITLE:
			_enter_title_state()
		State.GET_READY:
			_enter_get_ready_state()
		State.LEVEL_START:
			_enter_level_start_state()
		State.GAME_OVER:
			_enter_game_over_state()
		State.LEVEL_CLEAR:
			_enter_level_clear_state()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (game_state_manager.current_state == State.TITLE or game_state_manager.current_state == State.GET_READY)  and Input.is_action_pressed("new_game"):
		print("pressed enter")
		game_state_manager.change_state(State.LEVEL_START)
		
func _enter_title_state() -> void:
	game_stats_hud.hide()
	game_stats_hud.update_level(1)
	game_stats_hud.update_score(0)
	game_stats_hud.update_time(BASE_SCORE)
	
func _enter_get_ready_state() -> void:
	level+=1
	game_stats_hud.update_level(level)
	level_score = BASE_SCORE
	print("Get Ready!")
	

func _enter_level_start_state() -> void:
	print("called level start")
	$StartGameTimer.start()
	game_stats_hud.show()

func _enter_game_over_state() -> void:
	pass

func _enter_level_clear_state() -> void:
	print("CLEARED THE LEVEL!")
	for drone in get_tree().get_nodes_in_group("drones"):
		drone.queue_free()
	run_score += level_score
	game_stats_hud.update_score(run_score)
	game_state_manager.change_state(State.GET_READY)
	
func _on_queen_caught():
	print("CAUGHT HER!")
	$ScoreTimer.stop()
	game_state_manager.change_state(State.LEVEL_CLEAR)
	
func _add_drone_bee(board_rect: Rect2, queen_position: Vector2):
	var drone = drone_bee_scene.instantiate()
	drone.add_to_group("drones")
	add_child(drone)
	
	var drone_sprite = drone.get_node("AnimatedSprite2D")
	var drone_frame_texture = drone_sprite.sprite_frames.get_frame_texture(
		drone_sprite.animation,
		drone_sprite.frame
	)
	
	var drone_size = drone_frame_texture.get_size() * drone.scale
	
	var min_drone_x = board_rect.position.x + drone_size.x / 2
	var max_drone_x = board_rect.position.x + board_rect.size.x - drone_size.x / 2
	
	var min_drone_y = board_rect.position.y + drone_size.y / 2
	var max_drone_y = board_rect.position.y + board_rect.size.y - drone_size.y / 2
	
	var spawn_position: Vector2
	var use_ring = randf() < RING_SPAWN_WEIGHT
	
	if use_ring:
		var found_valid = false
		
		for i in MAX_RING_ATTEMPTS:
			var candidate_position = _random_point_around_queen(queen_position, DRONE_INNER_RADIUS, DRONE_OUTER_RADIUS)
			
			if _point_fits_in_board(candidate_position, min_drone_x, max_drone_x, min_drone_y, max_drone_y):
				spawn_position = candidate_position
				found_valid = true
				break
		
		if not found_valid:
			use_ring = false
			
	if not use_ring:
		var found_valid := false
	
		for i in MAX_BOARD_ATTEMPTS:
			var candidate := Vector2(
				randf_range(min_drone_x, max_drone_x),
				randf_range(min_drone_y, max_drone_y)
			)
			
			if candidate.distance_squared_to(queen_position) >= MIN_DISTANCE_FROM_QUEEN * MIN_DISTANCE_FROM_QUEEN:
				spawn_position = candidate
				found_valid = true
				break
				
		if not found_valid:
			spawn_position = queen_position + Vector2.RIGHT * MIN_DISTANCE_FROM_QUEEN
	
	drone.global_position = spawn_position	
	
	
func _on_start_game_timer_timeout():
	print("start timer timed out")
	$ScoreTimer.start()
	
	var queen = queen_bee_scene.instantiate()
	add_child(queen)
	queen.is_caught.connect(_on_queen_caught)
	
	var area = $GameBoard/Area2D
	var shape = area.get_node("CollisionShape2D").shape

	var board_rect: Rect2 = shape.get_rect()
	board_rect.position += area.global_position
	
	var queen_sprite = queen.get_node("AnimatedSprite2D")
	
	var queen_frame_texture = queen_sprite.sprite_frames.get_frame_texture(
		queen_sprite.animation,
		queen_sprite.frame
	)
	
	var queen_size = queen_frame_texture.get_size() * queen.scale
	
	var min_queen_x = board_rect.position.x + queen_size.x / 2
	var max_queen_x = board_rect.position.x + board_rect.size.x - queen_size.x / 2
	
	var min_queen_y = board_rect.position.y + queen_size.y / 2
	var max_queen_y = board_rect.position.y + board_rect.size.y - queen_size.y / 2
	
	var random_position = Vector2(
		randf_range(min_queen_x, max_queen_x),
		randf_range(min_queen_y, max_queen_y)
	)

	queen.global_position = random_position
	
	for i in level*20:
		_add_drone_bee(board_rect, random_position)
	
func _on_score_timer_timeout():
	level_score-=1
	game_stats_hud.update_time(level_score)
	
# helper function to find a random spawn point for drone bees that is centered around the position of the queen bee
func _random_point_around_queen(queen_position:Vector2, inner_radius:float, outer_radius:float) -> Vector2:
	var angle = randf() * TAU
	var r := sqrt(randf_range(
		inner_radius * inner_radius,
		outer_radius * outer_radius
	))
	return queen_position + Vector2(cos(angle), sin(angle)) * r

# helper function to validate an x,y point is within an area
func _point_fits_in_board(
	point: Vector2,
	min_x: float,
	max_x: float,
	min_y: float,
	max_y: float
) -> bool:
	return (
		point.x >= min_x and point.x <= max_x and
		point.y >= min_y and point.y <= max_y
	)
