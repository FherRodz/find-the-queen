extends Button

signal new_game_pressed

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	print("pressed new game")
	new_game_pressed.emit()


func _on_mouse_entered() -> void:
	_reset_tween()
	tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1.2,1.2), .5)
	
func _on_mouse_exited() -> void:
	_reset_tween()
	tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1,1), .7)
	
func _reset_tween() -> void:
	if tween:
		tween.kill()
