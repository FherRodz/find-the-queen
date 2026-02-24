extends Area2D

var tween: Tween

var is_interacting: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func start_scale_tween() -> void:
	_reset_tween()
	_hive_scale_up_tween()
	
func stop_scale_tween() -> void:
	_reset_tween()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .7)
	
func _hive_scale_up_tween() -> void:
	_reset_tween()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(2,2), .7)
	tween.tween_callback(_hive_scale_down_tween)
	
func _hive_scale_down_tween() -> void:
	_reset_tween()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), .7)
	tween.tween_callback(_hive_scale_up_tween)


func _reset_tween() -> void:
	if tween:
		tween.kill()

func _on_area_entered(area: Area2D) -> void:
	print("area entered on beehive: ", area)
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = 0
	start_scale_tween()
	

func _on_area_exited(area: Area2D) -> void:
	stop_scale_tween()
	$AnimatedSprite2D.play()
