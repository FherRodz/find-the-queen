extends Control

@onready var score_box := $VBoxContainer/Score
@onready var level_box := $VBoxContainer/Level
@onready var time_box  := $VBoxContainer/Time
@onready var smoker_btn := $VBoxContainer/SmokerBtn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_score(value: int):
	score_box.set_value(str(value))

func update_level(value: int):
	level_box.set_value("Lv " + str(value))

func update_time(seconds: int):
	time_box.set_value(str(seconds))
	
func toggle_smoker() -> void:
	smoker_btn.disabled = not smoker_btn.disabled
