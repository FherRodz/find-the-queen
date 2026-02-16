extends Node

signal state_changed(new_state)

enum State {
	TITLE,
	GET_READY,
	LEVEL_START,
	GAME_OVER,
	LEVEL_CLEAR
}

var current_state: State = State.TITLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func change_state(new_state: State):
	current_state = new_state
	state_changed.emit(new_state)
