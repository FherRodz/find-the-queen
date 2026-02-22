extends Control

var tween: Tween = create_tween()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start_scale_tween() -> void:
	_reset_tween()
	_title_scale_up_tween()
	
func stop_scale_tween() -> void:
	_reset_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .7)
	
func _title_scale_up_tween() -> void:
	_reset_tween()
	tween.tween_property(self, "scale", Vector2(2,2), .7)
	tween.tween_callback(_title_scale_down_tween)
	
func _title_scale_down_tween() -> void:
	_reset_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .7)
	tween.tween_callback(_title_scale_up_tween)
	
func _reset_tween() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	
