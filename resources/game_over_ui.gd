extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_level(value: int) -> void:
	$CenterContainer/MarginContainer/GridContainer/LevelInfoBox.set_value(str(value))
	
func update_score(value: int) -> void:
	$CenterContainer/MarginContainer/GridContainer/ScoreInfoBox.set_value(str(value))
