extends Sprite2D

@onready var pointer_texture = load("res://assets/cursor/pointer.png")
@onready var click_texture = load("res://assets/cursor/click.png")
@onready var grab_texture = load("res://assets/cursor/grab.png")
@onready var smoker_texture = load("res://assets/smoker.png")

const WEIGHT: float = 16.5 

var tween: Tween
var is_smoker: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, get_global_mouse_position(), WEIGHT*delta)
	
	if Input.is_action_just_pressed("click"):
		_click()

func _click() -> void:
	_reset_tween()
	if not is_smoker:
		texture = click_texture
	tween.tween_property(self, "rotation_degrees", -6.5, 0.1)
	tween.tween_callback(_point)

func _point() -> void:
	_reset_tween()
	texture = pointer_texture
	if is_smoker:
		tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.1)
	tween.tween_property(self, "rotation_degrees", 6.5, 0.1)
	
	
func smoke() -> void:
	_reset_tween()
	texture = smoker_texture
	is_smoker = true
	tween.tween_property(self, "scale", Vector2(1,1), 0.1)
	tween.parallel().tween_property(self, "offset", Vector2(10,10), 0.1)
	
func _reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
