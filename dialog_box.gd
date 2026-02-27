extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func update_dialog(value: String) -> void:
	if value.length() > 0:
		for char in value:
			$CenterContainer/Label.text += char
			await get_tree().create_timer(.05).timeout
	else:
		$CenterContainer/Label.text = value
