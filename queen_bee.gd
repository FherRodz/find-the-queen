extends CharacterBody2D

signal is_caught

func _process(delta: float) -> void:
	pass

func _on_queen_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_was_caught()
			
func _was_caught():
	queue_free()
	is_caught.emit()
