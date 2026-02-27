extends Node
@export var queen_bee_scene: PackedScene
@export var drone_bee_scene: PackedScene
@export var smoke_wave_scene: PackedScene

@onready var game_state_manager = $GameStateManager
@onready var game_stats_hud = $GameStatsHUD
@onready var game_title_ui = $TitleUI
@onready var game_clear_lvl_ui = $LevelClearUi
@onready var game_over_ui = $GameOverUi
@onready var dialog_box = $DialogBox
@onready var play_area: Area2D = $GameBoard/PlayArea
@onready var smoker_btn:= $GameStatsHUD/VBoxContainer/SmokerBtn

var State
var smoker_armed := false
var _board_rect: Rect2

# Constants
const DRONE_INNER_RADIUS: float = 20
const DRONE_OUTER_RADIUS: float = 150
const RING_SPAWN_WEIGHT = 0.6
const MAX_RING_ATTEMPTS = 6
const MIN_DISTANCE_FROM_QUEEN = DRONE_INNER_RADIUS
const MAX_BOARD_ATTEMPTS = 8
const BASE_SCORE = 15
const SMOKER_RADIUS := 160.0
const SMOKER_FORCE := 220.0

# Stats
var run_score = 0
var level_score = BASE_SCORE
var level = 1
var _current_queen: RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_reset_level()
	_reset_level_score()
	_reset_run_score()
	_reset_smoker()
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
	
	#A level is running
	if game_state_manager.current_state == State.LEVEL_START:
		if level_score == 0:
			game_state_manager.change_state(State.GAME_OVER)
			
		
func _enter_title_state() -> void:
	game_over_ui.hide()
	game_clear_lvl_ui.hide()
	game_stats_hud.hide()
	dialog_box.hide()
	game_stats_hud.update_level(1)
	game_stats_hud.update_score(0)
	game_stats_hud.update_time(BASE_SCORE)
	$GameTitle.start_scale_tween()
	game_title_ui.show()
	
func _enter_get_ready_state() -> void:
	game_clear_lvl_ui.update_level(level)
	game_clear_lvl_ui.update_score(level_score*5)
	level+=1
	_reset_level_score()
	game_stats_hud.update_time(level_score)
	game_clear_lvl_ui.show()
	

func _enter_level_start_state() -> void:
	print("called level start")
	$GameTitle.stop_scale_tween()
	
	game_stats_hud.show()
	game_title_ui.hide()
	game_clear_lvl_ui.hide()
	game_over_ui.hide()
	
	if level == 1:
		dialog_box.update_dialog("Click on the Queen to catch her... \nThat's the LARGE bee!")
		dialog_box.show()
		await get_tree().create_timer(5).timeout
		dialog_box.update_dialog("")
		dialog_box.update_dialog("...")
		await get_tree().create_timer(1).timeout
		dialog_box.update_dialog("")
		dialog_box.update_dialog("Use the smoker and click on the board to blow the drones away!")
		await get_tree().create_timer(5).timeout
		dialog_box.update_dialog("")
		dialog_box.hide()

	$StartGameTimer.start()

func _enter_game_over_state() -> void:
	print("Game Over!")
	print("Your Score was: ", run_score)
	$ScoreTimer.stop()
	$SmokerTimer.stop()
	_reset_smoker()
	smoker_btn.stop_scale_tween()
	game_stats_hud.toggle_smoker_off()
	_clear_queen()
	_clear_drones()
	game_over_ui.update_level(level)
	game_over_ui.update_score(run_score)
	_reset_level()
	_reset_run_score()
	_reset_level_score()
	game_over_ui.show()
	

func _enter_level_clear_state() -> void:
	print("CLEARED THE LEVEL!")
	_clear_drones()
	run_score += 5 * level_score
	game_stats_hud.update_score(run_score)
	game_state_manager.change_state(State.GET_READY)
	
func _on_queen_caught():
	print("CAUGHT HER!")
	$ScoreTimer.stop()
	$SmokerTimer.stop()
	game_state_manager.change_state(State.LEVEL_CLEAR)
	
