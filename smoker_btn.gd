extends Control

@onready var smoke_btn = $VBoxContainer/Button
@onready var smoke_cd = $VBoxContainer/SmokerCooldown

var original_smoke_btn_pos: Vector2

signal smoker_pressed

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	smoke_btn.disabled = true
	original_smoke_btn_pos = smoke_btn.position
	print("original pos: ", original_smoke_btn_pos.y-2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pressed() -> void:
	smoker_pressed.emit()
	
func start_scale_tween() -> void:
	_reset_tween()
	_title_scale_up_tween()
	smoke_cd.set_deferred("self_modulate", Color(1.0, 1.0, 0.682, 0.91))
	
func stop_scale_tween() -> void:
	_reset_tween()
	tween.parallel().tween_property(smoke_btn, "position", original_smoke_btn_pos, .4)
	smoke_cd.set_deferred("self_modulate", Color(1.0, 1.0, 1.0))
	
func _title_scale_up_tween() -> void:
	_reset_tween()
	tween.parallel().tween_property(smoke_btn, "position", Vector2(smoke_btn.position.x, smoke_btn.position.y -3), .4)
	tween.tween_callback(_title_scale_down_tween)
	
func _title_scale_down_tween() -> void:
	_reset_tween()
	tween.parallel().tween_property(smoke_btn, "position", Vector2(smoke_btn.position.x, smoke_btn.position.y +3), .4)
	tween.tween_callback(_title_scale_up_tween)
	
	
func _reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
