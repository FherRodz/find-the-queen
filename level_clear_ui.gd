extends Control

@onready var level_box = $CenterContainer/MarginContainer/GridContainer/LevelInfoBox
@onready var score_box = $CenterContainer/MarginContainer/GridContainer/ScoreInfoBox


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_level(value: int):
	level_box.set_value(str(value))

func update_score(value: int):
	score_box.set_value(str(value))
	
