extends CharacterBody2D

const SPEED = 30
var direction: float

signal is_caught

func _process(delta: float) -> void:
	#direction = randf_range()
	pass
	

func _on_queen_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_was_caught()
			
func _was_caught():
	queue_free()
	is_caught.emit()
	