func _add_drone_bee(board_rect: Rect2, queen_position: Vector2):
	var drone = drone_bee_scene.instantiate()
	drone.add_to_group("drones")
	add_child(drone)
	drone.target = _current_queen
	
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
	print("el focking smoker esta: ", smoker_armed)
	if smoker_btn.get_node("VBoxContainer/Button").disabled and not smoker_armed:
		print("fue este")
		$SmokerTimer.start()
	
	var queen = queen_bee_scene.instantiate()
	queen.add_to_group("queen")
	add_child(queen)
	_current_queen = queen
	queen.is_caught.connect(_on_queen_caught)
	
	var area = $GameBoard/PlayArea
	var shape = area.get_node("CollisionShape2D").shape

	var _board_rect: Rect2 = shape.get_rect()
	_board_rect.position += area.global_position
	
	var queen_sprite = queen.get_node("AnimatedSprite2D")
	
	var queen_frame_texture = queen_sprite.sprite_frames.get_frame_texture(
		queen_sprite.animation,
		queen_sprite.frame
	)
	
	var queen_size = queen_frame_texture.get_size() * queen.scale
	
	var min_queen_x = _board_rect.position.x + queen_size.x / 2
	var max_queen_x = _board_rect.position.x + _board_rect.size.x - queen_size.x / 2
	
	var min_queen_y = _board_rect.position.y + queen_size.y / 2
	var max_queen_y = _board_rect.position.y + _board_rect.size.y - queen_size.y / 2
	
	var random_position = Vector2(
		randf_range(min_queen_x, max_queen_x),
		randf_range(min_queen_y, max_queen_y)
	)

	queen.global_position = random_position
	
	for i in level*20:
		_add_drone_bee(_board_rect, random_position)
	
func _on_smoker_timer_timeout() -> void:
	print("Smoker cooldown is up!")
	game_stats_hud.toggle_smoker_on()
	smoker_btn.start_scale_tween()
	
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
	
func _reset_smoker() -> void:
	smoker_armed = false
	
func _arm_smoker() -> void:
	smoker_armed = true

func _reset_level_score() -> void:
	level_score = BASE_SCORE

func _reset_run_score() -> void:
	run_score = 0

func _reset_level() -> void:
	level = 1
	
func _clear_drones() -> void:
	for drone in get_tree().get_nodes_in_group("drones"):
		drone.queue_free()
		
func _clear_queen() -> void:
	for queen in get_tree().get_nodes_in_group("queen"):
		queen.queue_free()
			
func _apply_smoker_impulse(origin: Vector2) -> void:
	for drone in get_tree().get_nodes_in_group("drones"):
		if not drone is RigidBody2D:
			continue

		var to_drone = drone.global_position - origin
		var distance = to_drone.length()

		if distance == 0.0 or distance > SMOKER_RADIUS:
			continue

		var t = 1.0 - (distance / SMOKER_RADIUS)
		var direction = to_drone.normalized()

		drone.sleeping = false
		drone.apply_central_impulse(direction * SMOKER_FORCE * t)

func _on_new_game_btn_new_game_pressed() -> void:
	await get_tree().create_timer(.5).timeout
	game_state_manager.change_state(State.LEVEL_START)

func _on_quit_btn_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_next_btn_next_lvl_btn_pressed() -> void:
	print("Get Ready!")
	await get_tree().create_timer(.5).timeout
	game_stats_hud.update_level(level)
	game_state_manager.change_state(State.LEVEL_START)

func _on_title_btn_title_btn_pressed() -> void:
	await get_tree().create_timer(.5).timeout
	game_state_manager.change_state(State.TITLE)

func _on_game_board_clicked_play_area() -> void:
	var cursor_pos := get_viewport().get_mouse_position()
	if smoker_armed:
		var smoke = smoke_wave_scene.instantiate()
		smoke.global_position = cursor_pos
		add_child(smoke)
		_apply_smoker_impulse(cursor_pos)
		_reset_smoker()
		
		if game_state_manager.current_state == State.LEVEL_START and not smoker_armed:
			$SmokerTimer.start()

func _on_smoker_button_pressed() -> void:
	print("pressed")
	_arm_smoker()
	game_stats_hud.toggle_smoker_off()
	smoker_btn.stop_scale_tween()
	$CanvasLayer/Cursor/Sprite2D.smoke()
