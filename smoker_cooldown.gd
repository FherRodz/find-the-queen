extends TextureProgressBar

@export var cooldown_timer: Timer

var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update()
	
func update():
	value = (5 - cooldown_timer.time_left) * 100 / 5
